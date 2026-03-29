import Foundation

enum CollectionContent {

    // MARK: - Static Data

    static let collections: [CollectionMeta] = [
        // 1. Research Reading (10 sessions)
        CollectionMeta(
            id: "research-reading",
            title: "Research Reading",
            titleKo: "연구자처럼 읽기",
            description: "Read and analyze academic texts, abstracts, and data-driven arguments.",
            difficulty: 6,
            icon: "🔬",
            sessions: [
                CollectionContentItem(
                    id: "c-research-abstract",
                    title: "How to Read an Abstract in Three Minutes",
                    source: "Dayread Original",
                    genre: "paper",
                    difficulty: 6,
                    learningPoints: "학술 초록 구조, hedging 심화, 연구 어휘",
                    status: "session",
                    sessionId: "collection-how-to-read-an-abstract-in-three-minutes",
                    textFilePath: "docs/text/collections/research-reading/paper-original-how-to-read-an-abstract-in-three-minutes.md"
                ),
                CollectionContentItem(
                    id: "c-research-lit-review",
                    title: "What a Literature Review Actually Does",
                    source: "Dayread Original",
                    genre: "article",
                    difficulty: 6,
                    learningPoints: "선행연구 정리, synthesis vs summary, 학술 동사",
                    status: "session",
                    sessionId: "collection-what-a-literature-review-actually-does",
                    textFilePath: "docs/text/collections/research-reading/article-original-what-a-literature-review-actually-does.md"
                ),
                CollectionContentItem(
                    id: "c-research-data-viz",
                    title: "The Hidden Rhetoric of Data Visualization",
                    source: "Dayread Original",
                    genre: "essay",
                    difficulty: 6,
                    learningPoints: "시각화 비평, persuasion through design, 정량/정성 어휘",
                    status: "session",
                    sessionId: "collection-the-hidden-rhetoric-of-data-visualization",
                    textFilePath: "docs/text/collections/research-reading/essay-original-the-hidden-rhetoric-of-data-visualization.md"
                ),
                CollectionContentItem(
                    id: "c-research-experts-disagree",
                    title: "When Experts Disagree in Public",
                    source: "Dayread Original",
                    genre: "article",
                    difficulty: 6,
                    learningPoints: "전문가 의견 충돌, epistemic humility, 토론 관례",
                    status: "session",
                    sessionId: "collection-when-experts-disagree-in-public",
                    textFilePath: "docs/text/collections/research-reading/article-original-when-experts-disagree-in-public.md"
                ),
                CollectionContentItem(
                    id: "c-research-retraction",
                    title: "The Art of the Retraction",
                    source: "Dayread Original",
                    genre: "essay",
                    difficulty: 6,
                    learningPoints: "언론 정정 보도, 저널리즘 윤리, 제도적 신뢰와 인지 편향",
                    status: "session",
                    sessionId: "collection-the-art-of-the-retraction",
                    textFilePath: "docs/text/collections/media-literacy/article-original-the-art-of-the-retraction.md"
                ),
                CollectionContentItem(id: "c-research-peer-review-when", title: "How Peer Review Works — And When It Doesn't", source: "Dayread Original", genre: "article", difficulty: 6, learningPoints: "동료 심사 프로세스, 출판 부정행위, 오픈 사이언스", status: "session", sessionId: "collection-how-peer-review-works-and-when-it-doesnt", textFilePath: "docs/text/collections/research-reading/article-original-how-peer-review-works-and-when-it-doesnt.md"),
                CollectionContentItem(id: "c-research-peer-review-shapes", title: "How Peer Review Shapes What We Know", source: "Dayread Original", genre: "article", difficulty: 6, learningPoints: "블라인드 리뷰, 학술 게이트키핑, 재현 가능성", status: "session", sessionId: "collection-how-peer-review-shapes-what-we-know", textFilePath: "docs/text/collections/research-reading/article-original-how-peer-review-shapes-what-we-know.md"),
                CollectionContentItem(id: "c-research-replication", title: "Why Replication Matters More Than Discovery", source: "Dayread Original", genre: "essay", difficulty: 6, learningPoints: "재현 위기, p-해킹, 출판 편향과 사전등록", status: "session", sessionId: "collection-why-replication-matters-more-than-discovery", textFilePath: "docs/text/collections/research-reading/essay-original-why-replication-matters-more-than-discovery.md"),
                CollectionContentItem(id: "c-research-footnotes", title: "Reading Between the Footnotes", source: "Dayread Original", genre: "essay", difficulty: 6, learningPoints: "각주 읽기, 인용 전략, 학술적 수사 포지셔닝", status: "session", sessionId: "collection-reading-between-the-footnotes", textFilePath: "docs/text/collections/research-reading/essay-original-reading-between-the-footnotes.md"),
            ]
        ),

        // 2. Business & Professional English (9 sessions)
        CollectionMeta(
            id: "business-english",
            title: "Business & Professional English",
            titleKo: "비즈니스 영어",
            description: "Master professional communication: emails, meetings, cover letters, and contracts.",
            difficulty: 6,
            icon: "💼",
            sessions: [
                CollectionContentItem(
                    id: "c-business-email",
                    title: "What Makes a Business Email Effective",
                    source: "Dayread Original",
                    genre: "article",
                    difficulty: 6,
                    learningPoints: "비즈니스 톤, direct vs indirect requests, 격식 차이",
                    status: "session",
                    sessionId: "collection-what-makes-a-business-email-effective",
                    textFilePath: "docs/text/collections/business-english/article-original-what-makes-a-business-email-effective.md"
                ),
                CollectionContentItem(
                    id: "c-business-cover-letter",
                    title: "The Anatomy of a Strong Cover Letter",
                    source: "Dayread Original",
                    genre: "article",
                    difficulty: 6,
                    learningPoints: "자기소개 문체, persuasive self-presentation, 구직 어휘",
                    status: "session",
                    sessionId: "collection-the-anatomy-of-a-strong-cover-letter",
                    textFilePath: "docs/text/collections/business-english/article-original-the-anatomy-of-a-strong-cover-letter.md"
                ),
                CollectionContentItem(
                    id: "c-business-meeting",
                    title: "How to Run a Meeting That People Remember",
                    source: "Dayread Original",
                    genre: "article",
                    difficulty: 6,
                    learningPoints: "회의 진행 표현, facilitation language, 요약/결정 문체",
                    status: "session",
                    sessionId: "collection-how-to-run-a-meeting-that-people-remember",
                    textFilePath: "docs/text/collections/business-english/article-original-how-to-run-a-meeting-that-people-remember.md"
                ),
                CollectionContentItem(
                    id: "c-business-fine-print",
                    title: "Reading the Fine Print Without a Lawyer",
                    source: "Dayread Original",
                    genre: "article",
                    difficulty: 6,
                    learningPoints: "법률/약관 문체, shall/may 구분, 계약 어휘 기초",
                    status: "session",
                    sessionId: "collection-reading-the-fine-print-without-a-lawyer",
                    textFilePath: "docs/text/collections/business-english/article-original-reading-the-fine-print-without-a-lawyer.md"
                ),
                CollectionContentItem(
                    id: "c-business-bad-news",
                    title: "How to Deliver Bad News Without Losing Trust",
                    source: "Dayread Original",
                    genre: "article",
                    difficulty: 6,
                    learningPoints: "위기 커뮤니케이션, 리더십 신뢰 구축, 감정 지능과 전문 화법",
                    status: "session",
                    sessionId: "collection-how-to-deliver-bad-news-without-losing-trust",
                    textFilePath: "docs/text/collections/business-english/article-original-how-to-deliver-bad-news-without-losing-trust.md"
                ),
                CollectionContentItem(
                    id: "c-business-pitch-decks",
                    title: "The Hidden Grammar of Startup Pitch Decks",
                    source: "Dayread Original",
                    genre: "essay",
                    difficulty: 6,
                    learningPoints: "피치덱 수사학, 설득 메커니즘, 벤처 캐피탈 커뮤니케이션 구조",
                    status: "session",
                    sessionId: "collection-the-hidden-grammar-of-startup-pitch-decks",
                    textFilePath: "docs/text/collections/business-english/article-original-the-hidden-grammar-of-startup-pitch-decks.md"
                ),
                CollectionContentItem(id: "c-business-presentation", title: "How to Give a Presentation That Lands", source: "Dayread Original", genre: "article", difficulty: 6, learningPoints: "프레젠테이션 구조, 시그널 표현, 청중 참여 전략", status: "session", sessionId: "collection-how-to-give-a-presentation-that-lands", textFilePath: "docs/text/collections/business-english/article-original-how-to-give-a-presentation-that-lands.md"),
                CollectionContentItem(id: "c-business-negotiating", title: "Negotiating Without Saying No", source: "Dayread Original", genre: "article", difficulty: 6, learningPoints: "협상 화법, 간접 거절, 이해관계자 조율 전략", status: "session", sessionId: "collection-negotiating-without-saying-no", textFilePath: "docs/text/collections/business-english/article-original-negotiating-without-saying-no.md"),
                CollectionContentItem(id: "c-business-apology", title: "The Art of a Professional Apology", source: "Dayread Original", genre: "article", difficulty: 6, learningPoints: "공식 사과문, 기업 책임, 비사과(non-apology) 분석", status: "session", sessionId: "collection-the-art-of-a-professional-apology", textFilePath: "docs/text/collections/business-english/article-original-the-art-of-a-professional-apology.md"),
            ]
        ),

        // 3. Media & Public Discourse (8 sessions)
        CollectionMeta(
            id: "media-literacy",
            title: "Media & Public Discourse",
            titleKo: "미디어 리터러시",
            description: "Analyze editorials, policy language, headlines, and rhetorical strategies.",
            difficulty: 6,
            icon: "📡",
            sessions: [
                CollectionContentItem(
                    id: "c-media-editorials",
                    title: "How Editorials Build an Argument",
                    source: "Dayread Original",
                    genre: "essay",
                    difficulty: 6,
                    learningPoints: "사설 구조, rhetorical moves, 설득 전략 분석",
                    status: "session",
                    sessionId: "collection-how-editorials-build-an-argument",
                    textFilePath: "docs/text/collections/media-literacy/essay-original-how-editorials-build-an-argument.md"
                ),
                CollectionContentItem(
                    id: "c-media-policy",
                    title: "The Language of Policy Proposals",
                    source: "Dayread Original",
                    genre: "article",
                    difficulty: 6,
                    learningPoints: "정책 문서 문체, passive authority, 제안형 표현",
                    status: "session",
                    sessionId: "collection-the-language-of-policy-proposals",
                    textFilePath: "docs/text/collections/media-literacy/article-original-the-language-of-policy-proposals.md"
                ),
                CollectionContentItem(
                    id: "c-media-headlines",
                    title: "Why Headlines and Articles Tell Different Stories",
                    source: "Dayread Original",
                    genre: "article",
                    difficulty: 6,
                    learningPoints: "헤드라인 분석, framing effects, 독자 조작 기법",
                    status: "session",
                    sessionId: "collection-why-headlines-and-articles-tell-different-stories",
                    textFilePath: "docs/text/collections/media-literacy/article-original-why-headlines-and-articles-tell-different-stories.md"
                ),
                CollectionContentItem(
                    id: "c-media-speeches",
                    title: "Speeches That Changed the Way People Talked",
                    source: "Dayread Original",
                    genre: "article",
                    difficulty: 6,
                    learningPoints: "연설 분석, framing effects, 역사적 수사학",
                    status: "session",
                    sessionId: "collection-speeches-that-changed-the-way-people-talked",
                    textFilePath: "docs/text/collections/media-literacy/article-original-speeches-that-changed-the-way-people-talked.md"
                ),
                CollectionContentItem(
                    id: "c-media-podcasts",
                    title: "How Podcasts Rewired Public Conversation",
                    source: "Dayread Original",
                    genre: "article",
                    difficulty: 6,
                    learningPoints: "팟캐스트 미디어 영향, 공론장 변화, 에코 챔버와 미디어 민주화",
                    status: "session",
                    sessionId: "collection-how-podcasts-rewired-public-conversation",
                    textFilePath: "docs/text/collections/media-literacy/article-original-how-podcasts-rewired-public-conversation.md"
                ),
                CollectionContentItem(id: "c-media-crisis", title: "The Rhetoric of Crisis Reporting", source: "Dayread Original", genre: "article", difficulty: 6, learningPoints: "위기 보도 수사학, 미디어 인센티브, 선정주의 분석", status: "session", sessionId: "collection-the-rhetoric-of-crisis-reporting", textFilePath: "docs/text/collections/media-literacy/article-original-the-rhetoric-of-crisis-reporting.md"),
                CollectionContentItem(id: "c-media-think-tanks", title: "What Think Tank Reports Don't Tell You", source: "Dayread Original", genre: "article", difficulty: 6, learningPoints: "싱크탱크 보고서 비판적 읽기, 정책 연구 자금, 제도적 편향", status: "session", sessionId: "collection-what-think-tank-reports-dont-tell-you", textFilePath: "docs/text/collections/media-literacy/article-original-what-think-tank-reports-dont-tell-you.md"),
                CollectionContentItem(id: "c-media-framing", title: "How Framing Changes the Debate", source: "Dayread Original", genre: "article", difficulty: 6, learningPoints: "프레이밍 효과, 의제 설정, 인지 스키마와 정치 커뮤니케이션", status: "session", sessionId: "collection-how-framing-changes-the-debate", textFilePath: "docs/text/collections/media-literacy/article-original-how-framing-changes-the-debate.md"),
                CollectionContentItem(id: "c-media-satire", title: "When Satire Does the Work of Journalism", source: "Dayread Original", genre: "essay", difficulty: 6, learningPoints: "풍자와 저널리즘, 미디어 비평, 수사적 아이러니", status: "session", sessionId: "collection-when-satire-does-the-work-of-journalism", textFilePath: "docs/text/collections/media-literacy/essay-original-when-satire-does-the-work-of-journalism.md"),
            ]
        ),

        // 4. Literature & Criticism (9 sessions)
        CollectionMeta(
            id: "literature-criticism",
            title: "Literature & Criticism",
            titleKo: "문학과 비평",
            description: "Explore book reviews, literary epistemology, science writing, and deep reading.",
            difficulty: 6,
            icon: "📚",
            sessions: [
                CollectionContentItem(
                    id: "c-lit-book-reviews",
                    title: "What Book Reviews Reveal About the Reviewer",
                    source: "Dayread Original",
                    genre: "essay",
                    difficulty: 6,
                    learningPoints: "서평 문체, evaluative language, 비평적 관점",
                    status: "session",
                    sessionId: "collection-what-book-reviews-reveal-about-the-reviewer",
                    textFilePath: "docs/text/collections/literature-criticism/essay-original-what-book-reviews-reveal-about-the-reviewer.md"
                ),
                CollectionContentItem(
                    id: "c-lit-fiction-knowing",
                    title: "Fiction as a Way of Knowing",
                    source: "Dayread Original",
                    genre: "essay",
                    difficulty: 6,
                    learningPoints: "문학적 인식론, 서사와 논증의 경계, 비유의 설득력",
                    status: "session",
                    sessionId: "collection-fiction-as-a-way-of-knowing",
                    textFilePath: "docs/text/collections/literature-criticism/essay-original-fiction-as-a-way-of-knowing.md"
                ),
                CollectionContentItem(
                    id: "c-lit-science-public",
                    title: "When Science Writes for the Public",
                    source: "Dayread Original",
                    genre: "article",
                    difficulty: 6,
                    learningPoints: "과학 대중화 문체, simplification vs accuracy, 번역적 글쓰기",
                    status: "session",
                    sessionId: "collection-when-science-writes-for-the-public",
                    textFilePath: "docs/text/collections/literature-criticism/article-original-when-science-writes-for-the-public.md"
                ),
                CollectionContentItem(
                    id: "c-lit-info-understanding",
                    title: "The Difference Between Information and Understanding",
                    source: "Dayread Original",
                    genre: "essay",
                    difficulty: 6,
                    learningPoints: "정보 vs 이해, 메타인지적 독해, 통합 성찰",
                    status: "session",
                    sessionId: "collection-the-difference-between-information-and-understanding",
                    textFilePath: "docs/text/collections/literature-criticism/essay-original-the-difference-between-information-and-understanding.md"
                ),
                CollectionContentItem(
                    id: "c-lit-translation-meaning",
                    title: "How Translation Changes What a Text Can Mean",
                    source: "Dayread Original",
                    genre: "essay",
                    difficulty: 6,
                    learningPoints: "번역 이론, 언어적 등가성, 문화적 의미와 기계 번역의 한계",
                    status: "session",
                    sessionId: "collection-how-translation-changes-what-a-text-can-mean",
                    textFilePath: "docs/text/collections/literature-criticism/essay-original-how-translation-changes-what-a-text-can-mean.md"
                ),
                CollectionContentItem(
                    id: "c-lit-awards",
                    title: "Why Literary Awards Shape the Way We Read",
                    source: "Dayread Original",
                    genre: "article",
                    difficulty: 6,
                    learningPoints: "문학상과 정전 형성, 출판 산업의 문화 권력, 독서 기대의 구조화",
                    status: "session",
                    sessionId: "collection-why-literary-awards-shape-the-way-we-read",
                    textFilePath: "docs/text/collections/literature-criticism/essay-original-why-literary-awards-shape-the-way-we-read.md"
                ),
                CollectionContentItem(id: "c-lit-unreliable-narrators", title: "Why Unreliable Narrators Work", source: "Dayread Original", genre: "essay", difficulty: 6, learningPoints: "신뢰할 수 없는 화자, 극적 아이러니, 서사적 회의주의", status: "session", sessionId: "collection-why-unreliable-narrators-work", textFilePath: "docs/text/collections/literature-criticism/essay-original-why-unreliable-narrators-work.md"),
                CollectionContentItem(id: "c-lit-translation-story", title: "How Translation Changes a Story", source: "Dayread Original", genre: "essay", difficulty: 6, learningPoints: "문학 번역, 자국화 vs 이화, 번역 불가능성과 문체 변환", status: "session", sessionId: "collection-how-translation-changes-a-story", textFilePath: "docs/text/collections/literature-criticism/essay-original-how-translation-changes-a-story.md"),
                CollectionContentItem(id: "c-lit-ethics-real-people", title: "The Ethics of Writing About Real People", source: "Dayread Original", genre: "essay", difficulty: 6, learningPoints: "실존 인물 서사 윤리, 동의와 서사화, 합성 캐릭터와 프라이버시", status: "session", sessionId: "collection-the-ethics-of-writing-about-real-people", textFilePath: "docs/text/collections/literature-criticism/essay-original-the-ethics-of-writing-about-real-people.md"),
            ]
        ),

    ]

