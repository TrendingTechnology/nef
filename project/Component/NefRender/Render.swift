//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefCore
import NefModels

import Bow
import BowEffects

public struct Render<A> {
    public typealias Environment = RenderEnvironment<A>
    
    public init() {}
    
    public func page(content: String) -> EnvIO<Environment, RenderError, RenderingOutput<A>> {
        renderPage(content: content, info: .empty)
    }
    
    public func playground(_ playground: URL) -> EnvIO<Environment, RenderError, PlaygroundOutput<A>> {
        renderPlayground(RenderingURL(url: playground, title: playgroundName(playground)))
    }
    
    public func playgrounds(at folder: URL) -> EnvIO<Environment, RenderError, PlaygroundsOutput<A>> {
        func merge(playgrounds: NEA<RenderingURL>, output: NEA<PlaygroundOutput<A>>) -> EnvIO<Environment, RenderError, PlaygroundsOutput<A>> {
            guard playgrounds.count == output.count, !playgrounds.all().isEmpty else { return EnvIO.raiseError(.playgrounds)^ }
            
            let tuples = zip(playgrounds.all(), output.all()).map { playground, output in (playground: playground, output: output) }
            return EnvIO.pure(NEA.fromArrayUnsafe(tuples))^
        }
        
        let playgrounds = EnvIO<Environment, RenderError, NEA<RenderingURL>>.var()
        let rendered = EnvIO<Environment, RenderError, NEA<PlaygroundOutput<A>>>.var()
        let output = EnvIO<Environment, RenderError, PlaygroundsOutput<A>>.var()

        return binding(
            playgrounds <- self.getPlaygrounds(at: folder),
               rendered <- playgrounds.get.traverse(self.renderPlayground),
                 output <- merge(playgrounds: playgrounds.get, output: rendered.get),
        yield: output.get)^
    }
    
    // MARK: - render <helpers>
    private func renderPlayground(_ playground: RenderingURL) -> EnvIO<Environment, RenderError, PlaygroundOutput<A>> {
        let pages = EnvIO<Environment, RenderError, NEA<RenderingURL>>.var()
        let rendered = EnvIO<Environment, RenderError, PlaygroundOutput<A>>.var()
        
        return binding(
                pages <- self.getPages(playground: playground),
             rendered <- self.renderPages(pages.get, inPlayground: playground),
        yield: rendered.get)^
    }
    
    private func renderPages(_ pages: NEA<RenderingURL>, inPlayground playground: RenderingURL) -> EnvIO<Environment, RenderError, PlaygroundOutput<A>> {
        pages.traverse { (page: RenderingURL) in
            let url = page.url.appendingPathComponent("Contents.swift")
            guard let content = try? String(contentsOf: url) else { return EnvIO.raiseError(.page(url))^ }
            return self.renderPage(content: content, info: .info(playground: playground, page: page)).map { output in (page: page, output: output) }^
        }^
    }
    
    private func renderPage(content: String, info: RenderEnvironmentInfo) -> EnvIO<Environment, RenderError, RenderingOutput<A>> {
        EnvIO { env in
            let rendered = IO<RenderError, RenderingOutput<A>>.var()
            
            return binding(
                             |<-env.console.print(information: "\t• Rendering page \(info.data?.page.title ?? "content")"),
                    rendered <- env.nodePrinter(content).provide(info).mapLeft { _ in .content },
            yield: rendered.get)^.reportStatus(console: env.console)
        }
    }
    
    // MARK: - private <helpers>
    private func getPages(playground: RenderingURL) -> EnvIO<Environment, RenderError, NEA<RenderingURL>> {
        EnvIO { env in
            let pages = IO<RenderError, NEA<URL>>.var()
            let rendererPages = IO<RenderError, NEA<RenderingURL>>.var()
            
            return binding(
                              |<-env.console.print(information: "Get pages in playground '\(playground)'"),
                        pages <- env.playgroundSystem.pages(in: playground.url).mapLeft { _ in .getPages(playground: playground.url) },
                rendererPages <- pages.get.traverse { url in RenderingURL(url: url, title: self.pageName(url)).io() },
            yield: rendererPages.get)^.reportStatus(console: env.console)
        }
    }
    
    private func getPlaygrounds(at folder: URL) -> EnvIO<Environment, RenderError, NEA<RenderingURL>> {
        EnvIO { env in
            let playgrounds = IO<RenderError, NEA<URL>>.var()
            let rendered = IO<RenderError, NEA<RenderingURL>>.var()
            
            return binding(
                           |<-env.console.print(information: "Get playgrounds in '\(folder.lastPathComponent.removeExtension)'"),
               playgrounds <- env.playgroundSystem.playgrounds(at: folder).mapLeft { _ in .getPlaygrounds(folder: folder) },
                  rendered <- playgrounds.get.traverse { url in RenderingURL(url: url, title: self.playgroundName(url)).io() },
            yield: rendered.get)^.reportStatus(console: env.console)
        }
    }
    
    // MARK: - format file <helpers>
    private func playgroundName(_ playground: URL) -> String {
        playground.lastPathComponent.removeExtension
    }
    
    private func pageName(_ page: URL) -> String {
        var filename = page.lastPathComponent.removeExtension
        if filename == "README" {
            filename = page.deletingLastPathComponent().lastPathComponent.removeExtension
        }
        
        return filename
    }
}
