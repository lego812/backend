# Policy Sync Flow Diagram

```mermaid
flowchart TD
    A[스케줄 실행] --> B[정책 목록 조회]
    B --> C[대상 정책 필터]
    C --> D[수정일 비교]
    D --> E[정책 저장 또는 갱신]
    D --> F[변경 없음 건너뜀]

    E --> G[문서 동기화]
    G --> G1[문서 목록 로딩]
    G1 --> G2[정책 상세 조회]
    G2 --> G3[원문 문서 저장]
    G3 --> G4[키워드 매칭]
    G4 --> G5[필수 문서 저장]

    E --> H{신규 정책}
    H --> I[채팅방 생성]
    H --> J[채팅방 생략]

    A --> K[지역 업종 매핑]
    K --> K1[지역 업종 캐시]
    K1 --> K2[지역 매칭]
    K1 --> K3[업종 매칭]
    K2 --> K4[지역 기본값]
    K3 --> K5[업종 기본값]
    K4 --> K6[매핑 결과 저장]
    K5 --> K6
```

Notes:
- Scheduled task runs daily at 03:00.
- Only changed/new policies are persisted.
- Document mapping uses keyword-based matching with de-duplication.
- Category matching caches region/industry lists to reduce DB load.
```
