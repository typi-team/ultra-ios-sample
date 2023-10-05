//
//  ServerConfiguration.swift
//  UltraCore
//
//  Created by Slam on 7/30/23.
//

import Foundation

public protocol ServerConfigurationProtocol {
    var portOfServer: Int { get set }
    var pathToServer: String { get set }
}

struct ServerConfiguration: ServerConfigurationProtocol {
    var portOfServer: Int = 443
    var pathToServer: String = "ultra-dev.typi.team"
}
