import AVFoundation
import CryptoKit
import Foundation
import Observation

@Observable
final class TTSService {
    // MARK: - Public State

    private(set) var isSpeaking = false
    private(set) var isPaused = false
    private(set) var isLoading = false
    var rate: Double = 1.0 {
        didSet { audioPlayer?.rate = Float(rate) }
    }
    var voice: String = TTSConstants.defaultVoice

    // MARK: - Private

    private var audioPlayer: AVPlayer?
    private var playerObserver: Any?
    private var onEndCallback: (() -> Void)?
    private var requestId = 0

    private let synthesizer = AVSpeechSynthesizer()
    private let synthDelegate = SynthesizerDelegate()
    private var apiClient: APIClient?

    // Cache
    private let cacheDir: URL
    private let maxCacheEntries = 500
    private var inflightTasks: [String: Task<URL, Error>] = [:]

    // MARK: - Init

    init() {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        self.cacheDir = caches.appendingPathComponent("tts", isDirectory: true)
        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
    }

    func configure(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    // MARK: - Core Playback

    func speak(_ text: String, onEnd: (() -> Void)? = nil) {
        stop()
        let currentRequestId = requestId
        isLoading = true

        Task { [weak self] in
            guard let self else { return }
            do {
                let url = try await resolvePlaybackURL(text)
                guard requestId == currentRequestId else { return }
                await MainActor.run {
                    self.isLoading = false
                    self.playURL(url, onEnd: onEnd)
                }
            } catch {
                guard self.requestId == currentRequestId else { return }
                await MainActor.run {
                    self.isLoading = false
                    self.fallbackSpeak(text, onEnd: onEnd)
                }
            }
        }
    }

    func stop() {
        requestId += 1

        if let observer = playerObserver {
            NotificationCenter.default.removeObserver(observer)
            playerObserver = nil
        }
        audioPlayer?.pause()
        audioPlayer = nil

        synthesizer.stopSpeaking(at: .immediate)

        isSpeaking = false
        isPaused = false
        isLoading = false

        let callback = onEndCallback
        onEndCallback = nil
        callback?()
    }

    func pause() {
        guard let player = audioPlayer, player.rate > 0 else { return }
        player.pause()
        isPaused = true
        isSpeaking = false
    }

    func resume(onEnd: (() -> Void)? = nil) {
        guard let player = audioPlayer, isPaused else { return }
        if let onEnd { onEndCallback = onEnd }
        isPaused = false
        isSpeaking = true
        player.play()
    }

    // MARK: - Preloading

    func preload(_ text: String) {
        Task { [weak self] in
            try? await self?.resolvePlaybackURL(text)
        }
    }

    func preloadBatch(_ texts: [String], immediateCount: Int = 3) {
        let unique = Array(Set(texts.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }))
        guard !unique.isEmpty else { return }

        let immediate = Array(unique.prefix(immediateCount))
        let background = Array(unique.dropFirst(immediateCount))

        Task { [weak self] in
            for text in immediate {
                _ = try? await self?.resolvePlaybackURL(text)
            }
            for text in background {
                _ = try? await self?.resolvePlaybackURL(text)
            }
        }
    }

    // MARK: - URL Resolution (3-layer cache)

    func resolvePlaybackURL(_ text: String) async throws -> URL {
        let assetKey = TTSConstants.assetKey(voice: voice, text: text)

        // Layer 1: FileManager disk cache
        let localFile = cacheDir.appendingPathComponent(assetKey.replacingOccurrences(of: "/", with: "_"))
        if FileManager.default.fileExists(atPath: localFile.path) {
            return localFile
        }

        // Dedup inflight requests
        if let existing = inflightTasks[assetKey] {
            return try await existing.value
        }

        let task = Task<URL, Error> { [weak self] in
            guard let self else { throw URLError(.cancelled) }

            // Layer 2: Supabase storage public URL
            let publicURL = TTSConstants.resolveAssetURL(text: text, voice: voice)
            do {
                let data = try await downloadData(from: publicURL)
                try data.write(to: localFile)
                return localFile
            } catch {
                // Layer 3: POST backfill API
                guard let apiClient else { throw error }
                let data = try await apiClient.requestTTSBackfill(
                    text: TTSConstants.normalizeText(text),
                    voice: voice
                )
                try data.write(to: localFile)
                return localFile
            }
        }

        inflightTasks[assetKey] = task
        defer { inflightTasks.removeValue(forKey: assetKey) }

        return try await task.value
    }

    // MARK: - Private Helpers

    private func playURL(_ url: URL, onEnd: (() -> Void)?) {
        configureAudioSession()

        let playerItem = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: playerItem)
        player.rate = Float(rate)
        audioPlayer = player
        onEndCallback = onEnd

        playerObserver = NotificationCenter.default.addObserver(
            forName: AVPlayerItem.didPlayToEndTimeNotification,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            self?.handlePlaybackEnd()
        }

        isSpeaking = true
        isPaused = false
        player.play()
    }

    private func handlePlaybackEnd() {
        if let observer = playerObserver {
            NotificationCenter.default.removeObserver(observer)
            playerObserver = nil
        }
        audioPlayer = nil
        isSpeaking = false
        isPaused = false

        let callback = onEndCallback
        onEndCallback = nil
        callback?()
    }

    private func fallbackSpeak(_ text: String, onEnd: (() -> Void)?) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * Float(rate)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        onEndCallback = onEnd

        synthDelegate.onFinish = { [weak self] in
            self?.isSpeaking = false
            let callback = self?.onEndCallback
            self?.onEndCallback = nil
            callback?()
        }
        synthesizer.delegate = synthDelegate

        isSpeaking = true
        isPaused = false
        synthesizer.speak(utterance)
    }

    private func downloadData(from url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return data
    }

    private func configureAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
        try? AVAudioSession.sharedInstance().setActive(true)
    }
}

// MARK: - AVSpeechSynthesizer Delegate

private final class SynthesizerDelegate: NSObject, AVSpeechSynthesizerDelegate {
    var onFinish: (() -> Void)?

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        onFinish?()
    }
}
