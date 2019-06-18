//  Copyright © 2019 The nef Authors.

import Foundation
import Markup

let scriptName = "nef-carbon-page"

func main(downloader: CarbonDownloader) {
    let result = arguments(keys: "from", "to")
    guard let fromPage = result["from"],
          let output = result["to"] else {
            Console.help.show();
            exit(-1)
    }
    
    let from = "\(fromPage)/Contents.swift"
    let playgroundName = PlaygroundUtils.playgroundName(fromPage: from)
    let to = "\(output)/\(playgroundName)".expandingTildeInPath
    
    renderCarbon(downloader: downloader, from: from, to: to)
}

/// Method to render a page into Carbon's images.
///
/// - Parameters:
///   - filePath: input page in Apple's playground format.
///   - outputPath: output where to render the snippets.
func renderCarbon(downloader: CarbonDownloader, from filePath: String, to outputPath: String) {
    guard let content = try? String(contentsOf: URL(fileURLWithPath: filePath), encoding: .utf8) else { Console.error(information: "").show(); return }
    
    let style = CarbonStyle(background: CarbonStyle.Color.bow,
                            size: .x3,
                            theme: .dracula,
                            fontType: .firaCode,
                            lineNumbers: true)
    
    let carbonGenerator = CarbonGenerator(downloader: downloader, style: style, output: outputPath)
    guard let trace = carbonGenerator.render(content: content) else {  Console.error(information: "").show(); return }
    
    if carbonGenerator.isValid(trace: trace) {
        Console.success.show()
    } else {
        Console.error(information: trace).show()
    }
    
    CarbonApplication.terminate()
}


// #: - MAIN <launcher - AppKit>
_ = CarbonApplication { downloader in
    main(downloader: downloader)
}
