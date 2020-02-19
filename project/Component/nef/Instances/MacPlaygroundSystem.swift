//  Copyright © 2019 The nef Authors.

import Foundation
import NefCommon
import Bow
import BowEffects

class MacPlaygroundSystem: PlaygroundSystem {
    
    func xcworkspaces(at folder: URL) -> EnvIO<FileSystem, PlaygroundSystemError, NEA<URL>> {
        func isDependency(xcworkspace: URL) -> Bool {
            return xcworkspace.path.contains("/Pods/") || xcworkspace.path.contains("/Carthage/")
        }
        
        func workspace(file: URL, fileSystem: FileSystem) -> URL? {
            guard file.pathExtension == "pbxproj" else { return nil }
            
            let xcodeproj = file.deletingLastPathComponent()
            let xcworkspace = xcodeproj.deletingPathExtension().appendingPathExtension("xcworkspace")
            return fileSystem.exist(itemPath: xcworkspace.path) ? xcworkspace : nil
        }
        
        func nea(from xcworkspaces: [URL], atFolder folder: URL) -> IO<PlaygroundSystemError, NEA<URL>> {
            NEA<URL>.fromArray(xcworkspaces)
                    .fold({ IO.raiseError(.playgrounds(information: "not found any valid workspace in '\(folder.path)'")) },
                          { nea in IO.pure(nea) })^
        }
        
        return EnvIO { fileSystem in
            fileSystem.items(atPath: folder.path, recursive: true)
                      .mapError { e in PlaygroundSystemError.playgrounds(information: "\(e)") }
                      .map { paths in paths.map(URL.init(fileURLWithPath:)) }
                      .map { files in files.compactMap { file in workspace(file: file, fileSystem: fileSystem) } }
                      .map { workspaces in workspaces.filter { !isDependency(xcworkspace: $0) } }
                      .flatMap { xcworkspaces in nea(from: xcworkspaces, atFolder: folder) }
        }
    }
    
    func linkedPlaygrounds(at folder: URL) -> EnvIO<FileSystem, PlaygroundSystemError, NEA<URL>> {
        let xcworkspaces = EnvIO<FileSystem, PlaygroundSystemError, NEA<URL>>.var()
        let playgrounds = EnvIO<FileSystem, PlaygroundSystemError, NEA<URL>>.var()
        
        return binding(
            xcworkspaces <- self.xcworkspaces(at: folder),
             playgrounds <- self.getPlaygrounds(in: xcworkspaces.get),
        yield: playgrounds.get)^
    }
    
    func playgrounds(at folder: URL) -> EnvIO<FileSystem, PlaygroundSystemError, NEA<URL>> {
        func nea(from playgrounds: [URL], atFolder folder: URL) -> IO<PlaygroundSystemError, NEA<URL>> {
            NEA<URL>.fromArray(playgrounds)
                    .fold({ IO.raiseError(.playgrounds(information: "not found any playround in '\(folder.path)'")) },
                          { nea in IO.pure(nea) })^
        }
        
        return EnvIO { fileSystem in
            fileSystem.items(atPath: folder.path, recursive: false)
                      .mapError { e in PlaygroundSystemError.playgrounds(information: "\(e)") }
                      .map { paths in paths.filter { "\($0)$".contains(".playground$") } }
                      .map { paths in paths.map(URL.init(fileURLWithPath:)) }
                      .flatMap { playgrounds in nea(from: playgrounds, atFolder: folder) }
        }
    }
    
    func pages(in playground: URL) -> EnvIO<FileSystem, PlaygroundSystemError, NEA<URL>> {
        func extractPages(in playground: URL) -> EnvIO<FileSystem, PlaygroundSystemError, [URL]> {
            EnvIO.invoke { _ in
                let xcplayground = playground.appendingPathComponent("contents.xcplayground")
                let content = try String(contentsOf: xcplayground)

                return content.matches(pattern: "(?<=name=').*(?=')")
                              .map { page in playground.appendingPathComponent("Pages")
                                                       .appendingPathComponent(page)
                                                       .appendingPathExtension("xcplaygroundpage") }
            }
        }
        
        func checkNumberOfPages(_ pages: [URL], playground: URL) -> EnvIO<FileSystem, PlaygroundSystemError, [URL]> {
            EnvIO { fileSystem in
                guard pages.count == 0 else { return IO.pure(pages)^ }
                
                return fileSystem.items(atPath: playground.appendingPathComponent("Pages").path, recursive: false)
                          .map { paths in paths.map(URL.init(fileURLWithPath:)) }^
                          .mapError { _ in .pages() }
            }
        }
        
        func validatePages(_ pages: [URL], playground: URL) -> EnvIO<FileSystem, PlaygroundSystemError, [URL]> {
            EnvIO { fileSystem in
                pages.traverse { page in
                    fileSystem.exist(itemPath: page.path) ? IO.pure(page)
                                                          : IO.raiseError(.pages(information: "page '\(page.path)' is not linked properly to '\(playground.path)'"))
                }
            }
        }
        
        func buildNEA(pages: [URL], playground: URL) -> EnvIO<FileSystem, PlaygroundSystemError, NEA<URL>> {
            NEA<URL>.fromArray(pages).fold({ EnvIO.raiseError(.pages(information: "not found pages in '\(playground.path)'")) },
                                           { nea in EnvIO.pure(nea) })^
        }
        
        return extractPages(in: playground)
                .flatMap { pages in checkNumberOfPages(pages, playground: playground) }
                .flatMap { pages in validatePages(pages, playground: playground)      }
                .flatMap { pages in buildNEA(pages: pages, playground: playground)    }^
    }
    
    // MARK: - helpers
    private func getPlaygrounds(in xcworkspaces: NEA<URL>) -> EnvIO<FileSystem, PlaygroundSystemError, NEA<URL>> {
        func extractPlaygrounds(from xcworkspace: URL) -> EnvIO<FileSystem, PlaygroundSystemError, [URL]> {
            EnvIO.invoke { _ in
                let content = try String(contentsOf: xcworkspace.appendingPathComponent("contents.xcworkspacedata"))
                return content.matches(pattern: "(?<=group:).*.playground(?=\")")
                              .map { playground in xcworkspace.deletingLastPathComponent().appendingPathComponent(playground) }
            }^
        }
        
        func validatePlaygrounds(_ playgrounds: [URL]) -> EnvIO<FileSystem, PlaygroundSystemError, [URL]> {
            EnvIO { fileSystem in
                playgrounds.traverse { playground in
                    fileSystem.exist(itemPath: playground.path) ? IO.pure(playground)
                                                                : IO.raiseError(.playgrounds(information: "some playgrounds are not linked properly"))
                }
            }
        }
        
        func buildNEA(playgrounds: [URL]) -> EnvIO<FileSystem, PlaygroundSystemError, NEA<URL>> {
            NEA<URL>.fromArray(playgrounds).fold({ EnvIO.raiseError(.playgrounds(information: "can not find any playground in the workspace")) },
                                                 { nea in EnvIO.pure(nea) })^
        }
        
        return xcworkspaces.all()
                .parFlatTraverse(extractPlaygrounds)
                .flatMap(validatePlaygrounds)
                .flatMap(buildNEA)^
    }
}
