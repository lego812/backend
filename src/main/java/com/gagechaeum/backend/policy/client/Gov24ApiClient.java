package com.gagechaeum.backend.policy.client;

import com.gagechaeum.backend.global.exception.ExternalApiException;
import com.gagechaeum.backend.policy.dto.external.Gov24ApiDetailResponseDto;
import com.gagechaeum.backend.policy.dto.external.Gov24ApiResponseDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.net.URI;

@Slf4j
@Component
@RequiredArgsConstructor
public class Gov24ApiClient {

    private final RestTemplate restTemplate;

    // 정책 목록 조회를 위한 URL
    @Value("${external.gov24.api.url}")
    private String apiUrl;

    // 정책 상세 정보 조회를 위한 URL
    @Value("${external.gov24.api.detailUrl}")
    private String detailApiUrl;

    // 공통으로 사용되는 서비스 키
    @Value("${external.gov24.api.serviceKey}")
    private String serviceKey;

    public Gov24ApiResponseDto fetchPolicies(int page, int perPage) {
        URI uri = UriComponentsBuilder
                .fromUriString(apiUrl)
                .queryParam("page", page)
                .queryParam("perPage", perPage)
                .queryParam("serviceKey", serviceKey)
                .build(true)
                .toUri();

        try {
            log.info("Gov24 list API params: page={}, perPage={}", page, perPage);
            log.info("Requesting Gov24 Policy List API: {}", uri);
            return restTemplate.getForObject(uri, Gov24ApiResponseDto.class);
        } catch (HttpClientErrorException e) {
            log.error(
                    "Gov24 list API error: status={}, page={}, perPage={}, headers={}, body={}",
                    e.getStatusCode(),
                    page,
                    perPage,
                    e.getResponseHeaders(),
                    e.getResponseBodyAsString(),
                    e
            );
            throw new ExternalApiException("Failed to fetch policies from Gov24 API", e);
        } catch (RestClientException e) {
            log.error("Failed to fetch policies from Gov24 API", e);
            throw new ExternalApiException("Failed to fetch policies from Gov24 API", e);
        }
    }

    public Gov24ApiDetailResponseDto fetchPolicyDetailsSync(String serviceId, int page, int perPage) {
        URI uri = UriComponentsBuilder.fromHttpUrl(detailApiUrl)
                .queryParam("page", page)
                .queryParam("perPage", perPage)
                .queryParam("serviceKey", serviceKey)
                .queryParam("serviceId", serviceId)
                .build()
                .encode()
                .toUri();

        log.info("Gov24 detail API params: serviceId={}, page={}, perPage={}", serviceId, page, perPage);
        log.info("Requesting Gov24 Policy Detail API: {}", uri);
        try {
            return restTemplate.getForObject(uri, Gov24ApiDetailResponseDto.class);
        } catch (HttpClientErrorException e) {
            log.error(
                    "Gov24 detail API error: status={}, serviceId={}, page={}, perPage={}, headers={}, body={}",
                    e.getStatusCode(),
                    serviceId,
                    page,
                    perPage,
                    e.getResponseHeaders(),
                    e.getResponseBodyAsString(),
                    e
            );
            throw e;
        }
    }
}
