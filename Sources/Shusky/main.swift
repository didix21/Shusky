import Foundation
import Yams
//import ShuskyCore

let config = """
             pre-commit:
                - swift test
                - swift run swiftlint 
                - swift run
                - run:
                    command: swift run bla bla
                    path: ./path/to/where
                    critical: false
                    verbose: false
                - run:
                    command: swift run ble ble
                    path: ./path/to/where
                    critical: false
             """
//let ddd = try Yams.load(yaml: config)
//
//if let ddd = ddd as? [String: Any] {
////    for d in ddd {
////       print(d)
////    }
//    if let precommit = ddd["pre-commit"] {
//        if let precommit = precommit as? [Any] {
//            for command in precommit {
//                if let hashable = command as? [String: Any] {
//                    if let run = hashable["run"] as? [String: Any] {
//                        print(run)
//                    }
//                }
//            }
//        }
//    }
//}

extension String {
    static func ~= (lhs: String, rhs: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: rhs) else { return false }
        let range = NSRange(location: 0, length: lhs.utf16.count)
        return regex.firstMatch(in: lhs, options: [], range: range) != nil
    }

    func matchRegex(_ pattern: String) -> NSTextCheckingResult? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        return regex.firstMatch(in: self, range: NSRange(location: 0, length: self.utf16.count))
    }

    func matchGroupName(_ pattern: String) -> Substring? {
        guard let nMatch = pattern.matchRegex("(\\?<\\w+>){1}") else { return nil }
        guard let swiftRange = Range(nMatch.range(at: 0), in: self) else { return nil }
        var gName = pattern[swiftRange]
        guard let nameRange = gName.range(of: #"\w+"#, options: .regularExpression) else { return nil }
        let name = gName[nameRange]

        guard let match = self.matchRegex(pattern) else { return nil }

        if #available(OSX 10.13, *) {
            #if os(macOS)
            guard let range = Range(match.range(withName: String(name)), in: self) else {
                return nil
            }
            return self[range]
            #endif
        } else {
            let range: Range<String.Index>? = nil
        }
        return nil
    }
}

let input = "^Season\\s+(?<season>\\d+)\\s+Episode\\s+(?<episode>\\d+)"
let title = "Season 1 Episode 3 - When Joey meets Zoey"
//let input = "^Season\\s+(?<season>"
let matches = input.matchRegex("(\\?<\\w+>){1}")

//let range = input.range(of: #"(<\w+>)+"#, options: .regularExpression)
//
//if let range = range {
//    print(input[range])
//}
print(title.matchGroupName(input))
//for match in matches! {
//    let range = match.range(at: 0)
//    if let swiftRange = Range(range, in: input) {
//        let name = input[swiftRange]
//        print(name)
//    }
//}

//if let match = matches?.first {
//    let range = match.range(at:0)
//    if let swiftRange = Range(range, in: input) {
//        let name = input[swiftRange]
//        print(name)
//    }
//}
