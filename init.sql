DROP DATABASE gagechaeum_db;

CREATE DATABASE gagechaeum_db;
USE gagechaeum_db;

-- 테이블 설정

--	사용자
CREATE TABLE users (
	user_id	BIGINT	AUTO_INCREMENT PRIMARY KEY,
	email	VARCHAR(255)	NOT NULL,
	password	VARCHAR(255)	NOT NULL,
	nickname	VARCHAR(255)	NOT NULL,
	name	VARCHAR(255)	NOT NULL,
	phone	VARCHAR(255)	NULL,
	created_at	DATETIME	NOT NULL,
	social	VARCHAR(255)	NULL	COMMENT '소셜 provider',
	social_id	VARCHAR(255)	NULL	COMMENT '소셜 계정',
	deleted_at	DATETIME	NULL,
	notification	BOOLEAN	NOT NULL	DEFAULT true,
	profile_image_key	VARCHAR(255)	NOT NULL,
  is_verified BOOLEAN NOT NULL DEFAULT false
);

-- 지역
CREATE TABLE regions (
	region_id	BIGINT	PRIMARY KEY	COMMENT '법정동 코드',
	super_id	BIGINT	NULL,
	depth	INT	NOT NULL	COMMENT '1: 전국 2: 시/도 3: 시/군/구',
	name	VARCHAR(255)	NOT NULL	COMMENT '"종로구"',
	full_name	VARCHAR(255)	NOT NULL	COMMENT '"서울 종로구"',
	CONSTRAINT fk_regions_super_id FOREIGN KEY (super_id)
		REFERENCES regions (region_id)
		ON DELETE RESTRICT
);

-- 업종
CREATE TABLE industry (
	industry_id	BIGINT	AUTO_INCREMENT PRIMARY KEY,
	name	VARCHAR(255)	NOT NULL,
	keywords	VARCHAR(255)	NULL	COMMENT '매칭용 키워드'
);

-- 사업자
CREATE TABLE business_info (
	business_info_id	BIGINT	AUTO_INCREMENT PRIMARY KEY,
	user_id	BIGINT	NOT NULL,
	region_id	BIGINT	NOT NULL	COMMENT '법정동 코드',
	industry_id	BIGINT	NOT NULL	COMMENT '업종 코드',
	business_num	VARCHAR(255)	NOT NULL,
    estb_date date not null comment '개업일자',
	CONSTRAINT fk_business_info_user_id FOREIGN KEY (user_id)
		REFERENCES users (user_id)
		ON DELETE CASCADE,
	CONSTRAINT fk_business_info_region_id FOREIGN KEY (region_id)
		REFERENCES regions (region_id),
	CONSTRAINT fk_business_info_industry_id FOREIGN KEY (industry_id)
		REFERENCES industry (industry_id)
);




-- 정책
CREATE TABLE policies (
	policy_id	VARCHAR(255) PRIMARY KEY	COMMENT '공고의 서비스ID',
	industry_id	BIGINT	NULL,
	region_id	BIGINT	NULL	COMMENT '법정동 코드',
	department_name	VARCHAR(255)	NOT NULL,
	user_type	VARCHAR(255)	NOT NULL	COMMENT '"법인/시설/단체", "개인", ...',
	announcement_url	VARCHAR(255)	NOT NULL,
	policy_name	VARCHAR(255)	NOT NULL,
	policy_summary	TEXT	NOT NULL,
	policy_field	VARCHAR(255)	NOT NULL	COMMENT '"생활안정", "고용·창업", ...',
	selection_criteria	TEXT	NULL,
	supervising_organization_name	VARCHAR(255)	NOT NULL,
	receiving_organization_name	VARCHAR(255)	NULL,
	notice_date	DATETIME	NOT NULL,
	modification_date	DATETIME	NOT NULL,
	application_period	VARCHAR(255) NOT NULL,
	begin_date	DATE	NULL,
	end_date	DATE	NULL,
	application_method	VARCHAR(255)	NOT NULL,
	contact	TEXT	NULL,
	support_detail	TEXT	NOT NULL,
	support_target	TEXT	NOT NULL,
	CONSTRAINT fk_policies_industry_id FOREIGN KEY (industry_id)
		REFERENCES industry (industry_id),
	CONSTRAINT fk_policies_region_id FOREIGN KEY (region_id)
		REFERENCES regions (region_id)
);

CREATE TABLE policy_details_temp
(
    policy_id  varchar(255)                        not null
        primary key,
    raw_text   text                                null,
    updated_at timestamp default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP
);


CREATE TABLE policy_bookmark_counts (
	policy_bookmark_count_id	BIGINT	AUTO_INCREMENT PRIMARY KEY,
	policy_id	VARCHAR(255)	NOT NULL	COMMENT '공고의 서비스ID',
	industry_id	BIGINT	NOT NULL,
	bookmark_count	BIGINT	NOT NULL	DEFAULT 0,
	CONSTRAINT fk_policy_bookmark_counts_policy_id FOREIGN KEY (policy_id)
		REFERENCES policies (policy_id)
		ON DELETE CASCADE,
	CONSTRAINT fk_policy_bookmark_counts_industry_id FOREIGN KEY (industry_id)
		REFERENCES industry (industry_id)
		ON DELETE CASCADE
);

-- 대출 상품
CREATE TABLE loans (
	loan_id	BIGINT	AUTO_INCREMENT PRIMARY KEY,
	industry_id	BIGINT	NULL,
	region_id	BIGINT	NULL	COMMENT '법정동 코드',
	company_name	VARCHAR(255)	NOT NULL,
	product_name	VARCHAR(255)	NOT NULL,
	join_way	VARCHAR(255)	NOT NULL,
	begin_date	DATE	NOT NULL,
	end_date	DATE	NULL,
	product_page_url	VARCHAR(255)	NOT NULL,
	min_limit	BIGINT	NOT NULL,
	max_limit	BIGINT	NOT NULL,
	basic_rate	DECIMAL(5,2)	NOT NULL,
	CONSTRAINT fk_loans_industry_id FOREIGN KEY (industry_id)
		REFERENCES industry (industry_id),
	CONSTRAINT fk_loans_region_id FOREIGN KEY (region_id)
		REFERENCES regions (region_id)
);

CREATE TABLE rates (
	rate_id	BIGINT	AUTO_INCREMENT PRIMARY KEY,
	loan_id	BIGINT	NOT NULL,
	rate_type	VARCHAR(255)	NOT NULL	COMMENT '"대출금리", "기준금리", "가산금리"',
	average_rate	DECIMAL(5,2)	NULL,
	rate_range1	DECIMAL(5,2)	NULL	COMMENT '800점 초과',
	rate_range2	DECIMAL(5,2)	NULL	COMMENT '701 ~ 800점',
	rate_range3	DECIMAL(5,2)	NULL	COMMENT '601 ~ 700점',
	rate_range4	DECIMAL(5,2)	NULL	COMMENT '501 ~ 600점',
	rate_range5	DECIMAL(5,2)	NULL	COMMENT '401 ~ 500점',
	rate_range6	DECIMAL(5,2)	NULL	COMMENT '301 ~ 400점',
	rate_range7	DECIMAL(5,2)	NULL	COMMENT '201 ~ 300점',
	rate_range8	DECIMAL(5,2)	NULL	COMMENT '200점 이하',
	CONSTRAINT fk_rates_loan_id FOREIGN KEY (loan_id)
		REFERENCES loans (loan_id)
		ON DELETE CASCADE
);

CREATE TABLE loan_bookmark_counts (
	loan_bookmark_count_id	BIGINT	AUTO_INCREMENT PRIMARY KEY,
	loan_id	BIGINT	NOT NULL,
	industry_id	BIGINT	NOT NULL	COMMENT '업종 코드',
	bookmark_count	BIGINT	NOT NULL	DEFAULT 0,
	CONSTRAINT fk_loan_bookmark_counts_loan_id FOREIGN KEY (loan_id)
		REFERENCES loans (loan_id)
		ON DELETE CASCADE,
	CONSTRAINT fk_loan_bookmark_counts_industry_id FOREIGN KEY (industry_id)
		REFERENCES industry (industry_id)
		ON DELETE CASCADE
);

