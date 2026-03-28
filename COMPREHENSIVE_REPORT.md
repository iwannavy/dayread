# Dayread 종합 전략 보고서

**작성일**: 2026-03-28
**분석 팀**: Product & UX, Content & Curriculum, Engineering, Growth & Marketing, Monetization, QA & Reliability
**분석 범위**: 79개 Swift 소스 파일, 211개 SessionData JSON, 134개 마크다운 콘텐츠

---

## I. 앱 비전 & 미션

**비전**: 한국의 지식 근로자가 영어 원문을 스스로 해독하는 세상

**미션**: 실제 영어 텍스트(뉴스, 에세이, 논문)를 4단계 딥리딩 프로세스로 분해하여, 번역 의존 없이 진짜 읽기 능력을 키운다

**슬로건**: "읽어야 실력이 는다"

---

## II. 팀별 비전 & 미션

| 팀 | 비전 |
|---|---|
| **Product & UX** | 인지과학 기반 4단계 학습 UX로 영어 독해의 새 기준을 만든다 |
| **Content & Curriculum** | 문장 단위 정밀 분석 콘텐츠를 지속적으로 공급하여 학습 루프를 완성한다 |
| **Engineering** | 오프라인 우선 학습 경험, 안전한 결제, 고품질 TTS를 iOS 네이티브 품질로 구현한다 |
| **Growth & Marketing** | "번역 말고 이해" 포지션으로 한국 성인 영어 독해 시장 1위를 확립한다 |
| **Monetization** | Free 학습 경험을 통해 자연스럽게 Premium으로 전환되는 퍼널을 구축한다 |
| **QA & Reliability** | 결제/SRS/캐시의 무장애 운영을 보장하고 크래시 프리 99.5%+를 달성한다 |

---

## III. 현황 진단 (As-Is) -- 스코어카드

### 종합 점수

| 영역 | 점수 | 평가 |
|------|------|------|
| **아키텍처 & 코드 품질** | 79/100 | @Observable 패턴 모범적, 레이어 분리 우수 |
| **콘텐츠 완성도** | 65/100 | 커리큘럼 양호, Premium summary 0%, 미등록 세션 40개 |
| **UX & 디자인** | 72/100 | 학습 플로우 탁월, 접근성 11%, 터치 타겟 미달 |
| **수익화 인프라** | 80/100 | RevenueCat 완비, 퍼널 이벤트 부족 |
| **QA & 안정성** | 35/100 | 테스트 0개, Sentry 캡처 0건, 크래시 위험점 존재 |
| **마케팅 준비도** | 40/100 | ASO 미최적화, 바이럴 기능 없음, 브랜드 인지도 제로 |

### Engineering 세부 스코어

| 항목 | 점수 |
|------|------|
| 타입 안전성 | 8/10 (`as!` 0건, `try!` 0건) |
| 에러 처리 | 7/10 (LocalizedError 구현, 프로덕션 로깅 미비) |
| 동시성 안전성 | 8/10 (@MainActor, weak self 일관) |
| 메모리 관리 | 8/10 (관찰자 해제 명시적) |
| 모듈 분리 | 9/10 (Services/Network/Models/Views/Utils 명확) |

### 콘텐츠 매트릭스

| 콘텐츠 타입 | 세션 수 | Summary 보유 | 앱 노출 |
|---|---|---|---|
| Curriculum (12주) | 48 | 100% | 100% |
| Premium Daily | 50+ JSON | 0% | 25개만 등록 |
| Collections (4개) | 22 등록 + 14 미연결 | 등록분 100% | 22개만 |
| Legacy (TED/Speech 등) | 77 | 0% | 보너스 섹션 |

---

## IV. 종합 개선 우선순위 (TIER 1-4)

### TIER 1: 즉시 실행 (1-2주) -- 비즈니스 생존

