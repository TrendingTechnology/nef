//  Copyright © 2019 The nef Authors.

import Foundation
import NefCommon
import NefModels
import NefCore
import NefRender

import Bow
import BowEffects

public struct Jekyll {
    private let render = NefRender()
    
    public init() {}
    
    // MARK: - helpers
    private func generator(permalink: String) -> CoreRender {
        JekyllGenerator(permalink: permalink)
    }
}













/// Renders a page into Jekyll format.
///
/// - Parameters:
///   - content: content page in Xcode playground.
///   - outputPath: output where to write the Jekyll render.
///   - permalink: website relative url where locate the page.
///   - success: callback to notify if everything goes well.
///   - failure: callback with information to notify if something goes wrong.
public func renderJekyll(content: String,
                         to outputPath: String,
                         permalink: String,
                         success: @escaping (RendererOutput) -> Void,
                         failure: @escaping (String) -> Void) {
    
    let url = URL(fileURLWithPath: outputPath)
    guard let rendered = JekyllGenerator(permalink: permalink).render(content: content) else { failure("can not render page into Jekyll format"); return }
    guard let _ = try? rendered.output.write(to: url, atomically: true, encoding: .utf8) else { failure("invalid output path '\(url.path)'"); return }
    
    success(rendered)
}
