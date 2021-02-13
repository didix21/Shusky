#if !canImport(ObjectiveC)
import XCTest

extension CommandTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__CommandTests = [
        ("testRunWithCommandDefined", testRunWithCommandDefined),
        ("testRunWithCommandPathCriticalDefined", testRunWithCommandPathCriticalDefined),
        ("testRunWithCommandPathCriticalVerboseDefined", testRunWithCommandPathCriticalVerboseDefined),
        ("testRunWithInvalidTypeCommand", testRunWithInvalidTypeCommand),
    ]
}

extension GitHookFileHandlerTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__GitHookFileHandlerTests = [
        ("testAddHook", testAddHook),
        ("testAddHookWithPackagePath", testAddHookWithPackagePath),
        ("testAppendHook", testAppendHook),
        ("testAppendHookWithPackagePath", testAppendHookWithPackagePath),
        ("testCreateHookFileIfNotExists", testCreateHookFileIfNotExists),
        ("testDeleteHookFileMustBeDeleted", testDeleteHookFileMustBeDeleted),
        ("testDeleteHookFileMustBeDeletedWithPackagePath", testDeleteHookFileMustBeDeletedWithPackagePath),
        ("testDeleteHookFileMustNotBeDeletedWhenContainsOtherDataCase1", testDeleteHookFileMustNotBeDeletedWhenContainsOtherDataCase1),
        ("testDeleteHookFileMustNotBeDeletedWhenContainsOtherDataCase2", testDeleteHookFileMustNotBeDeletedWhenContainsOtherDataCase2),
        ("testDeleteHookFileMustNotBeDeletedWhenContainsOtherDataCase3", testDeleteHookFileMustNotBeDeletedWhenContainsOtherDataCase3),
        ("testDeleteHookFileMustNotBeDeletedWhenContainsOtherDataCase4", testDeleteHookFileMustNotBeDeletedWhenContainsOtherDataCase4),
        ("testDeleteHookIfThereIsNoShuskyRun", testDeleteHookIfThereIsNoShuskyRun),
        ("testDontAppendHookIfAlreadyExist", testDontAppendHookIfAlreadyExist),
        ("testDontAppendHookWithPackagePathIfAlreadyExist", testDontAppendHookWithPackagePathIfAlreadyExist),
        ("testExecutionPermissions", testExecutionPermissions),
        ("testOverwriteHookWhenOverwriteOptionIsProvided", testOverwriteHookWhenOverwriteOptionIsProvided),
    ]
}

extension HookHandlerTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__HookHandlerTests = [
        ("testCommandFails", testCommandFails),
        ("testCommandFailsButIsDefinedAsNonCritical", testCommandFailsButIsDefinedAsNonCritical),
        ("testCommandHandler", testCommandHandler),
        ("testCommandHandlerGlobalVerboseFalse", testCommandHandlerGlobalVerboseFalse),
        ("testIfSkipIsEnabled", testIfSkipIsEnabled),
        ("testIfVerboseIsSetFalseAndCommandFailsDisplayResult", testIfVerboseIsSetFalseAndCommandFailsDisplayResult),
        ("testLocalVerboseFalseAndGlobalVerboseTrue", testLocalVerboseFalseAndGlobalVerboseTrue),
        ("testLocalVerboseTrueAndGlobalVerboseFalse", testLocalVerboseTrueAndGlobalVerboseFalse),
        ("testLocalVerboseTrueAndGlobalVerboseTrue", testLocalVerboseTrueAndGlobalVerboseTrue),
    ]
}

extension HookTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__HookTests = [
        ("testHookIsEmpty", testHookIsEmpty),
        ("testHookNotFound", testHookNotFound),
        ("testIfVerboseIsNotDefinedIsSetTrueByDefault", testIfVerboseIsNotDefinedIsSetTrueByDefault),
        ("testInvalidCommandInHook", testInvalidCommandInHook),
        ("testInvalidRunInHook", testInvalidRunInHook),
        ("testInvalidTypeInHookVerboseKey", testInvalidTypeInHookVerboseKey),
        ("testValidHook", testValidHook),
    ]
}

extension RunTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__RunTests = [
        ("testRunCommand", testRunCommand),
        ("testRunCritical", testRunCritical),
        ("testRunInvalidDataInPath", testRunInvalidDataInPath),
        ("testRunPath", testRunPath),
        ("testRunVerbose", testRunVerbose),
    ]
}

