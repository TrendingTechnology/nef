import Foundation

indirect enum Node: Equatable {
    enum Code: Equatable {
        case code(String)
        case comment(String)
    }

    enum Nef: Equatable {
        enum Command: String, Equatable {
            case header
            case hidden
            case invalid

            static func get(in line: String) -> Command {
                guard line.contains("nef:") else { return .invalid }
                let commandRawValue = line.clean([" ","\n"]).components(separatedBy: ":").last ?? ""
                return Command(rawValue: commandRawValue) ?? .invalid
            }
        }
    }

    case nef(command: Nef.Command, [Node])
    case markup(description: String?, String)
    case block([Code])
    case raw(String)
}

// MARK: Helpers
// MARK: - compact nodes
extension Array where Element == Node {
    func reduce() -> [Node] {
        return self.reduce([]) { acc, next in
            guard let last = acc.last else { return acc + [next] }

            var result = [Node]()
            result.append(contentsOf: acc)
            result.removeLast()
            result.append(contentsOf: last.combine(next))

            return result
        }
    }
}

// MARK: - How to combine two nodes
extension Node {
    func combine(_ b: Node) -> [Node] {
        switch (self, b) {
        case let (.markup(description, textA), .markup(_, textB)):
            return [.markup(description: description, "\(textA)\n\(textB)")]

        case var (.block(nodesA), .block(nodesB)):
            guard let lastA = nodesA.popLast(), nodesB.count > 0 else { fatalError("Can not combine \(nodesB) into \(nodesA) because are empty") }
            let firstB = nodesB.removeFirst()
            return [.block(nodesA + lastA.combine(firstB) + nodesB)]

        case let (.raw(linesA), .raw(linesB)):
            return [.raw("\(linesA)\n\(linesB)")]

        default:
            return [self, b]
        }
    }
}

extension Node.Code {
    func combine(_ b: Node.Code) -> [Node.Code] {
        switch (self, b) {
        case let (.code(codeA), .code(codeB)):
            return [.code("\(codeA)\n\(codeB)")]
        case let (.comment(textA), .comment(textB)):
            return [.comment("\(textA)\n\(textB)")]
        default:
            return [self, b]
        }
    }
}
