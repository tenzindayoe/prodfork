import XCTest

final class EventDetailUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testDetailDisplaysSampleData() {
        let app = UITestLauncher.launchWithSampleData()
        XCTAssertTrue(app.staticTexts["Sample Event 1"].waitForExistence(timeout: 5))
        app.staticTexts["Sample Event 1"].tap()
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'UITest description for Sample Event 1'"))
            .firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Open website"].exists)
    }
}
