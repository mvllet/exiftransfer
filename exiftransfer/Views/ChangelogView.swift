import SwiftUI
import WebKit

struct ChangelogView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var html: String?
    @State private var isLoading = true
    @State private var loadFailed = false

    private let changelogURL = URL(string: "https://mvllet.dev/exiftransfer/changelog.md")!

    var body: some View {
        VStack(spacing: 0) {
            titleBar
            Divider()
            bodyContent
        }
        .frame(width: 520, height: 420)
        .task { await fetchChangelog() }
    }

    private var titleBar: some View {
        HStack {
            Text("What's New")
                .font(.headline)
            Spacer()
            Button("Done") { dismiss() }
        }
        .padding()
    }

    @ViewBuilder
    private var bodyContent: some View {
        if isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if loadFailed {
            ContentUnavailableView(
                "Unable to Load",
                systemImage: "wifi.slash",
                description: Text("Check your internet connection and try again.")
            )
        } else if let html {
            MarkdownWebView(html: html)
        }
    }

    private func fetchChangelog() async {
        var markdown: String?

        if let data = try? await URLSession.shared.data(from: changelogURL).0 {
            markdown = String(decoding: data, as: UTF8.self)
        } else if let url = Bundle.main.url(forResource: "changelog", withExtension: "md"),
                  let content = try? String(contentsOf: url, encoding: .utf8) {
            markdown = content
        }

        if let md = markdown {
            html = parseMarkdown(md)
        } else {
            loadFailed = true
        }
        isLoading = false
    }

    private func parseMarkdown(_ markdown: String) -> String {
        var body = ""

        for line in markdown.components(separatedBy: "\n") {
            if line.hasPrefix("# ") {
                let text = inline(String(line.dropFirst(2)))
                body += "<h1>\(text)</h1>"
            } else if line.hasPrefix("- ") {
                body += renderEntry(String(line.dropFirst(2)))
            }
        }

        return htmlTemplate(body: body)
    }

    private func renderEntry(_ text: String) -> String {
        let entries: [(prefix: String, cssClass: String, label: String, offset: Int)] = [
            ("Added", "cat-added", "Added", 6),
            ("Changed", "cat-changed", "Changed", 8),
            ("Fixed", "cat-fixed", "Fixed", 6)
        ]

        for entry in entries {
            if text.hasPrefix(entry.prefix + " ") {
                let description = inline(String(text.dropFirst(entry.offset)))
                return """
                <div class="entry">
                    <div class="category \(entry.cssClass)">\(entry.label)</div>
                    <div>\(description)</div>
                </div>
                """
            }
        }

        return "<div class=\"entry\"><div>\(inline(text))</div></div>"
    }

    private func escapeHTML(_ s: String) -> String {
        s.replacingOccurrences(of: "&", with: "&amp;")
         .replacingOccurrences(of: "<", with: "&lt;")
         .replacingOccurrences(of: ">", with: "&gt;")
    }

    private func inline(_ s: String) -> String {
        var result = escapeHTML(s)
        result = result.replacingOccurrences(
            of: #"\*\*(.+?)\*\*"#,
            with: "<strong>$1</strong>",
            options: .regularExpression
        )
        result = result.replacingOccurrences(
            of: #"\*(.+?)\*"#,
            with: "<em>$1</em>",
            options: .regularExpression
        )
        result = result.replacingOccurrences(
            of: #"`(.+?)`"#,
            with: "<code>$1</code>",
            options: .regularExpression
        )
        return result
    }

    private func htmlTemplate(body: String) -> String {
        """
        <html>
        <head>
        <meta name="color-scheme" content="light dark">
        <style>
            body {
                font-family: -apple-system, BlinkMacSystemFont, sans-serif;
                font-size: 13px;
                margin: 0;
                padding: 16px;
                color: #000;
                background: transparent;
                line-height: 1.5;
            }
            @media (prefers-color-scheme: dark) { body { color: #fff; } }

            h1 {
                font-size: 1.3em;
                margin: 20px 0 6px;
                font-weight: 600;
            }
            h1:first-child { margin-top: 0; }

            .entry {
                display: flex;
                align-items: baseline;
                margin: 3px 0;
                gap: 10px;
            }
            .category {
                flex-shrink: 0;
                width: 68px;
                font-weight: 600;
                font-size: 12px;
                text-align: right;
            }
            .cat-added { color: #2da44e; }
            .cat-changed { color: #d4a72c; }
            .cat-fixed { color: #cf222e; }
            @media (prefers-color-scheme: dark) {
                .cat-added { color: #56d364; }
                .cat-changed { color: #e3b341; }
                .cat-fixed { color: #ff7b72; }
            }

            code {
                font-family: monospace;
                background: rgba(128,128,128,0.15);
                padding: 1px 4px;
                border-radius: 3px;
            }
        </style>
        </head>
        <body>\(body)</body>
        </html>
        """
    }
}

struct MarkdownWebView: NSViewRepresentable {
    let html: String

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.preferences.setValue(false, forKey: "javaScriptEnabled")
        let view = WKWebView(frame: .zero, configuration: config)
        view.setValue(false, forKey: "drawsBackground")
        return view
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.loadHTMLString(html, baseURL: nil)
    }
}
