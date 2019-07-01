//  Copyright © 2019 The nef Authors.

import Foundation
import Markup
import Common

let scriptName = "nef-jekyll-page"
let console = JekyllConsole()

func main() {
    let result = arguments(keys: "from", "to", "permalink")
    guard let fromPage = result["from"],
          let output = result["to"],
          let permalink = result["permalink"] else {
            Console.help.show(output: console);
            exit(-1)
    }

    let from = "\(fromPage)/Contents.swift"
    let to = "\(output)/README.md"
    
    renderJekyll(from: from, to: to, permalink: permalink)
}

/// Method to render a page into Jekyll format.
///
/// - Parameters:
///   - filePath: input page in Apple's playgorund format.
///   - outputPath: output where to write the Jekyll render.
///   - permalink: website's relative url where locate the page.
func renderJekyll(from filePath: String, to outputPath: String, permalink: String) {
    let fileURL = URL(fileURLWithPath: filePath)
    let outputURL = URL(fileURLWithPath: outputPath)

    guard let content = try? String(contentsOf: fileURL, encoding: .utf8),
          let rendered = JekyllGenerator(permalink: permalink).render(content: content),
          let _ = try? rendered.write(to: outputURL, atomically: true, encoding: .utf8) else { Console.error(information: "").show(output: console); return }

    Console.success.show(output: console)
}

// #: - MAIN <launcher>
main()