| # | 항목 | 팀 | 영향도 |
|---|------|-----|--------|
| 1 | **ImmersiveView 강제 언래핑 제거** (`sentence!.id`) | QA | 크래시 방지 |
| 2 | **loadSummaries 상태 버그** (무한 로딩) | QA | UX 차단 |
| 3 | **구독 syncWithServer 에러 처리** (결제 성공 후 tier 미반영) | QA+Monetization | 매출 직결 |
| 4 | **LibrarySection 피커 한국어 전환** (Path/Daily/Topics) | UX | CLAUDE.md 위반 |
| 5 | **Week 3 textFilePath nil 수정** (4세션 경로 누락) | Content | 콘텐츠 파이프라인 |
| 6 | **Mixpanel 퍼널 이벤트 4개 추가** (plan_selected, trial_started, failed, dismissed) | Monetization | 전환율 측정 |

### TIER 2: 단기 실행 (2-4주) -- 제품 완성도

| # | 항목 | 팀 | 영향도 |
|---|------|-----|--------|
| 7 | **TTS 캐시 LRU eviction 구현** (500개 상한 실제 적용) | Engineering | 스토리지 |
| 8 | **소형 터치 타겟 44pt 확보** (FullTextPlayerView 3개, 기타 4개) | UX | 접근성 |
| 9 | **Premium 26개 미등록 세션 등록** | Content | 콘텐츠 볼륨 |
| 10 | **미연결 Collection 14개 → 신규 컬렉션 2개 구성** | Content | 콘텐츠 볼륨 |
| 11 | **Sentry captureError 추가** (전체 catch 블록) | QA | 모니터링 |
| 12 | **ReadableContentBlock unknown type 방어** (throw → skip) | QA | 앱 안정성 |
| 13 | **PaywallView 기능 설명 문구 개선** + 소셜 프루프 추가 | UX+Monetization | 전환율 |
| 14 | **핵심 접근성 마크업** (ImmersiveView, GrammarViz, 잠긴 세션) | UX | 접근성 |

### TIER 3: 중기 실행 (1-2개월) -- 성장 기반

| # | 항목 | 팀 | 영향도 |
|---|------|-----|--------|
| 15 | **Premium 50개 세션 Summary 생성** (배치 파이프라인) | Content | 유료 UX 완성 |
| 16 | **SRS 자동 연동** (세션 완료 시 핵심 어휘 자동 추가) | Content | 리텐션 |
| 17 | **"오늘의 문장" SNS 공유 기능** (GrammarViz 이미지 추출) | Marketing | 바이럴 |
| 18 | **스트릭 배지 공유 카드** (7/30/100일 달성) | Marketing | 바이럴 |
| 19 | **SRS 알고리즘 단위 테스트** + SessionAccess 테스트 | QA | 안전망 |
| 20 | **ASO 최적화** (키워드, 스크린샷, 프리뷰 영상) | Marketing | 검색 유입 |
| 21 | **온보딩 인터랙티브 체험** (GrammarViz 10초 체험 삽입) | UX+Marketing | Day-1 리텐션 |
| 22 | **DEBUG/PROD 엔드포인트 분리** (xcconfig) | Engineering | 개발 안전 |
| 23 | **DateFormatter 공유 인스턴스 전환** (6개소) | Engineering | 성능 |

### TIER 4: 장기 실행 (3-6개월) -- 시장 확장

| # | 항목 | 팀 | 영향도 |
|---|------|-----|--------|
| 24 | **연간 가격 A/B 테스트** (RevenueCat Experiments) | Monetization | 매출 |
| 25 | **평생 이용권 추가** (₩149,000~₩199,000) | Monetization | 고가치 세그먼트 |
| 26 | **B2B 기업 라이선싱 파일럿** (팀 10인+ 단체 구독) | Monetization | 매출 다각화 |
| 27 | **iOS CI/CD 파이프라인** (GitHub Actions xcodebuild) | Engineering | 자동화 |
| 28 | **Dynamic Type 지원** + 극소 폰트 교체 | UX | 접근성 |
| 29 | **커리큘럼 장르 다양화** (dialogue, speech transcript) | Content | 콘텐츠 품질 |
| 30 | **richContent 도입** (표/다이어그램, Week 10 대상) | Content | 학습 경험 |
| 31 | **CollectionsListView NavigationStack 정렬** | UX | iOS 표준 |
| 32 | **UserDefaults 스키마 마이그레이션** 도입 | QA | 데이터 안전 |

