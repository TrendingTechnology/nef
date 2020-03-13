//  Copyright © 2019 The nef Authors.

import Foundation
import nef
import Bow
import BowEffects
import ArgumentParser

public enum Console {
    case `default`
    
    public static func readArguments<A: ParsableCommand>(_ parsableCommand: A.Type) -> IO<Console.Error, A> {
        IO.invoke {
            try parsableCommand.parseAsRoot() as! A
        }^.mapError { (e: Swift.Error) in
            let info = parsableCommand.fullMessage(for: e)
            return Console.Error.arguments(info: info)
        }
    }
    
    public static func print(message: @escaping @autoclosure () -> String) -> IO<Console.Error, Void> {
        ConsoleIO.print(message(), separator: " ", terminator: "\n")
    }
    
    public static func help<A>(_ helpMessage: @escaping @autoclosure () -> String) -> IO<Console.Error, A> {
        print(message: helpMessage())
            .map { _ in Darwin.exit(-2) }^
    }
    
    public static func exit<A>(failure: String) -> IO<Console.Error, A> {
        print(message: "☠️ ".bold.red + "\(failure)")
            .map { _ in Darwin.exit(-1) }^
        
    }
    
    public static func exit<A>(success: String) -> IO<Console.Error, A> {
        print(message: "🙌 ".bold.green + "\(success)")
            .map { _ in Darwin.exit(0) }^
    }
    
    
    /// Kind of errors in ConsoleIO
    public enum Error: Swift.Error, CustomStringConvertible {
        case arguments(info: String)
        case render(info: String = "")
        
        public var description: String {
            switch self {
            case .arguments(let info):
                return info
            case .render(let info):
                return info.isEmpty ? "" : "Render failure: \(info.lightRed)"
            }
        }
    }
}

/// Defined `NefModel.Console` into `ConsoleIO`
extension Console: NefModels.Console {
    public func printStep<E: Swift.Error>(step: Step, information: String) -> IO<E, Void> {
        ConsoleIO.print(step.estimatedDuration > .seconds(3) ? "\(information)"+"...".lightGray : information,
                        separator: " ",
                        terminator: " ")
    }
    
    public func printSubstep<E: Swift.Error>(step: Step, information: [String]) -> IO<E, Void> {
        ConsoleIO.print(information.map { item in "\t• ".lightGray + "\(item)".cyan }.joined(separator: "\n"),
                        separator: " ",
                        terminator: "\n")
    }
    
    public func printStatus<E: Swift.Error>(success: Bool) -> IO<E, Void> {
        ConsoleIO.print(success ? "✓".bold.green : "✗".bold.red,
                        separator: "",
                        terminator: "\n")
    }
    
    public func printStatus<E: Swift.Error>(information: String, success: Bool) -> IO<E, Void> {
        let infoFormatted = !information.isEmpty ? "\n\t| \(information.replacingOccurrences(of: ": ", with: "\n\t| "))" : ""
        
        return ConsoleIO.print(success ? "✓".bold.green + infoFormatted
                                       : "✗".bold.red   + infoFormatted,
                               separator: "",
                               terminator: "\n")
    }
}
