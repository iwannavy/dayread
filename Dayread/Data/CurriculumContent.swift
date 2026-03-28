import Foundation

enum CurriculumContent {
    static let freeWeekLimit = 3

    // MARK: - Week Content (12 weeks x 4 sessions = 48 items)

    static let weekContent: [Int: [CurriculumContentItem]] = [
        // Week 1
        1: [
            CurriculumContentItem(
                id: "w01-original-attention",
                weekNumber: 1,
                title: "Why Attention Makes Learning Stick",
                source: "Dayread Original",
                genre: "article",
                difficulty: 1,
                learningPoints: "SVO 기본형, simple present, because / if, attention·memory 기초 어휘",
                status: "session",
                sessionId: "original-attention-makes-learning-stick",
                textFilePath: "docs/text/week-01/article-original-attention-makes-learning-stick.md"
            ),
            CurriculumContentItem(
                id: "w01-small-habits",
                weekNumber: 1,
                title: "How Small Habits Change a Week",
                source: "Dayread Original",
                genre: "article",
                difficulty: 1,
                learningPoints: "빈도 부사, daily routine 어휘, simple present 반복 표현",
                status: "session",
                sessionId: "original-small-habits-change-a-week",
                textFilePath: "docs/text/week-01/article-original-small-habits-change-a-week.md"
            ),
            CurriculumContentItem(
                id: "w01-city-parks",
                weekNumber: 1,
                title: "Why City Parks Feel Cooler in Summer",
                source: "Dayread Original",
                genre: "article",
                difficulty: 1,
                learningPoints: "기초 과학 설명, because / so, 날씨·도시 어휘",
                status: "session",
                sessionId: "original-city-parks-feel-cooler-in-summer",
                textFilePath: "docs/text/week-01/article-original-city-parks-feel-cooler-in-summer.md"
            ),
            CurriculumContentItem(
                id: "w01-good-question",
                weekNumber: 1,
                title: "What Makes a Good Question",
                source: "Dayread Original",
                genre: "article",
                difficulty: 1,
                learningPoints: "be동사 정의문, 질문 관련 어휘, 간단한 설명 패턴",
                status: "session",
                sessionId: "original-what-makes-a-good-question",
                textFilePath: "docs/text/week-01/article-original-what-makes-a-good-question.md"
            ),
        ],
        // Week 2
        2: [
            CurriculumContentItem(
                id: "w02-desk-window",
                weekNumber: 2,
                title: "A Desk by the Window",
                source: "Dayread Original",
                genre: "article",
                difficulty: 1,
                learningPoints: "장소 전치사, there is / there are, 공간 묘사",
                status: "session",
                sessionId: "original-a-desk-by-the-window",
                textFilePath: "docs/text/week-02/article-original-a-desk-by-the-window.md"
            ),
            CurriculumContentItem(
                id: "w02-library",
                weekNumber: 2,
                title: "Inside a Neighborhood Library",
                source: "Dayread Original",
                genre: "article",
                difficulty: 1,
                learningPoints: "형용사 수식, 위치 묘사, everyday place vocabulary",
                status: "session",
                sessionId: "original-inside-a-neighborhood-library",
                textFilePath: "docs/text/week-02/article-original-inside-a-neighborhood-library.md"
            ),
            CurriculumContentItem(
                id: "w02-buses-city",
                weekNumber: 2,
                title: "Why Buses Shape a City",
                source: "Dayread Original",
                genre: "article",
                difficulty: 1,
                learningPoints: "도시 이동 어휘, because절, 공공 공간 묘사",
                status: "session",
                sessionId: "original-why-buses-shape-a-city",
                textFilePath: "docs/text/week-02/article-original-why-buses-shape-a-city.md"
            ),
            CurriculumContentItem(
                id: "w02-weather-map",
                weekNumber: 2,
                title: "Reading a Weather Map for the First Time",
                source: "Dayread Original",
                genre: "article",
                difficulty: 1,
                learningPoints: "기초 지도 표현, 색·방향 어휘, 전치사구",
                status: "session",
                sessionId: "original-reading-a-weather-map-for-the-first-time",
                textFilePath: "docs/text/week-02/article-original-reading-a-weather-map-for-the-first-time.md"
            ),
        ],
        // Week 3
        3: [
            CurriculumContentItem(
                id: "w03-stories-facts",
                weekNumber: 3,
                title: "Why Stories Stay Longer Than Facts",
                source: "Dayread Original",
                genre: "article",
                difficulty: 2,
                learningPoints: "비교급, because / so, 기억 관련 어휘",
                status: "session",
                sessionId: "original-stories-stay-longer-than-facts",
                textFilePath: "docs/text/week-03/article-original-stories-stay-longer-than-facts.md"
            ),
            CurriculumContentItem(
                id: "w03-study-styles",
                weekNumber: 3,
                title: "Two Friends, Two Study Styles",
                source: "Dayread Original",
                genre: "article",
                difficulty: 2,
                learningPoints: "비교·대조, while, 학습 습관 표현",
                status: "session",
                sessionId: "original-two-friends-two-study-styles",
                textFilePath: "docs/text/week-03/article-original-two-friends-two-study-styles.md"
            ),
            CurriculumContentItem(
                id: "w03-music-room",
                weekNumber: 3,
                title: "How Music Changes a Room",
                source: "Dayread Original",
                genre: "article",
                difficulty: 2,
                learningPoints: "원인-결과, 감각 묘사, 비교 표현",
                status: "session",
                sessionId: "original-how-music-changes-a-room",
                textFilePath: "docs/text/week-03/article-original-how-music-changes-a-room.md"
            ),
            CurriculumContentItem(
                id: "w03-teams-problems",
                weekNumber: 3,
                title: "Why Some Teams Solve Problems Faster",
                source: "Dayread Original",
                genre: "article",
                difficulty: 2,
                learningPoints: "이유 설명, 협업 어휘, 비교 구조",
                status: "session",
                sessionId: "original-why-some-teams-solve-problems-faster",
                textFilePath: "docs/text/week-03/article-original-why-some-teams-solve-problems-faster.md"
            ),
        ],
        // Week 4
        4: [
            CurriculumContentItem(
                id: "w04-phone-died",
                weekNumber: 4,
                title: "The Day My Phone Died Too Early",
                source: "Dayread Original",
                genre: "article",
                difficulty: 2,
                learningPoints: "과거시제, 시간 순서, 일상 문제 묘사",
                status: "session",
                sessionId: "original-the-day-my-phone-died-too-early",
                textFilePath: "docs/text/week-04/article-original-the-day-my-phone-died-too-early.md"
            ),
            CurriculumContentItem(
                id: "w04-missed-train",
                weekNumber: 4,
                title: "A Missed Train, A Better Plan",
                source: "Dayread Original",
                genre: "article",
                difficulty: 2,
                learningPoints: "after / then, 짧은 서사 전개, 교훈 표현",
                status: "session",
                sessionId: "original-a-missed-train-a-better-plan",
                textFilePath: "docs/text/week-04/article-original-a-missed-train-a-better-plan.md"
            ),
            CurriculumContentItem(
                id: "w04-cooking-rain",
                weekNumber: 4,
                title: "Cooking for Friends on a Rainy Night",
                source: "Dayread Original",
                genre: "article",
                difficulty: 2,
                learningPoints: "감각 어휘, 과거시제, 배경 묘사",
                status: "session",
                sessionId: "original-cooking-for-friends-on-a-rainy-night",
                textFilePath: "docs/text/week-04/article-original-cooking-for-friends-on-a-rainy-night.md"
            ),
            CurriculumContentItem(
                id: "w04-small-mistake",
                weekNumber: 4,
                title: "When a Small Mistake Taught Me Something Useful",
                source: "Dayread Original",
                genre: "article",
                difficulty: 2,
                learningPoints: "when절, 회고 문체, lesson learned 표현",
                status: "session",
                sessionId: "original-when-a-small-mistake-taught-me-something-useful",
                textFilePath: "docs/text/week-04/article-original-when-a-small-mistake-taught-me-something-useful.md"
            ),
        ],
        // Week 5
        5: [
            CurriculumContentItem(
                id: "w05-school-start",
                weekNumber: 5,
                title: "Should School Start Later?",
                source: "Dayread Original",
                genre: "article",
                difficulty: 3,
                learningPoints: "should, 의견-근거, school policy 어휘",
                status: "session",
                sessionId: "original-should-school-start-later",
                textFilePath: "docs/text/week-05/article-original-should-school-start-later.md"
            ),
            CurriculumContentItem(
                id: "w05-four-day",
                weekNumber: 5,
                title: "Is a Four-Day Workweek Worth Trying?",
                source: "Dayread Original",
                genre: "article",
                difficulty: 3,
                learningPoints: "worth ~ing, however, 일과 휴식 어휘",
                status: "session",
                sessionId: "original-is-a-four-day-workweek-worth-trying",
                textFilePath: "docs/text/week-05/article-original-is-a-four-day-workweek-worth-trying.md"
            ),
            CurriculumContentItem(
                id: "w05-rules-creativity",
                weekNumber: 5,
                title: "Why Some Rules Help Creativity",
                source: "Dayread Original",
                genre: "article",
                difficulty: 3,
                learningPoints: "주장과 반례, should / can, 창의성 어휘",
                status: "session",
                sessionId: "original-why-some-rules-help-creativity",
                textFilePath: "docs/text/week-05/article-original-why-some-rules-help-creativity.md"
            ),
            CurriculumContentItem(
                id: "w05-quiet-spaces",
                weekNumber: 5,
                title: "Do We Need More Quiet Spaces?",
                source: "Dayread Original",
                genre: "article",
                difficulty: 3,
                learningPoints: "공공 공간 논의, 의견형 질문, 근거 제시",
                status: "session",
                sessionId: "original-do-we-need-more-quiet-spaces",
                textFilePath: "docs/text/week-05/article-original-do-we-need-more-quiet-spaces.md"
            ),
        ],
        // Week 6
        6: [
            CurriculumContentItem(
                id: "w06-grocery-prices",
                weekNumber: 6,
                title: "Why Grocery Prices Feel Different Every Week",
                source: "Dayread Original",
                genre: "article",
                difficulty: 3,
                learningPoints: "원인 사슬, 가격 관련 어휘, 과정 설명",
                status: "session",
                sessionId: "original-why-grocery-prices-feel-different-every-week",
                textFilePath: "docs/text/week-06/article-original-why-grocery-prices-feel-different-every-week.md"
            ),
            CurriculumContentItem(
                id: "w06-heavy-rain",
                weekNumber: 6,
                title: "How a City Plans for Heavy Rain",
                source: "Dayread Original",
                genre: "article",
                difficulty: 3,
                learningPoints: "수동태 입문, 도시 시스템 어휘, 순서 설명",
                status: "session",
                sessionId: "original-how-a-city-plans-for-heavy-rain",
                textFilePath: "docs/text/week-06/article-original-how-a-city-plans-for-heavy-rain.md"
            ),
            CurriculumContentItem(
                id: "w06-delivery-chain",
                weekNumber: 6,
                title: "What Happens When a Delivery Chain Slows Down",
                source: "Dayread Original",
                genre: "article",
                difficulty: 3,
                learningPoints: "what happens when, 시스템 설명, 공급망 기초 어휘",
                status: "session",
                sessionId: "original-what-happens-when-a-delivery-chain-slows-down",
                textFilePath: "docs/text/week-06/article-original-what-happens-when-a-delivery-chain-slows-down.md"
            ),
            CurriculumContentItem(
                id: "w06-public-maps",
                weekNumber: 6,
                title: "Why Public Maps Matter in Emergencies",
                source: "Dayread Original",
                genre: "article",
                difficulty: 3,
                learningPoints: "공공 안전 어휘, 이유 설명, 정보 설계 표현",
                status: "session",
                sessionId: "original-why-public-maps-matter-in-emergencies",
                textFilePath: "docs/text/week-06/article-original-why-public-maps-matter-in-emergencies.md"
            ),
        ],
        // Week 7
        7: [
            CurriculumContentItem(
                id: "w07-break-ice",
                weekNumber: 7,
                title: "Why People Say Break the Ice",
                source: "Dayread Original",
                genre: "article",
                difficulty: 3,
                learningPoints: "이디엄, social interaction 어휘, 구어체 설명",
                status: "session",
                sessionId: "original-why-people-say-break-the-ice",
                textFilePath: "docs/text/week-07/article-original-why-people-say-break-the-ice.md"
            ),
            CurriculumContentItem(
                id: "w07-same-page",
                weekNumber: 7,
                title: "What On the Same Page Really Means",
                source: "Dayread Original",
                genre: "article",
                difficulty: 3,
                learningPoints: "관용 표현, 협업 collocations, 의미 확장",
                status: "session",
                sessionId: "original-what-on-the-same-page-really-means",
                textFilePath: "docs/text/week-07/article-original-what-on-the-same-page-really-means.md"
            ),
            CurriculumContentItem(
                id: "w07-slang-online",
                weekNumber: 7,
                title: "How Slang Travels Online",
                source: "Dayread Original",
                genre: "article",
                difficulty: 3,
                learningPoints: "온라인 문화 어휘, 비격식 표현, tone 차이",
                status: "session",
                sessionId: "original-how-slang-travels-online",
                textFilePath: "docs/text/week-07/article-original-how-slang-travels-online.md"
            ),
            CurriculumContentItem(
                id: "w07-humor-cultures",
                weekNumber: 7,
                title: "When Humor Crosses Cultures Well",
                source: "Dayread Original",
                genre: "article",
                difficulty: 3,
                learningPoints: "문화 맥락, when절, 표현 차이",
                status: "session",
                sessionId: "original-when-humor-crosses-cultures-well",
                textFilePath: "docs/text/week-07/article-original-when-humor-crosses-cultures-well.md"
            ),
        ],
        // Week 8
        8: [
            CurriculumContentItem(
                id: "w08-problem-clearly",
                weekNumber: 8,
                title: "Explaining a Problem Clearly",
                source: "Dayread Original",
                genre: "article",
                difficulty: 3,
                learningPoints: "요약과 설명, 순서 표현, 문제 정의",
                status: "session",
                sessionId: "original-explaining-a-problem-clearly",
                textFilePath: "docs/text/week-08/article-original-explaining-a-problem-clearly.md"
            ),
            CurriculumContentItem(
                id: "w08-two-sides",
                weekNumber: 8,
                title: "Summarizing Two Sides Fairly",
                source: "Dayread Original",
                genre: "article",
                difficulty: 3,
                learningPoints: "balanced summary, on the one hand, 대조",
                status: "session",
                sessionId: "original-summarizing-two-sides-fairly",
                textFilePath: "docs/text/week-08/article-original-summarizing-two-sides-fairly.md"
            ),
            CurriculumContentItem(
                id: "w08-short-talk",
                weekNumber: 8,
                title: "Turning Notes into a Short Talk",
                source: "Dayread Original",
                genre: "article",
                difficulty: 3,
                learningPoints: "말하기 준비, 전환 표현, 구조화",
                status: "session",
                sessionId: "original-turning-notes-into-a-short-talk",
                textFilePath: "docs/text/week-08/article-original-turning-notes-into-a-short-talk.md"
            ),
            CurriculumContentItem(
                id: "w08-useful-feedback",
                weekNumber: 8,
                title: "Giving Useful Feedback to a Friend",
                source: "Dayread Original",
                genre: "article",
                difficulty: 3,
                learningPoints: "피드백 표현, 조심스러운 말하기, 친절한 톤",
                status: "session",
                sessionId: "original-giving-useful-feedback-to-a-friend",
                textFilePath: "docs/text/week-08/article-original-giving-useful-feedback-to-a-friend.md"
            ),
        ],
        // Week 9
        9: [
            CurriculumContentItem(
                id: "w09-third-places",
                weekNumber: 9,
                title: "Why Third Places Matter",
                source: "Dayread Original",
                genre: "article",
                difficulty: 4,
                learningPoints: "사회 분석, 추상 명사, 장문 단락 읽기",
                status: "session",
                sessionId: "original-why-third-places-matter",
                textFilePath: "docs/text/week-09/article-original-why-third-places-matter.md"
            ),
            CurriculumContentItem(
                id: "w09-neighborhood-fair",
                weekNumber: 9,
                title: "What Makes a Neighborhood Feel Fair",
                source: "Dayread Original",
                genre: "article",
                difficulty: 4,
                learningPoints: "공정성 어휘, 양보 표현, 사회 주제 분석",
                status: "session",
                sessionId: "original-what-makes-a-neighborhood-feel-fair",
                textFilePath: "docs/text/week-09/article-original-what-makes-a-neighborhood-feel-fair.md"
            ),
            CurriculumContentItem(
                id: "w09-screens-attention",
                weekNumber: 9,
                title: "How Screens Change Public Attention",
                source: "Dayread Original",
                genre: "article",
                difficulty: 4,
                learningPoints: "공적 관심, 미디어 어휘, 복합 설명",
                status: "session",
                sessionId: "original-how-screens-change-public-attention",
                textFilePath: "docs/text/week-09/article-original-how-screens-change-public-attention.md"
            ),
            CurriculumContentItem(
                id: "w09-trust-rebuild",
                weekNumber: 9,
                title: "Why Trust Is Hard to Rebuild",
                source: "Dayread Original",
                genre: "article",
                difficulty: 4,
                learningPoints: "추상 개념 설명, concede / rebuild, 장문 구조",
                status: "session",
                sessionId: "original-why-trust-is-hard-to-rebuild",
                textFilePath: "docs/text/week-09/article-original-why-trust-is-hard-to-rebuild.md"
            ),
        ],
        // Week 10
        10: [
            CurriculumContentItem(
                id: "w10-read-survey",
                weekNumber: 10,
                title: "How to Read a Survey Without Being Fooled",
                source: "Dayread Original",
                genre: "article",
                difficulty: 4,
                learningPoints: "evidence reading, 수치 해석, 조심스러운 판단",
                status: "session",
                sessionId: "original-how-to-read-a-survey-without-being-fooled",
                textFilePath: "docs/text/week-10/article-original-how-to-read-a-survey-without-being-fooled.md"
            ),
            CurriculumContentItem(
                id: "w10-good-study",
                weekNumber: 10,
                title: "What a Good Study Actually Shows",
                source: "Dayread Original",
                genre: "article",
                difficulty: 4,
                learningPoints: "연구 읽기, hedging, 결과 해석",
                status: "session",
                sessionId: "original-what-a-good-study-actually-shows",
                textFilePath: "docs/text/week-10/article-original-what-a-good-study-actually-shows.md"
            ),
            CurriculumContentItem(
                id: "w10-correlation-cause",
                weekNumber: 10,
                title: "Correlation, Cause, and Careful Claims",
                source: "Dayread Original",
                genre: "article",
                difficulty: 4,
                learningPoints: "correlation vs cause, may / might, 근거 구분",
                status: "session",
                sessionId: "original-correlation-cause-and-careful-claims",
                textFilePath: "docs/text/week-10/article-original-correlation-cause-and-careful-claims.md"
            ),
            CurriculumContentItem(
                id: "w10-small-samples",
                weekNumber: 10,
                title: "Why Small Samples Mislead Us",
                source: "Dayread Original",
                genre: "article",
                difficulty: 4,
                learningPoints: "표본 어휘, 연구 한계, 데이터 읽기",
                status: "session",
                sessionId: "original-why-small-samples-mislead-us",
                textFilePath: "docs/text/week-10/article-original-why-small-samples-mislead-us.md"
            ),
        ],
        // Week 11
        11: [
            CurriculumContentItem(
                id: "w11-tool-bad-habit",
                weekNumber: 11,
                title: "Can a Useful Tool Also Be a Bad Habit?",
                source: "Dayread Original",
                genre: "essay",
                difficulty: 5,
                learningPoints: "양면성 논의, 양보와 반박, 추상 토론",
                status: "session",
                sessionId: "original-can-a-useful-tool-also-be-a-bad-habit",
                textFilePath: "docs/text/week-11/essay-original-can-a-useful-tool-also-be-a-bad-habit.md"
            ),
            CurriculumContentItem(
                id: "w11-safety-freedom",
                weekNumber: 11,
                title: "When Safety and Freedom Pull Apart",
                source: "Dayread Original",
                genre: "essay",
                difficulty: 5,
                learningPoints: "공공 논쟁, 가치 충돌, nuanced language",
                status: "session",
                sessionId: "original-when-safety-and-freedom-pull-apart",
                textFilePath: "docs/text/week-11/essay-original-when-safety-and-freedom-pull-apart.md"
            ),
            CurriculumContentItem(
                id: "w11-good-arguments",
                weekNumber: 11,
                title: "Why Good Arguments Name Their Limits",
                source: "Dayread Original",
                genre: "essay",
                difficulty: 5,
                learningPoints: "반론, limits of argument, 메타 논증",
                status: "session",
                sessionId: "original-why-good-arguments-name-their-limits",
                textFilePath: "docs/text/week-11/essay-original-why-good-arguments-name-their-limits.md"
            ),
            CurriculumContentItem(
                id: "w11-change-mind",
                weekNumber: 11,
                title: "What It Means to Change Your Mind",
                source: "Dayread Original",
                genre: "essay",
                difficulty: 5,
                learningPoints: "입장 수정, 추상 성찰, debate language",
                status: "session",
                sessionId: "original-what-it-means-to-change-your-mind",
                textFilePath: "docs/text/week-11/essay-original-what-it-means-to-change-your-mind.md"
            ),
        ],
        // Week 12
        12: [
            CurriculumContentItem(
                id: "w12-letter-future",
                weekNumber: 12,
                title: "A Letter to Your Future Self as a Learner",
                source: "Dayread Original",
                genre: "essay",
                difficulty: 5,
                learningPoints: "미래지향 표현, 성찰형 문체, 자기 피드백",
                status: "session",
                sessionId: "original-a-letter-to-your-future-self-as-a-learner",
                textFilePath: "docs/text/week-12/essay-original-a-letter-to-your-future-self-as-a-learner.md"
            ),
            CurriculumContentItem(
                id: "w12-world-build",
                weekNumber: 12,
                title: "What Kind of World Do We Want to Build?",
                source: "Dayread Original",
                genre: "essay",
                difficulty: 5,
                learningPoints: "설득적 질문, 가치 언어, 종합 논의",
                status: "session",
                sessionId: "original-what-kind-of-world-do-we-want-to-build",
                textFilePath: "docs/text/week-12/essay-original-what-kind-of-world-do-we-want-to-build.md"
            ),
            CurriculumContentItem(
                id: "w12-learning-burnout",
                weekNumber: 12,
                title: "How to Keep Learning Without Burning Out",
                source: "Dayread Original",
                genre: "essay",
                difficulty: 5,
                learningPoints: "장기 학습 전략, 감정 어휘, 조언형 문체",
                status: "session",
                sessionId: "original-how-to-keep-learning-without-burning-out",
                textFilePath: "docs/text/week-12/essay-original-how-to-keep-learning-without-burning-out.md"
            ),
            CurriculumContentItem(
                id: "w12-explain-simply",
                weekNumber: 12,
                title: "The Skill of Explaining Hard Things Simply",
                source: "Dayread Original",
                genre: "essay",
                difficulty: 5,
                learningPoints: "통합 설명문, 설득적 결론, 메타 학습",
                status: "session",
                sessionId: "original-the-skill-of-explaining-hard-things-simply",
                textFilePath: "docs/text/week-12/essay-original-the-skill-of-explaining-hard-things-simply.md"
            ),
        ],
    ]

