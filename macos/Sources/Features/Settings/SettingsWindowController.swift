import Foundation
import Cocoa
import SwiftUI
import GhosttyKit

class SettingsWindowController: NSWindowController {
    static let shared = SettingsWindowController()

    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered, defer: false)
        window.title = "Ghostty Settings"
        window.center()
        self.init(window: window)
    }

    func show() {
        if let window = self.window {
             if window.contentView == nil || !(window.contentView is NSHostingView<SettingsView>) {
                if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
                    window.contentView = NSHostingView(rootView: SettingsView(app: appDelegate.ghostty))
                }
            }

            self.showWindow(nil)
            window.makeKeyAndOrderFront(nil)
        }
        NSApp.activate(ignoringOtherApps: true)
    }
}