extension ShellTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__ShellTests = [
        ("testShellExecute", testShellExecute),
        ("testShellExecuteRtProgress", testShellExecuteRtProgress),
    ]
}

extension ShuskyCoreTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__ShuskyCoreTests = [
        ("testDefaultContentOfShuskyYMlAndPreCommitConfigured", testDefaultContentOfShuskyYMlAndPreCommitConfigured),
        ("testDefaultInstallAndThenInstallAll", testDefaultInstallAndThenInstallAll),
        ("testInstallAddMultipleHooksIfTheyAreConfigured", testInstallAddMultipleHooksIfTheyAreConfigured),
        ("testInstallAllHooks", testInstallAllHooks),
        ("testInstallAllHooksPackagePath", testInstallAllHooksPackagePath),
        ("testInstallMustOverwriteHookIfAlreadyExistsAndOverwriteParamIsProvided", testInstallMustOverwriteHookIfAlreadyExistsAndOverwriteParamIsProvided),
        ("testInstallMustRemoveThoseHooksThatAreNoLongerPresentInShuskyYml", testInstallMustRemoveThoseHooksThatAreNoLongerPresentInShuskyYml),
        ("testInstallWithPackagePath", testInstallWithPackagePath),
        ("testRunReturn0IfAllCommandsAreExecuted", testRunReturn0IfAllCommandsAreExecuted),
        ("testRunReturn1IfHookIsEmpty", testRunReturn1IfHookIsEmpty),
        ("testRunReturn1IfShuskyFileDoesNotExist", testRunReturn1IfShuskyFileDoesNotExist),
        ("testRunReturns0IfHookIsNotDefined", testRunReturns0IfHookIsNotDefined),
        ("testRunReturnTheCodeErrorOfCommandThatHasFailed", testRunReturnTheCodeErrorOfCommandThatHasFailed),
        ("testRunUninstall", testRunUninstall),
        ("testRunUninstallDoesNotFailIfNotContainsShuskyRunCommand", testRunUninstallDoesNotFailIfNotContainsShuskyRunCommand),
        ("testRunUninstallWithPackagePath", testRunUninstallWithPackagePath),
        ("testRunVerboseFalse", testRunVerboseFalse),
    ]
}

extension ShuskyFileTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__ShuskyFileTests = [
        ("testCreateDefaultShuskyYamlFile", testCreateDefaultShuskyYamlFile),
        ("testCreateFile", testCreateFile),
        ("testDontCreateDefaultShuskyYamlFileIfNotEmpty", testDontCreateDefaultShuskyYamlFileIfNotEmpty),
        ("testReadShuskyYml", testReadShuskyYml),
        ("testShuskyFileName", testShuskyFileName),
        ("testShuskyFilePath", testShuskyFilePath),
    ]
}

extension ShuskyParserTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__ShuskyParserTests = [
        ("testEmptyYaml", testEmptyYaml),
        ("testHookContentIsEmpty", testHookContentIsEmpty),
        ("testHookParserNoHooksFound", testHookParserNoHooksFound),
        ("testHookParserShuskyConfigIsEmpty", testHookParserShuskyConfigIsEmpty),
        ("testHooksParser", testHooksParser),
        ("testHookTypeEnum", testHookTypeEnum),
        ("testInvalidTypeVerboseInHook", testInvalidTypeVerboseInHook),
        ("testNoHookFound", testNoHookFound),
        ("testParseComplexConfig", testParseComplexConfig),
        ("testParseSimpleConfig", testParseSimpleConfig),
    ]
}

extension SwiftExtensionTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__SwiftExtensionTests = [
        ("testEndIndex", testEndIndex),
        ("testIndex", testIndex),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CommandTests.__allTests__CommandTests),
        testCase(GitHookFileHandlerTests.__allTests__GitHookFileHandlerTests),
        testCase(HookHandlerTests.__allTests__HookHandlerTests),
        testCase(HookTests.__allTests__HookTests),
        testCase(RunTests.__allTests__RunTests),
        testCase(ShellTests.__allTests__ShellTests),
        testCase(ShuskyCoreTests.__allTests__ShuskyCoreTests),
        testCase(ShuskyFileTests.__allTests__ShuskyFileTests),
        testCase(ShuskyParserTests.__allTests__ShuskyParserTests),
        testCase(SwiftExtensionTests.__allTests__SwiftExtensionTests),
    ]
}
#endif
