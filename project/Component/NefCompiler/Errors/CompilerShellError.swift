//  Copyright © 2020 The nef Authors.

import Foundation

public enum CompilerShellError: Error {
    case notFound(command: String, information: String)
    case failed(command: String, information: String)
}

extension CompilerShellError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notFound(let command, let information):
            return "command not found '\(command)' \(information.isEmpty ? "." : " (\(information))")"
            
        case .failed(let command, let information):
            return "failed command '\(command)' \(information)"
        }
    }
}
