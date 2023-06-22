//
// Created by Dídac Coll Pujals on 24/05/2020.
//

import Foundation

public struct ShellResult: Equatable {
    public let output: String
    public let status: Int32
}

protocol Executable {
    /// Execute a command and wait until finish in order to show the output.
    ///     - Parameter command: the command that must be run.
    func execute(_ command: String) -> ShellResult

    /// Execute a commend and show his output progress while is running.
    ///     - Parameter command: the command that must be run.
    ///     - Parameter rtOut: a callback which returns the command's output progress.
    ///
    func executeWithRTProgress(_ command: String, rtOut: @escaping (_ progres: String) -> Void) -> ShellResult
}

/// Shell class is used to execute shell commands and return the output and status of the command.
public final class Shell: Executable {
    /// The default launch path is `/bin/bash`.
    private(set) var launchPath: String = "/bin/bash"
    private var task = Process()
    private var pipe = Pipe()
    
    /// Initializes a new instance of Shell.
    /// - Parameter launchPath: The path of the shell to be used for executing commands.
    public init(launchPath: String? = nil) {
        if let launchPath = launchPath {
            self.launchPath = launchPath
        }
    }
    
    /// Executes the given command and returns the output and status of the command.
    /// - Parameter command: The command to be executed.
    /// - Returns: The output and status of the command.
    public func execute(_ command: String) -> ShellResult {
        resetShell()
        configureShell(command)
        task.launch()
        task.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        return ShellResult(output: output, status: task.terminationStatus)
    }
    
    /// Executes the given command and returns the output and status of the command in real-time.
    /// - Parameters:
    ///   - command: The command to be executed.
    ///   - rtOut: The closure to be called with the output of the command in real-time.
    /// - Returns: The output and status of the command.
    public func executeWithRTProgress(_ command: String, rtOut: @escaping (_ progres: String) -> Void) -> ShellResult {
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
            object: outputHandler, queue: nil
        ) { _ in
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
    
    /// Resets the shell instance.
    private func resetShell() {
        task = Process()
        pipe = Pipe()
    }
    
    /// Configures the shell instance with the given command.
    /// - Parameter command: The command to be executed.
    private func configureShell(_ command: String) {
        task.launchPath = launchPath
        task.arguments = ["-c", command]
        task.standardOutput = pipe
    }
}
