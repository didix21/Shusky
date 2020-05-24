import Foundation
import Yams
import ShuskyCore

let fileManager = FileManager.default
fileManager.changeCurrentDirectoryPath("/Users/didaccoll/repos/Shusky")
let shuskyCore = ShuskyCore()
shuskyCore.run(hookType: .preCommit)

exit(1)