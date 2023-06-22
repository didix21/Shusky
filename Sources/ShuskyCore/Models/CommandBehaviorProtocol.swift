//
//  CommandBehaviorProtocol.swift
//  ShuskyCore
//
//  Created by Dídac Coll Pujals on 21/2/21.
//

import Foundation

protocol CommandBehaviorProtocol {
    var command: String { get }
    var verbose: Bool? { get }
    var critical: Bool? { get }
}
