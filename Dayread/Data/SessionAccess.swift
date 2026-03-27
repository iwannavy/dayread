import Foundation

/// Port of src/lib/session-access.ts
enum SessionAccess {
    static func isSessionOpen(_ session: StudySessionListItem) -> Bool {
        session.access?.canOpen ?? false
    }

    static func isCurriculumSession(_ session: StudySessionListItem) -> Bool {
        session.access?.category == .curriculum
    }

    static func isPremiumSession(_ session: StudySessionListItem) -> Bool {
        session.access?.category == .premium
    }

    static func isLegacySession(_ session: StudySessionListItem) -> Bool {
        session.access?.category == .legacy
    }

    static func isCollectionSession(_ session: StudySessionListItem) -> Bool {
        session.access?.category == .collection
    }

    static func getCurriculumSessions(_ sessions: [StudySessionListItem]) -> [StudySessionListItem] {
        sessions.filter { isCurriculumSession($0) }
    }

    static func getAccessibleCurriculumSessions(_ sessions: [StudySessionListItem]) -> [StudySessionListItem] {
        sessions.filter { isCurriculumSession($0) && isSessionOpen($0) }
    }

    static func getPremiumSessions(_ sessions: [StudySessionListItem]) -> [StudySessionListItem] {
        sessions
            .filter { isPremiumSession($0) }
            .sorted { ($1.access?.releaseDate ?? "") < ($0.access?.releaseDate ?? "") }
    }

    static func getLegacySessions(_ sessions: [StudySessionListItem]) -> [StudySessionListItem] {
        sessions
            .filter { isLegacySession($0) && isSessionOpen($0) }
            .sorted { $1.createdAt < $0.createdAt }
    }

    static func getCollectionSessionsList(_ sessions: [StudySessionListItem]) -> [StudySessionListItem] {
        sessions.filter { isCollectionSession($0) }
    }

    static func getLockedReasonText(access: SessionAccessState?, membershipTier: MembershipTier) -> String? {
        guard let access, !access.canOpen else { return nil }

        switch access.lockedReason {
        case .premiumRequired:
            return membershipTier == .premium
                ? "아직 열리지 않은 레슨입니다."
                : "프리미엄으로 업그레이드하면 이용할 수 있습니다."
        case .premiumWindowClosed:
            return membershipTier == .premium
                ? "7일 열람 기간이 지난 레슨입니다."
                : "프리미엄으로 업그레이드하면 7일 아카이브 전체를 이용할 수 있습니다."
        case .legacyBonusDisabled:
            return "보너스 콘텐츠가 현재 숨겨져 있습니다."
        case .none:
            return "프리미엄으로 업그레이드하면 이용할 수 있습니다."
        }
    }
}
