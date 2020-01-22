//  Copyright © 2019 The nef Authors.

import NefCommon
import NefModels
import NefCore
import BowEffects

public struct RenderEnvironment<A> {
    public typealias NodePrinter = (_ content: String) -> IO<CoreRenderError, RenderingOutput<A>>
    
    public let console: Console
    public let playgroundSystem: PlaygroundSystem
    public let nodePrinter: NodePrinter

    public init(console: Console, playgroundSystem: PlaygroundSystem, nodePrinter: @escaping NodePrinter) {
        self.console = console
        self.playgroundSystem = playgroundSystem
        self.nodePrinter = nodePrinter
    }
}
