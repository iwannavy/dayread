# 저작권 리스크 분석: Dayread 학습 콘텐츠

> 교차 검증 보고서 | 2026-03-28
> 에이전트: Leader (Claude Opus 4.6) + Codex (GPT-5.4 xhigh)

---

## 1. 분석 범위

| 항목 | 수치 |
|------|------|
| 전체 세션 파일 | 212개 (Resources/SessionData/*.json) |
| 프리미엄 원본 텍스트 | 38개 (docs/text/premium/original/*.md) |
| 외부 소스 콘텐츠 | 79개 (37.4%) |
| Dayread Original | 134개 (63.2%) — AI 생성, 저작권 문제 없음 |

## 2. 핵심 발견 — 합의 영역

**Leader와 Codex 모두 동일한 결론에 도달한 사항:**

### 2.1 원문은 전문(verbatim) 복제됨

- JSON의 `rawText` 필드 = 원본 기사 전문 그대로 포함
- `sentences[].original` = rawText를 문장 단위로 분리한 것 (100% 동일 텍스트)
- **Codex 정량 측정**: 외부 소스 79건, rawText 총 43,012단어, sentences 총 39,237단어
- The Economist/NYT: 문장-원문 일치율 **99.6~100%** (사실상 전문)
- TED: 일치율 **98.2%** (발췌이나 표현 동일)

### 2.2 리스크 분류

| 리스크 등급 | 파일 수 | 총 단어 | 소스 |
|------------|---------|---------|------|
| **🔴 HIGH** | **13** | ~14,000 | The Economist(9), NYT(2), The Atlantic(1), Wired(1) |
| **🟡 MEDIUM** | **40** | ~18,000 | TED(20+), 에세이(10+), arXiv(2), 기타 |
| **🟢 LOW** | **24** | ~10,000 | 공개 연설문(15), VOA/BBC(9) |
| **⚪ NONE** | **134** | ~200,000+ | Dayread Original (AI 생성) |

### 2.3 Fair Use 4요소 분석

| 요소 | 판단 | 근거 |
|------|------|------|
| (1) 사용 목적 | **불리** | 상업적 유료 구독 앱. 교육 목적이나 변환적(transformative) 주장 가능하지만, *Andy Warhol v. Goldsmith* (2023) 이후 상업적 목적에 대한 법원 기준 강화 |
| (2) 저작물 성격 | **불리** | 뉴스 기사, 에세이 = 창작적 표현이 포함된 저작물 |
| (3) 사용 분량 | **매우 불리** | 기사 전문 복제 (100%). 핵심 부분만이 아닌 전체 |
| (4) 시장 효과 | **매우 불리** | 원본 기사를 읽을 필요 없이 앱에서 전문 열람 가능 → 시장 대체 효과 |

**결론: Fair use 항변은 HIGH RISK 콘텐츠에 대해 극히 어려움.**

### 2.4 한국 저작권법 관점

- 제28조(공표된 저작물의 인용): "정당한 범위 안에서 공정한 관행에 합치되게" 인용 가능
- 전문 복제는 "정당한 범위"를 명백히 초과
- 제136조: 저작권 침해는 5년 이하 징역 또는 5천만원 이하 벌금

## 3. 상충 의견

없음. Leader와 Codex 분석이 일치.

## 4. 상세 파일 목록

### 🔴 HIGH RISK — 즉시 제거 필요 (13개)

| 파일 | 소스 | 제목 | 단어 수 | 복제율 |
|------|------|------|---------|--------|
| economist-ai-danger-2026.json | The Economist | AI danger gets real | 983 | 100% |
| economist-asia-energy-panic-2026.json | The Economist | The Iran war has put Asia on the brink of an energy panic | 1,274 | 100% |
| economist-china-ai-hongbao-2026.json | The Economist | China's AI giants are handing out cash to lure in users | 537 | 100% |
| economist-defence-stocks-2026.json | The Economist | Why war isn't always good for defence stocks | 729 | 100% |
| economist-electricity-ai-2026.json | The Economist | Americans' electricity bills are up. Don't blame AI | 801 | 100% |
| economist-firm-growth-2026.json | The Economist — Free Exchange | To understand why countries grow, look at their firms | 1,010 | 100% |
| economist-glass-ceiling-2026.json | The Economist | The Economist's glass-ceiling index | 733 | 100% |
| economist-k-shaped-economy-2026.json | The Economist | Would America be in recession without the super-rich? | 887 | 100% |
| economist-space-datacentres-2026.json | The Economist | Data centres in space: less crazy than you think | 1,300 | 100% |
| nyt-oil-prices-surge-2026.json | The New York Times | Oil Prices Surge Above $100 a Barrel | 666 | 100% |
| nyt-stablecoins-treasuries-2026.json | The New York Times | A Crypto Coin Is Gobbling Up U.S. Treasuries | 1,501 | 100% |
| carr-google-stupid.json | The Atlantic | Is Google Making Us Stupid? | ~500 | 발췌 |
| joy-future-doesnt-need-us.json | Wired Magazine | Why the Future Doesn't Need Us | ~400 | 발췌 |

### 🟡 MEDIUM RISK — 라이선스 확보 또는 교체 (40개)

**TED (20+개)**: CC BY-NC-ND 라이선스. 상업적 앱 = NC 위반, 분석 추가 = ND 위반 가능
- 발췌 비율: 10~40% (원 강연 대비)
- 대표: ted-robinson-schools-creativity (465단어/원 ~2,500단어)

**블로그 에세이**: Paul Graham(3), Sam Altman(2), Dario Amodei(2), Orwell(2), 기타
- Orwell (1936, 1946): 대부분 국가에서 퍼블릭 도메인 (사후 70년+)
- Paul Graham: 블로그 공개이나 저작권 보유. 상업적 전문 복제는 문제

**arXiv 논문 (2개)**: 저자 저작권 보유. 초록/발췌 수준은 학술 관행상 허용적

### 🟢 LOW RISK (24개)

**VOA (7개)**: 미국 정부 자금, 교육 목적 사용 관대. 상업적 전체 복제는 확인 필요
**BBC (1개)**: BBC 콘텐츠는 저작권 보호, 낮은 우선순위
**공개 연설문 (15개)**: 대부분 공정 사용 가능
- **주의**: MLK "I Have a Dream" — King 유족이 저작권 적극 집행

## 5. 최종 판단 및 권고

### 즉시 조치 (1주 이내)

1. **🔴 HIGH RISK 13개 파일 제거**: 앱 번들에서 삭제
   - `economist-*.json` (9개)
   - `nyt-*.json` (2개)
   - `carr-google-stupid.json`
   - `joy-future-doesnt-need-us.json`

2. **교체 콘텐츠 생성**: 동일 주제를 Dayread Original로 재작성
   - 예: "AI danger gets real" → AI 위험성에 대한 자체 에디토리얼
   - 기존 Dayread Original 파이프라인 활용

3. **manifest.json 업데이트**: 제거된 세션 ID 반영

### 단기 조치 (1개월 이내)

4. **TED 콘텐츠 재검토**: CC BY-NC-ND 라이선스 준수 여부 확인
   - 옵션 A: TED Media에 상업적 교육 라이선스 문의
   - 옵션 B: 자체 콘텐츠로 교체 (추천)

5. **MLK 연설문 제거**: `speech-mlk-dream.json` — King 유족의 적극적 저작권 집행

6. **블로그 에세이**: 저자에게 사용 허가 이메일 (PG, Altman 등은 관대한 편)

### 장기 전략

7. **콘텐츠 소싱 가이드라인**:
   - 외부 소스: 최대 10% 발췌 + 출처 링크 (fair use 범위)
   - 원칙: Dayread Original 비율 90%+ 목표 (현재 63%)
   - 공공 도메인/CC 콘텐츠 우선 사용

8. **라이선스 메타데이터 추가**: 각 세션 JSON에 `license` 필드 추가
   ```json
   "license": {
     "type": "dayread-original" | "public-domain" | "cc-by" | "fair-use-excerpt",
     "source_url": "...",
     "excerpt_ratio": 0.15
   }
   ```

## 6. 신뢰도

| 에이전트 | 신뢰도 | 근거 |
|----------|--------|------|
| Leader (Opus 4.6) | **High** | 전체 파일 읽기 + 1:1 비교 실증 + 법적 원칙 적용 |
| Codex (GPT-5.4) | **High** | 정량 분석(유사도 측정) + 웹 검색(저작권법, 판례, ToS 확인) |
| Claude Reviewer | N/A | 결과 미생성 |

**종합 신뢰도: High** — 두 에이전트가 독립적으로 동일 결론 도달. 정량/정성 분석 모두 일치. 구체적 법률 자문은 저작권 전문 변호사 확인 권장.

---

*교차 검증 완료. 보고서 생성: 2026-03-28 16:47 KST*
