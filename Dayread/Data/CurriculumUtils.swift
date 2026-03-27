import Foundation
import SwiftUI

/// Port of src/lib/curriculum.ts + genre/difficulty helpers
enum CurriculumUtils {
    // MARK: - Curriculum Months

    struct CurriculumMonth {
        let month: Int
        let title: String
        let titleKo: String
        let description: String
        let weeks: [CurriculumWeekMeta]
        let milestones: [String]
    }

    struct CurriculumWeekMeta {
        let week: Int
        let theme: String
        let themeKo: String
        let focus: [String]
        let difficulty: Int
    }

    static let months: [CurriculumMonth] = [
        CurriculumMonth(
            month: 1, title: "Core Patterns", titleKo: "핵심 문장 패턴",
            description: "일상 주제 기반의 오리지널 텍스트로 기본 문장 구조와 설명 문체를 익힌다.",
            weeks: [
                CurriculumWeekMeta(week: 1, theme: "Attention & Everyday Learning", themeKo: "집중과 일상 학습", focus: ["SVO 기본형", "simple present", "because / if", "기초 학습 어휘"], difficulty: 1),
                CurriculumWeekMeta(week: 2, theme: "Space, Place, and Description", themeKo: "공간과 묘사", focus: ["전치사구", "there is / there are", "형용사 위치", "장소 묘사"], difficulty: 1),
                CurriculumWeekMeta(week: 3, theme: "Causes, Choices, Comparisons", themeKo: "원인, 선택, 비교", focus: ["because / so", "비교급", "while", "원인-결과 구조"], difficulty: 2),
                CurriculumWeekMeta(week: 4, theme: "Short Personal Narratives", themeKo: "짧은 개인 서사", focus: ["과거시제", "시간 표현", "when / after", "회고 문체"], difficulty: 2),
            ],
            milestones: ["기본 문장 패턴 적응", "설명문과 짧은 서사 읽기 시작", "핵심 어휘 루틴 만들기"]
        ),
        CurriculumMonth(
            month: 2, title: "Ideas in Motion", titleKo: "생각의 확장",
            description: "사회, 일상, 문화 주제를 통해 의견과 설명, 연결 문장을 확장한다.",
            weeks: [
                CurriculumWeekMeta(week: 5, theme: "Opinions in Daily Life", themeKo: "일상 속 의견", focus: ["should / must", "however", "의견-근거 구조", "생활 논제"], difficulty: 3),
                CurriculumWeekMeta(week: 6, theme: "Systems and Hidden Causes", themeKo: "시스템과 숨은 원인", focus: ["과정 설명", "수동태 입문", "원인 사슬", "공공 시스템 어휘"], difficulty: 3),
                CurriculumWeekMeta(week: 7, theme: "Idioms, Tone, and Culture", themeKo: "이디엄, 톤, 문화", focus: ["이디엄", "collocation", "문체 차이", "문화 맥락"], difficulty: 3),
                CurriculumWeekMeta(week: 8, theme: "Review and Communication", themeKo: "복습과 전달", focus: ["요약", "전환 표현", "피드백", "설명 재구성"], difficulty: 3),
            ],
            milestones: ["의견과 설명 확장", "짧은 요약과 재구성 가능", "실용 표현 폭 넓히기"]
        ),
        CurriculumMonth(
            month: 3, title: "Nuance & Synthesis", titleKo: "뉘앙스와 통합",
            description: "사회적 주제, 연구 읽기, 논쟁, 성찰형 글쓰기를 통해 고급 읽기 기반을 만든다.",
            weeks: [
                CurriculumWeekMeta(week: 9, theme: "Society and Long-form Reading", themeKo: "사회와 장문 읽기", focus: ["장문 단락 읽기", "추상 명사", "양보", "사회 분석"], difficulty: 4),
                CurriculumWeekMeta(week: 10, theme: "Research and Evidence", themeKo: "연구와 근거", focus: ["hedging", "evidence claims", "correlation vs cause", "조심스러운 주장"], difficulty: 4),
                CurriculumWeekMeta(week: 11, theme: "Nuance and Debate", themeKo: "뉘앙스와 토론", focus: ["양보와 반박", "논점의 한계", "추상 토론", "관점 비교"], difficulty: 5),
                CurriculumWeekMeta(week: 12, theme: "Capstone and Reflection", themeKo: "캡스톤과 성찰", focus: ["통합 요약", "미래 지향 표현", "설득적 결론", "학습 성찰"], difficulty: 5),
            ],
            milestones: ["고급 설명문 적응", "근거와 주장 구분", "성찰형 영어 표현 시작"]
        ),
    ]

    static func getWeekData(_ weekNumber: Int) -> CurriculumWeekMeta? {
        for month in months {
            if let week = month.weeks.first(where: { $0.week == weekNumber }) {
                return week
            }
        }
        return nil
    }

    static func getMonthForWeek(_ weekNumber: Int) -> CurriculumMonth? {
        months.first { month in month.weeks.contains { $0.week == weekNumber } }
    }

    static let maxLiveWeek = 12

    // MARK: - Genre Icons (SF Symbols)

    static func genreIcon(_ genre: String) -> String {
        switch genre {
        case "article": return "doc.text"
        case "essay": return "text.book.closed"
        case "speech": return "mic"
        case "paper": return "doc.richtext"
        default: return "doc.text"
        }
    }

    // MARK: - Difficulty

    static func difficultyLabel(_ difficulty: Int) -> String {
        switch difficulty {
        case 1: return "Lv.1"
        case 2: return "Lv.2"
        case 3: return "Lv.3"
        case 4: return "Lv.4"
        case 5: return "Lv.5"
        case 6: return "Lv.6"
        default: return "Lv.?"
        }
    }

    static func difficultyColor(_ difficulty: Int) -> Color {
        switch difficulty {
        case 1: return .green
        case 2: return .teal
        case 3: return .blue
        case 4: return .orange
        case 5: return .red
        case 6: return .purple
        default: return .gray
        }
    }
}
