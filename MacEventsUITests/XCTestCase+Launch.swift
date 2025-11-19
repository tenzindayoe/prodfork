import XCTest

enum UITestLauncher {
    static func launchWithSampleData(likedIDs: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments.append("UITestSampleData")
        app.launchEnvironment["UITestLikedIDs"] = likedIDs.joined(separator: ",")
        app.launchEnvironment["UITestResetLikedStore"] = "1"
        app.launch()
        return app
    }
}
