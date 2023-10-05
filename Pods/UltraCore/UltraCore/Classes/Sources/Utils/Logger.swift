//
//  Loger.swift
//  UltraCore
//
//  Created by Slam on 4/14/23.
//

import Foundation

enum LogLevel: Int {
    case verbose = 0
    case debug = 1
    case info = 2
    case warning = 3
    case error = 4
}

class PP {
    static var logLevel: LogLevel = .verbose

    static func verbose(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        if PP.logLevel.rawValue <= LogLevel.verbose.rawValue {
            log("[VERBOSE 😎] \(message)", file: file, function: function, line: line)
        }
    }

    static func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        if PP.logLevel.rawValue <= LogLevel.debug.rawValue {
            log("[DEBUG 🤓] \(message)", file: file, function: function, line: line)
        }
    }

    static func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        if PP.logLevel.rawValue <= LogLevel.info.rawValue {
            log("[INFO 🥹] \(message)", file: file, function: function, line: line)
        }
    }

    static func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        if PP.logLevel.rawValue <= LogLevel.warning.rawValue {
            log("[WARNING 😤] \(message)", file: file, function: function, line: line)
        }
    }

    static func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        if PP.logLevel.rawValue <= LogLevel.error.rawValue {
            log("[ERROR 🤬] \(message)", file: file, function: function, line: line)
        }
    }

    private static func log(_ message: String, file: String, function: String, line: Int) {
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "\(fileName):\(line) \(function) - \(message)"
        print(logMessage)
    }
}
