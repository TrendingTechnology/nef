//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import Bow
import BowEffects

struct JekyllPageCommand: ConsoleCommand {
    static var commandName: String = "nef-jekyll-page"
    static var configuration = CommandConfiguration(commandName: commandName,
                                                    abstract: "Render a markdown file from a Playground page that can be consumed from Jekyll")

    @ArgumentParser.Option(help: ArgumentHelp("Path to playground page. ex. `/home/nef.playground/Pages/Intro.xcplaygroundpage`", valueName: "playground's page"))
    var page: String
    
    @ArgumentParser.Option(help: "Path where Jekyll markdown are saved to. ex. `/home`")
    var output: String
    
    @ArgumentParser.Option(help: ArgumentHelp("Relative path where Jekyll will render the documentation. ex. `/about/`", valueName: "relative URL"))
    var permalink: String
    
    @ArgumentParser.Flag (help: "Run jekyll page in verbose mode")
    var verbose: Bool
    
    var pageContent: String? { try? String(contentsOfFile: pagePath) }
    var outputURL: URL { URL(fileURLWithPath: output.trimmingEmptyCharacters.expandingTildeInPath).appendingPathComponent("README.md") }
    var pagePath: String {
        let path = page.trimmingEmptyCharacters.expandingTildeInPath
        return path.contains("Contents.swift") ? path : "\(path)/Contents.swift"
    }
}

@discardableResult
public func jekyllPage(commandName: String) -> Either<CLIKit.Console.Error, Void> {
    JekyllPageCommand.commandName = commandName
    
    func arguments(parsableCommand: JekyllPageCommand) -> IO<CLIKit.Console.Error, (content: String, permalink: String, output: URL, verbose: Bool)> {
        guard let pageContent = parsableCommand.pageContent, !pageContent.isEmpty else {
            return IO.raiseError(.arguments(info: "could not read page content"))^
        }
        
        return IO.pure((content: pageContent,
                        permalink: parsableCommand.permalink,
                        output: parsableCommand.outputURL,
                        verbose: parsableCommand.verbose))^
    }
    
    return CLIKit.Console.default.readArguments(JekyllPageCommand.self)
        .flatMap(arguments)
        .flatMap { (content, permalink, output, verbose) in
            nef.Jekyll.renderVerbose(content: content, permalink: permalink, toFile: output)
                .provide(Console.default)
                .mapError { _ in .render() }
                .foldM({ e in Console.default.exit(failure: "rendering jekyll page. \(e)") },
                       { (url, ast, rendered) in Console.default.exit(success: "rendered jekyll page '\(url.path)'.\(verbose ? "\n\n• AST \n\t\(ast)\n\n• Output \n\t\(rendered)" : "")") }) }^
        .reportStatus(in: .default)
        .unsafeRunSyncEither()
}
