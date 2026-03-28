import SwiftUI

struct FullTextPlayerView: View {
    let sentences: [String]
    let currentIndex: Int
    let viewMode: ViewMode
    var onSentenceChange: ((Int) -> Void)? = nil
    var onPlayIndexChange: ((Int?) -> Void)? = nil
    var maxUnlockedSentence: Int = .max
    var mode: PlaybackMode = .continuous
    var autoPlayOnNav: Bool = false
    var onAutoPlayChange: ((Bool) -> Void)? = nil

    @Environment(TTSService.self) private var tts
    @State private var playIndex = 0
    @State private var isPlaying = false
    @State private var showSettings = false

    var body: some View {
        HStack(spacing: 6) {
            // Prev
            Button { handlePrev() } label: {
                Image(systemName: "backward.fill")
                    .font(.caption)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .foregroundStyle(.tertiary)

            // Play/Pause
            Button { handlePlayPause() } label: {
                Group {
                    if tts.isLoading {
                        ProgressView()
                            .scaleEffect(0.6)
                    } else if tts.isSpeaking {
                        // Audio visualizer dots
                        HStack(spacing: 2) {
                            ForEach(0..<5, id: \.self) { i in
                                Capsule()
                                    .fill(Color.dayreadGold)
                                    .frame(width: 2, height: CGFloat([5, 9, 7, 11, 8][i]))
                            }
                        }
                    } else {
                        Image(systemName: "play.fill")
                            .font(.caption)
                    }
                }
                .frame(width: 44, height: 44)
                .background(tts.isSpeaking ? Color.dayreadGold.opacity(0.15) : Color.gray.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .foregroundStyle(tts.isSpeaking ? Color.dayreadGold : Color.gray)
            .disabled(tts.isLoading)

            // Next
            Button { handleNext() } label: {
                Image(systemName: "forward.fill")
                    .font(.caption)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .foregroundStyle(.tertiary)

            Spacer()

            // Settings
            Button { showSettings.toggle() } label: {
                Image(systemName: "gearshape")
                    .font(.caption)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .foregroundStyle(.tertiary)
            .popover(isPresented: $showSettings) {
                settingsMenu
                    .presentationCompactAdaptation(.popover)
            }
        }
        .onChange(of: currentIndex) { _, newIndex in
            if (viewMode == .focus || viewMode == .immersive), !isPlaying {
                playIndex = newIndex
            }
        }
        .onChange(of: isPlaying) { _, _ in
            onPlayIndexChange?(tts.isSpeaking || isPlaying ? playIndex : nil)
        }
        .onAppear {
            playIndex = currentIndex
            // Preload nearby sentences
            let window = Array(sentences.dropFirst(currentIndex).prefix(3))
            if !window.isEmpty {
                tts.preloadBatch(window, immediateCount: 3)
            }
        }
    }

    // MARK: - Settings Menu

    private var settingsMenu: some View {
        VStack(alignment: .leading, spacing: 16) {
            voiceSection
            speedSection
            if mode == .single {
                autoPlaySection
            }
        }
        .padding(16)
        .frame(minWidth: 220)
    }

    private var voiceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("음성")
                .studySectionHeaderStyle()
            HStack(spacing: 4) {
                ForEach(TTSConstants.voices, id: \.id) { v in
                    let isSelected = tts.voice == v.id
                    Button { tts.voice = v.id } label: {
                        Text(v.label)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background {
                                if isSelected {
                                    RoundedRectangle(cornerRadius: 8).fill(.regularMaterial)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .foregroundStyle(isSelected ? Color.primary : Color.secondary)
                    .buttonStyle(.plain)
                }
            }
            .padding(2)
            .background(Color.gray.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private var speedSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("속도")
                .studySectionHeaderStyle()
            HStack(spacing: 4) {
                ForEach([0.5, 0.75, 1.0, 1.25, 1.5], id: \.self) { speed in
                    let isActive = abs(tts.rate - speed) < 0.01
                    Button { tts.rate = speed } label: {
                        Text(speed == 1.0 ? "1x" : String(format: "%.2gx", speed))
                            .font(.caption)
                            .monospacedDigit()
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(isActive ? Color.dayreadGold.opacity(0.15) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .foregroundStyle(isActive ? Color.dayreadGold : Color.secondary)
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var autoPlaySection: some View {
        Button {
            onAutoPlayChange?(!autoPlayOnNav)
        } label: {
            HStack {
                Text("이동 시 자동 재생")
                    .font(.caption)
                Spacer()
                if autoPlayOnNav {
                    Image(systemName: "checkmark")
                        .font(.caption2)
                        .foregroundStyle(Color.dayreadGold)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(autoPlayOnNav ? Color.dayreadGold.opacity(0.1) : Color.gray.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .foregroundStyle(autoPlayOnNav ? Color.dayreadGold : Color.secondary)
        .buttonStyle(.plain)
    }

    // MARK: - Playback Control

    private func handlePlayPause() {
        if tts.isSpeaking {
            tts.pause()
        } else if tts.isPaused {
            tts.resume { handleOnEnd() }
        } else {
            playSentence(playIndex)
        }
    }

    private func handlePrev() {
        playSentence(max(0, playIndex - 1))
    }

    private func handleNext() {
        let nextIdx = playIndex + 1
        guard nextIdx <= maxUnlockedSentence, nextIdx < sentences.count else { return }
        playSentence(nextIdx)
    }

    private func playSentence(_ idx: Int) {
        guard idx >= 0, idx < sentences.count else {
            isPlaying = false
            return
        }
        playIndex = idx
        isPlaying = true
        if viewMode == .focus { onSentenceChange?(idx) }
        tts.speak(sentences[idx]) { handleOnEnd() }
    }

    private func handleOnEnd() {
        if mode == .continuous {
            playSentence(playIndex + 1)
        } else {
            isPlaying = false
        }
    }
}

// MARK: - Playback Mode

enum PlaybackMode {
    case continuous, single
}
