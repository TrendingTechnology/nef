//  Copyright © 2019 The nef Authors.

import Foundation
import Markup
import Common

let scriptName = "nef-markdown-page"
let console = MarkdownConsole()

func main() {
    let result = arguments(keys: "from", "to", "filename")
    guard let fromPage = result["from"],
          let output = result["to"],
          let filename = result["filename"] else {
            Console.help.show(output: console);
            exit(-1)
    }

    let from = "\(fromPage)/Contents.swift"
    let to = "\(output)/\(filename).md"

    renderMarkdown(from: from, to: to)
}

/// Method to render a page into Markdown format.
///
/// - Parameters:
///   - filePath: input page in Apple's playground format.
///   - outputPath: output where to write the Markdown render.
func renderMarkdown(from filePath: String, to outputPath: String) {
    let fileURL = URL(fileURLWithPath: filePath)
    let outputURL = URL(fileURLWithPath: outputPath)

    guard let content = try? String(contentsOf: fileURL, encoding: .utf8),
          let rendered = MarkdownGenerator().render(content: content),
          let _ = try? rendered.write(to: outputURL, atomically: true, encoding: .utf8) else {
            Console.error(information: "").show(output: console)
            return
    }

    Console.success.show(output: console)
}

// #: - MAIN <launcher>
main()
