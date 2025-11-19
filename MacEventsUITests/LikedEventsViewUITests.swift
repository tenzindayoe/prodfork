import XCTest

final class LikedEventsViewUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testEmptyStateAppearsWhenNoFavorites() {
        let app = UITestLauncher.launchWithSampleData()
        let likedButton = app.tabBars.buttons["Liked"]
        XCTAssertTrue(likedButton.waitForExistence(timeout: 5))
        likedButton.tap()
        XCTAssertTrue(app.staticTexts["No liked events"].waitForExistence(timeout: 5))
    }

    func testTappingSampleEventOpensDetail() {
        let app = UITestLauncher.launchWithSampleData(likedIDs: ["sample-event-1"])
        let likedButton = app.tabBars.buttons["Liked"]
        XCTAssertTrue(likedButton.waitForExistence(timeout: 5))
        likedButton.tap()
        XCTAssertTrue(app.staticTexts["Sample Event 1"].waitForExistence(timeout: 5))
        app.staticTexts["Sample Event 1"].tap()
        XCTAssertTrue(app.buttons["Open website"].waitForExistence(timeout: 5))
    }
}
