//
//  Printer.swift
//  ShuskyCore
//
//  Created by Dídac Coll
//  

import Foundation

protocol Printable {
    func print(_ str: Any)
    func print(_ str: Any, terminator: String)
}

final class Printer: Printable {
    func print(_ str: Any) {
        Swift.print(str)
    }

    func print(_ str: Any, terminator: String) {
        Swift.print(str, terminator: terminator)
    }
}
