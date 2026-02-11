import Foundation
import SwiftUI
import Combine
import GhosttyKit

class SettingsViewModel: ObservableObject {
    @Published var config: Ghostty.Config

    private var cancellables = Set<AnyCancellable>()

    init(app: Ghostty.App) {
        self.config = app.config

        app.$config
            .receive(on: RunLoop.main)
            .sink { [weak self] newConfig in
                self?.config = newConfig
            }
            .store(in: &cancellables)
    }

    var fontSize: Binding<Double> {
        Binding(
            get: { self.config.fontSize },
            set: { val in
                if abs(self.config.fontSize - val) > 0.1 {
                    ConfigFileManager.shared.updateConfig(key: "font-size", value: String(format: "%.1f", val))
                }
            }
        )
    }

    var fontFamily: Binding<String> {
        Binding(
            get: { self.config.fontFamily ?? "" },
            set: { val in
                if self.config.fontFamily != val {
                    ConfigFileManager.shared.updateConfig(key: "font-family", value: val)
                }
            }
        )
    }

    var theme: Binding<String> {
        Binding(
            get: { self.config.theme ?? "" },
            set: { val in
                if self.config.theme != val {
                    ConfigFileManager.shared.updateConfig(key: "theme", value: val)
                }
            }
        )
    }

    var backgroundOpacity: Binding<Double> {
        Binding(
            get: { self.config.backgroundOpacity },
            set: { val in
                 if abs(self.config.backgroundOpacity - val) > 0.01 {
                    ConfigFileManager.shared.updateConfig(key: "background-opacity", value: String(format: "%.2f", val))
                 }
            }
        )
    }

    var windowDecorations: Binding<Bool> {
        Binding(
            get: { self.config.windowDecorations },
            set: { val in
                if self.config.windowDecorations != val {
                    ConfigFileManager.shared.updateConfig(key: "window-decoration", value: val ? "auto" : "none")
                }
            }
        )
    }

    var blur: Binding<Bool> {
        Binding(
            get: { self.config.backgroundBlur.isEnabled },
            set: { val in
                if self.config.backgroundBlur.isEnabled != val {
                    ConfigFileManager.shared.updateConfig(key: "background-blur", value: val ? "20" : "0")
                }
            }
        )
    }
}