-- 사용자 정책
CREATE TABLE user_policies (
    user_policy_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    policy_id VARCHAR(255) NULL,
    start_date DATE NOT NULL,
    end_date DATE NULL,
    first_payment_date DATE NULL,
    monthly_amount INT NULL,
    total_amount INT NULL,
    CONSTRAINT fk_user_policies_user_id FOREIGN KEY (user_id)
        REFERENCES users (user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_user_policies_policy_id FOREIGN KEY (policy_id)
        REFERENCES policies (policy_id)
        ON DELETE SET NULL
);

-- 사용자 대출
CREATE TABLE user_loans (
	user_loan_id	BIGINT	AUTO_INCREMENT PRIMARY KEY,
	user_id	BIGINT	NOT NULL,
	loan_id	BIGINT	NULL,
	collect_data	DATETIME	NOT NULL,
	account_num	VARCHAR(255)	NOT NULL,
	product_name	VARCHAR(255)	NOT NULL,
	account_type	VARCHAR(255)	NOT NULL	COMMENT '"신용대출", "담보대출"',
	issue_date	DATE	NOT NULL,
	expiry_date	DATE	NOT NULL,
	last_offered_rate	DECIMAL(5,2)	NOT NULL,
	repay_date	DATE	NOT NULL	COMMENT '대출거래약정서상의 월 상환일',
	repay_method	VARCHAR(255)	NOT NULL	COMMENT '"만기일시상환", "원금균등분할상환"',
	repay_organization	VARCHAR(255)	NOT NULL	COMMENT '자동이체 계좌 소속 기관',
	repay_account_num	VARCHAR(255)	NOT NULL	COMMENT '자동이체 계좌번호',
	balance_amount	BIGINT	NOT NULL,
	loan_principal	BIGINT	NOT NULL,
	next_repay_date	DATE	NOT NULL,
	loan_organization	VARCHAR(255)	NOT NULL,
	CONSTRAINT fk_user_loans_user_id FOREIGN KEY (user_id)
		REFERENCES users (user_id)
		ON DELETE CASCADE,
	CONSTRAINT fk_user_loans_loan_id FOREIGN KEY (loan_id)
		REFERENCES loans (loan_id)
		ON DELETE SET NULL
);

CREATE TABLE repayments (
	repayment_id	BIGINT	AUTO_INCREMENT PRIMARY KEY,
	user_loan_id	BIGINT	NOT NULL,
	amount	INT	NOT NULL,
	status	VARCHAR(255)	NOT NULL,
	paid_date	DATE	NOT NULL,
	balance_amount	BIGINT	NOT NULL,
	principal_amount	BIGINT	NOT NULL,
	interest_amount	BIGINT	NOT NULL,
	return_interest_amount	BIGINT	NOT NULL,
	interest_start_date	DATE	NOT NULL,
	interest_end_date	DATE	NOT NULL,
	interest_rate	DECIMAL(5,2)	NOT NULL,
	applied_interest_amount	BIGINT	NOT NULL	COMMENT '이자 기간과 적용이율을 통해 계산된 금액',
	interest_type	VARCHAR(255)	NOT NULL	COMMENT '"정상이자", "지연이자", "잔액연체이자"',
	CONSTRAINT fk_repayments_user_loan_id FOREIGN KEY (user_loan_id)
		REFERENCES user_loans (user_loan_id)
		ON DELETE CASCADE
);

-- 즐겨찾기
CREATE TABLE user_policy_bookmarks (
	bookmark_policy_id	BIGINT	AUTO_INCREMENT PRIMARY KEY,
	user_id	BIGINT	NOT NULL,
	policy_id	VARCHAR(255)	NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT '요건확인' COMMENT '"요건확인", "서류 수집/업로드", "제출 준비", "제출 완료/결과"',
	created_at DATETIME	NOT NULL DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT fk_user_policy_bookmarks_user_id FOREIGN KEY (user_id)
		REFERENCES users (user_id)
		ON DELETE CASCADE,
	CONSTRAINT fk_user_policy_bookmarks_policy_id FOREIGN KEY (policy_id)
		REFERENCES policies (policy_id)
		ON DELETE CASCADE
);

CREATE TABLE user_loan_bookmarks (
	bookmark_loan_id	BIGINT	AUTO_INCREMENT PRIMARY KEY,
	user_id	BIGINT	NOT NULL,
	loan_id	BIGINT	NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT '요건확인' COMMENT '"요건확인", "서류 수집/업로드", "제출 준비", "제출 완료/결과"',
	created_at DATETIME	NOT NULL DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT fk_user_loan_bookmarks_user_id FOREIGN KEY (user_id)
		REFERENCES users (user_id)
		ON DELETE CASCADE,
	CONSTRAINT fk_user_loan_bookmarks_loan_id FOREIGN KEY (loan_id)
		REFERENCES loans (loan_id)
		ON DELETE CASCADE
);

-- 서류
CREATE TABLE documents (
	document_id	BIGINT	AUTO_INCREMENT PRIMARY KEY,
	document_name	VARCHAR(255)	NOT NULL,
	issuing_authority	VARCHAR(255)	NULL,
	issuing_authority_url	VARCHAR(255)	NULL,
    keywords VARCHAR(255) NULL COMMENT '매칭용 키워드, 쉼표(,)로 구분'
);

CREATE TABLE required_documents (
	required_document_id	BIGINT	AUTO_INCREMENT PRIMARY KEY,
	document_id	BIGINT	NOT NULL,
	policy_id	VARCHAR(255)	NULL,
	loan_id	BIGINT	NULL,
	CONSTRAINT fk_required_documents_document_id FOREIGN KEY (document_id)
		REFERENCES documents (document_id)
		ON DELETE CASCADE,
	CONSTRAINT fk_required_documents_policy_id FOREIGN KEY (policy_id)
		REFERENCES policies (policy_id)
		ON DELETE CASCADE,
	CONSTRAINT fk_required_documents_loan_id FOREIGN KEY (loan_id)
		REFERENCES loans (loan_id)
		ON DELETE CASCADE,

    -- 중복 방지를 위한 UNIQUE 제약 조건
    CONSTRAINT uc_document_policy UNIQUE (document_id, policy_id),
    CONSTRAINT uc_document_loan UNIQUE (document_id, loan_id)
);

CREATE TABLE user_documents (
	user_document_id	BIGINT	AUTO_INCREMENT PRIMARY KEY,
	user_id	BIGINT NOT NULL,
	document_id	BIGINT	NOT NULL,
	document_name VARCHAR(255) NOT NULL,
	issued_at	DATE	NOT NULL,
	file_key	VARCHAR(255)	NOT NULL,
	CONSTRAINT fk_user_documents_user_id FOREIGN KEY (user_id)
		REFERENCES users (user_id)
		ON DELETE CASCADE,
	CONSTRAINT fk_user_documents_document_id FOREIGN KEY (document_id)
		REFERENCES documents (document_id)
		ON DELETE CASCADE
);

-- 채팅
CREATE TABLE chat_rooms (
	room_id	BIGINT	AUTO_INCREMENT PRIMARY KEY,
	industry_id	BIGINT	NULL,
	region_id	BIGINT	NULL,
	loan_id	BIGINT	NULL,
	policy_id	VARCHAR(255)	NULL,
	room_type	VARCHAR(255)	NOT NULL	COMMENT '"업종", "지역", "대출", "정책"',
	CONSTRAINT fk_chat_rooms_industry_id FOREIGN KEY (industry_id)
		REFERENCES industry (industry_id)
		ON DELETE CASCADE,
	CONSTRAINT fk_chat_rooms_region_id FOREIGN KEY (region_id)
		REFERENCES regions (region_id)
		ON DELETE CASCADE,
	CONSTRAINT fk_chat_rooms_policy_id FOREIGN KEY (policy_id)
		REFERENCES policies (policy_id)
		ON DELETE CASCADE,
	CONSTRAINT fk_chat_rooms_loan_id FOREIGN KEY (loan_id)
		REFERENCES loans (loan_id)
		ON DELETE CASCADE
);

CREATE TABLE chat_messages (
	message_id	BIGINT	AUTO_INCREMENT PRIMARY KEY,
	room_id	BIGINT	NOT NULL,
	user_id	BIGINT	NULL,
	content	TEXT	NOT NULL,
	created_at	TIMESTAMP	DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT fk_chat_messages_room_id FOREIGN KEY (room_id)
		REFERENCES chat_rooms (room_id)
		ON DELETE CASCADE,
	CONSTRAINT fk_chat_messages_user_id FOREIGN KEY (user_id)
		REFERENCES users (user_id)
		ON DELETE SET NULL
);

CREATE TABLE chat_attachments (
	attachment_id	BIGINT	AUTO_INCREMENT PRIMARY KEY,
	message_id	BIGINT	NOT NULL,
	file_key	VARCHAR(255)	NOT NULL,
	file_name	VARCHAR(255)	NOT NULL,
	file_type	VARCHAR(255)	NOT NULL,
	CONSTRAINT fk_chat_attachments_message_id FOREIGN KEY (message_id)
		REFERENCES chat_messages (message_id)
		ON DELETE CASCADE
);

CREATE TABLE user_chat_rooms (
	user_chat_room_id	BIGINT	AUTO_INCREMENT PRIMARY KEY,
	user_id	BIGINT	NOT NULL,
	room_id	BIGINT	NOT NULL,
	last_left_at	DATETIME	NULL,
	CONSTRAINT fk_user_chat_rooms_user_id FOREIGN KEY (user_id)
		REFERENCES users (user_id)
		ON DELETE CASCADE,
	CONSTRAINT fk_user_chat_rooms_room_id FOREIGN KEY (room_id)
		REFERENCES chat_rooms (room_id)
		ON DELETE CASCADE
);

-- 업종/서류/지역/채팅방 데이터 삽입

-- 업종 데이터
INSERT INTO industry (name, keywords) VALUES
	('농업, 임업 및 어업', '농업, 임업, 어업, 축산, 채소, 과수, 곡물, 산림, 수산, 양식, 어류, 농산물, 축산물'),
	('광업', '광업, 채굴, 금속, 석탄, 석유, 천연가스, 광물, 채광, 채석'),
	('제조업', '제조업, 식음료, 제과, 제빵, 음료, 의류, 섬유, 신발, 가방, 전자, 기계, 자동차, 화학, 철강, 금속, 플라스틱, 종이, 가구, 목재, 기계부품, 의료기기'),
	('전기, 가스, 증기 및 공기조절 공급업', '전기, 가스, 증기, 냉난방, 공기조절, 에너지, 발전, 배전, 공급'),
	('수도, 하수, 폐기물 처리, 원료 재생업', '상수도, 하수, 폐수, 폐기물, 재활용, 환경, 처리, 수처리'),
	('건설업', '건설, 건축, 토목, 인테리어, 주택, 도로, 교량, 설비, 조경, 건설자재, 공사'),
	('도소매업', '도소매, 소매, 도매, 슈퍼마켓, 편의점, 의류, 패션, 가전, 전자제품, 자동차, 연료, 건축자재, 잡화'),
	('운수 및 창고업', '운송, 물류, 창고, 택배, 배송, 항공, 철도, 버스, 트럭, 해운, 선박, 항만, 물류센터, 운수서비스'),
	('숙박 및 음식점업', '숙박, 호텔, 모텔, 여관, 게스트하우스, 호스텔, 음식점, 식당, 카페, 커피숍, 주점, 술집, 호프'),
	('정보통신업', '정보통신, IT, 소프트웨어, 앱, 인터넷, 통신, 네트워크, 데이터, 방송, 콘텐츠, 플랫폼, 클라우드'),
	('금융 및 보험업', '금융, 은행, 증권, 보험, 대출, 카드, 투자, 자산운용, 펀드, 연금, 신용, 재무, 회계, 캐피탈, 저축은행'),
	('부동산업', '부동산, 임대, 전대, 부동산중개, 개발, 건물관리, 부동산서비스'),
	('전문, 과학 및 기술 서비스업', '전문서비스, 과학, 기술, 연구, 컨설팅, 회계, 법률, 설계, 엔지니어링, IT컨설팅, 디자인, 분석, 특허'),
	('사업시설관리, 사업지원 및 임대 서비스업', '시설관리, 사업지원, 임대, 경비, 청소, 사무지원, 렌탈, 장비대여'),
	('공공행정, 국방 및 사회보장행정', '공공행정, 국방, 사회보장, 행정, 정부, 정책, 공공서비스'),
	('교육서비스업', '교육, 학원, 학교, 강의, 훈련, 유아교육, 초중고, 대학, 직업교육, 온라인교육'),
	('보건업 및 사회복지 서비스업', '보건, 의료, 병원, 요양, 복지, 간호, 사회복지, 재활, 건강관리, 클리닉'),
	('예술, 스포츠 및 여가관련 서비스업', '예술, 문화, 스포츠, 여가, 공연, 영화, 음악, 전시, 미술, 체육, 레저, 여행, 오락'),
	('협회 및 단체, 수리 및 기타 개인 서비스업', '협회, 단체, 수리, 개인서비스, 미용, 세탁, 세차, 애완, 이벤트, 상담'),
	('전체', '');


-- 서류 데이터
INSERT INTO documents (document_name, issuing_authority, issuing_authority_url) VALUES
	('지방세 납세증명서', '정부24', 'https://www.gov.kr'),
	('납세증명서', '정부24, 홈택스', 'https://www.gov.kr, https://www.hometax.go.kr'),
	('부가가치세과세표준증명', '정부24, 홈택스', 'https://www.gov.kr, https://www.hometax.go.kr'),
	('부가가치세면세사업자수입금액증명', '정부24, 홈택스', 'https://www.gov.kr, https://www.hometax.go.kr'),
	('사업자등록증명', '정부24, 홈택스', 'https://www.gov.kr, https://www.hometax.go.kr'),
	('소득금액증명', '정부24, 홈택스', 'https://www.gov.kr, https://www.hometax.go.kr'),
	('폐업사실증명', '정부24, 홈택스', 'https://www.gov.kr, https://www.hometax.go.kr'),
	('표준재무제표증명', '정부24, 홈택스', 'https://www.gov.kr, https://www.hometax.go.kr'),
	('휴업사실증명', '정부24, 홈택스', 'https://www.gov.kr, https://www.hometax.go.kr'),
	('금융거래확인서', '정부24', 'https://www.gov.kr'),
	('중소기업확인서', '중소벤처24', 'https://smb.go.kr'),
	('법인등기사항전부증명서(말소사항 포함)', '인터넷등기소', 'http://www.iros.go.kr'),
	('4대사회보험 가입자 가입내역 확인서', '정부24, 국민연금공단 4대사회보험 정보연계센터', 'https://www.gov.kr, https://www.4insure.or.kr'),
	('기타', NULL, NULL);

-- 서류 데이터 키워드 추가
UPDATE documents SET keywords = '지방세,지방세납세' WHERE document_name = '지방세 납세증명서';
UPDATE documents SET keywords = '납세증명,국세완납,세금완납,완납증명' WHERE document_name = '납세증명서';
UPDATE documents SET keywords = '부가가치세,부가세,과세표준' WHERE document_name = '부가가치세과세표준증명';
UPDATE documents SET keywords = '면세사업자,수입금액증명' WHERE document_name = '부가가치세면세사업자수입금액증명';
UPDATE documents SET keywords = '사업자등록,사업자,개인사업자,법인사업자' WHERE document_name = '사업자등록증명';
UPDATE documents SET keywords = '소득금액,소득증명,소득확인' WHERE document_name = '소득금액증명';
UPDATE documents SET keywords = '폐업사실,폐업' WHERE document_name = '폐업사실증명';
UPDATE documents SET keywords = '재무제표,재무상태표,손익계산서' WHERE document_name = '표준재무제표증명';
UPDATE documents SET keywords = '휴업사실,휴업' WHERE document_name = '휴업사실증명';
UPDATE documents SET keywords = '금융거래' WHERE document_name = '금융거래확인서';
UPDATE documents SET keywords = '중소기업,벤처기업,중소기업확인' WHERE document_name = '중소기업확인서';
UPDATE documents SET keywords = '법인등기,등기부등본,등기사항전부' WHERE document_name = '법인등기사항전부증명서(말소사항 포함)';
UPDATE documents SET keywords = '4대보험,4대 사회보험,가입내역,자격득실' WHERE document_name = '4대사회보험 가입자 가입내역 확인서';

-- 지역 데이터
-- 1. 전국
INSERT INTO regions (region_id, super_id, depth, name, full_name) VALUES
	(1, NULL, 1, '전국', '전국');

-- 2. 시/도
INSERT INTO regions (region_id, super_id, depth, name, full_name) VALUES
	(11, 1, 2, '서울특별시', '서울특별시'),
	(26, 1, 2, '부산광역시', '부산광역시'),
	(27, 1, 2, '대구광역시', '대구광역시'),
	(28, 1, 2, '인천광역시', '인천광역시'),
	(29, 1, 2, '광주광역시', '광주광역시'),
	(30, 1, 2, '대전광역시', '대전광역시'),
	(31, 1, 2, '울산광역시', '울산광역시'),
	(41, 1, 2, '경기도', '경기도'),
	(42, 1, 2, '강원도', '강원도'),
	(43, 1, 2, '충청북도', '충청북도'),
	(44, 1, 2, '충청남도', '충청남도'),
	(45, 1, 2, '전라북도', '전라북도'),
	(46, 1, 2, '전라남도', '전라남도'),
	(47, 1, 2, '경상북도', '경상북도'),
	(48, 1, 2, '경상남도', '경상남도'),
	(50, 1, 2, '제주특별자치도', '제주특별자치도');

-- 3. 시/군/구
-- 서울특별시
INSERT INTO regions (region_id, super_id, depth, name, full_name) VALUES
	(11010, 11, 3, '종로구', '서울특별시 종로구'),
	(11020, 11, 3, '중구', '서울특별시 중구'),
	(11030, 11, 3, '용산구', '서울특별시 용산구'),
	(11040, 11, 3, '성동구', '서울특별시 성동구'),
	(11050, 11, 3, '광진구', '서울특별시 광진구'),
	(11060, 11, 3, '동대문구', '서울특별시 동대문구'),
	(11070, 11, 3, '중랑구', '서울특별시 중랑구'),
	(11080, 11, 3, '성북구', '서울특별시 성북구'),
	(11090, 11, 3, '강북구', '서울특별시 강북구'),
	(11100, 11, 3, '도봉구', '서울특별시 도봉구'),
	(11110, 11, 3, '노원구', '서울특별시 노원구'),
	(11120, 11, 3, '은평구', '서울특별시 은평구'),
	(11130, 11, 3, '서대문구', '서울특별시 서대문구'),
	(11140, 11, 3, '마포구', '서울특별시 마포구'),
	(11150, 11, 3, '양천구', '서울특별시 양천구'),
	(11160, 11, 3, '강서구', '서울특별시 강서구'),
	(11170, 11, 3, '구로구', '서울특별시 구로구'),
	(11180, 11, 3, '금천구', '서울특별시 금천구'),
	(11190, 11, 3, '영등포구', '서울특별시 영등포구'),
	(11200, 11, 3, '동작구', '서울특별시 동작구'),
	(11210, 11, 3, '관악구', '서울특별시 관악구'),
	(11220, 11, 3, '서초구', '서울특별시 서초구'),
	(11230, 11, 3, '강남구', '서울특별시 강남구'),
	(11240, 11, 3, '송파구', '서울특별시 송파구'),
	(11250, 11, 3, '강동구', '서울특별시 강동구');

-- 부산광역시
INSERT INTO regions (region_id, super_id, depth, name, full_name) VALUES
	(26010, 26, 3, '중구', '부산광역시 중구'),
	(26020, 26, 3, '서구', '부산광역시 서구'),
	(26030, 26, 3, '동구', '부산광역시 동구'),
	(26040, 26, 3, '영도구', '부산광역시 영도구'),
	(26050, 26, 3, '부산진구', '부산광역시 부산진구'),
	(26060, 26, 3, '동래구', '부산광역시 동래구'),
	(26070, 26, 3, '남구', '부산광역시 남구'),
	(26080, 26, 3, '북구', '부산광역시 북구'),
	(26090, 26, 3, '해운대구', '부산광역시 해운대구'),
	(26100, 26, 3, '사하구', '부산광역시 사하구'),
	(26110, 26, 3, '금정구', '부산광역시 금정구'),
	(26120, 26, 3, '강서구', '부산광역시 강서구'),
	(26130, 26, 3, '연제구', '부산광역시 연제구'),
	(26140, 26, 3, '수영구', '부산광역시 수영구'),
	(26150, 26, 3, '사상구', '부산광역시 사상구'),
	(26160, 26, 3, '기장군', '부산광역시 기장군');

-- 대구광역시
INSERT INTO regions (region_id, super_id, depth, name, full_name) VALUES
	(27010, 27, 3, '중구', '대구광역시 중구'),
	(27020, 27, 3, '동구', '대구광역시 동구'),
	(27030, 27, 3, '서구', '대구광역시 서구'),
	(27040, 27, 3, '남구', '대구광역시 남구'),
	(27050, 27, 3, '북구', '대구광역시 북구'),
	(27060, 27, 3, '수성구', '대구광역시 수성구'),
	(27070, 27, 3, '달서구', '대구광역시 달서구'),
	(27080, 27, 3, '달성군', '대구광역시 달성군');

-- 인천광역시
INSERT INTO regions (region_id, super_id, depth, name, full_name) VALUES
	(28010, 28, 3, '중구', '인천광역시 중구'),
	(28020, 28, 3, '동구', '인천광역시 동구'),
	(28030, 28, 3, '미추홀구', '인천광역시 미추홀구'),
	(28040, 28, 3, '연수구', '인천광역시 연수구'),
	(28050, 28, 3, '남동구', '인천광역시 남동구'),
	(28060, 28, 3, '부평구', '인천광역시 부평구'),
	(28070, 28, 3, '계양구', '인천광역시 계양구'),
	(28080, 28, 3, '서구', '인천광역시 서구'),
	(28090, 28, 3, '강화군', '인천광역시 강화군'),
	(28100, 28, 3, '옹진군', '인천광역시 옹진군');

-- 광주광역시
INSERT INTO regions (region_id, super_id, depth, name, full_name) VALUES
	(29010, 29, 3, '동구', '광주광역시 동구'),
	(29020, 29, 3, '서구', '광주광역시 서구'),
	(29030, 29, 3, '남구', '광주광역시 남구'),
	(29040, 29, 3, '북구', '광주광역시 북구'),
	(29050, 29, 3, '광산구', '광주광역시 광산구');

-- 대전광역시
INSERT INTO regions (region_id, super_id, depth, name, full_name) VALUES
	(30010, 30, 3, '동구', '대전광역시 동구'),
	(30020, 30, 3, '중구', '대전광역시 중구'),
	(30030, 30, 3, '서구', '대전광역시 서구'),
	(30040, 30, 3, '유성구', '대전광역시 유성구'),
	(30050, 30, 3, '대덕구', '대전광역시 대덕구');

-- 울산광역시
INSERT INTO regions (region_id, super_id, depth, name, full_name) VALUES
	(31010, 31, 3, '중구', '울산광역시 중구'),
	(31020, 31, 3, '남구', '울산광역시 남구'),
	(31030, 31, 3, '동구', '울산광역시 동구'),
	(31040, 31, 3, '북구', '울산광역시 북구'),
	(31050, 31, 3, '울주군', '울산광역시 울주군');

-- 경기도
INSERT INTO regions (region_id, super_id, depth, name, full_name) VALUES
	(41110, 41, 3, '수원시 장안구', '경기도 수원시 장안구'),
	(41120, 41, 3, '수원시 권선구', '경기도 수원시 권선구'),
	(41130, 41, 3, '수원시 팔달구', '경기도 수원시 팔달구'),
	(41140, 41, 3, '수원시 영통구', '경기도 수원시 영통구'),
	(41210, 41, 3, '성남시 수정구', '경기도 성남시 수정구'),
	(41220, 41, 3, '성남시 중원구', '경기도 성남시 중원구'),
	(41230, 41, 3, '성남시 분당구', '경기도 성남시 분당구'),
	(41310, 41, 3, '의정부시', '경기도 의정부시'),
	(41320, 41, 3, '안양시 만안구', '경기도 안양시 만안구'),
	(41330, 41, 3, '안양시 동안구', '경기도 안양시 동안구'),
	(41410, 41, 3, '부천시', '경기도 부천시'),
	(41420, 41, 3, '광명시', '경기도 광명시'),
	(41430, 41, 3, '평택시', '경기도 평택시'),
	(41440, 41, 3, '동두천시', '경기도 동두천시'),
	(41450, 41, 3, '안산시 상록구', '경기도 안산시 상록구'),
	(41460, 41, 3, '안산시 단원구', '경기도 안산시 단원구'),
	(41470, 41, 3, '고양시 덕양구', '경기도 고양시 덕양구'),
	(41480, 41, 3, '고양시 일산동구', '경기도 고양시 일산동구'),
	(41490, 41, 3, '고양시 일산서구', '경기도 고양시 일산서구'),
	(41510, 41, 3, '과천시', '경기도 과천시'),
	(41520, 41, 3, '의왕시', '경기도 의왕시'),
	(41530, 41, 3, '구리시', '경기도 구리시'),
	(41540, 41, 3, '남양주시', '경기도 남양주시'),
	(41550, 41, 3, '오산시', '경기도 오산시'),
	(41560, 41, 3, '시흥시', '경기도 시흥시'),
	(41570, 41, 3, '군포시', '경기도 군포시'),
	(41580, 41, 3, '의정부시', '경기도 의정부시'),
	(41590, 41, 3, '하남시', '경기도 하남시'),
	(41600, 41, 3, '용인시 처인구', '경기도 용인시 처인구'),
	(41610, 41, 3, '용인시 기흥구', '경기도 용인시 기흥구'),
	(41620, 41, 3, '용인시 수지구', '경기도 용인시 수지구'),
	(41630, 41, 3, '파주시', '경기도 파주시'),
	(41640, 41, 3, '이천시', '경기도 이천시'),
	(41650, 41, 3, '안성시', '경기도 안성시'),
	(41660, 41, 3, '김포시', '경기도 김포시'),
	(41670, 41, 3, '화성시', '경기도 화성시'),
	(41680, 41, 3, '광주시', '경기도 광주시'),
	(41690, 41, 3, '양주시', '경기도 양주시'),
	(41700, 41, 3, '포천시', '경기도 포천시'),
	(41710, 41, 3, '여주시', '경기도 여주시'),
	(41720, 41, 3, '연천군', '경기도 연천군'),
	(41730, 41, 3, '가평군', '경기도 가평군'),
	(41740, 41, 3, '양평군', '경기도 양평군');

-- 강원도
INSERT INTO regions (region_id, super_id, depth, name, full_name) VALUES
	(42110, 42, 3, '춘천시', '강원도 춘천시'),
	(42120, 42, 3, '원주시', '강원도 원주시'),
	(42130, 42, 3, '강릉시', '강원도 강릉시'),
	(42140, 42, 3, '동해시', '강원도 동해시'),
	(42150, 42, 3, '태백시', '강원도 태백시'),
	(42160, 42, 3, '속초시', '강원도 속초시'),
	(42170, 42, 3, '삼척시', '강원도 삼척시'),
	(42210, 42, 3, '홍천군', '강원도 홍천군'),
	(42220, 42, 3, '횡성군', '강원도 횡성군'),
	(42230, 42, 3, '영월군', '강원도 영월군'),
	(42240, 42, 3, '평창군', '강원도 평창군'),
	(42250, 42, 3, '정선군', '강원도 정선군'),
	(42260, 42, 3, '철원군', '강원도 철원군'),
	(42270, 42, 3, '화천군', '강원도 화천군'),
	(42280, 42, 3, '양구군', '강원도 양구군'),
	(42290, 42, 3, '인제군', '강원도 인제군'),
	(42300, 42, 3, '고성군', '강원도 고성군'),
	(42310, 42, 3, '양양군', '강원도 양양군');

-- 충청북도
INSERT INTO regions (region_id, super_id, depth, name, full_name) VALUES
	(43110, 43, 3, '청주시 상당구', '충청북도 청주시 상당구'),
	(43120, 43, 3, '청주시 서원구', '충청북도 청주시 서원구'),
	(43130, 43, 3, '청주시 흥덕구', '충청북도 청주시 흥덕구'),
	(43140, 43, 3, '청주시 청원구', '충청북도 청주시 청원구'),
	(43210, 43, 3, '충주시', '충청북도 충주시'),
	(43220, 43, 3, '제천시', '충청북도 제천시'),
	(43230, 43, 3, '보은군', '충청북도 보은군'),
	(43240, 43, 3, '옥천군', '충청북도 옥천군'),
	(43250, 43, 3, '영동군', '충청북도 영동군'),
	(43260, 43, 3, '진천군', '충청북도 진천군'),
	(43270, 43, 3, '괴산군', '충청북도 괴산군'),
	(43280, 43, 3, '음성군', '충청북도 음성군'),
	(43290, 43, 3, '단양군', '충청북도 단양군');

-- 충청남도
INSERT INTO regions (region_id, super_id, depth, name, full_name) VALUES
	(44130, 44, 3, '천안시 동남구', '충청남도 천안시 동남구'),
	(44131, 44, 3, '천안시 서북구', '충청남도 천안시 서북구'),
	(44150, 44, 3, '공주시', '충청남도 공주시'),
	(44160, 44, 3, '보령시', '충청남도 보령시'),
	(44170, 44, 3, '아산시', '충청남도 아산시'),
	(44190, 44, 3, '서산시', '충청남도 서산시'),
	(44200, 44, 3, '논산시', '충청남도 논산시'),
	(44210, 44, 3, '계룡시', '충청남도 계룡시'),
	(44220, 44, 3, '당진시', '충청남도 당진시'),
	(44230, 44, 3, '금산군', '충청남도 금산군'),
	(44240, 44, 3, '부여군', '충청남도 부여군'),
	(44250, 44, 3, '서천군', '충청남도 서천군'),
	(44260, 44, 3, '청양군', '충청남도 청양군'),
	(44270, 44, 3, '홍성군', '충청남도 홍성군'),
	(44280, 44, 3, '예산군', '충청남도 예산군'),
	(44990, 44, 3, '태안군', '충청남도 태안군');

-- 전라북도
INSERT INTO regions (region_id, super_id, depth, name, full_name) VALUES
	(45110, 45, 3, '전주시 완산구', '전라북도 전주시 완산구'),
	(45120, 45, 3, '전주시 덕진구', '전라북도 전주시 덕진구'),
	(45210, 45, 3, '군산시', '전라북도 군산시'),
	(45220, 45, 3, '익산시', '전라북도 익산시'),
	(45230, 45, 3, '정읍시', '전라북도 정읍시'),
	(45240, 45, 3, '남원시', '전라북도 남원시'),
	(45250, 45, 3, '김제시', '전라북도 김제시'),
	(45280, 45, 3, '완주군', '전라북도 완주군'),
	(45290, 45, 3, '진안군', '전라북도 진안군'),
	(45300, 45, 3, '무주군', '전라북도 무주군'),
	(45310, 45, 3, '장수군', '전라북도 장수군'),
	(45320, 45, 3, '임실군', '전라북도 임실군'),
	(45330, 45, 3, '순창군', '전라북도 순창군'),
	(45340, 45, 3, '고창군', '전라북도 고창군'),
	(45370, 45, 3, '부안군', '전라북도 부안군');

-- 전라남도
INSERT INTO regions (region_id, super_id, depth, name, full_name) VALUES
	(46110, 46, 3, '목포시', '전라남도 목포시'),
	(46120, 46, 3, '여수시', '전라남도 여수시'),
	(46130, 46, 3, '순천시', '전라남도 순천시'),
	(46140, 46, 3, '나주시', '전라남도 나주시'),
	(46150, 46, 3, '광양시', '전라남도 광양시'),
	(46210, 46, 3, '담양군', '전라남도 담양군'),
	(46220, 46, 3, '곡성군', '전라남도 곡성군'),
	(46230, 46, 3, '구례군', '전라남도 구례군'),
	(46240, 46, 3, '고흥군', '전라남도 고흥군'),
	(46250, 46, 3, '보성군', '전라남도 보성군'),
	(46260, 46, 3, '화순군', '전라남도 화순군'),
	(46270, 46, 3, '장흥군', '전라남도 장흥군'),
	(46280, 46, 3, '강진군', '전라남도 강진군'),
	(46290, 46, 3, '해남군', '전라남도 해남군'),
	(46300, 46, 3, '영암군', '전라남도 영암군'),
	(46310, 46, 3, '무안군', '전라남도 무안군'),
	(46320, 46, 3, '함평군', '전라남도 함평군'),
	(46330, 46, 3, '영광군', '전라남도 영광군'),
	(46340, 46, 3, '장성군', '전라남도 장성군'),
	(46350, 46, 3, '완도군', '전라남도 완도군'),
	(46360, 46, 3, '진도군', '전라남도 진도군'),
	(46370, 46, 3, '신안군', '전라남도 신안군');

-- 경상북도
INSERT INTO regions (region_id, super_id, depth, name, full_name) VALUES
	(47110, 47, 3, '포항시 남구', '경상북도 포항시 남구'),
	(47120, 47, 3, '포항시 북구', '경상북도 포항시 북구'),
	(47210, 47, 3, '경주시', '경상북도 경주시'),
	(47220, 47, 3, '김천시', '경상북도 김천시'),
	(47230, 47, 3, '안동시', '경상북도 안동시'),
	(47240, 47, 3, '구미시', '경상북도 구미시'),
	(47250, 47, 3, '영주시', '경상북도 영주시'),
	(47260, 47, 3, '영천시', '경상북도 영천시'),
	(47270, 47, 3, '상주시', '경상북도 상주시'),
	(47280, 47, 3, '문경시', '경상북도 문경시'),
	(47290, 47, 3, '경산시', '경상북도 경산시'),
	(47310, 47, 3, '군위군', '경상북도 군위군'),
	(47320, 47, 3, '의성군', '경상북도 의성군'),
	(47330, 47, 3, '청송군', '경상북도 청송군'),
	(47340, 47, 3, '영양군', '경상북도 영양군'),
	(47350, 47, 3, '영덕군', '경상북도 영덕군'),
	(47360, 47, 3, '청도군', '경상북도 청도군'),
	(47370, 47, 3, '고령군', '경상북도 고령군'),
	(47380, 47, 3, '성주군', '경상북도 성주군'),
	(47390, 47, 3, '칠곡군', '경상북도 칠곡군'),
	(47410, 47, 3, '예천군', '경상북도 예천군'),
	(47420, 47, 3, '봉화군', '경상북도 봉화군'),
	(47430, 47, 3, '울진군', '경상북도 울진군'),
	(47440, 47, 3, '울릉군', '경상북도 울릉군');

-- 경상남도
INSERT INTO regions (region_id, super_id, depth, name, full_name) VALUES
	(48110, 48, 3, '창원시 의창구', '경상남도 창원시 의창구'),
	(48120, 48, 3, '창원시 성산구', '경상남도 창원시 성산구'),
	(48130, 48, 3, '창원시 마산합포구', '경상남도 창원시 마산합포구'),
	(48140, 48, 3, '창원시 마산회원구', '경상남도 창원시 마산회원구'),
	(48150, 48, 3, '창원시 진해구', '경상남도 창원시 진해구'),
	(48210, 48, 3, '진주시', '경상남도 진주시'),
	(48220, 48, 3, '통영시', '경상남도 통영시'),
	(48230, 48, 3, '사천시', '경상남도 사천시'),
	(48240, 48, 3, '김해시', '경상남도 김해시'),
	(48250, 48, 3, '밀양시', '경상남도 밀양시'),
	(48260, 48, 3, '거제시', '경상남도 거제시'),
	(48270, 48, 3, '양산시', '경상남도 양산시'),
	(48310, 48, 3, '의령군', '경상남도 의령군'),
	(48320, 48, 3, '창녕군', '경상남도 창녕군'),
	(48330, 48, 3, '고성군', '경상남도 고성군'),
	(48340, 48, 3, '남해군', '경상남도 남해군'),
	(48350, 48, 3, '하동군', '경상남도 하동군'),
	(48360, 48, 3, '산청군', '경상남도 산청군'),
	(48370, 48, 3, '함안군', '경상남도 함안군'),
	(48380, 48, 3, '거창군', '경상남도 거창군'),
	(48390, 48, 3, '합천군', '경상남도 합천군');

-- 제주도
INSERT INTO regions (region_id, super_id, depth, name, full_name) VALUES
	(50110, 50, 3, '제주시', '제주특별자치도 제주시'),
	(50130, 50, 3, '서귀포시', '제주특별자치도 서귀포시');

-- -- 채팅방 데이터
-- -- 업종별 채팅방
-- INSERT INTO chat_rooms (industry_id, region_id, room_type) VALUES
-- 	(1, NULL, 'industry'),
-- 	(2, NULL, 'industry'),
-- 	(3, NULL, 'industry'),
-- 	(4, NULL, 'industry'),
-- 	(5, NULL, 'industry'),
-- 	(6, NULL, 'industry'),
-- 	(7, NULL, 'industry'),
-- 	(8, NULL, 'industry'),
-- 	(9, NULL, 'industry'),
-- 	(10, NULL, 'industry'),
-- 	(11, NULL, 'industry'),
-- 	(12, NULL, 'industry'),
-- 	(13, NULL, 'industry'),
-- 	(14, NULL, 'industry'),
-- 	(15, NULL, 'industry'),
-- 	(16, NULL, 'industry'),
-- 	(17, NULL, 'industry'),
-- 	(18, NULL, 'industry'),
-- 	(19, NULL, 'industry');
--
-- -- 시/도별 채팅방
-- INSERT INTO chat_rooms (industry_id, region_id, room_type) VALUES
-- 	(NULL, 11, 'region'),
-- 	(NULL, 26, 'region'),
-- 	(NULL, 27, 'region'),
-- 	(NULL, 28, 'region'),
-- 	(NULL, 29, 'region'),
-- 	(NULL, 30, 'region'),
-- 	(NULL, 31, 'region'),
-- 	(NULL, 41, 'region'),
-- 	(NULL, 42, 'region'),
-- 	(NULL, 43, 'region'),
-- 	(NULL, 44, 'region'),
-- 	(NULL, 45, 'region'),
-- 	(NULL, 46, 'region'),
-- 	(NULL, 47, 'region'),
-- 	(NULL, 48, 'region'),
-- 	(NULL, 50, 'region');
--
-- -- 사용자
-- INSERT INTO users (user_id, email, password, nickname, name, phone, created_at, social, social_id, notification, profile_image_key)
-- VALUES (
-- 		   1,
-- 		   'test@example.com',
-- 		   '$2a$10$4DKsqy/vPc05zfqNSyy6Fe43KNk3Q6GeDatsjesWKjKyzsdUvt87i',
-- 		   'angela4',
-- 		   '사윤민',
-- 		   '010-1234-5678',
-- 		   NOW(),
-- 		   NULL,
-- 		   NULL,
-- 		   true,
--            'userProfileImage/default.png'
-- 	   );
--
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('142000000045', '5', '1', '전통시장과', '소상공인||법인/시설/단체', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/142000000045', '전통시장 주차환경개선 지원', '전통시장 또는 상점가 고객들이 이용할 수 주차장 설치를 지원', '고용·창업', NULL, '중소벤처기업부', NULL, '2020-12-17 14:26:13', '2025-08-21 16:20:51', '1월~2월 초', NULL, NULL, '직접입력', NULL, '전통시장 또는 상점가 고객전용 공영주차장 설치 지원
-- 공공 및 사설주차장 이용보조 지원', '전통시장및상점가육성을위한특별법에 따른 전통시장, 상점가, 상권활성화구역');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('142000000072', '3', '1', '지역상권과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/142000000072', '소공인 판로개척 지원', '25개업종 10인 미만 제조업자에게 전시회 참가, 마케팅전략수립 등을 바우처 방식으로 지원', '고용·창업', NULL, '중소벤처기업부', NULL, '2020-12-17 14:26:13', '2025-08-21 16:20:43', '연초', NULL, NULL, '기타 온라인신청', NULL, '○ 소공인이 지원한도 내에서 전시회 참가 등 9개 지원항목 중 필요한 사업을 자유롭게 선택하는 바우처 방식으로 지원
-- (온라인 및 오프라인몰 입점, 전시회 참가, 홍보영상제작, 뉴미디어마케팅, 디자인 개발, KC인증획득, 해외배송, 마케팅전략수립)', '○ 한국표준산업분류 25개 업종(소공인법 시행령 별표)에 해당하는 10인 미만 제조업자');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('142000000088', '11', '1', '소상공인재도약과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/142000000088', '소상공인 재기지원', '경영위기·폐업(예정) 소상공인 대상으로 폐업, 취업, 업종전환, 재창업을 위한 컨설팅 제공', '고용·창업', NULL, '중소벤처기업부', NULL, '2020-12-17 14:26:13', '2025-08-21 16:35:50', '사업공고에 따름', NULL, NULL, '기타 온라인신청', NULL, '○ (경영개선지원)경영위기 소상공인을 대상으로 경영진단 결과에 따라 후속사업(교육, 사업화, 폐업) 지원
--
-- ○ (원스톱폐업지원) 사업정리 컨설팅, 점포철거지원, 법률자문, 채무조정 등을 통한 신속한 폐업 지원
--
-- ○ (재취업지원) 재취업교육, 기업수요 연계 특화교육, 전직장려수당(취업활동 시 40만원 + 취업성공 시 60만원) 지급
--
-- ○ (재창업지원) 업종별 재창업교육, 업종 전환 및 성장 업종(헬스·뷰티케어, 친환경, 레져·문화, 애견·시니어 산업 등) 분야 재창업 사업화 (최대2천만원, 지원금만큼 자부담) 지원', '1. 희망리턴패키지 : 경영위기 또는 폐업(예정) 소상공인
-- 2. 자영업자 고용보험료 지원 : 자영업자 고용보험에 가입한 소상공인');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('142000000090', '20', '1', '소상공인정책과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/142000000090', '장애인 기업 시제품제작 지원', '장애인 및 기업에게 제품디자인 및 시제품모형제작에 소요되는 비용 일부 지원', '고용·창업', NULL, '중소벤처기업부', NULL, '2020-12-17 14:26:13', '2025-08-21 16:21:10', '3월~4월', NULL, NULL, '방문신청', NULL, '○ (제품디자인 및 시제품모형제작) 기업규모에 따라 70%~90% 이내, 최대 1,500만원
--
-- ○ (시제품금형제작) 기업규모에 따라 70%~90% 이내, 최대 2,500만원', '○ 장애인 예비창업자, 장애인기업');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('142100000050', '11', '1', '소상공인성장촉진과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/142100000050', '혁신 소상공인 투자연계지원', '민간자금 연계 및 집중지원으로 소상공인에서 소기업, 중기업으로의 압축성장을 지원', '고용·창업', NULL, '중소벤처기업부', NULL, '2025-07-07 14:19:27', '2025-07-11 13:58:58', '별도 안내', NULL, NULL, '기타 온라인신청', NULL, '○  스케일딥 : 지정된 민간 운영사로부터 1천만원 이상 최초 투자를 유치한 소상공인을 대상으로 투자금의 최대 3배, 최대 1억원 사업화자금(정부지원금) 지원
-- ○  스케일업 :➊2차례 이상 투자를 받은 소상공인 또는 ➋기업가형 소상공인 육성사업 수혜업체를 대상으로 투자금의 최대 3배, 최대 2억원 사업화자금(정부지원금) 지원', '○ 선투자 받은 비기술·생활기반의 소상공인');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('142100000051', '20', '1', '소상공인성장촉진과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/142100000051', '우리동네 크라우드펀딩', '크라우드펀딩 교육·컨설팅, 오픈·홍보지원, 펀딩수수료 등 펀딩에 필요한 제반비용 지원 등', '고용·창업', NULL, '중소벤처기업부', NULL, '2025-07-07 14:29:09', '2025-07-11 13:34:05', '상시신청', NULL, NULL, '직접입력', NULL, '크라우드펀딩 교육·컨설팅, 오픈·홍보지원, 펀딩수수료 등 펀딩에 필요한 제반비용 지원 등', '소상공인보호법 제2조에 따른 소상공인');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('142100000052', '20', '1', '소상공인성장촉진과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/142100000052', '로컬브랜드 창출', '로컬크리에이터가 소상공인과 협력, 지역의 인적·물적 자산을 연결하여 지역 정체성을 골목길에', '고용·창업', NULL, '중소벤처기업부', NULL, '2025-07-07 14:36:03', '2025-07-11 13:51:53', '별도 안내', NULL, NULL, '기타 온라인신청', NULL, '로컬크리에이터가 소상공인과 협력, 지역의 인적·물적 자산을 연결하여 지역 정체성을 골목길에 담아 골목상권의 브랜드화 지원', '로컬크리에이터, 소상공인 등');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('142100000058', '16', '1', '청년정책과', '개인||소상공인||법인/시설/단체', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/142100000058', '창업중심대학', '사업화자금 및 창업역량 강화 프로그램 지원', '고용·창업', NULL, '중소벤처기업부', NULL, '2025-07-17 15:10:56', '2025-07-18 12:21:14', '모집공고 기한 내(''25.3.14~''25.4.2)', NULL, NULL, '기타 온라인신청', NULL, '사업화자금 및 창업역량 강화 프로그램 지원', '예비 창업자 및 창업기업');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('149200005008', '11', '1', '고용보험기획과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/149200005008', '자영업자 실업급여', '비자발적으로 폐업한 자영업자에 대한 실업급여 지급', '고용·창업', NULL, '고용노동부', NULL, '2021-02-18 10:41:53', '2025-04-22 20:12:24', '상시신청', NULL, NULL, '방문신청', NULL, '○ 고용보험 가입(고용산재보험료징수법 제49조의2)
--   -  근로자를 사용하지 아니하거나 50명 미만의 근로자를 사용하는 사업주* 중 가입희망자(임의가입)
--    *  ①사업자등록을 하고 사업을 영위하는 사람, ②고유번호를 부여받은 자영업자로서 가정어린이집, 민간어린이집, 노인장기요양기관을 운영하는 사람, ③농어업경영정보를 등록하고 농어업을 영위하는 사람
--   -  고용보험료는 기준보수액의 2.25%
--
-- ○ 실업급여 지급(고용보험법 제4장(실업급여) 제4절(자영업자인 피보험자에 대한 실업급여 적용의 특례) 제69조의2부터 제69조의9까지)
--   - 매출액이 감소하는 등 비자발적으로 폐업하고, 폐업일 이전 24개월 동안 1년 이상 고용보험료를 납부한 사업주
--   - 기초일액의 60%를 120~210일까지 지급', '○ 구직급여 수급요건(고용보험법 제69조의3) 폐업한 자영업자인 피보험자가 아래 요건을 모두 갖춘 경우 지급
--  -  폐업일 이전 24개월간 제41조제1항 단서에 따라 자영업자인 피보험자로서 갖춘 피보험 단위기간이 합산하여 1년 이상일 것
--  -  근로의 의사와 능력에도 불구하고 취업하지 못한 상태에 있을 것
--  -  폐업사유가 고용보험법 제69조의7에 따른 수급자격의 제한 사유에 해당하지 아니할 것
--  -  재취업을 위한 노력을 적극적으로 할 것');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('174100000071', '6', '1', '지진방재정책과', '개인||가구||소상공인||법인/시설/단체', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/174100000071', '민간건축물 대상 지진안전 시설물 인증제 신청에 필요한 비용(내진성능평가 비용, 인증 수수료) 지원', '○ 지진안전 시설물 인증에 소요되는 비용의 일부를 국가에서 보조', '행정·안전', NULL, '행정안전부', NULL, '2024-04-25 13:56:56', '2025-07-23 14:30:16', '상시신청', NULL, NULL, '방문신청||직접입력', NULL, '○ 지진안전 시설물 인증에 소요되는 비용(내진성능평가 비용, 인증 수수료)의 일부를 국가에서 보조
--     - 내진성능평가: 3,000만원 한도로 국가 60%(최대 1,800만원 지원), 지자체 30~40% 지원
--     - 인증 수수료: 1,000만원 한도로 국가 60%(최대 600만원 지원), 지자체 30~40% 지원', '○ 지진안전 시설물 인증을 받고자 하는 민간건축물(건축물 소유주가 민간)(공공 제외)');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('304000000186', '20', '11050', '지역경제과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/304000000186', '소상공인 손실보상금 지원(현장신청 지원)', '방역조치로 경영상 손실이 발생한 소상공인에게 보상금 지원', '생활안정', NULL, '서울특별시 광진구', NULL, '2021-11-12 09:45:23', '2025-07-24 09:02:19', '상시신청', NULL, NULL, '기타 온라인신청||방문신청', NULL, '코로나19로 정부의 집합금지·영업시간 제한 방역조치를 이행한 소상공인에 대한 보상
--   - 업체별 손실규모에 비례해 맞춤형 보상금을 산정해 지급
--   - 상한액 1억원, 하한액 100만원', '2021년 3분기~2022년 2분기 집합금지, 영업시간제한 방역조치로 경영상 손실이 발생한 소상공인, 소기업');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('319000000149', '19', '11200', '경제정책과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/319000000149', '착한가격업소 지원', '맞춤형 소모품 지원, 청소(반기별) 및 소독(2개월 당 1회) 등 지원', '생활안정', NULL, '서울특별시 동작구', NULL, '2023-11-14 17:02:29', '2025-07-21 19:01:01', '매년 상반기(3~4월)', NULL, NULL, '방문신청', NULL, '-착한가격업소 지원 및 관리', '동작구 소재지의 상시근로자 5인 미만의 소상공인 개인서비스업 자영업자');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('343000000131', '19', '27030', '위생과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/343000000131', '노후 이‧미용업 시설개선 지원사업', '시설개선비용의 60% 지원(200만원한도)', '문화·환경', NULL, '대구광역시 서구', NULL, '2022-02-09 10:38:29', '2025-07-23 09:53:50', '접수기관 별 상이', NULL, NULL, '방문신청||직접입력', NULL, '○  노후 이‧미용업 영업장 내 외부 인테리어 및 이‧미용설비 시설개선 지원
--      - 간판, 바닥, 도배, 조명, 이‧미용의자, 세면대, 온수기, 소독기 등', '○ 신청대상 :  영업신고 후 6개월이 경과한 이‧미용업
-- ○ 선정방법 :서류 및 현장평가, 심의위원회 심의 후 지원결정');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('345000000109', '5', '27050', '위생과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/345000000109', '음식점 환경개선 지원', '노후된 일반음식점 영업장 개보수에 소요되는 공사비 및 구입비 일부 지원', '보건·의료', NULL, '대구광역시 북구', NULL, '2022-06-28 14:49:54', '2025-07-21 15:20:26', '접수기관 별 상이', NULL, NULL, '방문신청', NULL, '○ 관내 일반음식점 중 노후된 영업장 개·보수 및 입식테이블 교체 등 환경개선
--    - 지원대상 : 관내 일반음식점 영업주(소주, 호프방 등 주점식 형태 제외)
--    - 지원금액 : 가구 구입비 및 공사비 소요금액의 50%(최대2백만원) 지원', '영업신고일 또는 영업자 지위승계일로부터 6개월이 경과하고, 식사류를 취급하는 일반음식점 영업주');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('349000000115', '20', '28010', '경제산업과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/349000000115', '지역사랑상품권(인천e음) 상생가맹점 인센티브 지원', '지원내용 : 지역사랑상품권 상생가맹점 카드결제액의 1~5% 지원 (월 최대 30만원)', '생활안정', NULL, '인천광역시 중구', NULL, '2022-06-03 14:57:57', '2025-07-21 17:58:52', '상시신청', NULL, NULL, '방문신청', NULL, '지원내용 : 지역사랑상품권 상생가맹점 카드결제액의 1~5% 지원 (월 최대 30만원)', '신청대상 : 중구에 사업장을 둔 지역사랑상품권 상생가맹점');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('355000000111', '20', '28070', '일자리정책과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/355000000111', '노란우산공제부금 가입장려금 지급', '월 3만원 가입장려금 지원 (1년간 최대 36만원 지원)
-- ※ 인천시 2만원, 계양구 1만원', '생활안정', NULL, '인천광역시 계양구', NULL, '2022-06-07 09:35:13', '2025-07-21 13:46:33', '상시신청', NULL, NULL, '기타 온라인신청||방문신청', NULL, '월 3만원 가입장려금 지원 (1년간 최대 36만원 지원, 인천시 2만원, 계양구 1만원)
--
-- 예시) 노란우산 가입자가 월 5만원씩 12개월, 총 60만원을 납부하고 폐업
-- 99만원 수령: {원금 60만원 + 장려금 36만원(계양구 12만원 + 인천시 24만원)} + 이자 28,800원(원금+장려금의 3.0%내외)', '관내 소상공인 중 노란우산 공제부금 신규가입자');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('358000000125', '11', '28100', '경제정책과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/358000000125', '중소기업 및 소상공인 특례보증 대상 이차보전', '특례보증을 통해 대출받은 소상공인에 이자 지원', '생활안정', NULL, '인천광역시 옹진군', NULL, '2022-06-03 16:35:07', '2025-07-23 09:24:42', '상시신청', NULL, NULL, '방문신청', NULL, '○ 중소기업 및 소상공인 특례보증 대상 이차보전
--   - 특례보증을 통해 대출받은 소상공인에 이자 지원', '○ 옹진군 관내 특례보증 대출을 받은 소상공인');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('383000000165', '20', '41', '기업경제과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/383000000165', '청년창업 (기업) 상시지원', '○ 예비창업부터 단계별·맞춤형 지원으로 강소기업 육성  ', '고용·창업', NULL, '경기도 안양시', NULL, '2021-11-04 10:45:10', '2025-07-24 15:32:56', '사업별 상이', NULL, NULL, '방문신청', NULL, '○ (청년창업 공간운영) 청년오피스, 1인창조기업지원센터
--       - 사무인프라, 인터넷, 전기 등 무상 입주 지원
-- ○ (청년창업기업 엑셀러레이팅 지원)
--      - 초기기업 사업화 전략 전문 엑셀러레이터 선정/운영
-- ○ (청년·창업기업 사업화컨설팅 지원)
--      - 사업성장 지원 전문가 컨설팅 지원으로 사업계획서 진단 및 고도화
-- ○ (청년창업기업 스케일업)
--      - 창업기업의 시작부터, 엑셀러레이팅 이후 고성장 스타트업 육성을 위한 스케일업 지원
-- ○ (창업기업 디자인 개발 제작지원)
--      - 청년창업기업의  기업 인지도 향상과 시장 경쟁력 강화를 위한 브랜드(CI/BI) 및 디자인 개발 지원', '○ 예비창업자, 창업초기기업, 청년 기업 등: 프로그램별로 상이');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('427000000215', '20', '1', '경제과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/427000000215', '착한가격업소 인센티브 지원', '착한가격지정업소의 소상공인에게 인센티브 지원', '고용·창업', NULL, '강원특별자치도 영월군', NULL, '2021-09-23 12:34:56', '2025-07-20 13:47:46', '상시신청', NULL, NULL, '방문신청', NULL, '○ 대상 : 관내 착한가격지정업소
--
-- ○ 지원 : 인센티브 최대 300만원 지원', '○ 착한가격업소로 지정된 업소');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('427000000235', '9', '1', '환경위생과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/427000000235', '모범음식점 인센티브 지원', '모범업소로 지정된 음식점에 상수도 사용요금 (지하수 수질검사비) 및 쓰레기 종량제 봉투지원', '고용·창업', NULL, '강원특별자치도 영월군', NULL, '2021-09-23 12:34:56', '2025-07-18 16:48:36', '하반기(모범음식점 신청업소 모집공고)', NULL, NULL, '방문신청', NULL, '○ 상수도 사용요금 및 지하수 수질검사 비용 지원
--  - 지원금액 : 매 분기별 상수도요금(월 징수요금의 30%, 월 20만원 한도) 및 지하수 수질검사 비용(매년)
--  ※ 매 분기 기준 상수도 요금 체납액이 없는 업소
--  - 지원방법 : 매 분기 익 월말 계좌이체
--
-- ○ 쓰레기 종량제 봉투(50L기준) 지원
--  - 지원수량 : 업소별 월 20매(분기 60매)
--  - 지원방법 : 업소 방문배부(소비자식품위생감시원 협조)', '○ 관내 일반음식점 중 모범업소로 지정된 음식점');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('427000000239', '5', '1', '경제과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/427000000239', '소상공인 경영환경 개선지원', '소상공인 경영환경 개선 사업 지원', '고용·창업', NULL, '강원특별자치도 영월군', NULL, '2021-09-23 12:34:56', '2025-07-20 13:44:48', '2025. 1~2월 중 공고예정', NULL, NULL, '방문신청', NULL, '○ 대상 : 관내소상공인
--
-- ○ 지원 : 경영환경 개선 최대 800만원 지원 (총사업비의 80%범위  이내)
--                 - 홍보물제작 : 포장박스, 홍보지, 상품안내서 등
--                - 점포 경영환경 개선 : 소규모 리모델링,간판교체 등
--                - 안전위생 지원 : CCTV 설치, 소독기, 살균시, 식기세척기 등
--               - 스마트화 지원 : POS기기, 키오스크, 테이블오더 등', '○ 소상공인(중소기업기본법에 따른 소기업중 100대 생활업종 중 접갤밀접업종)
--     - 최근 1년이상 영월군 주민등록되어있고, 해당사업 1년이상 계속 영위하였으며, 향후 3년이상 해당 업종 운영예정인 사업자
--    - 우선순위자 : 관내 거주기간, 사업영위기간 등');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('428000000112', '20', '1', '축산농기계과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/428000000112', '명태산업 광역특구 황태 기자재 지원', '황태 가공·생산업체에 기자재 구입 지원', '농림축산어업', NULL, '강원특별자치도 평창군', NULL, '2021-09-23 12:34:56', '2025-07-22 09:03:26', '상시신청', NULL, NULL, '방문신청', NULL, '○ 황태 가공·생산 기자재 구입 지원', '○ 관내 황태 가공·생산업체');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('439000000849', '5', '43210', '경제과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/439000000849', '소상공인 점포환경개선 지원', '소상공인에게 점포환경 개선 지원', '고용·창업', NULL, '충청북도 충주시', NULL, '2021-09-23 12:34:56', '2025-07-25 09:54:16', '상시신청', NULL, NULL, '방문신청', NULL, '○ 소상공인 점포환경 개선 지원
--  - 지원대상 : 사업장 및 대표자 주소지를 충주시에 두고 6개월 이상 사업을 영위하고 있는 소상공인
--  - 지원금액 : 개소당 최대 200만원(공급가액의 80% 지원, 부가세 자부담)
--  - 지원내용 : 간판개선, 내부인테리어, 키오스크 등
--  ※ 전년도 매출액, 사업영위 기간 등 심사 기준에 따라 예산범위 내에서 지원됨
--  ※ 지원대상 및 지원금액 등은 시 정책상 변동될 수 있음', '○ 사업 공고일 기준, 사업장 및 대표자 주소지를 충주시에 두고 6개월 이상 사업을 영위하고 있는 소상공인');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('443000000662', '5', '43240', '경제과', '개인||소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/443000000662', '소상공인 경영개선(점포환경) 지원', '관내 소상공인 대상 점포환경 개선 비용 지원', '생활안정', NULL, '충청북도 옥천군', NULL, '2024-02-13 11:45:56', '2025-07-16 09:05:24', '접수기관 별 상이', NULL, NULL, '방문신청', NULL, '○ 소상공인 경영개선(점포환경) 지원
--  - 지원내용: 점포 환경개선, 내부시설 지원, 경영관리 물품, 안전·위생시설 등
--  - 지원한도: 부가세를 제외한 사업비의 80% 범위에서 최대 2천만원까지 지원
--   ㆍ본 사업을 기지원받은 업체: 부가세를 제외한 사업비의 70% 지원(자담30%)
--
-- ※ 납부세액, 거주 및 사업장 운영 기간 등 심사 기준에 따라 예산범위 내에서 지원됨
-- ※ 지원대상 및 지원금액 등은 시 정책상 변동될 수 있음', '○ 옥천군에 공고일로부터 최근 3년 이상 주민등록과 거주사실이 있고 3년 이상 해당사업을 계속 영위하며, 상시 근로자 수가 3명 미만인 소상공인');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('451000000125', '1', '44160', '축산과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/451000000125', '축산물판매업소 위생개선 재료 지원', '축산물판매업소에 흡수지, 위생마스크 등 위생개선 재료 지원', '고용·창업', NULL, '충청남도 보령시', NULL, '2021-09-23 12:34:56', '2025-07-17 18:01:28', '2025.5.1~2025.5.30.', NULL, NULL, '정부24온라인신청||방문신청', NULL, '○ 흡수지, 위생마스크, 골절기 톱날, 진공포장 필름 등 식육판매업소 소모성 재료 지원
--  - 대상 : 식육판매업소
--  - 사업비 : 1,000만원(보조 100%)
--  - 사업량 : 25개소', '○ 식육판매업소');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('451000000141', '20', '44160', '지역경제과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/451000000141', '청년창업지원', '○ 예비 창업자 등에게 창업교육 및  초기 창업자금 지원
-- -- ', '고용·창업', NULL, '충청남도 보령시', NULL, '2021-09-23 12:34:56', '2025-07-17 09:14:58', '매년 상반기', NULL, NULL, '방문신청||직접입력', NULL, '○ 보령시에 주소를 두고 있는 예비 청년창업자에게 초기창업자금 지원
-- --     - 창업교육, 사업계획 수립, 엑셀러레이팅 등 초기창업 지원', '○  보령시에서 창업을 희망하는 18세 이상  45세 이하 청년');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('477000000112', '20', '1', '경제교통과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/477000000112', '소상공인 지원', '소상공인에게 시설개보수, 장비, 비품구입비 지원', '고용·창업', NULL, '전북특별자치도 순창군', NULL, '2021-09-23 12:34:56', '2025-07-25 15:20:20', '상시신청', NULL, NULL, '방문신청', NULL, '○ 총사업비 4천만원 이내에서 시설개보수, 장비, 비품구입비 50% 지원', '○ 관내 2년이상 거주자로, 사업 운영기간 2년 이상인 소상공인');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('478000000108', '9', '1', '환경위생과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/478000000108', '음식점, 위생업소 등 시설개선 지원', '음식점, 위생업소 등에 업소당 최대 7백만원의 시설개선사업 지원', '고용·창업', NULL, '전북특별자치도 고창군', NULL, '2021-09-23 12:34:56', '2025-07-24 17:49:01', '접수기관 별 상이', NULL, NULL, '기타 온라인신청', NULL, '○ 음식점 등 시설개선 지원사업(업소당 지원액 최대 7백만원, 자부담 30% 이상)
--  - 주방, 영업장 화장실 등 영업장 환경 개선
--  - 입식테이블 지원, 테이블 간 칸막이 또는 파티션 지원
--
-- ○ 위생업소 시설개선 지원사업(업소당 지원액 최대 1천만원, 자부담 50% 이상)
--  - 위생업소의 영업장, 조리장, 화장실 등 시설개선', '○ 고창군 전 지역 위생등급 지정(신청)식품접객업소, 모법업소, 음식문화개선 참여업소
--
-- ○ 고창군 전 지역 일반·휴게음식점, 식품제조가공업, 즉석판매제조가공업, 목욕, 세탁, 이·미용업');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('482000000135', '1', '46130', '친환경농업과', '소상공인||법인/시설/단체', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/482000000135', '원예작물 친환경자재 지원', '친환경 인증취득 농가에 친환경약제 및 채소과수 재배농가에 노동력 절감 방안으로 부직포 지 ', '농림축산어업', NULL, '전라남도 순천시', NULL, '2023-08-29 16:39:01', '2025-05-15 17:18:09', '연초 사업기간 공지 후 신청기간내 개별 신청', NULL, NULL, '방문신청', NULL, '친환경부직포(과수, 채소), 친환경약제 지원', '1. 원예작물 친환경 약제 지원
--     ○ 순천시에 주소를 두고 농업경영체를 등록한 농업인, 단체
--     ○ ‘24. 12. 31.까지 친환경 인증을 획득한 농가 지원(배추 무사마귀병 제외)
--     ○ 사업 성격상 신청 농가가 많고, 사업비가 소액이므로 업무추진의 효율성을 기하기 위하여 가급적 마을이나 작목반 단위로 신청을 받아 작목반장 책임 하에 사업
--          추진 (작목반의 경우 농가별 신청내역 첨부)/작목반 없는 경우만 개별 신청
-- 2.채소 및 과수부직포 지원
--    - 채소를 0.1ha 이상 재배하고, 제초용 부직포 설치를 희망하는 농가
--    - 과수 재배 면적이 넓은  농가
--    - 잡초 발생전 조기에(5월까지) 사업을 완료할 수 있는 농가
--    - 친환경 농법으로 작물을 재배하고 있는 고령농가
--    - 친환경 인증을 취득한 농가 또는 실천하고 있는 농가');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('486000000122', '20', '46220', '도시경제과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/486000000122', '소상공인 지원', '소상공인을 대상으로 창업자금, 카드수수료, 온라인 마케팅 등 지원', '고용·창업', NULL, '전라남도 곡성군', NULL, '2021-09-23 12:34:56', '2025-05-12 10:51:08', '상시신청', NULL, NULL, '방문신청', NULL, '○ 소상공인 카드수수료 지원 : 연 매출 3억 이하 관내 주소지 및 사업장을 두고있는 소상공인, 전전년도 카드매출액의 0.8% 지원
--
-- ○ 소상공인 온라인 마케팅 지원 : 소상공인 온라인 진출을 위한 온라인 마케팅 비용 지원
--
-- ○ 1인 자영업자 고용산재 보험료 지원 : 1인 자영업자 고용, 산재보험료 일부 지원
--
-- ○ 착한가격업소 지원 : 선정된 착한가격업소에 대해 인증표찰 배부, 소모품 지원, 홍보시책 등 지원
--
-- ○ 소상공인 노란우산 가입 장려금 지원 : 노란우산 공제 신규가입자 장려금 적립 지원(월 2만원)
--
-- ○ 곡성군 스타가게 지원사업 : 스타가게로 선정된 3개소에 최대 100만원 지원
--
-- ○ 소상공인 공동체 육성지원 : 곡성군 소상공인 5인 이상 공동체 최대 500만원 지원
--
-- ○ 소상공인 경영환경개선 지원 : 관내 6개월 이상 영업자에 대해 사업비의 70% 최대 700만원 지원', '○ 대상 자격을 갖춘 관내 소상공인');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('493000000109', '1', '46290', '해양수산과', '개인||소상공인||법인/시설/단체', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/493000000109', '수산물 포장재 등 지원', '어업인 등에게 수산물 포장재 디자인 개발 및 포장재 구입 지원', '농림축산어업', NULL, '전라남도 해남군', NULL, '2021-09-23 12:34:56', '2025-07-29 15:36:52', '상시신청', NULL, NULL, '방문신청', NULL, '○ 디자인 개발(신규 및 개선) 및 포장재 제작비용에 초과되는 사업비에 대하여는 자부담 원칙
--
-- ○ 수산물 브랜드 가치향상을 위한 디자인 전문업체와 추진
--
-- ○ 해남군 해남CI 인 “심벌마크”및 “땅끝해남 ”브랜드 표기', '○ 사업자등록한 수산물 가공 및 포장판매 개인사업자, 생산자단체 ,  영어조합법인 등');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('493000000111', '9', '46290', '관광실', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/493000000111', '식품위생업소 시설개선 설치 지원', '일반음식점에 저온저장고 및 입식테이블 설치 비용 지원', '생활안정', NULL, '전라남도 해남군', NULL, '2021-09-23 12:34:56', '2025-07-28 09:12:27', '공고 게시 ', NULL, NULL, '방문신청', NULL, '○ 해남군에 주소를 두고 일반음식점을 운영하는 영업주에게 저온저장고 및 입식테이블 설치 비용 50% 지원
--  - 지원범위 : 저온저장고 최대3,150천원, 입식테이블 최대 2,000천원', '○ 관내 일반음식점');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('493000000131', '5', '46290', '관광실', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/493000000131', '공중위생업소(숙박업 및 이미용업소) 시설개선 및 환경개선 지원', '공중위생업소에 시설 개선 비용 지원', '생활안정', NULL, '전라남도 해남군', NULL, '2021-09-23 12:34:56', '2025-07-29 15:07:29', '공개 모집 게시', NULL, NULL, '방문신청', NULL, '○ 해남군에 주소를 두고있는 숙박업소 영업주에게  숙박업소 시설 개선 비용  50% 지원
--  - 숙박업소 시설개선 지원 :최대 10,000천원(군비 50%, 자부담 50%)
-- ○ 해남군에 주소를 두고 있는 이미용업소 영업주에게 이미용업소 시설개선 비용 50%지원
--   - 이미용업소 시설개선 지원: 4,000천원(군비 50%, 자부담 50%)', '○ 관내 공중위생업소
--   - 공고일 기준 6개월 이상 사업체를 운영
--   - 공고일 기준 영업주 및 영업장 주소가 해남에 소재');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('493000000273', '12', '46290', '문화예술과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/493000000273', '공예품 개발지원', '공예품 제품개발, 컨설팅, 재료, 홍보, 포장재 구입 지원', '문화·환경', NULL, '전라남도 해남군', NULL, '2024-02-21 09:20:14', '2025-08-18 10:55:38', '매년 3월 경', NULL, NULL, '방문신청', NULL, '공예품 업체를 대상으로 공예품 제품개발, 컨설팅, 재료, 홍보, 포장재 구입 지원', '관내 (정상 운영중인) 공예품 생산업체');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('493000000285', '20', '46290', '환경과', '가구||소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/493000000285', '음식물 감량기 설치 지원', '대상자 선정 후 음식물 감량기 구입 시 구입액의 50%를 지원', '생활안정', NULL, '전라남도 해남군', NULL, '2024-02-21 14:18:28', '2025-07-29 15:29:43', '매년 2~3월 경', NULL, NULL, '방문신청', NULL, '○ 음식물 감량기 설치 금액의 50% 지원
-- - 대상자 선정 후 구입
--  - 최대 가정용 300천원', '○ 신청자격: 공고일 기준
--  - 가정: 해남군에 주소를 둔 세대
-- ○ 제외대상
--  - 지방세 및 세외수입 체납자
--  - 최근 3년이내 음식물감량기 설치 보조금을 받은 자
--  - 음식물 감량기 설치된 아파트 거주자(다우아르미안, 하늘연가, 백두3차, 주공 1차)');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('494000000189', '9', '46300', '농축산유통과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/494000000189', '국산김치 사용업소 식자재 구입비 지원', '수입산 김치보다 비싼 국산김치를 사용하는 외식업소의 부담 경감 및 지역농수산물 소비 촉진', '생활안정', NULL, '전라남도 영암군', NULL, '2023-02-10 11:07:14', '2025-07-24 17:56:44', '상시신청', NULL, NULL, '방문신청', NULL, '○ 국산김치를 사용해 김치협회로부터 지정 받은 외식업소에 대해 식자재 구입비 지원
-- ○ 김치재료는 도내에서 생산된 농수산물, 김치완성품은 도내 소재업체 생산물을 남도장터를 통해 구매한 경우 지원', '○ 지원대상
--  - 식품위생법 시행령에 따라 음식류를 조리ㆍ판매하는 휴게음식점, 일반음식점 중 국산김치 자율표시위원회로부터 국산김치 사용지정을 받은 업소');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('496000000109', '11', '46320', '인구경제과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/496000000109', '소상공인 카드수수료 지원', '소상공인에게 카드수수료 지원', '고용·창업', NULL, '전라남도 함평군', NULL, '2021-09-23 12:34:56', '2025-02-24 13:29:08', '2024.6. ~ 예산소진시 ', NULL, NULL, '방문신청', NULL, '○ 전년도 카드 매출액의 0.8% 지원(최대 40만원)', '○ 함평군 소상공인');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('497000000128', '11', '46330', '일자리경제과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/497000000128', '2025년 영광군 소상공인 신용보증수수료 지원', '신용보증수수료 지원', '생활안정', NULL, '전라남도 영광군', NULL, '2022-09-26 10:50:36', '2025-05-13 11:41:43', '2025. 5. 1. ~ 2025. 11. 28.', NULL, NULL, '방문신청', NULL, '영광군 소상공인 신용보증수수료 최대 0.8%(1년분) 지원', '연매출 10억 원 이하 관내 소상공인 중 전남신용보증재단을 통해 자금 대출 받은 자');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('497000000129', '20', '46330', '일자리경제과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/497000000129', '노란우산공제 희망장려금 지원', '연매출 3억원 이하 관내 소상공인 중 노란우산공제 신규 가입자들에게 추가적립2만원(최대1년', '고용·창업', NULL, '전라남도 영광군', NULL, '2022-09-26 10:57:06', '2025-05-08 13:26:37', '상시신청', NULL, NULL, '방문신청', NULL, '노란우산공제 희망장려금 지원
-- - 기간 : 2025. 1.~12.
-- - 대상: 연매출 3억원 이하 관내 소상공인 중 노란우산공제 신규 가입자
-- - 지원내용: 장려금 2만원 추가 적립', '연매출 3억원 이하 관내 소상공인 중 노란우산공제 신규 가입자');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('497000000137', '13', '46330', '일자리경제과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/497000000137', '2025년 디지털 소상공인 1만 양성', '스마트기술 기기 도입 시 최대 1백만 원 한도 지원', '생활안정', NULL, '전라남도 영광군', NULL, '2023-08-24 15:56:10', '2025-07-14 16:43:00', '2025. 5. 13.(화) ∼ 예산소진 시 까지', NULL, NULL, '방문신청', NULL, '스마트기술 기기 도입 시 최대 1백만 원 한도 지원
-- ※ 세부내용: 영광군 대표누리집 공고문 참고', '「소상공인 보호 및 지원에 관한 법률 」에 따른 소상공인으로, 신청일 기준 정상적으로 영업 중인 연매출액 10억원 이하 영광군 관내 사업자
-- ※ 지원규모: 10개소(선착순)');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('502000000237', '10', '47', '경제노동정책과', '개인||소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/502000000237', '경북 소상공인 출산장려 아이보듬 사업', '출산하는 소상공인의 사업장 내 종사자 인건비 지원
-- (최대 6개월간 매달 200만원)', '생활안정', NULL, '경상북도 포항시', NULL, '2024-12-18 10:38:47', '2025-09-01 17:39:13', '상시신청', NULL, NULL, '직접입력', NULL, '출산하는 소상공인의 사업장 내 종사자 인건비 지원
-- (최대 6개월간 매달 200만원)', '포항시에서 출산하는 소상공인(배우자 포함) 대체인력(보조인력 포함 지원)
-- - 지원방법 : 온라인 접수 시행(*경상북도 모이소앱)');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('508000000690', '3', '47240', '노동복지과', '개인||소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/508000000690', '구미시 근로취약계층 유급병가 지원', '입원, 입원연계 외래진료, 공단 일반건강검진 시 생계비 지원', '보건·의료', NULL, '경상북도 구미시', NULL, '2024-02-06 13:22:26', '2025-07-25 14:05:37', '2025.1.1.~2025.12.31.', '2025-12-31', NULL, '방문신청', NULL, '○ 근로취약계층 생계비 지원
-- - 입원, 입원연계 외래진료, 공단 일반건강검진 대상자
-- - 2025년 최저시급 기준 1일 80,240원 최대 14일 1,123,360원 카드형 구미사랑상품권 지원', '○ 관내 주소를 둔 건강보험 지역가입자인 근로소득자 및 자영업자 중 아래 요건을 모두 충족하는 자
--   - 건강보험 지역가입자인 근로소득자 및 자영업자(입원 등 발생 전 3개월 간 근로소득 24일 이상 또는 개인사업 45일 이상 유지)
--   - 입원 등 발생 1개월 전부터 심사완료일까지 주민등록상 구미시 거주자
--   - 신청인과 가구 소득의 합계가 2025년 기준 중위소득 100% 이하이면서 재산 합계가 2억 3천만원 이하');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('510000000132', '11', '47260', '일자리노사과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/510000000132', '소상공인 정책자금 이차보전', '○ 소상공인시장진흥공단 정책자금 대출에 대한 이자 2.5% 2년 지원
-- ', '생활안정', NULL, '경상북도 영천시', NULL, '2022-02-08 18:42:21', '2025-07-23 11:37:32', '상반기(7월), 하반기(12월) 신청', NULL, NULL, '방문신청', NULL, '○ 소상공인시장진흥공단 정책자금 대출에 대한 이자 2.5% 2년 지원', '(모두충족)
--   ○ 2019. 1. 1.부터 소상공인시장진흥공단을 통하여 대출이 실행된 정책자금(대리대출)
--   ○ 융자를 받은 날부터 계속하여 영천시에 사업장과 주민등록을 둔 자
--   ○ 영천시 관내 제1금융권에서 융자를 받은 자');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('516000000124', '1', '47330', '유통정책과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/516000000124', '축산물판매업소 육절기, 골절기 구입비용 지원', '식육판매업소 및 식육즉석판매가공업소에 육절기 및 골절기 구입비용 지원', '고용·창업', NULL, '경상북도 청송군', NULL, '2021-09-23 12:34:56', '2025-07-24 11:51:11', '상시신청', NULL, NULL, '방문신청', NULL, '식육판매업소 및 식육즉석판매가공업소에 육절기 및 골절기 구입비용 지원', '○ 식육판매업소 및 식육즉석판매가공업');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('547000000152', '5', '48380', '수도사업소', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/547000000152', '상수도요금 감면(소상공인)', '소상공인 수도요금 감면', '문화·환경', NULL, '경상남도 거창군', NULL, '2022-12-01 22:14:12', '2025-07-11 10:03:37', '상시신청', NULL, NULL, '방문신청', NULL, '○ 상수도 사용료 감면(3개월간 50%)
-- - 「재난 및 안전관리 기본법」 제38조제2항에 따른 재난 위기경보 발령 시에「소상공인 보호 및 지원에 관한 법률」 제2조에 따른 소상공인의 군 소재 사업장', '거창군 소재 사업장을 둔 소상공인');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('547000000153', '5', '48380', '수도사업소', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/547000000153', '하수도요금 감면(소상공인)', '소상공인 하수도 사용료 감면', '문화·환경', NULL, '경상남도 거창군', NULL, '2022-12-01 22:17:21', '2025-07-11 10:04:28', '상시신청', NULL, NULL, '방문신청', NULL, '○ 하수도 사용료 감면(3개월간 50%)
-- - 「재난 및 안전관리 기본법」 제38조제2항에 따른 재난 위기경보 발령 시에「소상공인 보호 및 지원에 관한 법률」 제2조에 따른 소상공인의 군 소재 사업장', '거창군 소재 사업장을 둔 소상공인');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('559000000127', '1', '41690', '농업정책과', '개인||소상공인||법인/시설/단체', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/559000000127', '농산물 임가공 및 포장재, 디자인 지원', '판매업 허가를 얻은 농업(법)인에게 임가공, 포장재 구입 등 비용 지원', '농림축산어업', NULL, '경기도 양주시', NULL, '2021-09-23 12:34:56', '2025-07-17 09:04:45', '1분기 중 공고 참고', NULL, NULL, '방문신청', NULL, '○ 농산물 가공시설이 없는 소규모 농가에 임가공비 지원
-- ○ 포장재 및 디자인 개발비 지원', '○ 아래에 모두 해당하는 관내 거주 농업(법)인
--  - 「농어업경영체육성 및 지원에관한법률」 제4조에 농업경영정보를 등록한 농업인(법인) 또는 단체
--  - 사업자 및 판매업 허가(통신판매업, 즉석가공 등)를 득한 농업인 및 농업법인
--    (우선순위) 1순위: 신청 분야가 디자인 개발 또는 임가공비 지원인 농가
--                      2순위: 소규모 농가(경지면적 5,000㎡ 이하)3순위: G마크 또는 GAP 인증을 받은 농가
--                      3순위: G마크 또는 GAP 인증을 받은 농가
--     ※ 신청인원이 많을 경우 경지면적이 작은 순으로 선정
--     ※ 공고일 기준 2개년 이내 동일 사업 취소(포기)자는 선정 대상 후순위로 함');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('560000000139', '20', '41700', '일자리경제과', '소상공인||법인/시설/단체', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/560000000139', '포천 청년 창업자 임차료 지원', '포천시의 19~49세 청년 창업자에게 심사를 거쳐 사업장 임차료의50%를 8개월간 지원', '고용·창업', NULL, '경기도 포천시', NULL, '2024-12-19 10:16:48', '2025-08-28 14:35:19', '(1차)2025년 2월, (2차) 2025년 4월', NULL, NULL, '기타 온라인신청||방문신청', NULL, '공고일 기준 19~49세 청년 창업자(소상공인) 중 아래 조건을 모두 만족하는 자에게 심사를 거쳐 사업장 임차료의 50%를 8개월 간 지원(월 최대 50만원)
--    ① 공고일 기준 주민등록상 포천시 거주 및 관내 사업장 운영(사업 기간에도 포천시 주민등록 및 사업장 유지)
--    ② 공고일 기준 사업자 등록일로부터 3년 이내 창업자', '공고일 기준 19~49세 청년 창업자(소상공인) 중 아래 조건을 모두 만족하는 자
--  ① 공고일 기준 주민등록상 포천시 거주 및 관내 사업장 운영(사업 기간에도 포천시 주민등록 및 사업장 유지)
--  ② 공고일 기준 사업자 등록일로부터 3년 이내 창업자');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('569000000371', '20', '1', '소상공인과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/569000000371', '노란우산공제 희망장려금 지원', '소상공인에게 희망장려금 지원', '고용·창업', NULL, '세종특별자치시', NULL, '2021-09-23 12:34:56', '2025-07-28 09:22:40', '상시신청', NULL, NULL, '기타 온라인신청||방문신청', NULL, '○ 노란우산공제 신규가입자 중 연매출 3억원 이하 소상공인에게 가입일로부터 매월 2만원씩 지원(1년간 24만원)', '○ 노란우산공제 신규가입자 중 연매출 3억원 이하 소상공인');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('627000000160', '20', '27', '민생경제과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/627000000160', '노란우산공제 희망장려금', '연매출 3억원 이하 지역 소상공인 노란우산공제 신규가입 시 월 2만원 씩 1년간 지원', '생활안정', NULL, '대구광역시', NULL, '2022-05-30 16:40:32', '2025-07-21 10:18:55', '상시신청', NULL, NULL, '기타 온라인신청||방문신청', NULL, '○ 목적
--   - 지역 영세 소상공인의 노란우산공제 가입을 촉진하여 노령, 폐업 등 생계위협에 대비해 생활안정 및 사업재기의 기회 제공
--
-- ○ 지원 대상
--   - 지역 소재 연 매출 3억원 이하 소상공인 중 노란우산공제 신규가입자
--
--  ○ 지원 내용
--   - 노란우산공제 가입일로부터 매월 2만원 씩 1년 간 공제부금에 추가 적립(예산 소진 시까지)', '○ 대구광역시 소재 연매출 3억원 이하 소상공인
--
-- ○ 장려금 지원기간 중 사업장이 대구 이외의 타 지역으로 이전하거나, 폐업 등 공제금 지급 사유가 발생하는 경우 해당 사유 발생일까지만 지원');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('629000000193', '11', '29', '경제정책과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/629000000193', '1인 자영업자 사회보험료 지원', '1인 자영업자의 고용·산재보험료 지원을 통한 사회보험 가입 활성화 및 사회안전망 강화', '고용·창업', NULL, '광주광역시', NULL, '2021-11-02 18:13:37', '2025-07-31 16:28:28', '2025. 2. ~ (예산소진시 마감)', NULL, NULL, '기타 온라인신청', NULL, '❍ 지원대상 : 1인자영업자 (고용∙산재보험 旣 가입자 및 신규가입자)
-- ❍ 지원내용 : 고용보험료 납부액의 20%,  산재보험료 납부액의 50%
-- ❍ 신청방법
--  - 신청기간 : ‘25. 2. ~ 예산 소진시까지
--  - 신청장소 :  광주기업지원시스템 / https://www.gjbizinfo.or.kr/
--  - 구비서류 :  지원신청서, 사업자등록증 등
-- ❍ 지원절차 : 고용․산재보험료 납입후 지원신청(1회)
-- ❍ 지급시기 : 자료 확인후 월별 지급', '고용보험 또는 산재보험에 기(신규) 가입한 광주 소재 1인 자영업자
--  (공동사업자의 경우 대표 1인만 지원)');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('629000000805', '20', '29', '관리담당관', '개인||가구||소상공인||법인/시설/단체', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/629000000805', '중소사업장 가족친화경영 지원', '가족친화경영 프로그램 도입 및 지원', '고용·창업', NULL, '광주광역시', NULL, '2025-07-03 13:14:03', '2025-07-25 16:40:48', '공고 기간내 신청가능', NULL, NULL, '직접입력', NULL, 'ㅇ가족친화문화조성프로그램 운영비 지원
-- ㅇ가족친화데이 ‘빛나는 날’ 필수운영(생일, 기념일등 조기퇴근 또는 특별휴가)
-- ㅇ가족친화직장문화조성 프로그램(자유 제안) 동시운영', '가족친화경영에 모범적인 관내 300인미만 중소사업장');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('630000000162', '20', '30', '소상공정책과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/630000000162', '노란우산공제 정액장려금 지원', '○ 매월 공제부금 납입 시마다 3만원씩 1년간 적립(최대 36만원)', '생활안정', NULL, '대전광역시', NULL, '2022-07-05 11:11:46', '2025-07-30 16:53:16', '연중(예산소진 시까지)', NULL, NULL, '방문신청', NULL, '○ 매월 공제부금 납입 시마다 3만원씩 1년간 적립(최대 36만원)', '○ 연매출 3억원 이하 대전 소재 소상공인 중 공제 신규가입자');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('631000000137', '20', '31', '기업지원과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/631000000137', '노란우산공제 희망장려금 지원', '연매출액 3억원 이하 소상공인에 대해 매월 공제부금 납입시마다 1만원씩 장려금 적립 지원', '생활안정', NULL, '울산광역시', NULL, '2022-06-02 11:18:18', '2025-07-24 08:55:22', '상시신청', NULL, NULL, '방문신청', NULL, '연매출액 3억원 이하 소상공인에 대해 매월 공제부금 납입시마다 1만원씩 장려금 적립 지원', '연매출액 3억원 이하 신규․무등록* 소상공인');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('631000000138', '5', '31', '기업지원과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/631000000138', '소상공인 경영환경개선 지원', '점포 환경개선, 홍보 및 광고, 위생 및 안전관리 비용 중 일정액 지원', '생활안정', NULL, '울산광역시', NULL, '2022-06-02 11:36:14', '2025-07-24 08:53:28', '상반기, 하반기 공고문에 따름', NULL, NULL, '기타 온라인신청||방문신청', NULL, '점포 환경개선, 홍보 및 광고, 위생 및 안전관리 비용 중 일정액 지원', '소상공인(창업 6개월 이상 소상공인)');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('641000000184', '20', '41', '소상공인과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/641000000184', '영세 소상공인 노란우산 가입지원', '도내 연매출 3억원 이하 소상공인 신규가입 시 월1만원(12개월) 장려금 지원', '생활안정', NULL, '경기도', NULL, '2022-05-31 09:24:28', '2025-07-28 10:26:51', '예산 소진 전까지 상시 신청', NULL, NULL, '기타 온라인신청||방문신청', NULL, '도내 연매출 3억원 이하 영세 소상공인 노란우산 신규가입 지원
-- - 당해 신규가입 후 장려금 지원 신청
-- - 공제부금 납입시 월 1만원, 최대 12개월 지원', '도내 연매출 3억원 이하 소상공인');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('641000000185', '5', '41', '소상공인과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/641000000185', '소상공인 경영환경개선사업', '점포환경개선,시스템개선,간판 및 입식테이블 교체, 판로개척 지원
-- ', '생활안정', NULL, '경기도', NULL, '2022-05-31 09:45:45', '2025-07-28 09:39:17', '연초', NULL, NULL, '기타 온라인신청||방문신청', NULL, '도내 창업 3년 이상 소상공인의 경영환경개선 비용 일부 지원
-- - 점포환경개선(최대 3백만원), 시스템 개선(최대 2백만원), 간판 및 입식 테이블 교체(최대 2백만원), 판로개척(최대200만원)', '도내 창업 3년 이상 소상공인
-- ※ 최근 3년 이내 경기도와 타 시·군 동일사업 및 유사 지원사업으로 지원받은 소상공인 제외');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('641000000186', '20', '41', '소상공인과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/641000000186', '소상공인 사업정리 지원', '도내 폐업 및 폐업예정 소상공인 대상 지원', '생활안정', NULL, '경기도', NULL, '2022-05-31 10:50:57', '2025-07-28 09:40:03', '상시신청', NULL, NULL, '기타 온라인신청||방문신청', NULL, '도내 폐업 및 폐업예정 소상공인 대상 지원
-- - 사업정리 컨설팅 제공
-- - 사업정리 지원금(재기장려금 또는 점포철거비)', '도내  폐업 및 폐업 예정 소상공인');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('642000000679', '1', '1', '동물방역과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/642000000679', '축산물 작업장 위생설비 개선 지원', '축산물작업장에 장비, 시설 지원', '농림축산어업', NULL, '강원특별자치도', NULL, '2021-09-23 12:34:56', '2025-07-24 18:02:04', '상시신청', NULL, NULL, '방문신청', NULL, '○ 도축장·축산물가공장 및 열세 축산물판매업소의 장비, 시설 지원(자부담 50%)
--  - 지원단가
--   ㆍ도축장·가공장 위생설비 개선 : (도축장) 5억원/개소, (가공장) 5,000만원/개소
--   ㆍ축산물판매업소 위생장비 지원 : (축산물판매업소) 400만원/개소', '○ 도내 허가‧등록된 축산물작업장(도축장, 축산물가공장, 식육포장처리장, 축산물판매장)
--  - 위생‧처리시설 노후 도축장‧가공장 우선 지원
--  - 위생설비 개선이 필요한 도축장‧가공장 우선 지원
--  - 영세·노령 축산물 판매업소 우선 지원');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('642000000735', '20', '1', '기업지원과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/642000000735', '노란우산공제 신규가입 장려금 지원', '소기업소상공인 생활안정 및 재기기반 마련 위해 노란우산 가입자가 신청 시 월1만원 지원', '생활안정', NULL, '강원특별자치도', NULL, '2022-05-30 10:28:48', '2025-07-21 08:53:41', '2025.1.1. ~ 2025. 12.31.', NULL, NULL, '방문신청', NULL, '○ 지원내용
--   1. (사업기간) ’24. 1. 1.~12. 31.(자금소진시까지)
--   2. (지원대상) 도내 소기업·소상공인     ※ 신규가입자+기존지원자
--   3. (지원금액) 월 1만원(최대 12개월)
--   4. (수행기관) 중소기업중앙회 강원지역본부', '○ 도내 소기업, 소상공인 중 노란우산 공제 신규 가입자, 연매출 3억원 이하');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('643000000144', '2', '43', '소상공인정책과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/643000000144', '소상공인공제(노란우산공제) 가입(희망)장려금', '소상공인공제(노란우산공제) 가입(희망)장려금 지원', '생활안정', NULL, '충청북도', NULL, '2022-06-07 11:17:54', '2025-07-29 13:24:30', '상시신청', NULL, NULL, '방문신청||직접입력', NULL, '노란우산공제 신규가입 소상공인 1년간 월1만원 희망장려금 지급', '○ 연매출액 3억원 이하 소상공인
--  - 광업, 제조업, 건설업, 운수업 : 상시근로자 10인 미만
--  - 그외 업종(도소매, 음식업 등) : 상시근로자 5인 미만');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('644000000239', '20', '44', '경제정책과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/644000000239', '노란우산 공제 가입 장려금 지원', '신규가입 도내 소상공인(연매출액 3억 이하) 월 1만원(최대 1년) → 총 12만원 지원 ', '생활안정', NULL, '충청남도', NULL, '2022-05-26 15:46:17', '2025-07-23 15:00:59', '상시신청', NULL, NULL, '방문신청||직접입력', NULL, '노란우산공제 신규가입자 중 연매출 3억원 이하인 사업장이 충청남도에 소재한 소상공인', '노란우산공제 신규가입자 중 연매출 3억원 이하인 사업장이 충청남도에 소재한 소상공인');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('645000000124', '11', '1', '일자리민생경제과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/645000000124', '영세소상공인 카드수수료 지원', '영세 소상공인에게 카드수수료 지원', '고용·창업', NULL, '전북특별자치도', NULL, '2021-09-23 12:34:56', '2025-07-30 09:53:38', '시군 공고 후 상시신청', NULL, NULL, '방문신청||직접입력', NULL, '○ 전북특별자치도내 연매출 3억원 이하의 소상공인 카드매출액의 0.5% 지원(최대 30만원)
--  - 신청방법 등 문의사항은 시군을 통해 안내받으실 수 있습니다.', '○ 전북특별자치도내 연매출 3억원 이하의 소상공인
--  카드수수료 0.5%(최대 30만원 지원)');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('647000000165', '9', '47', '민생경제과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/647000000165', '소상공인 노란우산공제 희망장려금 지원', ' 소상공인공제 노란우산 희망장려금 지원', '생활안정', NULL, '경상북도', NULL, '2022-06-08 15:52:24', '2025-08-01 11:11:52', '상시신청', NULL, NULL, '기타 온라인신청||방문신청', NULL, '○ 소상공인공제 노란우산 희망장려금 지원
--   - 매월 공제부금 납임시마다 2만원씩 장려금 지원
--   - 노란우산공제 가입일로부터 1년간 지원(최대12회)
--  - 단, 장려금 지원기간 중 사업장이 경북 이외의 타 지역으로 이전하거나, 폐업 등 공제금 지급사유가 발생하는 경우 해당사유 발생일 까지만 지원
-- ※ 노란우산공제
--   (제도) 07년 9월 도입된 소기업 소상공인 대상 공적 공제제도
--   (납입부금) 월납 기준 5만원 ~ 100만원 *별도 만기 없음
--   (주요혜택) 복리이율, 연 최대 500만원 소득공제, 압류금지
--   (공제금 지급) 지급사유(폐업, 노령, 사믕 등) 발생 시 지급', '○ 경상북도 소재 연매출액 3억원 이하 소상공인
--    * 여신전문금융법 시행령 제6조의13 준용
-- ○ 일반유흥주점업, 무도유흥주점업, 단란주점, 무도장 운영업, 도박장 운영업, 의료행위 아닌 안마업을 제외한 전 업종');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('648000001087', '11', '48', '소상공인정책과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/648000001087', '경상남도 1인 자영업자 고용 및 산재보험료 지원', '경남도내 1인 자영업자 대상 고용보험료 및 산재보험료 지원', '생활안정', NULL, '경상남도', NULL, '2022-06-07 14:51:06', '2025-09-10 09:24:32', '2025. 2.~예산소진 시까지', NULL, NULL, '기타 온라인신청', NULL, '- 고용보험료 지원 : 납부한 월 고용보험료의 전 등급 20%, 3년간(분기별 환급)
-- - 산재보험료 지원 : 납부한 월 산재보험료의 등급별* 30~50%, 3년간(분기별 환급)
--   *1~4등급 : 50%, 5~8등급 : 40%, 9~12등급 : 30%', '자영업자 고용보험 및 중소기업사업주 산재보험에 가입한 경남도내 1인 자영업자');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('648000001090', '5', '48', '소상공인정책과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/648000001090', '소상공인 소규모 경영환경 개선지원(사업장별 시설개선비 최대 200만원 지원)', '사업장별 시설개선비 최대 200만원 지원(공급가액의 70% 이내)', '생활안정', NULL, '경상남도', NULL, '2022-06-07 15:14:42', '2025-07-17 09:46:47', '접수기관 별 상이', NULL, NULL, '방문신청', NULL, ' 0 지원규모 : 사업장별 시설개선비 최대 200만원 지원(공급가액의 70% 이내)
--       - (환경개선) 인테리어(내·외부), 간판 교체, 입식테이블, 화장실 개선, 안전시스템 등
--       * (지원제외) 컴퓨터, 노트북, 텔레비전, 가스레인지, 주방기구, 냉장고, 에어컨(시스템형 가능) 등 자산성 동산, 건물 공용화장실', '도내 공고일 기준 6개월 이상 영업 중인 소상공인');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('648000001091', '20', '48', '소상공인정책과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/648000001091', '노란우산공제 희망장려금 지원', '○ 노란우산공제 신규가입자 중 연매출 3억 원 이하 소상공인에게 월 2만원, 1년간 지원', '생활안정', NULL, '경상남도', NULL, '2022-06-07 15:15:36', '2025-07-17 09:46:10', '노란우산공제 신규가입 후 30일이내 신청(신청서 및 매출액증빙서류 제출완료) ', NULL, NULL, '기타 온라인신청||방문신청', NULL, '○ 노란우산공제 신규가입자 중 연매출 3억 원 이하 소상공인에게 월 2만원, 가입일로부터 1년간(최대 12회) 지원', '○ 도내 연매출 3억 원 이하인 노란우산공제 신규가입 소상공인');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('648000001139', '20', '48', '소상공인정책과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/648000001139', '소상공인 디지털 인프라 지원(사업장별 디지털기기 구입비 최대 200만원 지원)', '사업장별 디지털기기 구입비 최대 200만원 지원(공급가액의 70% 이내)', '생활안정', NULL, '경상남도', NULL, '2025-07-02 08:13:10', '2025-07-17 09:45:31', '접수기관 별 상이', NULL, NULL, '방문신청', NULL, ' 0 지원규모 : 사업장별 디지털기기 구입비 최대 200만원 지원(공급가액의 70% 이내)
--       - (지원항목) 스마트오더(키오스크, 테이블오더, 스마트오더, POS 기기 등), VR·AR(가상 피팅, 스마트미러, 체형분석기 등),
--                            3D(3D 풋 스캐너, 3D 프린터, 3D 경화 및 세척기 등), AI(무인판매기, 스마트밴딩머신, 서빙로봇, 조리로봇, 팔레타이징 등) 등', '도내 공고일 기준 6개월 이상 영업 중인 소상공인');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('650000000312', '17', '50', '장애인복지과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/650000000312', '장애인 고용촉진장려금 지원', '장애인을 고용한 사업체에 고용촉진장려금 지원', '고용·창업', NULL, '제주특별자치도', NULL, '2021-09-23 12:34:56', '2025-07-28 15:54:56', '  - 분기별(1월, 4월, 7월, 10월) ', NULL, NULL, '방문신청', NULL, '○ 안정적인 일자리 제공 및 고용유지를 통해 장애인의 자랩생활 기반을 강화하고 최저임금인상에 따른 영세업체의 부담비용 경감을 위하여 장애인을 고용한 사업주에게 장애인고용촉진장려금 지원', '○ 지원대상
-- -  근로기준법에 따른 상시근로자 수가 5인 이상 50인 미만 도내 장애인을 고용한 사업체    ※ 사업주는 상시근로자 수에서 제외
-- -  장애인표준사업장으로서 50인 이상인 도내 사업주
--     ※ 장애인표준사업장 :「장애인고용촉진 및 직업재활법 시행규칙」제3조에 따른 사업장
--
-- ○  지원 제외
-- -  비영리법인, 관공서, 국가·지자체로부터 운영비 지원을 받고 있는 사업체 등 제외
-- -  상시근로자가 50인 이상 사업체(장애인표준사업장은 예외)
--     ※ 장애인고용촉진장려금은 상시근로자가 50인 이상이 되는 달부터 지원 제외
--
-- ○  지원단가
-- - 중증(여성 65만원, 남성 55만원), 경증(여성 45만원, 남성 35만원)');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('650000000317', '20', '50', '노동일자리과', '소상공인||법인/시설/단체', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/650000000317', '청년 취업지원 희망프로젝트', '각 사업에 참여하는 청년을 정규직 채용시 인건비 일부 지원', '고용·창업', NULL, '제주특별자치도', NULL, '2021-09-23 12:34:56', '2025-07-24 18:00:42', '청년취업지원희망프로젝트 사업참여신청접수-분기별(1월, 4월, 7월,10월)11일~20일', NULL, NULL, '기타 온라인신청||방문신청', NULL, '○ 청년취업지원희망프로젝트 : 15세~39세 이하 미취업청년을 채용한 도내 중소기업(5인 미만 고용)에 1인당 월 50~70만원 최대 2년간 지원', '○ 청년취업지원희망프로젝트 : 15세~39세이하 미취업청년을 채용한 도내 중소기업(5인 미만 고용)');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('650000000330', '11', '50', '노동일자리과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/650000000330', '일자리창출 소상공인 사회보험료 지원', '정부 두루누리 사회보험료 지원 사업 참여하고 있는 근로자 10인 미만기업 사회보험료 지원 ', '생활안정', NULL, '제주특별자치도', NULL, '2022-08-16 20:07:52', '2025-07-24 18:15:10', '상시신청', NULL, NULL, '기타 온라인신청||방문신청||직접입력', NULL, '❍ 사업기간 : 2024. 1월 ~ 12월
-- ❍ 사 업 비 : 305백만원(사회보장적수혜금)
-- ❍ 지원대상 : 정부 두루누리 사회보험료 지원 사업에 참여하고 있는 제주특별자치도 내 근로자 10인 미만 기업
-- ❍ 지원내용 : 신규 채용한 근로자(고용보험 취득일 기준)에 대한 두루누리 사회보험 지원금 외 사업주 부담 사회보험료 전액 지원
-- ❍ 지원기간 : 최대 3년(정부 두루누리사업 지원기간에 연동)', '정부 두루누리 사회보험료 지원사업에 참여하고 있는 제주특별자치도 소재 근로자 10인 미만 기업');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('654000000010', '5', '1', '동물방역과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/654000000010', '가축 살처분 등 비용 지원', '제1종 가축전염병 발생에 따른 가축 등 살처분 및 처리 등에 소요되는 비용지원', '농림축산어업', NULL, '전북특별자치도', NULL, '2025-07-03 16:18:57', '2025-07-23 15:19:24', '신청없음', NULL, NULL, '신청불필요', NULL, '제1종 가축전염병 발생에 따른 가축 등 살처분 및 처리 등에 소요되는 비용지원', '가축 살처분 처리업체');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('999000000070', '20', '1', '소상공인정책과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/999000000070', '장애인 창업아이템 경진대회', '우수창업 아이템을 가진 장애인 예비창업자와 장애인기업에게 상금지급', '고용·창업', NULL, '중소벤처기업부', NULL, '2020-12-17 14:26:13', '2025-08-21 16:19:00', '2월', NULL, NULL, '방문신청', NULL, '○ 우수 창업아이템 발굴을 통한 정부포상 및 상금지급(대상 10백만원, 최우수상 5백만원 등 총 11건, 32백만원)', '○ 장애인 예비창업자, 7년 미만 장애인기업');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('999000000071', '20', '1', '소상공인정책과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/999000000071', '장애인맞춤형사업화지원', '장애인 예비창업자와 장애인기업을 위해 창업초기비용 지원(최대 20백만원)', '고용·창업', NULL, '중소벤처기업부', NULL, '2020-12-17 14:26:13', '2025-08-21 16:21:48', '3월~4월', NULL, NULL, '방문신청', NULL, '○ 시설, 인테리어, 마케팅 등 창업초기비용 지원(최대 20백만원)', '○ 장애인 예비창업자, 업종전환 희망 장애인기업');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('B41000200004', '4', '1', '수요관리실', '개인||가구||소상공인||법인/시설/단체', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/B41000200004', '프리미엄 전동기 지원', '한국전력공사(한전) 고객이 고효율 기기(프리미엄 전동기) 교체 시 지원금 지급', '생활안정', NULL, '한국전력공사', NULL, '2022-07-15 00:00:00', '2025-08-20 10:25:35', '상시신청', NULL, NULL, '기타 온라인신청||방문신청||직접입력', NULL, '에너지 효율향상 및 온실가스 감축을 위해 고객이 고효율 기기 교체 시 지원금 지급', '○ 고효율(IE2)이하 저압 3상유도전동기를 프리미엄전동기(IE3)로 교체하여 총 절감전력이 0.2kW이상인 고객 또는 ESCO 등 사업자
--  - 한국에너지공단에 등록된 프리미엄등급 저압 3상 유도전동기
--
-- ○  전통시장 및 상점가 육성을 위한 특별법 의거 전통시장 내 점포를 운영하는 고객은 총 절감전력 합계 0.02kW 이상 시 지원');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('B41000200005', '4', '1', '수요관리실', '개인||소상공인||법인/시설/단체', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/B41000200005', '고효율 터보압축기 지원', '한국전력공사(한전) 고객이 고효율 기기(고효율 터보압축기) 교체 시 지원금 지급', '생활안정', NULL, '한국전력공사', NULL, '2022-07-15 00:00:00', '2025-08-20 10:34:43', '상시신청', NULL, NULL, '기타 온라인신청||방문신청||직접입력', NULL, '에너지 효율향상 및 온실가스 감축을 위해 고객이 고효율 기기 교체 시 지원금 지급', '○ 기존 루츠블로어, 스크루블로어를 고효율 터보압축기로 교체하는 고객
--  - 한국에너지공단에 등록된 고효율 터보압축기');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('B41000200007', '4', '1', '수요관리실', '개인||가구||소상공인||법인/시설/단체', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/B41000200007', '고효율 냉동기 지원', '한국전력공사(한전) 고객이 고효율 기기(고효율 냉동기) 교체 시 지원금 지급', '생활안정', NULL, '한국전력공사', NULL, '2022-07-15 00:00:00', '2025-08-20 10:27:25', '상시신청', NULL, NULL, '기타 온라인신청||방문신청||직접입력', NULL, '에너지 효율향상 및 온실가스 감축을 위해 고객이 고효율 기기 교체 시 지원금 지급', '○ 일반 냉동기를 효율기준 충족하는 원심식 또는 고효율 스크루 냉동기로 교체하는 고객
--  - 한국에너지공단에 등록된 300USRT 이하 COP 5.96 이상, 301~2,000USRT COP 6.39 이상의 원심식 냉동기 또는 500USRT 이하 고효율 스크루 냉동기');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('B41000200008', '4', '1', '수요관리실', '개인||가구||소상공인||법인/시설/단체', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/B41000200008', '고효율LED조명 지원', '고효율 기기(고효율 LED)교체 시 지원금 지급', '생활안정', NULL, '한국전력공사', NULL, '2022-07-15 00:00:00', '2025-08-20 10:32:46', '상시신청', NULL, NULL, '기타 온라인신청||방문신청||직접입력', NULL, '에너지 효율향상 및 온실가스 감축을 위해 고객이 고효율 기기 교체 시 지원금 지급', '○ 기존 조명기기(형광등, 메탈할라이드등, LED 등)를 효율 1등급 또는 고효율인증 LED로 교체 시 절감전력 합계가 0.4kW  이상인 고객, 사업자 등
--
-- ○ 농사용전력을 사용하며, 백열등을 고효율 또는 1등급 LED로 교체 시 절감전력 합계가 10kW 이상인 고객, 사업자 등
--  - 농사용 전력을 사용하는 고객의 기존 조명기기 중 형광등, LED, 백열등을 제외한 조명기기의 지원신청은 일시 중단
-- ○ 전통시장 내 점포를 운영하는 고객으로 총 절감전력합계 0.1kW 이상 시 지원
--
-- - (지원기기) 한국에너지공단에 등록된 고효율 또는 효율1등급 LED');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('B41000200009', '4', '1', '수요관리실', '개인||가구||소상공인||법인/시설/단체', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/B41000200009', '심야 히트펌프보일러 지원', '고효율 기기(심야 히트펌프 보일러) 교체 시 지원금 지급', '생활안정', NULL, '한국전력공사', NULL, '2022-07-15 00:00:00', '2025-08-20 10:30:08', '상시신청', NULL, NULL, '방문신청||직접입력', NULL, '에너지 효율향상 및 온실가스 감축을 위해 고객이 고효율 기기 교체 시 지원금 지급', '○ 기존 심야전기보일러를 히트펌프보일러로 교체 또는 신설하는 고객
--  - 5~15kW 히트펌프보일러(한전 인정제품)');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('B41000200010', '20', '1', '수요관리실', '개인||소상공인||법인/시설/단체', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/B41000200010', '회생제동장치 지원', '한국전력공사(한전) 고객이 고효율 기기(회생제동장치) 교체 시 지원금 지급', '생활안정', NULL, '한국전력공사', NULL, '2022-07-15 00:00:00', '2025-08-20 10:35:46', '상시신청', NULL, NULL, '기타 온라인신청||방문신청||직접입력', NULL, '에너지 효율향상 및 온실가스 감축을 위해 고객이 고효율 기기 교체 시 지원금 지급', '○ 엘리베이터의 기존 저항제동장치를 회생제동장치 또는 회생제동 기능이 적용된 제어반으로 교체하는 고객
--  - (지원기기) 한전 또는 한국승강기안전공단 승인 제품');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('B41000200011', '20', '1', '수요관리실', '개인||가구||소상공인||법인/시설/단체', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/B41000200011', '인버터제어 공기압축기 지원', '고효율 기기(인버터제어 공기압축기) 교체 시 지원금 지급', '생활안정', NULL, '한국전력공사', NULL, '2023-04-24 13:35:10', '2025-08-20 10:22:59', '상시신청', NULL, NULL, '기타 온라인신청||방문신청||직접입력', NULL, '에너지 효율향상 및 온실가스 감축을 위해 고객이 고효율 기기 교체 시 지원금 지급', '○ 정속형 공기압축기를 인버터제어형 공기압축기로 교체하는 고객, 사업자 등
--  - 인버터제어형 공기압축기 동력이 정속형 공기압축기 동력과 같거나 작은 경우 지원');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('B41000200012', '4', '1', '수요관리실', '개인||가구||소상공인||법인/시설/단체', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/B41000200012', '고효율 변압기 지원', '고효율 기기(고효율 변압기) 교체 시 지원금 지급', '생활안정', NULL, '한국전력공사', NULL, '2023-04-24 13:46:51', '2025-08-20 10:33:47', '상시신청', NULL, NULL, '기타 온라인신청||방문신청||직접입력', NULL, '에너지 효율향상 및 온실가스 감축을 위해 고객이 고효율 기기 교체 시 지원금 지급', '○ 고압고객용 일반 변압기를 1차 정격전압 22.9kV이하 3상 고효율 변압기(용량 100~3,000KVA)로 교체하는 고객
--  - 지원기기 : 한국에너지공단에 등록된 고효율변압기
-- (용량 100~3,000kVA)');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('B41000200013', '4', '1', '수요관리실', '개인||가구||소상공인||법인/시설/단체', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/B41000200013', '고효율 인버터 지원', '한국전력공사(한전) 고객이 고효율 기기(고효율 인버터) 교체 시 지원금 지급', '생활안정', NULL, '한국전력공사', NULL, '2023-04-24 13:51:24', '2025-08-20 10:31:53', '상시신청', NULL, NULL, '기타 온라인신청||방문신청||직접입력', NULL, '에너지 효율향상 및 온실가스 감축을 위해 고객이 고효율 기기 교체 시 지원금 지급', '○  부하기기(팬, 펌프, 콤프레샤, 유압식 사출기)에 제어판넬, 리액터, 노이즈필터가 포함된 고효율 인버터(용량 3.7~220kW)를 신설하는 한국전력공사(한전) 고객
-- - 지원기기 : 한국에너지공단의 등록된 고효율 인버터(용량 3.7~220kW)');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('B41000200020', '4', '1', '수요관리실', '개인||소상공인||법인/시설/단체', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/B41000200020', '히트펌프 김 건조기 지원', '한국전력공사(한전) 고객이 고효율 기기(히트펌프 김 건조기) 교체 시 지원금 지급', '농림축산어업', NULL, '한국전력공사', NULL, '2023-04-24 14:31:21', '2025-08-20 10:28:22', '상시신청', NULL, NULL, '기타 온라인신청||방문신청||직접입력', NULL, '에너지 효율향상 및 온실가스 감축을 위해 고객이 고효율 기기 교체 시 지원금 지급', '○ 농사용전력을 사용하며 에너지진단을 통해 전열히터 김건조기를 히트펌프 김건조기로 교체하는 고객 또는 ESCO사업자 등
--  - (지원기기) 히트펌프와 급기팬 등 전 건조설비
--   ※ 세부 구성품(삼상유도전동기, 원심식송풍기) 중 한국에너지공단효율관리제도, 고효율에너지기자재 대상인 경우 반드시 등록제품 설치');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('B41000200021', '4', '1', '수요관리실', '개인||소상공인||법인/시설/단체', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/B41000200021', '고효율 펌프 지원', '한국전력공사(한전) 고객이 고효율 기기(고효율 펌프) 교체 시 지원금 지급', '생활안정', NULL, '한국전력공사', NULL, '2023-04-24 14:41:05', '2025-08-20 10:30:54', '상시신청', NULL, NULL, '기타 온라인신청||방문신청||직접입력', NULL, '에너지 효율향상 및 온실가스 감축을 위해 고객이 고효율 기기 교체 시 지원금 지급', '○ 일반 펌프를 고효율 펌프로 교체하는 고객, 사업자 등
--  - 각각의 동력 및 유량이 기존 펌프와 같거나 작은 경우 지원
--  - (지원기기) 한국에너지공단에 등록된 고효율 펌프');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('B41000200037', '20', '1', '수요관리실', '소상공인||법인/시설/단체', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/B41000200037', '식품매장 냉장고 문달기 지원', '식품매장 내 기존 개방형 냉장고(쇼케이스)를 Door형으로 개조 또는 교체 시 지원금 지급', '생활안정', NULL, '한국전력공사', NULL, '2023-09-26 14:44:26', '2025-08-20 09:15:02', '상시신청', NULL, NULL, '기타 온라인신청||방문신청||직접입력', NULL, '식품매장 내 기존 개방형 냉장고(쇼케이스)를 Door형으로 개조, 교체 또는 Door형 냉장고를 신규로 설치  시 지원금 지급', '○ 식품매장 내 기존 개방형 냉장고(쇼케이스)를 Door형으로 개조, 교체 또는 Door형 냉장고를 신규로 설치하는 고객(단, 기존 냉장고 형태에 따라 Door 설치가 어려울 수 있음)
--  - 미닫이(Sliding), 여닫이(Swing) 등 설치 형태 무관');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('B41000200038', '4', '1', '수요관리실', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/B41000200038', '소상공인 고효율 기기 지원', '소상공인이 기존 기기를 에너지효율1등급 냉방기 또는 냉난방기로 교체 시 지원금 지급', '생활안정', NULL, '한국전력공사', NULL, '2023-09-26 14:53:32', '2025-08-20 08:58:28', '상시신청', NULL, NULL, '기타 온라인신청', NULL, '소상공인이 에너지효율1등급 냉방기, 냉난방기, 냉장고, 세탁기, 건조기를 구매 시 지원금 지급', '○ ''소상공인기본법'' 제2조와 ''중소기업기본법''제2조 제2항에 의한 소상공인으로서, 고효율 냉방기, 냉난방기, 냉장고, 세탁기, 건조기 등을 구매한 자');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('B49000100207', '16', '1', '사회복귀지원부', '소상공인||법인/시설/단체', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/B49000100207', '산재장해인 원직장복귀지원', '직장복귀지원금, 직장적응훈련비 및 재활운동비를 사업주에게 지원', '고용·창업', NULL, '근로복지공단', NULL, '2022-07-15 00:00:00', '2025-08-04 13:44:16', '상시신청', NULL, NULL, '기타 온라인신청||방문신청||직접입력', NULL, '○ 직장복귀지원금, 직장적응훈련비 및 재활운동비를 사업주에게 지원하여 산재장해인의 원직장 복귀 촉진
--
--
-- ○ 직장복귀지원금: 사업주가 산재근로자에게 실제 지급한 임금액을 기준으로 고용노동부 월 고시금액(장해등급별 차등)의 범위 내에서 지급(최대 12개월)
--  - 1~3급, 월 80만원 이내, (연 최대 960만원)
--  - 4~9급, 월 60만원 이내, (연 최대 720만원)
--  - 10~12급, 월 45만원 이내, (연 최대 540만원)
--  - 지급 제한
--   • 「장애인고용촉진 및 직업재활법」제28조에 따른 고용의무가 있는 장애인을 고용한 경우
--    ① 장애인고용의무가 있는 사업주는 의무고용률을 초과하고 장애인고용장려금을 지급 받지 않은 경우에 지급
--    ② 청구대상인 장해급여자가 장애인에 해당하지 않는 경우는 장애인고용의무와 상관없이 지급 가능
--   • 장해급여자가 사업에 복귀하기 전 3개월 전부터 복귀후 6개월 이내에 다른 장해급여자 또는 장애인을 퇴직하게 한 경우
--   • 「장애인고용촉진 및 직업재활법」제30조에 따른 고용장려금을 지급 받은 경우,「고용보험법」 제23조에 따른 지원금을 받은 경우 등 그 밖의 다른 법령에 따른 직장복귀지원금에 해당하는 금액을 받은 경우
--   ※ 단, 해당하는 금액을 받은 경우에는 그 금액을 뺀 차액 지급
--
-- ○ 직장적응훈련비
--  - 직장적응훈련을 시작한 날부터 최대 3개월까지 지급
--  - 고용노동부장관 고시금액 월 450,000원 범위 내에서 실비 지급
--  - 지급제한
--   • 다른 법령에 따라 직장적응훈련비에 해당하는 지원금 지급 받은 경우에는 그 받은 금액을 빼고 지급
--
-- ○ 재활운동비
--  - 재활운동을 시작한 날부터 최대 3개월까지 지급
--  - 고용노동부장관 고시금액 월 150,000원 범위에서 실비 지급
--  - 지급제한
--   • 다른 법령에 따라 재활운동비에 해당하는 지원금 지급 받은 경우에는 그 받은 금액을 빼고 지급', '○ 직장복귀지원금
--  - 장해등급 제1급~제12급의 장해급여자를 고용단절없이 원직장에 복귀시켜 요양종결일(또는 직장복귀일)부터 6개월 이상 고용을 유지한 사업주
--
-- ○ 직장적응훈련비
-- - 요양 중 또는 원직장에 복귀한 산재장해인(제1급~제12급)에게 요양종결일(또는 직장복귀일) 전 3개월부터 이후 6개월 이내에 ‘직무수행이나 직무전환’에 필요한 직장적응훈련을 시작하고, 직장적응훈련이 끝난 날 다음날 부터 6개월 이상 고용유지한 사업주
--
-- ○ 재활운동비
--  - 원직장에 복귀한 산재장해인(제1급~제12급)에게 요양종결일(또는 직장복귀일)부터 6개월 이내에  ‘직무수행이나 직무전환’에 필요한 재활운동을 시작하고, 재활운동이 끝난 날 다음날 부터 6개월 이상 고용 유지한 사업주');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('B49000100216', '11', '1', '사회복귀지원부', '소상공인||법인/시설/단체', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/B49000100216', '산재근로자 대체인력지원금', '근로자 50인 미만 고용 등 지원요건 충족 사업주에게 대체근로자 임금의 50% 이내 지원', '고용·창업', NULL, '근로복지공단', NULL, '2023-11-22 14:06:20', '2025-08-04 13:40:58', '상시신청', NULL, NULL, '기타 온라인신청||방문신청||직접입력', NULL, '○ 대체근로자 임금의 50% 범위내 지원(월 60만원 이내, 최대 6개월까지)
--  - 산재근로자 원직장복귀 후 30일이 지난 날의 다음날부터 2년 이내 청구
--  - 산재보험료가 체납된 경우, 체납보험료 완납 시에 지급 가능', '○ (재해일이 속하는 달 말일 기준) 상시근로자 수 50인 미만을 고용하는 사업주
--  - (산재근로자) 산재장해인 또는 요양승인 기간 60일 이상의 산재근로자를 원직장복귀시켜 30일 이상 고용을 유지하고 임금 지급
--  - (대체근로자) 재해일 이후 신규로 대체근로자를 고용하고 30일 이상 고용을 유지(산재보험 또는 고용보험 피보험자격 취득)');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('B55284200012', '20', '1', '북한이탈주민지원재단', '개인||소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/B55284200012', '북한이탈주민 경영개선자금 지원', '북한이탈주민 기창업자의 경영개선자금 지원', '고용·창업', NULL, '북한이탈주민지원재단', NULL, '2024-01-30 16:10:26', '2025-05-02 14:34:12', '연 2회(2-3월, 9-10월)', NULL, NULL, '방문신청||직접입력', NULL, '○ 경영개선자금 연 300만원(생애 누적 900만원) 지원 및 경영컨설팅 연계
-- - 사업장의 시설개선, 집기비품, 홍보비, 기타 심사위원회에서 지원이 필요하다고 인정하는 경우
--
-- ※인건비, 임차료, 보험료, 세금 등 단기적이거나 소모적인 비용은 지원 제외함', '○ 북한이탈주민 본인 명의의 사업자등록증을 발급받아 공고일 기준 만 6개월 이상 사업 중인 개인사업자');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('B55307700024', '20', '1', '기업가형소상공인육성팀', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/B55307700024', '강한소상공인 성장지원', '유망소상공인을 발굴하여 사업모델 고도화를 위한 사업화자금 지원을 통해 강한소상공인 육성', '고용·창업', NULL, '소상공인시장진흥공단', NULL, '2024-02-20 16:41:15', '2025-08-13 09:54:52', '2025. 2월 ~ 3월 (지원 유형별 상이, 공고문 참고 필요)', NULL, NULL, '기타 온라인신청', NULL, '팀빌딩 프로그램 및 교육, 멘토링과 사업모델 고화 및 스케일업(확장)에 필요한 사업화 자금 지원 (최대 1억원 이내)', '소상공인기본법 제2조에 따른 소상공인');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('B55307700040', '1', '1', '사회안전망팀', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/B55307700040', '소상공인 고용보험료 지원', '소상공인이 납부한 자영업자 고용보험료의 50~80%를 최대5년간 환급 지원', '생활안정', NULL, '소상공인시장진흥공단', NULL, '2025-07-01 17:05:37', '2025-07-04 16:01:15', '상시신청', NULL, NULL, '기타 온라인신청', NULL, '소상공인이 납부한 자영업자 고용보험료의 50~80%를 최대5년간 환급 지원', '''자영업자 고용보험''에 가입한 소상공인(사업주)
--
-- 소상공인 기준 : 소상공인기본법 시행령 제3조(소상공인의 범위 등)
-- 1) 상시근로자 수 : 5명 미만 (단, 광업, 제조업, 건설업 및 운수업은 10명 미만)
-- 2) 연간매출액 : 숙박 및 음식접업, 수리 및 기타 개인 서비스업 10억원 이하,
--                           도소매업 50억원 이하,
--                           농업, 임업, 어업, 광업, 건설업, 운수업 80억 이하,
--                           제조업(식료품, 의복, 가구, 전기장비) 120억원 이하 등');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('O00046700025', '10', '1', '서비스 관리부서', '소상공인||법인/시설/단체', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/O00046700025', '웹콘텐츠 기업 레벨업', '고양시 기업의 웹콘텐츠 제작비 지원, 또는 고양성을 가진  웹콘텐츠 IP의 제작비 지원', '고용·창업', NULL, '고양산업진흥원', NULL, '2023-03-22 10:11:13', '2025-07-24 15:10:22', '상시신청', NULL, NULL, '기타 온라인신청', NULL, '○ 고양 웹콘텐츠 창작기업 육성
--    - 대상 : 고양시 웹콘텐츠(웹툰, 웹소설) 창작기업
--    - 지원 : 웹소설, 웹툰 제작비용의 70%
--                (웹소설 300만원, 웹툰 500만원)
-- ○ 고양특화 웹콘텐츠 제작 지원
--    - 대상 : 국내 웹콘텐츠(웹툰, 웹소설, 웹애니) 창작기업
--    - 지원 : 콘텐츠 제작비용의 70%
--                (웹소설 800만원, 웹툰 1,800만원, 웹애니 2,600만원)
--    - 조건(하나 이상 충족) : 제작사가 고양시
--                                            소재가 고양시
--                                            메인 제작자 또는 원작자가 고양시민 이거나 교육 수료생, 공모전 수상자
--                                            사업비의 30% 이상을 고양시 기업, 고양시민, 교육 수료생에게 지출', '○ 고양 웹콘텐츠 창작기업 육성 : 고양시 웹콘텐츠(웹툰, 웹소설) 창작기업
--
-- ○ 고양특화 웹콘텐츠 제작 지원 : 국내 웹콘텐츠(웹툰, 웹소설, 웹애니) 창작기업
--    - 조건(하나 이상 충족) : 제작사가 고양시
--                                            소재가 고양시
--                                            메인 제작자 또는 원작자가 고양시민 이거나 교육 수료생, 공모전 수상자
--                                            사업비의 30% 이상을 고양시 기업, 고양시민, 교육 수료생에게 지출');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('O00082800005', '11', '1', '서비스 관리부서', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/O00082800005', '서울특별시 자영업자 고용보험료 지원', '납부보험료 지원으로 ''자영업자 고용보험'' 가입 활성화 및 소상공인 사회안전망 확대', '생활안정', NULL, '서울신용보증재단', NULL, '2022-11-02 14:57:07', '2025-07-21 15:22:49', '상시신청', NULL, NULL, '기타 온라인신청||방문신청', NULL, '○ 지원기간 : 최대 5년간 지원
--   - 지원금 수혜기간은 5년을 초과할 수 없음
-- ○ 지원내용 : 월 납입 보험료의 20%를 환급 지원
--   - 신청일이 속한 연도의 1월 납부 분부터 소급하여 지원
-- ○ 지원규모 : 595,484천원 이내
--   -  예산소진 시 신청 및 지원이 조기 마감될 수 있음', '''자영업자 고용보험''에 가입한 서울시 소재 소상공인');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('O00089100002', '10', '1', '서비스 관리부서', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/O00089100002', '온라인 플랫폼 지원', '소상공인 대상 온라인 플랫폼의 중개수수료 및 쿠폰발행비 등 지원', '고용·창업', NULL, '울산신용보증재단', NULL, '2022-07-15 00:00:00', '2025-07-21 18:23:49', '접수기관 별 상이', NULL, NULL, '기타 온라인신청', NULL, '○ 온라인 플랫폼 중개수수료, 쿠폰발행비 지원
--  - 지원금액 : 최대100만원 이내(공급가액의 90%)
--  - 지원내용
--   · 온라인 플랫폼 이용에 부과되는 중개 수수료
--   · 온라인 플랫폼 노출을 위한 홍보 · 광고비
--   · 온라인 플랫폼 판촉을 위한 쿠폰 발행비', '○ 사업대상
--  - 울산광역시 내 창업한 자로서 「소상공인 보호 및 지원에 관한 법률」제2조에 따른 소상공인 사업자');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('O00089100003', '5', '1', '서비스 관리부서', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/O00089100003', '소상공인 경영환경개선사업', '옥외광고물 제작, 시설 교체 등 경영환경개선에 소요되는 비용 지원', '고용·창업', NULL, '울산신용보증재단', NULL, '2022-07-15 00:00:00', '2025-07-21 18:23:04', '접수기관 별 상이', NULL, NULL, '기타 온라인신청||방문신청', NULL, '○ 점포환경개선비
--  - 지원금액 : 최대250만원 이내(공급가액의 80%)
--  - 지원분야 : 옥외광고물/인테리어/고정식 영업시설
--
-- ○ 홍보·광고비
--  - 지원금액 : 최대 200만원 이내(공급가액의 80%)
--  - 지원내용 : ① 홍보용 판촉물, 카탈로그 등 ②국내TV,라디어, 대중교통, 게시대 광고 등
--
-- ○ 위생· 안전 및 시스템개선비
--  - 지원금액 : 최대200만원 이내(공급가액의 80%)
--  - 지원분야 : CCTV/ 안전·위생/ POS경비/무인결제시스템(키오스크) 등
--
-- ※3개 단위 사업 中 택 1', '○ 사업대상
--  - 울산광역시 내 창업 6개월 이상 소상공인 중 세부 기준에 해당하는 자');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('O00089100006', '5', '1', '서비스 관리부서', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/O00089100006', '울주군 소상공인 경영환경개선 및 디지털기기 지원 사업', '옥외광고물 제작, 시설 교체 등 경영환경개선에 소요되는 비용 지원', '고용·창업', NULL, '울산신용보증재단', NULL, '2024-05-03 13:34:58', '2025-07-21 18:20:11', '접수기관 별 상이', NULL, NULL, '기타 온라인신청||방문신청', NULL, '○ 점포환경개선비
--  - 지원금액 : 최대300만원 이내(공급가액의 80%)
--  - 지원분야 : 옥외광고물/인테리어/고정식 영업시설
--
-- ○ 디지털기기 구입비
--  - 지원금액 : 최대300만원 이내(공급가액의 80%)
--  - 지원분야 : POS기기 및 프로그램 구매, 무인결제시스템(키오스크, 테이블오더 등) 구매, 서빙로봇 구매', '○ 사업대상
--  - 울주군 내 창업 6개월 이상 소상공인 중 세부 기준에 해당하는 자');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('O00093000020', '20', '1', '서비스 관리부서', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/O00093000020', '골목(시장)이음 패키지', '골목(시장) 활성화 지원', '고용·창업', NULL, '전남신용보증재단', NULL, '2024-02-13 09:34:01', '2025-07-26 15:01:02', '접수기관 별 상이', NULL, NULL, '기타 온라인신청||방문신청', NULL, '○ 골목형상점가 또는 시장 활성화 지원
--    - 온라인 판로개척 컨설팅
--    - 방문고객 대상 이벤트 지원', '○ 전라남도 내 소상공인 중 센터 사업을 수료한 사업자');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('O00108000004', '10', '1', '서비스관리부서', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/O00108000004', '2025년 소상공인 디지털 전환 (온라인 플랫폼 판로 지원)', '1) 온라인 시장 진출/활성화 지원
-- 2) 라이브커머스 진출/활성화 지원 (25년 모집종료)', '생활안정', NULL, '재단법인충남경제진흥원', NULL, '2023-03-30 09:16:01', '2025-07-23 18:26:59', '2025.07.10 ~ 2025.07.31', '2025-07-10', '2025-07-31', '직접입력', NULL, '- 2025. 1. 1. ~ 접수 당일까지 사용금액에 한하여 공급가액 기준 150만원 지원가능', '○ 자발적인 온라인 마케팅 활동을 통해 실질적인 성과를 이룬 소상공인에게 사후 지원사업
-- ○ 사업자등록증 상 개업일이 2024.7.1 이전 소상공인이며, 접수 당일까지 2025년 온라인 마케팅 추진 및 지출완료한 소상공인');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('SD0000003276', '9', '1', '기업일자리지원과', '소상공인||법인/시설/단체', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/SD0000003276', '고용창출장려금(일자리 함께하기, 국내복귀기업 지원, 신중년 적합직무 지원)', '일자리 함께하기 지원, 국내복귀기업 지원, 신중년 적합직무 등 지원', '고용·창업', NULL, '고용노동부', NULL, '2020-12-17 14:26:13', '2025-09-02 23:38:23', '지원대상 근로자를 고용한 날부터 12개월 이내에 첫번째 주기 장려금 신청', NULL, NULL, '기타 온라인신청', NULL, '○ (일자리함께하기 지원) 일자리함께하기 제도를 도입․확대하여 근로자수가 증가한 경우 증가근로자 수 1인당 연간 최대 480~960만원, 임금감소액 일부 또는 전부를 사업주가 보전한 경우 사업주 지급 금액의 80% 한도로 연간 최대 120~480만원 지원
-- ○ (국내복귀기업 고용지원) 국내복귀기업으로 지정 후 5년 이내인 기업의 근로자수가 증가한 경우 증가근로자 수 1인당 우선지원대상기업 연간 최대 720만원, 중견기업 연간 최대 360만원 지원
-- ○ (신중년 적합직무 고용지원) 만 50세 이상 실업자를 신중년 적합직무에 6개월 이상 고용한 경우 신규 고용 근로자 1인당 우선지원대상기업은 연간 최대 960만원,  중견 기업은 연간 최대 480만원 지원', '○ 일자리 창출 사업주(소상공인, 중소기업, 중견기업, 대기업 등)
--
-- ○ 지원제외대상 사업주
--  - 국가, 지자체, 공공기관
--  - 일반유흥․무도유흥․기타주점업, 갬블링 및 베팅업 등 중소기업인력지원 특별법 시행령 제2조에서 정한 업종
--  - 근로기준법 제43조2에 따라 임금 등을 체불하여 명단이 공개중인 사업주
--  - 산업안전보건법 제10조에 따라 중대산업재해 발생 등으로 명단이 공표 중인 사업주
--  - 고용창출장려금 지급대상자를 고용한 사업주가 해당 근로자의 이직(해당 사업주가 해당 근로자를 고용하기 전 1년 이내에 이직한 경우에  한정) 당시의 사업주와 같은 경우. 다만, 「근로기준법」제25조제1항에 따라 해당 근로자를 우선적으로 고용한 경우와 일용근로자로 고용하였던 근로자를 기간의 정함이 없는 근로계약을 체결하여 다시 고용한 경우는 제외
--  - 고용창출장려금 지급대상자를 고용한 사업주가 해당 근로자의 이직(해당 사업주가 해당 근로자를 고용하기 전 1년 이내에 이직한 경우에 한정) 당시의 사업주와 밀접한 관련성이 있다고 인정되는 경우
--  - 지원대상 근로자를 고용한 날부터 12개월 이내에 첫 번쨰 주기 장려금을 신청하지 않은 경우(''22. 7. 1. 이후 고용한 경우 부터 적용)
--
-- ○ 지원제외대상 근로자
--  - 근로계약 기간을 정한 근로자(일부 예외 가능)
--  - 최저임금법 제5조제1항․제2항에 따른 최저임금액 미만의 임금을 지급받기로 한 근로자(일자리 함께하기, 신중년 적합직무, 국내복귀기업 지원, 청년채용특별장려금)
--  - 고용산재보험료징수법 제16조의10에 따라 사업주가 신고한 월 평균 보수가 110만원 미만인 근로자(고용촉진장려금)
--  - 비상근촉탁근로자
--  - 사업주(법인의 경우 법인의 대표이사)의 배우자, 직계 존·비속
--  - 고용 후 정년까지의 기간이 2년 미만인 근로자
--  - 대한민국 국적을 보유하지 않은 외국인. 다만, 고용보험법 적용 대상인 거주(F-2), 영주(F-5), 결혼이민자(F-6)는 가능
--  - 고용보험에 가입되어 있지 않은 근로자');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('SD0000003857', '20', '1', '기업일자리지원과', '소상공인||법인/시설/단체', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/SD0000003857', '고용촉진장려금', '대상 근로자 고용시 연 최대 720만원 지원', '고용·창업', NULL, '고용노동부', NULL, '2020-12-17 14:26:13', '2025-09-02 23:37:27', '지급대상 근로자를 고용한 날부터 12개월 이내에 첫번재 주기 고용촉진장려금을 신청', NULL, NULL, '기타 온라인신청', NULL, '○ 고용촉진장려금
--  - 지원수준: 대상근로자 고용시 1년간 우선지원대상기업, 중견기업은 연 최대 720만원, 대규모기업은 연  360만원(6개월단위 지급, 사업주가 고용산재보험료징수법 제16조의10에 따라 신고한 보수 한도에서 지원)
--  - 중증장애인, 여성가장 등은 최대 2년간 지원', '○ 직업안정기관 등에 구직 등록을 한 사람으로서 고용노동부 장관이 고시하는 취업지원프로그램 이수자를 고용하거나, 고용일 이전 1년 이내에 구직등록 이력과 1개월 이상 실업상태에 있는 중증장애인, 여성가장을 기간의 정함이 없는 근로자로 채용한 사업주');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('SD0000007429', '15', '1', '소상공인경영안정과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/SD0000007429', '소상공인 정책자금 융자 지원(일반경영안정자금, 특별경영안정자금, 성장기반자금 등)', '소상공인 대상 시중은행 대비 저금리 정책자금을 지원', '고용·창업', NULL, '중소벤처기업부', NULL, '2020-12-17 14:26:13', '2025-07-08 16:11:39', '자금별 상이', NULL, NULL, '기타 온라인신청||방문신청', NULL, '○ 정책목적에 따라 일반경영안정자금, 특별경영안정자금, 성장기반자금 등 지원', '○ 「소상공인 기본법」에 따른 소상공인
--    ※ 단, 소상공인 정책자금 융자공고에 따른 융자제외업종은 지원 불가');
-- INSERT INTO policies (policy_id, industry_id, region_id, department_name, user_type, announcement_url, policy_name, policy_summary, policy_field, selection_criteria, supervising_organization_name, receiving_organization_name, notice_date, modification_date, application_period, begin_date, end_date, application_method, contact, support_detail, support_target) VALUES ('SD0000007975', '1', '1', '식품안전인증과', '소상공인', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/SD0000007975', 'HACCP 위생안전시설 개선 자금 지원', 'HACCP 적용을 받는 업소 등에 위생안전시설 설치자금의 50%, 최대 천만원 지원', '보건·의료', NULL, '식품의약품안전처', NULL, '2020-12-17 14:26:13', '2025-08-25 14:24:30', '사업신청 접수일부터 보조금 소진시까지', NULL, NULL, '방문신청', NULL, '○ HACCP 적용에 소요되는 위생안전 시설 및 설비 등 설치자금의 50% 지원(최대 천만원)', '○ (축산물) HACCP인증 의무적용 대상(식육가공업, 식육포장처리업) 소규모 작업장
-- ○ 전년도 전체 매출액 100억원 이상인 업소 제외');
--
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '142000000045', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '142000000045', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '142000000045', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '142000000045', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '142000000045', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '142000000045', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '142000000045', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '142000000045', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '142000000045', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '142000000045', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '142000000045', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '142000000045', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '142000000045', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '142000000045', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '142000000072', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '142000000072', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '142000000072', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '142000000072', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '142000000072', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '142000000072', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '142000000072', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '142000000072', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '142000000072', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '142000000072', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '142000000072', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '142000000072', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '142000000072', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '142000000072', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '142000000088', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '142000000088', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '142000000088', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '142000000088', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '142000000088', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '142000000088', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '142000000088', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '142000000088', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '142000000088', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '142000000088', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '142000000088', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '142000000088', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '142000000088', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '142000000088', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '142000000090', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '142000000090', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '142000000090', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '142000000090', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '142000000090', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '142000000090', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '142000000090', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '142000000090', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '142000000090', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '142000000090', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '142000000090', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '142000000090', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '142000000090', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '142000000090', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '142100000050', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '142100000050', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '142100000050', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '142100000050', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '142100000050', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '142100000050', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '142100000050', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '142100000050', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '142100000050', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '142100000050', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '142100000050', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '142100000050', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '142100000050', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '142100000050', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '142100000051', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '142100000051', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '142100000051', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '142100000051', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '142100000051', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '142100000051', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '142100000051', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '142100000051', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '142100000051', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '142100000051', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '142100000051', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '142100000051', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '142100000051', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '142100000051', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '142100000052', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '142100000052', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '142100000052', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '142100000052', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '142100000052', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '142100000052', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '142100000052', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '142100000052', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '142100000052', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '142100000052', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '142100000052', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '142100000052', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '142100000052', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '142100000052', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '142100000058', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '142100000058', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '142100000058', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '142100000058', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '142100000058', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '142100000058', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '142100000058', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '142100000058', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '142100000058', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '142100000058', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '142100000058', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '142100000058', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '142100000058', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '142100000058', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '149200005008', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '149200005008', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '149200005008', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '149200005008', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '149200005008', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '149200005008', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '149200005008', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '149200005008', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '149200005008', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '149200005008', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '149200005008', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '149200005008', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '149200005008', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '149200005008', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '174100000071', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '174100000071', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '174100000071', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '174100000071', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '174100000071', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '174100000071', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '174100000071', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '174100000071', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '174100000071', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '174100000071', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '174100000071', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '174100000071', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '174100000071', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '174100000071', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '304000000186', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '304000000186', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '304000000186', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '304000000186', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '304000000186', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '304000000186', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '304000000186', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '304000000186', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '304000000186', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '304000000186', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '304000000186', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '304000000186', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '304000000186', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '304000000186', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '319000000149', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '319000000149', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '319000000149', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '319000000149', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '319000000149', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '319000000149', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '319000000149', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '319000000149', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '319000000149', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '319000000149', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '319000000149', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '319000000149', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '319000000149', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '319000000149', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '343000000131', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '343000000131', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '343000000131', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '343000000131', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '343000000131', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '343000000131', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '343000000131', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '343000000131', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '343000000131', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '343000000131', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '343000000131', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '343000000131', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '343000000131', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '343000000131', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '345000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '345000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '345000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '345000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '345000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '345000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '345000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '345000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '345000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '345000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '345000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '345000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '345000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '345000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '349000000115', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '349000000115', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '349000000115', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '349000000115', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '349000000115', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '349000000115', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '349000000115', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '349000000115', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '349000000115', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '349000000115', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '349000000115', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '349000000115', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '349000000115', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '349000000115', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '355000000111', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '355000000111', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '355000000111', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '355000000111', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '355000000111', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '355000000111', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '355000000111', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '355000000111', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '355000000111', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '355000000111', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '355000000111', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '355000000111', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '355000000111', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '355000000111', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '358000000125', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '358000000125', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '358000000125', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '358000000125', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '358000000125', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '358000000125', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '358000000125', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '358000000125', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '358000000125', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '358000000125', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '358000000125', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '358000000125', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '358000000125', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '358000000125', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '383000000165', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '383000000165', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '383000000165', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '383000000165', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '383000000165', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '383000000165', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '383000000165', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '383000000165', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '383000000165', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '383000000165', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '383000000165', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '383000000165', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '383000000165', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '383000000165', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '427000000215', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '427000000215', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '427000000215', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '427000000215', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '427000000215', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '427000000215', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '427000000215', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '427000000215', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '427000000215', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '427000000215', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '427000000215', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '427000000215', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '427000000215', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '427000000215', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '427000000235', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '427000000235', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '427000000235', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '427000000235', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '427000000235', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '427000000235', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '427000000235', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '427000000235', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '427000000235', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '427000000235', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '427000000235', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '427000000235', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '427000000235', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '427000000235', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '427000000239', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '427000000239', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '427000000239', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '427000000239', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '427000000239', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '427000000239', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '427000000239', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '427000000239', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '427000000239', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '427000000239', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '427000000239', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '427000000239', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '427000000239', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '427000000239', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '428000000112', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '428000000112', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '428000000112', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '428000000112', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '428000000112', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '428000000112', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '428000000112', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '428000000112', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '428000000112', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '428000000112', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '428000000112', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '428000000112', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '428000000112', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '428000000112', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '439000000849', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '439000000849', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '439000000849', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '439000000849', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '439000000849', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '439000000849', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '439000000849', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '439000000849', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '439000000849', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '439000000849', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '439000000849', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '439000000849', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '439000000849', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '439000000849', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '443000000662', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '443000000662', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '443000000662', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '443000000662', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '443000000662', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '443000000662', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '443000000662', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '443000000662', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '443000000662', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '443000000662', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '443000000662', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '443000000662', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '443000000662', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '443000000662', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '451000000125', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '451000000125', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '451000000125', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '451000000125', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '451000000125', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '451000000125', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '451000000125', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '451000000125', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '451000000125', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '451000000125', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '451000000125', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '451000000125', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '451000000125', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '451000000125', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '451000000141', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '451000000141', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '451000000141', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '451000000141', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '451000000141', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '451000000141', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '451000000141', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '451000000141', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '451000000141', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '451000000141', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '451000000141', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '451000000141', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '451000000141', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '451000000141', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '477000000112', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '477000000112', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '477000000112', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '477000000112', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '477000000112', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '477000000112', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '477000000112', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '477000000112', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '477000000112', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '477000000112', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '477000000112', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '477000000112', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '477000000112', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '477000000112', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '478000000108', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '478000000108', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '478000000108', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '478000000108', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '478000000108', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '478000000108', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '478000000108', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '478000000108', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '478000000108', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '478000000108', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '478000000108', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '478000000108', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '478000000108', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '478000000108', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '482000000135', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '482000000135', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '482000000135', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '482000000135', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '482000000135', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '482000000135', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '482000000135', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '482000000135', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '482000000135', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '482000000135', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '482000000135', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '482000000135', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '482000000135', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '482000000135', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '486000000122', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '486000000122', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '486000000122', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '486000000122', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '486000000122', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '486000000122', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '486000000122', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '486000000122', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '486000000122', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '486000000122', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '486000000122', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '486000000122', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '486000000122', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '486000000122', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '493000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '493000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '493000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '493000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '493000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '493000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '493000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '493000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '493000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '493000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '493000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '493000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '493000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '493000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '493000000111', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '493000000111', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '493000000111', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '493000000111', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '493000000111', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '493000000111', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '493000000111', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '493000000111', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '493000000111', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '493000000111', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '493000000111', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '493000000111', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '493000000111', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '493000000111', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '493000000131', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '493000000131', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '493000000131', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '493000000131', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '493000000131', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '493000000131', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '493000000131', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '493000000131', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '493000000131', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '493000000131', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '493000000131', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '493000000131', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '493000000131', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '493000000131', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '493000000273', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '493000000273', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '493000000273', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '493000000273', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '493000000273', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '493000000273', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '493000000273', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '493000000273', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '493000000273', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '493000000273', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '493000000273', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '493000000273', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '493000000273', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '493000000273', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '493000000285', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '493000000285', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '493000000285', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '493000000285', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '493000000285', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '493000000285', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '493000000285', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '493000000285', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '493000000285', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '493000000285', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '493000000285', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '493000000285', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '493000000285', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '493000000285', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '494000000189', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '494000000189', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '494000000189', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '494000000189', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '494000000189', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '494000000189', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '494000000189', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '494000000189', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '494000000189', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '494000000189', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '494000000189', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '494000000189', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '494000000189', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '494000000189', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '496000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '496000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '496000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '496000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '496000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '496000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '496000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '496000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '496000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '496000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '496000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '496000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '496000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '496000000109', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '497000000128', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '497000000128', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '497000000128', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '497000000128', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '497000000128', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '497000000128', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '497000000128', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '497000000128', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '497000000128', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '497000000128', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '497000000128', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '497000000128', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '497000000128', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '497000000128', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '497000000129', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '497000000129', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '497000000129', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '497000000129', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '497000000129', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '497000000129', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '497000000129', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '497000000129', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '497000000129', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '497000000129', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '497000000129', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '497000000129', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '497000000129', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '497000000129', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '497000000137', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '497000000137', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '497000000137', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '497000000137', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '497000000137', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '497000000137', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '497000000137', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '497000000137', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '497000000137', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '497000000137', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '497000000137', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '497000000137', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '497000000137', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '497000000137', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '502000000237', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '502000000237', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '502000000237', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '502000000237', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '502000000237', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '502000000237', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '502000000237', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '502000000237', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '502000000237', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '502000000237', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '502000000237', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '502000000237', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '502000000237', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '502000000237', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '508000000690', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '508000000690', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '508000000690', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '508000000690', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '508000000690', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '508000000690', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '508000000690', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '508000000690', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '508000000690', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '508000000690', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '508000000690', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '508000000690', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '508000000690', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '508000000690', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '510000000132', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '510000000132', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '510000000132', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '510000000132', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '510000000132', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '510000000132', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '510000000132', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '510000000132', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '510000000132', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '510000000132', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '510000000132', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '510000000132', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '510000000132', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '510000000132', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '516000000124', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '516000000124', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '516000000124', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '516000000124', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '516000000124', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '516000000124', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '516000000124', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '516000000124', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '516000000124', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '516000000124', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '516000000124', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '516000000124', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '516000000124', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '516000000124', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '547000000152', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '547000000152', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '547000000152', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '547000000152', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '547000000152', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '547000000152', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '547000000152', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '547000000152', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '547000000152', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '547000000152', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '547000000152', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '547000000152', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '547000000152', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '547000000152', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '547000000153', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '547000000153', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '547000000153', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '547000000153', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '547000000153', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '547000000153', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '547000000153', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '547000000153', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '547000000153', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '547000000153', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '547000000153', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '547000000153', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '547000000153', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '547000000153', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '559000000127', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '559000000127', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '559000000127', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '559000000127', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '559000000127', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '559000000127', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '559000000127', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '559000000127', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '559000000127', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '559000000127', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '559000000127', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '559000000127', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '559000000127', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '559000000127', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '560000000139', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '560000000139', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '560000000139', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '560000000139', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '560000000139', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '560000000139', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '560000000139', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '560000000139', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '560000000139', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '560000000139', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '560000000139', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '560000000139', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '560000000139', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '560000000139', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '569000000371', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '569000000371', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '569000000371', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '569000000371', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '569000000371', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '569000000371', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '569000000371', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '569000000371', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '569000000371', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '569000000371', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '569000000371', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '569000000371', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '569000000371', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '569000000371', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '627000000160', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '627000000160', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '627000000160', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '627000000160', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '627000000160', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '627000000160', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '627000000160', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '627000000160', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '627000000160', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '627000000160', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '627000000160', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '627000000160', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '627000000160', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '627000000160', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '629000000193', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '629000000193', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '629000000193', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '629000000193', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '629000000193', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '629000000193', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '629000000193', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '629000000193', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '629000000193', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '629000000193', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '629000000193', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '629000000193', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '629000000193', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '629000000193', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '629000000805', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '629000000805', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '629000000805', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '629000000805', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '629000000805', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '629000000805', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '629000000805', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '629000000805', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '629000000805', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '629000000805', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '629000000805', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '629000000805', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '629000000805', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '629000000805', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '630000000162', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '630000000162', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '630000000162', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '630000000162', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '630000000162', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '630000000162', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '630000000162', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '630000000162', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '630000000162', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '630000000162', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '630000000162', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '630000000162', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '630000000162', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '630000000162', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '631000000137', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '631000000137', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '631000000137', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '631000000137', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '631000000137', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '631000000137', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '631000000137', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '631000000137', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '631000000137', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '631000000137', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '631000000137', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '631000000137', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '631000000137', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '631000000137', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '631000000138', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '631000000138', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '631000000138', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '631000000138', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '631000000138', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '631000000138', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '631000000138', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '631000000138', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '631000000138', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '631000000138', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '631000000138', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '631000000138', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '631000000138', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '631000000138', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '641000000184', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '641000000184', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '641000000184', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '641000000184', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '641000000184', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '641000000184', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '641000000184', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '641000000184', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '641000000184', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '641000000184', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '641000000184', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '641000000184', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '641000000184', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '641000000184', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '641000000185', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '641000000185', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '641000000185', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '641000000185', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '641000000185', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '641000000185', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '641000000185', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '641000000185', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '641000000185', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '641000000185', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '641000000185', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '641000000185', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '641000000185', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '641000000185', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '641000000186', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '641000000186', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '641000000186', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '641000000186', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '641000000186', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '641000000186', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '641000000186', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '641000000186', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '641000000186', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '641000000186', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '641000000186', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '641000000186', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '641000000186', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '641000000186', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '642000000679', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '642000000679', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '642000000679', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '642000000679', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '642000000679', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '642000000679', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '642000000679', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '642000000679', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '642000000679', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '642000000679', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '642000000679', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '642000000679', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '642000000679', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '642000000679', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '642000000735', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '642000000735', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '642000000735', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '642000000735', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '642000000735', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '642000000735', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '642000000735', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '642000000735', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '642000000735', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '642000000735', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '642000000735', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '642000000735', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '642000000735', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '642000000735', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '643000000144', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '643000000144', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '643000000144', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '643000000144', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '643000000144', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '643000000144', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '643000000144', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '643000000144', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '643000000144', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '643000000144', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '643000000144', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '643000000144', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '643000000144', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '643000000144', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '644000000239', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '644000000239', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '644000000239', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '644000000239', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '644000000239', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '644000000239', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '644000000239', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '644000000239', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '644000000239', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '644000000239', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '644000000239', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '644000000239', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '644000000239', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '644000000239', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '645000000124', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '645000000124', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '645000000124', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '645000000124', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '645000000124', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '645000000124', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '645000000124', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '645000000124', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '645000000124', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '645000000124', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '645000000124', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '645000000124', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '645000000124', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '645000000124', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '647000000165', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '647000000165', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '647000000165', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '647000000165', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '647000000165', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '647000000165', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '647000000165', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '647000000165', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '647000000165', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '647000000165', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '647000000165', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '647000000165', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '647000000165', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '647000000165', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '648000001087', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '648000001087', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '648000001087', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '648000001087', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '648000001087', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '648000001087', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '648000001087', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '648000001087', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '648000001087', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '648000001087', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '648000001087', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '648000001087', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '648000001087', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '648000001087', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '648000001090', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '648000001090', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '648000001090', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '648000001090', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '648000001090', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '648000001090', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '648000001090', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '648000001090', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '648000001090', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '648000001090', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '648000001090', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '648000001090', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '648000001090', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '648000001090', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '648000001091', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '648000001091', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '648000001091', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '648000001091', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '648000001091', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '648000001091', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '648000001091', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '648000001091', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '648000001091', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '648000001091', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '648000001091', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '648000001091', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '648000001091', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '648000001091', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '648000001139', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '648000001139', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '648000001139', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '648000001139', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '648000001139', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '648000001139', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '648000001139', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '648000001139', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '648000001139', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '648000001139', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '648000001139', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '648000001139', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '648000001139', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '648000001139', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '650000000312', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '650000000312', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '650000000312', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '650000000312', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '650000000312', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '650000000312', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '650000000312', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '650000000312', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '650000000312', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '650000000312', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '650000000312', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '650000000312', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '650000000312', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '650000000312', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '650000000317', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '650000000317', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '650000000317', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '650000000317', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '650000000317', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '650000000317', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '650000000317', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '650000000317', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '650000000317', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '650000000317', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '650000000317', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '650000000317', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '650000000317', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '650000000317', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '650000000330', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '650000000330', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '650000000330', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '650000000330', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '650000000330', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '650000000330', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (1, '650000000330', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (6, '650000000330', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (11, '650000000330', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (2, '650000000330', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (8, '650000000330', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (7, '650000000330', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (9, '650000000330', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (4, '650000000330', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (14, '654000000010', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (12, '654000000010', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (5, '654000000010', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (10, '654000000010', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (13, '654000000010', NULL);
-- INSERT INTO required_documents (document_id, policy_id, loan_id) VALUES (3, '654000000010', NULL);