---

## V. 유료화 방안

### 현재 가격 구조

| 플랜 | 가격 | 무료 체험 | 비고 |
|------|------|----------|------|
| 월간 | ₩7,900 | 7일 | 기본값 아님 |
| 연간 | ₩59,900 (월 ₩4,992) | 7일 | 기본 선택, 37% OFF 배지 |

### 시장 벤치마크

| 경쟁사 | 월간 | 연간 | Dayread 대비 |
|--------|------|------|-------------|
| 듀오링고 Plus | ₩14,500 | ₩79,900 | Dayread -46% (월간) |
| 케이크 Pro | ₩9,900 | ₩59,900 | Dayread -20% (월간), 동일 (연간) |
| 산타토익 | ₩19,900 | ₩99,000 | Dayread -60% (월간) |

**결론**: 현재 가격은 시장 최저 수준. 런치 가격으로 6개월 유지 후 인상 가능.

### 가격 로드맵

| 시점 | 월간 | 연간 | 추가 |
|------|------|------|------|
| 현재~6개월 | ₩7,900 | ₩59,900 | 런치 가격 유지 |
| 6~18개월 | ₩9,900 | ₩69,900 | 기존 가입자 Grandfather |
| 18개월+ | ₩9,900 | ₩69,900 | +평생 이용권 ₩149,000~199,000 |

### 수익 전망

| 시나리오 | Year 1 | Year 2 | Year 3 |
|---------|--------|--------|--------|
| 보수적 (유료 500명) | ₩2,774만 | ₩7,344만 | ₩1.53억 |
| 기본 (유료 1,000명) | ₩5,549만 | ₩1.84억 | ₩4.49억 |
| 낙관적 (유료 2,500명) | ₩1.47억 | ₩5.20억 | ₩13.1억 |

*실수령 기준 (App Store 소규모 개발사 수수료 15% 제외)*

### 긴급 조치: Mixpanel 퍼널 보강

현재 `paywall_shown` → `purchase_completed` 2개만 존재. 추가 필요:
- `paywall_plan_selected` (월간/연간 선택)
- `free_trial_started` (체험 시작)
- `purchase_failed` (에러 유형 포함)
- `paywall_dismissed` (닫기)

---

## VI. 마케팅 방안

### SWOT 요약

| | 긍정 | 부정 |
|---|---|---|
| **내부** | 4단계 딥리딩 차별화, Dayread Original 97개+, GrammarViz 시각 차별점 | 브랜드 인지도 제로, iOS 단독, 바이럴 기능 없음 |
| **외부** | 성인 영어 시장 4조+, AI 번역 역설적 수요, B2B 기업 교육 | 빅플레이어 모방, ChatGPT 경쟁, 무료 기대치 상승 |

### 타겟 퍼소나

| 퍼소나 | 나이 | 핵심 페인포인트 | Dayread 메시지 |
|--------|------|----------------|---------------|
| **커리어 클라이머** | 28세 직장인 | 영문 이메일을 구글번역에 의존 | "오늘 읽은 아티클이 내일 회의에서 써먹히는 영어" |
| **대학원 준비생** | 24세 취준생 | 논문 Abstract가 너무 어려움 | "논문 영어를 문장 단위로 해체하세요" |
| **지적 독서가** | 35세 팀장 | NYT를 읽고 싶지만 시간 부족 | "이코노미스트 수준 아티클을 오늘부터 문장 단위로" |

### 성장 해킹 Top 5

1. **"오늘의 문장" SNS 공유** — GrammarViz 색상 분해 이미지 + Dayread 워터마크
2. **7일 무료 Premium Daily 체험** — 신규 설치 후 7일간 전체 열람
3. **스트릭 배지 SNS 공유** — 7/30/100일 달성 시 공유 카드
4. **카카오 오픈채팅 학습방** — 비용 0원, 매일 핵심 표현 공유
5. **App Store Editors' Choice 공략** — GrammarViz + 4단계 UX로 피칭