    // MARK: - Private Lazy Maps

    private static let collectionSessionMap: [String: CollectionMeta] = {
        var map: [String: CollectionMeta] = [:]
        for collection in collections {
            for item in collection.sessions where item.status == "session" && item.sessionId != nil {
                map[item.sessionId!] = collection
            }
        }
        return map
    }()

    private static let collectionSessionItemMap: [String: CollectionContentItem] = {
        var map: [String: CollectionContentItem] = [:]
        for collection in collections {
            for item in collection.sessions where item.status == "session" && item.sessionId != nil {
                map[item.sessionId!] = item
            }
        }
        return map
    }()

    /// Only the first session of the first collection is free.
    private static let freeCollectionSessionIds: Set<String> = {
        guard let first = collections.first else { return [] }
        let sessionItems = first.sessions.filter { $0.status == "session" && $0.sessionId != nil }
        guard let firstItem = sessionItems.first, let sessionId = firstItem.sessionId else { return [] }
        return [sessionId]
    }()

    // MARK: - Helper Functions

    static func getCollectionMeta(_ collectionId: String) -> CollectionMeta? {
        collections.first { $0.id == collectionId }
    }

    static func getCollectionForSession(_ sessionId: String) -> CollectionMeta? {
        collectionSessionMap[sessionId]
    }

    static func getCollectionSessionItem(_ sessionId: String) -> CollectionContentItem? {
        collectionSessionItemMap[sessionId]
    }

    static func isCollectionSessionId(_ sessionId: String) -> Bool {
        collectionSessionItemMap[sessionId] != nil
    }

    static func isFreeCollectionSessionId(_ sessionId: String) -> Bool {
        freeCollectionSessionIds.contains(sessionId)
    }

    static func getCollectionSessions(_ collectionId: String) -> [CollectionContentItem] {
        guard let collection = getCollectionMeta(collectionId) else { return [] }
        return collection.sessions.filter { $0.status == "session" }
    }
}
