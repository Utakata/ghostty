import Foundation
import GhosttyKit

class ConfigFileManager {
    static let shared = ConfigFileManager()

    private init() {}

    func getConfigPath() -> String? {
        let str = Ghostty.AllocatedString(ghostty_config_open_path()).string
        guard !str.isEmpty else { return nil }
        return str
    }

    func updateConfig(key: String, value: String) {
        guard let path = getConfigPath() else {
            print("Error: Could not determine config file path")
            return
        }

        do {
            let fileURL = URL(fileURLWithPath: path)
            var content = ""

            if FileManager.default.fileExists(atPath: path) {
                content = try String(contentsOf: fileURL, encoding: .utf8)
            }

            var lines = content.components(separatedBy: .newlines)
            var found = false

            // Regex to find the key assignment.
            // Matches: ^ optional_whitespace key optional_whitespace =
            let pattern = "^\\s*\(NSRegularExpression.escapedPattern(for: key))\\s*="
            let regex = try NSRegularExpression(pattern: pattern)

            for (index, line) in lines.enumerated() {
                // Ignore comments
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.hasPrefix("#") { continue }

                let range = NSRange(location: 0, length: line.utf16.count)
                if regex.firstMatch(in: line, options: [], range: range) != nil {
                    lines[index] = "\(key) = \(value)"
                    found = true
                    break
                }
            }

            if !found {
                 lines.append("\(key) = \(value)")
            }

            let newContent = lines.joined(separator: "\n")
            try newContent.write(to: fileURL, atomically: true, encoding: .utf8)

        } catch {
            print("Error updating config file: \(error)")
        }
    }
}
