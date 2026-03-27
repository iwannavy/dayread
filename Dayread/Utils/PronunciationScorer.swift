import Foundation

/// Port of scorePronunciation from src/lib/speech.ts
/// Uses Levenshtein distance for word-level matching
enum PronunciationScorer {
    struct ScoringResult {
        let score: Double
        let matchedWords: [WordMatch]
    }

    struct WordMatch {
        let expected: String
        let spoken: String?
        let matched: Bool
    }

    static func score(expected: String, spoken: String) -> ScoringResult {
        let expectedWords = normalizeWords(expected)
        let spokenWords = normalizeWords(spoken)

        guard !expectedWords.isEmpty else {
            return ScoringResult(score: 0, matchedWords: [])
        }

        var matches: [WordMatch] = []
        var spokenIndex = 0

        for expectedWord in expectedWords {
            var bestMatch: (index: Int, distance: Int)?

            // Search within a window around current position
            let searchStart = max(0, spokenIndex - 2)
            let searchEnd = min(spokenWords.count, spokenIndex + 3)

            for i in searchStart..<searchEnd {
                let distance = levenshteinDistance(expectedWord, spokenWords[i])
                let threshold = max(1, expectedWord.count / 3)

                if distance <= threshold {
                    if bestMatch.map({ distance < $0.distance }) ?? true {
                        bestMatch = (i, distance)
                    }
                }
            }

            if let best = bestMatch {
                matches.append(WordMatch(expected: expectedWord, spoken: spokenWords[best.index], matched: true))
                spokenIndex = best.index + 1
            } else {
                matches.append(WordMatch(expected: expectedWord, spoken: nil, matched: false))
            }
        }

        let matchCount = matches.filter(\.matched).count
        let score = Double(matchCount) / Double(expectedWords.count) * 100

        return ScoringResult(score: min(100, score), matchedWords: matches)
    }

    // MARK: - Private Helpers

    private static func normalizeWords(_ text: String) -> [String] {
        text.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
    }

    private static func levenshteinDistance(_ a: String, _ b: String) -> Int {
        let aChars = Array(a)
        let bChars = Array(b)
        let m = aChars.count
        let n = bChars.count

        if m == 0 { return n }
        if n == 0 { return m }

        var matrix = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)

        for i in 0...m { matrix[i][0] = i }
        for j in 0...n { matrix[0][j] = j }

        for i in 1...m {
            for j in 1...n {
                let cost = aChars[i - 1] == bChars[j - 1] ? 0 : 1
                matrix[i][j] = min(
                    matrix[i - 1][j] + 1,       // deletion
                    matrix[i][j - 1] + 1,       // insertion
                    matrix[i - 1][j - 1] + cost  // substitution
                )
            }
        }

        return matrix[m][n]
    }
}