### 예산 배분 (월 500만원)

| 채널 | 비율 | 월 예산 |
|------|------|---------|
| SNS 콘텐츠 제작 | 20% | 100만원 |
| 유튜버 스폰서십 | 30% | 150만원 |
| 구글/메타 광고 | 30% | 150만원 |
| ASO 도구 | 6% | 30만원 |
| B2B 영업 | 10% | 50만원 |
| 실험 예비 | 4% | 20만원 |

---

## VII. 콘텐츠 연구

### 콘텐츠 볼륨 현황

| 구분 | 등록 | 미등록 | 총 JSON |
|------|------|--------|---------|
| Curriculum | 48 | 0 | 48 |
| Premium | 25 | 26 | 50+ |
| Collection | 22 | 14 | 36 |
| Legacy | — | — | 77 |
| **합계** | **95** | **40** | **211** |

**즉시 확보 가능한 40개 세션이 앱에 노출되지 않고 있음.**

### 콘텐츠 갭 Top 5

| 순위 | 갭 | 심각도 | 해결 방법 |
|------|-----|--------|----------|
| 1 | Week 3 textFilePath nil (4세션) | 코드 버그 | `CurriculumContent.swift` 경로값 입력 |
| 2 | Premium 26개 JSON 미등록 | 누락 | `PremiumContent.swift`에 항목 추가 |
| 3 | Collection 14개 JSON 미연결 | 누락 | 신규 컬렉션 2개 구성 추가 |
| 4 | Premium 50개 Summary 0% | 콘텐츠 | 파이프라인 배치 처리 |
| 5 | 난이도 Lv.1 Premium/Collection 없음 | 설계 | 초급 콘텐츠 추가 |

### 학습 설계 평가

**강점**: 4단계 루프가 입력→이해→분석→재통합에 충실. 문장당 grammarElements, vocabulary, patterns, koreanAlignment, pronunciationNotes 완비. SM-2 SRS 완전 구현.

**약점**: SRS 세션 자동 연동 미구현 (수동 저장 의존). 장르 article 83% 쏠림. richContent 모델 있으나 실제 콘텐츠 0개.

---

## VIII. 기술 전략

### 아키텍처 현황

```
DayreadApp (@main)
├── Services (14개, @Observable + @Environment)
│   ├── AuthService, APIClient, LibraryService (3-tier 캐시)
│   ├── TTSService (3-layer 캐시), SubscriptionService (RevenueCat)
│   └── SRSService (SM-2), NetworkMonitor, AnalyticsService (Sentry+Mixpanel)
├── Network (APIClient + 5개 Endpoint extension)
├── Data (정적 커리큘럼/컬렉션/프리미엄 메타데이터)
├── Models (Codable 구조체/열거형)
└── Views (34개 SwiftUI View)
```

### 기술 부채 Top 5

| 순위 | 항목 | 심각도 | 노력 |
|------|------|--------|------|
| 1 | **테스트 코드 전무** (XCTest 0개) | 높음 | 높음 |
| 2 | **Sentry captureError 0건** | 중간 | 낮음 |
| 3 | **TTS 캐시 LRU 미구현** | 중간 | 낮음 |
| 4 | **DEBUG/PROD API 동일** | 중간 | 낮음 |
| 5 | **swipeUpZone 중복** (~40줄) | 낮음 | 중간 |

### 보안 현황: 양호

시크릿 xcconfig 주입 (하드코딩 0건), Supabase Keychain 토큰, 401 자동 로그아웃, ATS 적용, PrivacyInfo.xcprivacy 구현 완료.

---

## IX. 실행 로드맵 (통합 타임라인)

### Week 1-2: 긴급 수정
- ImmersiveView 강제 언래핑 제거
- loadSummaries 상태 버그 수정
- 구독 syncWithServer 에러 처리
- LibrarySection 피커 한국어 전환
- Week 3 textFilePath nil 수정
- Mixpanel 퍼널 이벤트 4개 추가

