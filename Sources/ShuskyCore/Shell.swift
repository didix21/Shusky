//
// Created by Dídac Coll Pujals on 24/05/2020.
//

import Foundation

struct ShellResult: Equatable {
    let output: String
    let status: Int32
}

protocol Executable {
    func execute(_ command: String) -> ShellResult
    func executeWithRTProgress(_ command: String, rtOut: @escaping (_ progres: String) -> ()) -> ShellResult
}

final class Shell: Executable {
    private(set) var launchPath: String = "/bin/bash"
    private var task: Process = Process()
    private var pipe: Pipe = Pipe()
    public init(launchPath: String? = nil) {
        if let launchPath = launchPath {
            self.launchPath = launchPath
        }
    }

    public func execute(_ command: String) -> ShellResult {
        resetShell()
        configureShell(command)
        task.launch()
        task.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        return ShellResult(output: output, status: task.terminationStatus)
    }

    public func executeWithRTProgress(_ command: String, rtOut: @escaping (_ progres: String) -> ()) -> ShellResult {
        resetShell()
        configureShell(command)
        let outputHandler = pipe.fileHandleForReading
        outputHandler.waitForDataInBackgroundAndNotify()

        var output = ""
        let notificationCenter = NotificationCenter.default
        let dataNotificationName = NSNotification.Name.NSFileHandleDataAvailable
        var dataObserver: NSObjectProtocol?
        dataObserver = notificationCenter.addObserver(
                forName: dataNotificationName,
                object: outputHandler, queue: nil) { notification in
                    let data = outputHandler.availableData
                    guard data.count > 0 else {
                        if let dataObserver = dataObserver {
                            notificationCenter.removeObserver(dataObserver)
                        }
                        return
                    }
                    if let line = String(data: data, encoding: .utf8) {
                        rtOut(line)
                        output += line
                    }
                    outputHandler.waitForDataInBackgroundAndNotify()
                }
        task.launch()
        task.waitUntilExit()
        return ShellResult(output: output, status: task.terminationStatus)
    }

    private func resetShell() {
        task = Process()
        pipe = Pipe()
    }

    private func configureShell(_ command: String) {
        task.launchPath = launchPath
        task.arguments = ["-c", command]
        task.standardOutput = pipe
    }
}