#if !canImport(ObjectiveC)
import XCTest

extension ShuskyFileTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__ShuskyFileTests = [
        ("testCreateDefaultShuskyYamlFile", testCreateDefaultShuskyYamlFile),
        ("testCreateFile", testCreateFile),
        ("testReadShuskyYml", testReadShuskyYml),
        ("testShuskyFileName", testShuskyFileName),
        ("testShuskyFilePath", testShuskyFilePath),
    ]
}

extension ShuskyModelsTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__ShuskyModelsTests = [
        ("testEmptyYaml", testEmptyYaml),
        ("testHookTypeEnum", testHookTypeEnum),
        ("testInvalidCommand", testInvalidCommand),
        ("testInvalidDictInHook", testInvalidDictInHook),
        ("testInvalidTypeVerboseInHook", testInvalidTypeVerboseInHook),
        ("testNoHookFound", testNoHookFound),
        ("testParseComplexConfig", testParseComplexConfig),
        ("testParseSimpleConfig", testParseSimpleConfig),
        ("testRunWithCommandDefined", testRunWithCommandDefined),
        ("testRunWithCommandPathCriticalDefined", testRunWithCommandPathCriticalDefined),
        ("testRunWithCommandPathCriticalVerboseDefined", testRunWithCommandPathCriticalVerboseDefined),
        ("testRunWithCommandPathDefined", testRunWithCommandPathDefined),
        ("testRunWithInvalidTypeCommand", testRunWithInvalidTypeCommand),
        ("testRunWithInvalidTypeCritical", testRunWithInvalidTypeCritical),
        ("testRunWithInvalidTypePath", testRunWithInvalidTypePath),
        ("testRunWithInvalidTypeVerbose", testRunWithInvalidTypeVerbose),
        ("testRunWithNoCommandDefined", testRunWithNoCommandDefined),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ShuskyFileTests.__allTests__ShuskyFileTests),
        testCase(ShuskyModelsTests.__allTests__ShuskyModelsTests),
    ]
}
#endif
