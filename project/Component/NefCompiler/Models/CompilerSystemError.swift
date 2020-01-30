//  Copyright © 2020 The nef Authors.

import Foundation

public enum CompilerSystemError: Error {
    case code(String)
    case dependencies(URL, information: String = "")
}
