# 저작권 유사성 교차 검증 보고서: Dayread 프리미엄 학습자료

> 교차 검증 보고서 | 2026-03-28 21:17
> Leader: Claude Opus 4.6 | Codex: GPT-5.4-xhigh | Claude Reviewer: Opus 4.6

---

## 1. 분석 범위

| 항목 | 수치 |
|------|------|
| 프리미엄 원본 (original) | 38개 |
| 참조 원본 폴더 (reference) | 16개 |
| 직접 대응쌍 (basename 일치) | 15쌍 |
| 주제 매칭 포함 대응 | 28쌍 |
| 중복 파일 (날짜만 상이, 본문 동일) | 13쌍 |
| 평균 원본 길이 | 430단어 |
| 평균 참조 합산 길이 | 3,067단어 |
| 원본/참조 압축률 | 15.2% |

---

## 2. 합의 영역 (세 에이전트 공통 결론)

### 2.1. 직접 복제(Verbatim Copy)는 낮음

| 지표 | Leader | Codex | Claude Reviewer |
|------|--------|-------|----------------|
| 5-gram 평균 겹침 | 1.6% | 1.63% | 0.5%~3.6% |
| 8-gram 평균 겹침 | 0.15% | 0.15% | ~0% |
| 최대 연속 일치 평균 | 6.9단어 | 6.87단어 | 5~8단어 |
| 정확 문장 일치 | 0건 | 0건 | 0건 |

**결론**: 문장 수준의 verbatim 복제는 사실상 없음. 학술 표절 탐지 기준(5-10%) 대비 1/3~1/10 수준.

### 2.2. 프로젝트 자체 규칙 위반 3건 존재

세 에이전트 모두 9단어 이상 연속 일치 사례를 식별:

| 파일 | 최장 일치 | 위반 구절 |
|------|----------|----------|
| `american-power-symbols..._3` | 9단어 | "federal law bars the depiction of living presidents on" |
| `indias-contradictions..._2` | 9단어 | "little to boost domestic production or diversify its supply" |
| `iran-deadlock..._4` | 9단어 | "the most intensive opening air campaign in modern history" |

**프로젝트 규칙("No 9-word n-gram overlap") 위반 → 즉시 패러프레이즈 수정 필요.**

### 2.3. 패러프레이즈 품질은 대체로 양호

- 문장 표면은 실질적으로 변환됨 (평균 문장 유사도 0.408, 0.65 이상은 전체의 4%)
- 숫자를 글자로 표기($97bn → "ninety-seven billion dollars"), 어휘 교체("rate" → "pace") 등 의미적 패러프레이즈 적용
- Noma, Europe, Russia 쌍은 구조적 재구성이 특히 철저

---

## 3. 상충 의견 (에이전트 간 견해 차이)

### 3.1. 전체 리스크 등급

| 에이전트 | 판정 | 근거 |
|---------|------|------|
| **Leader** | 80% 안전, 20% 위반 (n-gram 기준) | 정량적 규칙 위반 중심. 대부분 안전 범위 |
| **Claude Reviewer** | 대체로 안전, 일부 주의 | 5개 샘플 심층 분석. 출처 미표기가 주요 리스크 |
| **Codex** | 조건부 Medium 리스크 | 가장 보수적. n-gram 낮아도 구조적 파생물 리스크 존재 |

### 3.2. "n-gram이 낮으면 안전한가?"

- **Leader/Claude Reviewer**: n-gram 기준으로 대부분 안전. 표현 변환이 충분.
- **Codex**: n-gram이 낮아도 **문단-원천 cosine 유사도가 높으므로** (71개 문단 중 57개가 0.5 이상) 구조적 파생물(derivative work)로 볼 여지 있음. **"selection/arrangement/expression"이 보호 논점.**

### 3.3. "Gaps AI Cannot Close" 쌍의 위험도

- **Leader**: 8단어 경계선 (기술 서술이므로 자연스러운 겹침)
- **Claude Reviewer**: **준-직접 인용** — "computing performance has roughly tripled every few years, but off-chip memory bandwidth has improved by only a factor of about 1.6"이 원문과 실질 동일. 단어 1~2개만 변경.
- **Codex**: 5-gram 3.6%로 전체 최고. 리스크 Medium-High.

**종합 판단**: Claude Reviewer의 분석이 가장 구체적. 해당 문장은 즉시 재작성 대상.

---

## 4. 고유 인사이트 (각 에이전트만 발견한 관점)

### 4.1. Codex만 발견

- **13쌍 중복 파일**: 날짜만 변경하고 본문 MD5 해시가 동일한 구/신버전 13쌍 존재. provenance 추적과 삭제 대응을 복잡하게 만듦.
- **문단-원천 구조 분석**: 7/15쌍은 reference 기사 순서(R1→R2→R3)를 그대로 따름. "기사 세 개를 순서대로 한 문단씩 뽑아 엮은" 패턴이 구조적 독립성을 약화.
- **reference 폴더 자체의 고위험**: 외부 매체 기사 전문이 저장되어 있으므로, 앱 번들이나 외부 동기화에 포함되면 original보다 훨씬 큰 저작권 문제.
- **법적 기준 교차 확인**: 미국 17 U.S.C. §107, 한국 저작권법 제35조의5를 공식 출처에서 직접 확인.

### 4.2. Claude Reviewer만 발견

