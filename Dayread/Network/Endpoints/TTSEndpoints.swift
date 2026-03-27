import Foundation
import CryptoKit

// MARK: - TTS Constants

enum TTSConstants {
    static let publicBucket = "tts-public"
    static let assetVersion = "v3"
    static let defaultVoice = "en-US-AriaNeural"

    static let voices: [(id: String, label: String, gender: String)] = [
        ("en-US-AriaNeural", "Aria", "F"),
        ("en-US-GuyNeural", "Guy", "M"),
    ]

    static func normalizeText(_ text: String) -> String {
        // Match React: NFKC normalize, collapse whitespace, trim
        text.precomposedStringWithCompatibilityMapping
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)
    }

    static func assetKey(voice: String, text: String) -> String {
        let normalized = normalizeText(text)
        let hashInput = "\(voice)\0\(normalized)"
        let hash = SHA256.hash(data: Data(hashInput.utf8))
        let hex = hash.map { String(format: "%02x", $0) }.joined()
        return "tts/\(assetVersion)/\(voice)/\(hex).mp3"
    }

    static func publicURL(assetKey: String) -> URL {
        let base = AppConstants.Supabase.url.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let encoded = assetKey.split(separator: "/").map {
            $0.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? String($0)
        }.joined(separator: "/")
        return URL(string: "\(base)/storage/v1/object/public/\(publicBucket)/\(encoded)")!
    }

    static func resolveAssetURL(text: String, voice: String = defaultVoice) -> URL {
        let key = assetKey(voice: voice, text: text)
        return publicURL(assetKey: key)
    }
}

// MARK: - API Endpoints

extension APIClient {
    /// GET /api/tts — fetch pre-built TTS audio
    func fetchTTSAudio(text: String, voice: String? = nil) async throws -> Data {
        var queryItems = [URLQueryItem(name: "text", value: text)]
        if let voice {
            queryItems.append(URLQueryItem(name: "voice", value: voice))
        }
        return try await getData("/api/tts", queryItems: queryItems)
    }

    /// POST /api/tts — backfill: request server to generate TTS when pre-built asset is missing
    func requestTTSBackfill(text: String, voice: String = TTSConstants.defaultVoice) async throws -> Data {
        struct BackfillRequest: Encodable {
            let text: String
            let voice: String
        }
        let body = BackfillRequest(text: text, voice: voice)
        return try await postData("/api/tts", body: body)
    }
}
