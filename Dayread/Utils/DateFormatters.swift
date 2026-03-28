import Foundation

enum DateFormatters {
    static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static let displayDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일"
        return formatter
    }()

    static let displayDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 a h:mm"
        return formatter
    }()

    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    /// Fallback: fractional seconds 없는 ISO8601
    static let iso8601Plain: ISO8601DateFormatter = {
        ISO8601DateFormatter()
    }()

    static func parseISO(_ string: String?) -> Date? {
        guard let string else { return nil }
        return iso8601.date(from: string) ?? iso8601Plain.date(from: string)
    }

    static func relativeTime(from dateString: String?) -> String {
        guard let date = parseISO(dateString) else { return "" }
        let interval = Date().timeIntervalSince(date)

        if interval < 60 { return "방금" }
        if interval < 3600 { return "\(Int(interval / 60))분 전" }
        if interval < 86400 { return "\(Int(interval / 3600))시간 전" }
        if interval < 604800 { return "\(Int(interval / 86400))일 전" }

        return displayDate.string(from: date)
    }
}