- **출처 미표기 리스크**: "Dayread Original"이라고만 표기하고 실제 참조 출처(The Economist, NYT 등)를 밝히지 않음. Fair use 판단에서 출처 표기는 중요한 방어 요소.
- **"total concept and feel" 테스트 리스크**: 일부 원본은 참조 기사의 factual core를 거의 그대로 전달하여, 전체적 개념과 느낌의 유사성 테스트에서 문제될 수 있음.
- **상업적 이용 불리**: 유료 프리미엄 콘텐츠로 판매한다는 점이 fair use 4요소 중 "이용의 목적 및 성격"에서 불리.

### 4.3. Leader만 발견

- **참조 폴더 없는 23개 원본**: 전체 38개 중 reference 폴더와 매칭되지 않는 원본이 23개. 이들의 저작권 상태를 별도 검증 불가.
- **8단어 경계선 5건의 성격 분류**: 사실 진술("using military force to unify china and taiwan"), 기술 서술, 일반적 시간 표현 등으로 세분화.

---

## 5. 최종 판단

### 5.1. 종합 리스크 등급: **Medium** (조건부)

현재 프리미엄 학습자료는 **"직접 복제"가 아닌 "강하게 source-conditioned된 추상 요약/재구성"**에 해당합니다.

- **Literal copying 리스크**: 낮음 (5-gram 1.6%, 문장 일치 0건)
- **Derivative work 리스크**: 중간 (문단 구조가 원천에 고정, 구조적 독립성 부족)
- **규칙 위반**: 3건 (9단어 연속 일치) + 8건 경계선 (8단어)
- **상업적 이용 리스크**: 중~높음 (유료 프리미엄, 출처 미표기)

### 5.2. 즉시 조치 필요 항목

| 우선순위 | 항목 | 상세 |
|---------|------|------|
| P0 | 9단어 위반 3건 수정 | 해당 문장을 패러프레이즈하여 8단어 이하로 |
| P0 | "Gaps AI" 준-직접 인용 수정 | "computing performance..." 문장 전면 재작성 |
| P1 | 8단어 경계선 5건 재검토 | 안전 마진 확보를 위해 표현 변형 |
| P1 | 13쌍 중복 파일 정리 | 구버전 제거 또는 canonical 파일 지정 |

### 5.3. 구조적 개선 권장 항목

| 우선순위 | 항목 | 상세 |
|---------|------|------|
| P1 | 자동 n-gram 검사 파이프라인 | `generate-premium-study.mjs` 후처리에 5-gram>2%, max-run>=8 자동 경고 추가 |
| P1 | 출처 속성 추가 | "Based on reporting by The Economist (March 2026)" 등 일반적 출처 표기 |
| P2 | reference 폴더 격리 | .gitignore 추가 또는 앱 번들 제외 확인 |
| P2 | 구조적 독립성 강화 | 독자적 논점, 반론, 비-source 예시 삽입으로 변환성(transformativeness) 향상 |
| P3 | 법률 자문 | 상업적 유료 서비스에서 외부 매체 참조 기반 콘텐츠 모델에 대한 전문 법률 자문 |

---

## 6. 정량 데이터 부록

### 15쌍 전수 n-gram 분석 (Leader 실행)

| 파일 | 단어수 | 5-gram% | 8-gram% | 최장일치 | 판정 |
|------|--------|---------|---------|---------|------|
| noma | 347 | 0.6% | 0.0% | 5 | 안전 |
| africas-new-growth-story | 389 | 0.5% | 0.0% | 6 | 안전 |
| american-power-symbols | 446 | 2.0% | 0.5% | **9** | **위반** |
| chinas-shifting-calculus | 437 | 1.2% | 0.2% | 8 | 주의 |
| cultural-crosscurrents | 432 | 0.5% | 0.0% | 5 | 안전 |
| europes-economic-reset | 386 | 0.5% | 0.0% | 5 | 안전 |
| forces-reshaping-corporate | 383 | 0.0% | 0.0% | 4 | 안전 |
| gaps-ai-cannot-close | 416 | 3.6% | 0.2% | 8 | 주의 |
| gulf-energy-shock | 459 | 1.5% | 0.0% | 6 | 안전 |
| hidden-fragilities | 453 | 1.6% | 0.0% | 7 | 주의 |
| indias-contradictions | 417 | 2.2% | 0.5% | **9** | **위반** |
| iran-deadlock | 452 | 2.7% | 0.4% | **9** | **위반** |
| latin-americas-economic | 455 | 2.4% | 0.2% | 8 | 주의 |
| russias-war-economy | 452 | 1.3% | 0.0% | 6 | 안전 |
| scientific-frontiers | 450 | 3.1% | 0.2% | 8 | 주의 |

### Codex 추가 지표 (15쌍)

| 지표 | 값 |
|------|-----|
| Bigram containment 평균 | 23.96% |
| Trigram containment 평균 | 8.04% |
| 문단 best-match cosine 평균 | 0.595 |
| cosine >= 0.6 문단 비율 | 56% (40/71) |
| cosine >= 0.7 문단 비율 | 20% (14/71) |
| 기사 순서 유지 비율 | 47% (7/15) |

---

*보고서 생성: Claude Opus 4.6 (Leader) | 2026-03-28*
*원본 작업 디렉토리: .xverify/20260328_211725/*
