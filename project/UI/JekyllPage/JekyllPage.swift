//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import Bow
import BowEffects

public struct JekyllPageCommand: ParsableCommand {
    public static var commandName: String = "nef-jekyll-page"
    public static var configuration = CommandConfiguration(commandName: commandName,
                                                           abstract: "Render a markdown file from a Playground page that can be consumed from Jekyll")

    public init() {}
    
    @ArgumentParser.Option(help: ArgumentHelp("Path to playground page. ex. `/home/nef.playground/Pages/Intro.xcplaygroundpage`", valueName: "playground's page"))
    private var page: ArgumentPath
    
    @ArgumentParser.Option(help: "Path where Jekyll markdown are saved to. ex. `/home`")
    private var output: ArgumentPath
    
    @ArgumentParser.Option(help: ArgumentHelp("Relative path where Jekyll will render the documentation. ex. `/about/`", valueName: "relative URL"))
    private var permalink: String
    
    @ArgumentParser.Flag (help: "Run jekyll page in verbose mode")
    private var verbose: Bool
    
    private var outputFile: URL { output.url.appendingPathComponent("README.md") }
    
    
    public func run() throws {
        try run().provide(Self.console)^.unsafeRunSync()
    }
    
    func run() -> EnvIO<CLIKit.Console, nef.Error, Void> {
        nef.Jekyll.renderVerbose(page: page.url, permalink: permalink, toFile: outputFile)
            .reportStatus(failure: { e in "rendering jekyll page. \(e)" },
                          success: { (url, ast, rendered) in "rendered jekyll page '\(url.path)'.\(self.verbose ? "\n\n• AST \n\t\(ast)\n\n• Output \n\t\(rendered)" : "")" })
    }
}
