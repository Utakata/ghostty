import SwiftUI
import GhosttyKit

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel

    init(app: Ghostty.App) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(app: app))
    }

    var body: some View {
        TabView {
            GeneralSettingsView(viewModel: viewModel)
                .tabItem {
                    Label("General", systemImage: "gear")
                }

            AppearanceSettingsView(viewModel: viewModel)
                .tabItem {
                    Label("Appearance", systemImage: "paintpalette")
                }
        }
        .padding()
        .frame(minWidth: 500, minHeight: 300)
    }
}

struct GeneralSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var fontFamily: String = ""
    @State private var theme: String = ""

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Font Family:")
                        .frame(width: 100, alignment: .trailing)
                    TextField("Monospace", text: $fontFamily)
                        .onSubmit {
                            viewModel.fontFamily.wrappedValue = fontFamily
                        }
                }

                HStack {
                    Text("Font Size:")
                        .frame(width: 100, alignment: .trailing)
                    Stepper(value: viewModel.fontSize, in: 6...72, step: 1) {
                        Text(String(format: "%.1f", viewModel.fontSize.wrappedValue))
                    }
                }

                HStack {
                    Text("Theme:")
                        .frame(width: 100, alignment: .trailing)
                    TextField("Theme Name", text: $theme)
                        .onSubmit {
                            viewModel.theme.wrappedValue = theme
                        }
                }
            }
        }
        .padding()
        .onAppear {
            fontFamily = viewModel.config.fontFamily ?? ""
            theme = viewModel.config.theme ?? ""
        }
        .onChange(of: viewModel.config.fontFamily) { newValue in
             let val = newValue ?? ""
             if val != fontFamily { fontFamily = val }
        }
        .onChange(of: viewModel.config.theme) { newValue in
             let val = newValue ?? ""
             if val != theme { theme = val }
        }
    }
}

struct AppearanceSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var opacity: Double = 1.0

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    Text("Background Opacity: \(Int(opacity * 100))%")
                    Slider(value: $opacity, in: 0...1) { editing in
                        if !editing {
                            viewModel.backgroundOpacity.wrappedValue = opacity
                        }
                    }
                }
                .padding(.bottom)

                Toggle("Background Blur", isOn: viewModel.blur)

                Toggle("Window Decorations", isOn: viewModel.windowDecorations)
            }
        }
        .padding()
        .onAppear {
            opacity = viewModel.config.backgroundOpacity
        }
        .onChange(of: viewModel.config.backgroundOpacity) { newValue in
            if abs(opacity - newValue) > 0.01 {
                opacity = newValue
            }
        }
    }
}
