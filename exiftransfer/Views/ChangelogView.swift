// ChangelogView.swift

import SwiftUI
import WebKit

// Remote markdown changelog rendered inside a WKWebView.
struct ChangelogView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var html: String?
    @State private var isLoading = true
    @State private var loadFailed = false

    private let changelogURL = URL(
        string: "https://mvllet.dev/exiftransfer/changelog.md"
    )!

    var body: some View {
        VStack(spacing: 0) {
            titleBar
            Divider()
            bodyContent
        }
        .frame(width: 520, height: 420)
        .task {
            await fetchChangelog()
        }
    }

    private var titleBar: some View {
        HStack {
            Text("What's New")
                .font(.headline)

            Spacer()

            Button("Done") {
                dismiss()
            }
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
                description: Text(
                    "Check your internet connection and try again."
                )
            )
        } else if let html {
            MarkdownWebView(html: html)
        }
    }

    private func fetchChangelog() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: changelogURL)

            let markdown = String(
                decoding: data,
                as: UTF8.self
            )

            let result = await Task.detached(
                priority: .userInitiated
            ) {
                await markdownToHTML(markdown)
            }.value

            html = result
        } catch {
            loadFailed = true
        }

        isLoading = false
    }

    private func markdownToHTML(_ markdown: String) -> String {
        let lines = markdown.components(separatedBy: "\n")

        var html: [String] = []
        var inCodeBlock = false
        var inList = false

        for line in lines {
            if line.hasPrefix("```") {
                if inList {
                    html.append("</ul>")
                    inList = false
                }

                if inCodeBlock {
                    html.append("</code></pre>")
                } else {
                    html.append("<pre><code>")
                }

                inCodeBlock.toggle()
                continue
            }

            if inCodeBlock {
                html.append(escapeHTML(line))
                continue
            }

            if line.hasPrefix("### ") {
                closeList(&html, &inList)

                html.append(
                    "<h3>\(inline(String(line.dropFirst(4))))</h3>"
                )
            } else if line.hasPrefix("## ") {
                closeList(&html, &inList)

                html.append(
                    "<h2>\(inline(String(line.dropFirst(3))))</h2>"
                )
            } else if line.hasPrefix("# ") {
                closeList(&html, &inList)

                html.append(
                    "<h1>\(inline(String(line.dropFirst(2))))</h1>"
                )
            } else if line.hasPrefix("- ") || line.hasPrefix("* ") {
                if !inList {
                    html.append("<ul>")
                    inList = true
                }

                html.append(
                    "<li>\(inline(String(line.dropFirst(2))))</li>"
                )
            } else if line.trimmingCharacters(
                in: .whitespaces
            ).isEmpty {
                closeList(&html, &inList)
                html.append("<br>")
            } else {
                closeList(&html, &inList)
                html.append("<p>\(inline(line))</p>")
            }
        }

        closeList(&html, &inList)

        if inCodeBlock {
            html.append("</code></pre>")
        }

        let body = html.joined(separator: "\n")

        return """
        <html>
        <head>
        <meta name="color-scheme" content="light dark">
        <style>
            body { font-family: -apple-system, sans-serif; font-size: 13px;
                   margin: 16px; color: #000; background: transparent; }
            @media (prefers-color-scheme: dark) { body { color: #fff; } }
            h1 { font-size: 1.4em; margin: 12px 0 4px; }
            h2 { font-size: 1.2em; margin: 10px 0 4px; }
            h3 { font-size: 1em;   margin: 8px 0 4px; }
            p  { margin: 4px 0; }
            ul { margin: 4px 0; padding-left: 20px; }
            li { margin: 2px 0; }
            code { font-family: monospace; background: rgba(128,128,128,0.15);
                   padding: 1px 4px; border-radius: 3px; }
            pre  { background: rgba(128,128,128,0.1); padding: 8px;
                   border-radius: 6px; overflow-x: auto; }
            pre code { background: none; padding: 0; }
        </style>
        </head>
        <body>\(body)</body>
        </html>
        """
    }

    private func closeList(
        _ html: inout [String],
        _ inList: inout Bool
    ) {
        if inList {
            html.append("</ul>")
            inList = false
        }
    }

    private func escapeHTML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }

    private func inline(_ string: String) -> String {
        var result = escapeHTML(string)

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
}

// Lightweight WKWebView wrapper for rendered markdown HTML.
struct MarkdownWebView: NSViewRepresentable {
    let html: String

    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()

        configuration.preferences.setValue(
            false,
            forKey: "javaScriptEnabled"
        )

        let webView = WKWebView(
            frame: .zero,
            configuration: configuration
        )

        webView.setValue(
            false,
            forKey: "drawsBackground"
        )

        return webView
    }

    func updateNSView(
        _ nsView: WKWebView,
        context: Context
    ) {
        nsView.loadHTMLString(
            html,
            baseURL: nil
        )
    }
}
