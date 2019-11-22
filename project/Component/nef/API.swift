//  Copyright © 2019 The nef Authors.

import Foundation
@_exported import NefModels

import Bow
import BowEffects


public enum Markdown: MarkdownAPI {}
public enum Jekyll: JekyllAPI {}
public enum Carbon: CarbonAPI {}
public enum SwiftPlayground: SwiftPlaygroundAPI {}


public protocol MarkdownAPI {
    /// Renders content into Markdown file.
    ///
    /// - Precondition: this method must be invoked from main thread.
    ///
    /// - Parameters:
    ///   - content: content page in Xcode playground.
    ///   - file: output where to write the Markdown render (path to the file without extension).
    /// - Returns: An `IO` to perform IO operations that produce carbon error of type `nef.Error` and values with the file generated of type `URL`.
    static func render(content: String, toFile file: URL) -> IO<nef.Error, URL>
}

public protocol JekyllAPI {
    /// Renders content into Jekyll format.
    ///
    /// - Precondition: this method must be invoked from main thread.
    ///
    /// - Parameters:
    ///   - content: content page in Xcode playground.
    ///   - file: output where to write the Markdown render (path to the file without extension).
    ///   - permalink: website relative url where locate the page.
    /// - Returns: An `IO` to perform IO operations that produce carbon error of type `nef.Error` and values with the file generated of type `URL`.
    static func render(content: String, toFile file: URL, permalink: String) -> IO<nef.Error, URL>
}

public protocol CarbonAPI {
    /// Renders a code selection into Carbon image.
    ///
    /// - Precondition: this method must be invoked from background thread.
    ///
    /// - Parameters:
    ///   - carbon: content+style to generate code snippet.
    ///   - file: output where to render the snippets (path to the file without extension).
    /// - Returns: An `IO` to perform IO operations that produce carbon error of type `nef.Error` and values with the file generated of type `URL`.
    static func render(carbon: CarbonModel, toFile file: URL) -> IO<nef.Error, URL>
    
    /// Get an URL Request given a carbon configuration
    ///
    /// - Parameter carbon: configuration
    /// - Returns: URL request to carbon.now.sh
    static func request(with configuration: CarbonModel) -> URLRequest
    
    /// Get a NSView given a carbon configuration
    ///
    /// - Parameter carbon: configuration
    /// - Returns: NSView
    static func view(with configuration: CarbonModel) -> CarbonView
}

public protocol SwiftPlaygroundAPI {
    /// Renders a Swift Package content into Swift Playground compatible to iPad.
    ///
    /// - Parameters:
    ///   - package: content to Swift Package
    ///   - name: name for the output Swift Playground
    ///   - output: folder where to write the Swift Playground
    /// - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error` and values with the Swift Playground output of type `URL`, having access to an immutable environment of type `Console`. It can be seen as a Kleisli function `(Console) -> IO<nef.Error, URL>`.
    static func render(package: String, name: String, output: URL) -> EnvIO<Console, nef.Error, URL>
}
