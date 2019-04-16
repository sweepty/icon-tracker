//
//  Logger.swift
//  ICON-tracker
//
//  Created by Seungyeon Lee on 01/04/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import Foundation

public enum LogLevel: String {
    case info       = "INFO"
    case debug      = "DEBUG"
    case verbose    = "VERBOSE"
    case warning    = "WARNING"
    case error      = "ERROR"
}

extension LogLevel {
    var symbol: String {
        switch self {
        case .info:
            return "💙"
            
        case .verbose:
            return "💜"
            
        case .debug:
            return "❤️"
            
        case .warning:
            return "💛"
            
        case .error:
            return "💔"
        }
    }
}

struct Log {
    static func Info<T>(_ object: @autoclosure () -> T, _ file: String = #file, _ function: String = #function, line: Int = #line) {
        logger(.info, object(), file, function, line)
    }
    
    static func Verbose<T>(_ object: @autoclosure () -> T, _ file: String = #file, _ function: String = #function, line: Int = #line) {
        logger(.verbose, object(), file, function, line)
    }
    
    static func Debug<T>(_ object: @autoclosure () -> T, _ file: String = #file, _ function: String = #function, line: Int = #line) {
        logger(.debug, object(), file, function, line)
    }
    
    static func Warning<T>(_ object: @autoclosure () -> T, _ file: String = #file, _ function: String = #function, line: Int = #line) {
        logger(.warning, object(), file, function, line)
    }
    
    static func Error<T>(_ object: @autoclosure () -> T, _ file: String = #file, _ function: String = #function, line: Int = #line) {
        logger(.error, object(), file, function, line)
    }
    
    static func logger<T>(_ category: LogLevel, _ object: @autoclosure () -> T, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        #if DEBUG
        let value = object()
        var stringRepresentation: String = ""
        
        if let value = value as? CustomStringConvertible {
            stringRepresentation = value.description
        }
        
        let fileURL = URL(fileURLWithPath: file).lastPathComponent
        print("로그 \(category.symbol): \(fileURL) \(function) [Line:\(line)] " + stringRepresentation)
        #endif
    }
}
