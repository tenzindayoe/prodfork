import XCTest

final class EventHomeUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testSampleEventsAppearInHomeList() {
        let app = UITestLauncher.launchWithSampleData()
        XCTAssertTrue(app.staticTexts["Sample Event 1"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Sample Event 2"].exists)
    }

    func testSelectingSampleEventShowsDetail() {
        let app = UITestLauncher.launchWithSampleData()
        XCTAssertTrue(app.staticTexts["Sample Event 1"].waitForExistence(timeout: 5))
        app.staticTexts["Sample Event 1"].tap()
        XCTAssertTrue(app.buttons["Open website"].waitForExistence(timeout: 5))
    }
}
