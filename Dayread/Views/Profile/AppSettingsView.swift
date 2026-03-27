import SwiftUI

struct AppSettingsView: View {
    @Environment(PreferencesService.self) private var preferencesService

    private var prefs: AppPreferences {
        preferencesService.preferences
    }

    var body: some View {
        Section("설정") {
            // 테마
            HStack {
                Label("테마", systemImage: "paintbrush")
                Spacer()
                Picker("", selection: Binding(
                    get: { prefs.theme },
                    set: { preferencesService.setTheme($0) }
                )) {
                    Text("시스템").tag(ThemePreference.system)
                    Text("라이트").tag(ThemePreference.light)
                    Text("다크").tag(ThemePreference.dark)
                }
                .labelsHidden()
                .pickerStyle(.menu)
            }

            // 글자 크기
            HStack {
                Label("글자 크기", systemImage: "textformat.size")
                Spacer()
                Picker("", selection: Binding(
                    get: { prefs.textScale },
                    set: { preferencesService.setTextScale($0) }
                )) {
                    Text("작게").tag(TextScale.compact)
                    Text("보통").tag(TextScale.default)
                    Text("크게").tag(TextScale.large)
                }
                .labelsHidden()
                .pickerStyle(.menu)
            }

            // 본문 서체
            HStack {
                Label("본문 서체", systemImage: "textformat")
                Spacer()
                Picker("", selection: Binding(
                    get: { prefs.fontStyle },
                    set: { preferencesService.setFontStyle($0) }
                )) {
                    Text("산세리프").tag(FontStyle.sans)
                    Text("세리프").tag(FontStyle.serif)
                }
                .labelsHidden()
                .pickerStyle(.menu)
            }

            // 포커스 모드 자동 재생
            Toggle(isOn: Binding(
                get: { prefs.autoplayAudio },
                set: { preferencesService.setAutoplayAudio($0) }
            )) {
                Label("포커스 모드 자동 재생", systemImage: "play.circle")
            }

            // 기본 재생 속도
            HStack {
                Label("기본 재생 속도", systemImage: "gauge.with.dots.needle.bottom.50percent")
                Spacer()
                Picker("", selection: Binding(
                    get: { prefs.defaultPlaybackRate },
                    set: { preferencesService.setPlaybackRate($0) }
                )) {
                    Text("0.5x").tag(0.5)
                    Text("0.75x").tag(0.75)
                    Text("1.0x").tag(1.0)
                    Text("1.25x").tag(1.25)
                    Text("1.5x").tag(1.5)
                }
                .labelsHidden()
                .pickerStyle(.menu)
            }

            // 푸시 알림
            Toggle(isOn: Binding(
                get: { prefs.pushNotificationsEnabled },
                set: { newValue in
                    preferencesService.setPushNotifications(enabled: newValue)
                    Task {
                        await NotificationService.rescheduleIfNeeded(
                            enabled: newValue, hour: prefs.notificationHour
                        )
                    }
                }
            )) {
                Label("푸시 알림", systemImage: "bell")
            }

            // 리마인더 시간
            if prefs.pushNotificationsEnabled {
                HStack {
                    Label("리마인더 시간", systemImage: "clock")
                    Spacer()
                    Picker("", selection: Binding(
                        get: { prefs.notificationHour },
                        set: { newHour in
                            preferencesService.setPushNotifications(enabled: prefs.pushNotificationsEnabled, hour: newHour)
                            Task {
                                await NotificationService.rescheduleIfNeeded(
                                    enabled: true, hour: newHour
                                )
                            }
                        }
                    )) {
                        ForEach(0..<24, id: \.self) { hour in
                            Text(String(format: "%02d:00", hour)).tag(hour)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                }
            }

            // 진동 피드백
            Toggle(isOn: Binding(
                get: { prefs.hapticsEnabled },
                set: { preferencesService.setHapticsEnabled($0) }
            )) {
                Label("진동 피드백", systemImage: "iphone.radiowaves.left.and.right")
            }
        }
    }
}