    // MARK: - Lazy Computed Maps

    private static let sessionWeekMap: [String: Int] = {
        var map: [String: Int] = [:]
        for (week, items) in weekContent {
            for item in items where item.status == "session" && item.sessionId != nil {
                map[item.sessionId!] = week
            }
        }
        return map
    }()

    private static let sessionItemMap: [String: CurriculumContentItem] = {
        var map: [String: CurriculumContentItem] = [:]
        for (_, items) in weekContent {
            for item in items where item.status == "session" && item.sessionId != nil {
                map[item.sessionId!] = item
            }
        }
        return map
    }()

    private static let freeSessionIds: Set<String> = {
        var ids: Set<String> = []
        for week in 1...freeWeekLimit {
            guard let items = weekContent[week] else { continue }
            for item in items where item.status == "session" && item.sessionId != nil {
                ids.insert(item.sessionId!)
            }
        }
        return ids
    }()

    // MARK: - Helper Functions

    static func getWeekContent(_ week: Int) -> [CurriculumContentItem] {
        return weekContent[week] ?? []
    }

    static func getSessionWeek(_ sessionId: String) -> Int? {
        return sessionWeekMap[sessionId]
    }

    static func getCurriculumSessionItem(_ sessionId: String) -> CurriculumContentItem? {
        return sessionItemMap[sessionId]
    }

    static func isCurriculumSessionId(_ sessionId: String) -> Bool {
        return sessionItemMap[sessionId] != nil
    }

    static func isFreeCurriculumSessionId(_ sessionId: String) -> Bool {
        return freeSessionIds.contains(sessionId)
    }
}
