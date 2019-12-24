//  Copyright © 2019 The nef Authors.

import Foundation

public enum MarkdownError: Error {
    case render(page: URL)
    case create(file: URL)
    case getPlaygrounds(folder: URL)
    case getPages(folder: URL)
    case structure
}

extension MarkdownError {
    var information: String {
        switch self {
        case .render(let page):
            return "can not render page '\(page.path)'"
        case .create(let file):
            return "can not create the file '\(file.path)'"
        case .structure:
            return "could not create project structure"
        case .getPlaygrounds(let folder):
            return "could not get playgrounds at '\(folder.path)'"
        case .getPages(let folder):
            return "could not get pages at '\(folder.path)'"
        }
    }
}
