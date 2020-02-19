//  Copyright © 2020 The nef Authors.

import Foundation
import Bow
import BowEffects

public protocol PlaygroundSystem {
    func xcworkspaces(at folder: URL) -> IO<PlaygroundSystemError, NEA<URL>>
    func linkedPlaygrounds(at folder: URL) -> IO<PlaygroundSystemError, NEA<URL>>
    func playgrounds(at folder: URL) -> IO<PlaygroundSystemError, NEA<URL>>
    func pages(in playground: URL) -> IO<PlaygroundSystemError, NEA<URL>>
}
