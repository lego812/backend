package com.gagechaeum.backend.policy.service;

import com.gagechaeum.backend.chat.service.ChatService;
import com.gagechaeum.backend.common.util.DateParserUtil;
import com.gagechaeum.backend.document.domain.Document;
import com.gagechaeum.backend.document.domain.RequiredDocument;
import com.gagechaeum.backend.document.mapper.DocumentMapper;
import com.gagechaeum.backend.document.mapper.RequiredDocumentMapper;
import com.gagechaeum.backend.policy.client.Gov24ApiClient;
import com.gagechaeum.backend.policy.domain.Policy;
import com.gagechaeum.backend.policy.dto.external.Gov24ApiDetailDto;
import com.gagechaeum.backend.policy.dto.external.Gov24ApiDetailResponseDto;
import com.gagechaeum.backend.policy.dto.external.Gov24ApiResponseDto;
import com.gagechaeum.backend.policy.dto.external.Gov24ApiServiceDto;
import com.gagechaeum.backend.policy.mapper.PolicyMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class PolicySyncServiceImpl implements PolicySyncService {

    private final Gov24ApiClient gov24ApiClient;
    private final PolicyMapper policyMapper;
    private final PolicyMatchingService policyMatchingService;
    private final ChatService chatService;
    private final PolicyService policyService;
    private final DocumentMapper documentMapper;
    private final RequiredDocumentMapper requiredDocumentMapper;

    private static final String TARGET_USER_TYPE = "소상공인";
    private static final String TARGET_SUPPORT_TYPE = "현금";

    private static final DateTimeFormatter DATETIME_FORMATTER = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

    @Override
    @Async("taskExecutor")
    @Scheduled(cron = "0 0 3 * * *")
    @Transactional
    public void syncPolicies() {

        log.error("정책 기본 정보 동기화 호출됨 {}", LocalDateTime.now());
        syncPoliciesFromGov24Api();
        log.error("정책 기본 정보 동기화가 완료되었습니다.");

        log.error("새로 추가된 정책들에 대해 Java 기반 카테고리 매칭을 시작합니다.");
        policyMatchingService.matchAndSaveCategories();
        log.error("정책 기본 정보 동기화 호출됨 {}", LocalDateTime.now());

    }

    private void syncPoliciesFromGov24Api() {
        log.error("외부 API 정책 데이터 동기화를 시작합니다.");
        int page = 1;
        int perPage = 30;


        List<Policy> existingPolicies = policyMapper.findAllPolicyIdsWithModificationDate();
        Map<String, LocalDateTime> existingMap = existingPolicies.stream()
                .filter(p -> p.getPolicyId() != null)
                .collect(Collectors.toMap(Policy::getPolicyId, Policy::getModificationDate));

        do {
            long pageFetchStart = System.currentTimeMillis();
            Gov24ApiResponseDto apiResponse = gov24ApiClient.fetchPolicies(page, perPage);
            log.error("fetchPolicies page {} took {} ms", page, System.currentTimeMillis() - pageFetchStart);
            if (apiResponse == null || apiResponse.getData() == null || apiResponse.getData().isEmpty()) {
                log.error("페이지 {}에서 더 이상 데이터가 없습니다. 동기화를 종료합니다.", page);
                break;
            }

            log.error("{} 페이지에서 {}개의 정책을 처리합니다.", page, apiResponse.getCurrentCount());

            log.error("page: {}, currentCount: {}, totalCount: {}", page, apiResponse.getCurrentCount(), apiResponse.getTotalCount());
            for (Gov24ApiServiceDto dto : apiResponse.getData()) {
                long policyStart = System.currentTimeMillis();
                log.error("processing policyId: {}", dto.getServiceId());
                if (!isSmallBusinessCashSupportPolicy(dto)) {
                    log.trace("소상공인 대상 현금 지원 정책이 아니므로 건너<binary data, 2 bytes>니다 (policyName: {}, userType: {}, supportType: {})",
                            dto.getServiceName(), dto.getUserType(), dto.getSupportContent());
                    continue;
                }


                Policy policy = mapDtoToDomain(dto);
                LocalDateTime existingDate = existingMap.get(policy.getPolicyId());
                boolean isNewPolicy = (existingDate == null); // 신규 정책 여부 확인
                boolean needsUpdate = isNewPolicy ||
                        (policy.getModificationDate() != null &&
                                policy.getModificationDate().isAfter(existingDate));

                if (needsUpdate) {
                    long upsertStart = System.currentTimeMillis();
                    policyMapper.saveOrUpdatePolicy(policy);
                    log.error("policy upsert policyId: {} took {} ms", policy.getPolicyId(), System.currentTimeMillis() - upsertStart);
                    log.debug("소상공인 지원금 정책 정보 저장 완료 (policyId: {})", policy.getPolicyId());

                    long docStart = System.currentTimeMillis();
                    fetchAndSavePolicyDocuments(policy.getPolicyId());
                    log.error("fetchAndSavePolicyDocuments policyId: {} took {} ms", policy.getPolicyId(), System.currentTimeMillis() - docStart);

                    if (isNewPolicy) {
                        try {
                            long chatStart = System.currentTimeMillis();
                            chatService.createChatRoomForPolicy(policy);
                            log.error("chat room create policyId: {} took {} ms", policy.getPolicyId(), System.currentTimeMillis() - chatStart);
                            log.debug("신규 정책에 대한 채팅방 생성을 요청했습니다. (policyId: {})", policy.getPolicyId());
                        } catch (Exception e) {
                            log.error("정책 ID '{}'의 채팅방 생성 중 오류 발생", policy.getPolicyId(), e);
                        }
                    }
                }
                log.error("processing policyId: {} total took {} ms", dto.getServiceId(), System.currentTimeMillis() - policyStart);
            }
            page++;
        } while (true);
        log.error("정책 기본 정보 동기화가 완료되었습니다.");
    }

    private void fetchAndSavePolicyDocuments(String serviceId) {
        int page = 1;
        final int perPage = 100;
        long detailTotalStart = System.currentTimeMillis();

        List<Document> allDocuments = documentMapper.findAll();
        Document etcDocument = allDocuments.stream()
                .filter(doc -> "기타".equals(doc.getDocumentName()))
                .findFirst()
                .orElseThrow(() -> new IllegalStateException("'기타' 서류가 DB에 없습니다."));

        while (true) {
            long detailFetchStart = System.currentTimeMillis();
            Gov24ApiDetailResponseDto response = gov24ApiClient.fetchPolicyDetailsSync(serviceId, page, perPage);
            int detailCount = (response == null || response.getData() == null) ? 0 : response.getData().size();
            log.error("fetchPolicyDetailsSync serviceId: {} page: {} took {} ms (count: {})",
                    serviceId, page, System.currentTimeMillis() - detailFetchStart, detailCount);
            if (response != null && response.getData() != null && !response.getData().isEmpty()) {
                Gov24ApiDetailDto first = response.getData().get(0);
                log.error("detail sample serviceId: {} page: {} firstDetailServiceId: {} requiredDocumentsLen: {}",
                        serviceId,
                        page,
                        first.getServiceId(),
                        first.getRequiredDocuments() == null ? 0 : first.getRequiredDocuments().length());
            }

            if (response == null || response.getData() == null || response.getData().isEmpty()) {
                break;
            }

            response.getData().forEach(detailDto -> {
                String rawText = detailDto.getRequiredDocuments();
                policyMapper.saveOrUpdateTempPolicyDetail(detailDto.getServiceId(), rawText, LocalDateTime.now());

                if (!StringUtils.hasText(rawText) || "해당없음".equals(rawText)) {
                    return;
                }

                Arrays.stream(rawText.split(","))
                        .map(String::trim)
                        .filter(StringUtils::hasText)
                        .map(rawDocName -> allDocuments.stream()
                                .filter(stdDoc -> StringUtils.hasText(stdDoc.getKeywords()) &&
                                        Arrays.stream(stdDoc.getKeywords().split(","))
                                                .anyMatch(keyword -> rawDocName.contains(keyword.trim())))
                                .findFirst()
                                .orElse(etcDocument))
                        .distinct()
                        .forEach(matchedDoc -> {
                            RequiredDocument requiredDocument = RequiredDocument.builder()
                                    .policyId(serviceId)
                                    .documentId(matchedDoc.getDocumentId())
                                    .build();
                            requiredDocumentMapper.save(requiredDocument);
                        });
            });
            page++;
        }
        log.error("fetchAndSavePolicyDocuments total serviceId: {} took {} ms",
                serviceId, System.currentTimeMillis() - detailTotalStart);
    }

    private boolean isSmallBusinessCashSupportPolicy(Gov24ApiServiceDto dto) {
        boolean isTargetUser = dto.getUserType() != null && dto.getUserType().contains(TARGET_USER_TYPE);
        boolean isTargetSupport = TARGET_SUPPORT_TYPE.equals(dto.getSupportType());
        return isTargetUser && isTargetSupport;
    }

    private Policy mapDtoToDomain(Gov24ApiServiceDto dto) {
        Policy policy = new Policy();
        if (dto.getServiceId() != null && !dto.getServiceId().isBlank()) {
            policy.setPolicyId(dto.getServiceId());
        }
        policy.setPolicyName(getOrDefault(dto.getServiceName(), "정책 이름 정보 없음"));
        policy.setPolicySummary(getOrDefault(dto.getServiceSummary(), "요약 정보 없음"));
        policy.setDepartmentName(getOrDefault(dto.getDepartmentName(), "부서 정보 없음"));
        policy.setSupervisingOrganizationName(getOrDefault(dto.getOrganizationName(), "소관 기관 정보 없음"));
        policy.setAnnouncementUrl(getOrDefault(dto.getDetailUrl(), "#"));
        policy.setSupportDetail(getOrDefault(dto.getSupportContent(), "지원 내용 정보 없음"));
        policy.setApplicationPeriod(getOrDefault(dto.getApplicationPeriod(), "신청 기간 정보 없음"));
        policy.setUserType(getOrDefault(dto.getUserType(), "정보 없음"));
        policy.setPolicyField(getOrDefault(dto.getPolicyField(), "분야 정보 없음"));
        policy.setApplicationMethod(getOrDefault(dto.getApplicationMethod(), "신청 방법 정보 없음"));
        policy.setSupportTarget(getOrDefault(dto.getSupportTarget(), "지원 대상 정보 없음"));

        if (dto.getNoticeDate() != null) {
            policy.setNoticeDate(LocalDateTime.parse(dto.getNoticeDate(), DATETIME_FORMATTER));
        }
        if (dto.getModificationDate() != null) {
            policy.setModificationDate(LocalDateTime.parse(dto.getModificationDate(), DATETIME_FORMATTER));
        }

        LocalDate[] dates = DateParserUtil.parseDateRange(dto.getApplicationPeriod());
        policy.setBeginDate(dates[0]);
        policy.setEndDate(dates[1]);

        return policy;
    }

    private String getOrDefault(String value, String defaultValue) {
        return (value != null && !value.isBlank()) ? value : defaultValue;
    }
}