### Week 3-4: 콘텐츠 & 안정성
- TTS 캐시 LRU eviction 구현
- 소형 터치 타겟 44pt 확보
- Premium 26개 미등록 세션 등록
- 미연결 Collection 14개 → 신규 컬렉션 2개
- Sentry captureError 추가 (전체 catch)
- ReadableContentBlock unknown type 방어

### Month 2: 전환율 & 마케팅 기반
- PaywallView 개선 (소셜 프루프, 기능 설명)
- 핵심 접근성 마크업 추가
- Premium 50개 Summary 배치 생성
- ASO 최적화 + 인스타그램 "오늘의 문장" 시작
- DateFormatter 공유 인스턴스 전환
- DEBUG/PROD 엔드포인트 분리

### Month 3: 성장 엔진
- SNS 공유 기능 출시 (GrammarViz 이미지)
- SRS 자동 연동 구현
- SRS 알고리즘 단위 테스트 + Xcode Test Target
- 온보딩 인터랙티브 체험 삽입

### Month 4-6: 스케일업
- 연간 가격 A/B 테스트
- B2B 파일럿 (5개사)
- iOS CI/CD 파이프라인
- Dynamic Type 지원
- 핵심 Services 테스트 커버리지 40%+

---

## X. 성공 지표 (KPI Dashboard)

### 성장

| 지표 | 3개월 | 6개월 | 12개월 |
|------|-------|-------|--------|
| 신규 설치 (월간) | 1,000 | 5,000 | 20,000 |
| DAU | 300 | 1,500 | 8,000 |
| MAU | 800 | 4,000 | 18,000 |

### 수익

| 지표 | 3개월 | 6개월 | 12개월 |
|------|-------|-------|--------|
| 유료 전환율 | 3% | 5% | 8% |
| 프리미엄 구독자 | 30 | 250 | 1,600 |
| MRR | ₩237K | ₩1.98M | ₩12.6M |

### 품질

| 지표 | 현재 | 3개월 | 6개월 |
|------|------|-------|-------|
| 단위 테스트 | 0개 | 50+ | 150+ |
| Sentry 캡처 지점 | 0 | 8+ | 전체 |
| 앱 노출 세션 | 95 | 135 | 160+ |
| App Store 평점 | — | 4.3+ | 4.6+ |

---

## XI. 결론

### 3개 팀 이상 공통 지적

1. **테스트 부재**: 79개 파일 중 XCTest 0개. SRS, SessionAccess, LibraryService 최우선
2. **Sentry 미활용**: SDK 설치 완료이나 captureError 0건. 프로덕션 에러 무음 실패
3. **콘텐츠 미노출**: 40개 세션이 JSON 존재하나 앱 미등록
4. **퍼널 측정 불가**: Mixpanel 이벤트 2개만 존재. 중간 이탈 분석 불가

### Dayread의 핵심 경쟁력

1. **4단계 딥리딩**: 시장 유일의 Overview→Immersive→Focus→Reoverview 순환
2. **문장 단위 정밀 분석**: 3,500+ 문장에 grammar/vocabulary/patterns/alignment 완비
3. **GrammarViz 시각화**: 색상 기반 문법 역할 — 광고 소재로서도 강력한 차별점
4. **Dayread Original**: 97개+ 자체 제작 세션, 이코노미스트 수준. 단기 복제 불가능

### 최우선 실행 (This Week, 합산 ~2시간)

| 순서 | 항목 | 소요 |
|------|------|------|
| 1 | ImmersiveView `sentence!` → guard let | 10분 |
| 2 | loadSummaries 상태 `.error` 설정 | 15분 |
| 3 | LibrarySection 한국어 전환 | 5분 |
| 4 | Week 3 textFilePath 4개 입력 | 10분 |
| 5 | syncWithServer 실패 시 toast 에러 | 30분 |
| 6 | Mixpanel 이벤트 4개 추가 | 1시간 |

**이 6개 항목으로 크래시 위험, 무한 로딩, 언어 정책 위반, 콘텐츠 누락, 결제 무음 실패를 모두 해소합니다.**

---

*6개 전문 팀이 79개 Swift 소스, 211개 SessionData JSON, 134개 마크다운을 직접 분석한 결과를 종합.*
