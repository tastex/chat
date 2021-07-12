//
//  ChatProfileUITests.swift
//  ChatProfileUITests
//
//  Created by VB on 05.05.2021.
//

import XCTest

class ChatProfileUITests: XCTestCase {

   func testTextTwoViewsExist() throws {
       let app = XCUIApplication()
       app.launch()

       let profileButton = app.navigationBars.otherElements["ProfileBarButtonItem"].firstMatch
       guard profileButton.waitForExistence(timeout: 5.0) else { XCTFail("Can't find and tap on ProfileBarButtonItem")
           return
       }
       profileButton.tap()

       let nameTextView = app.textViews["NameTextView"].firstMatch
       let nameTextViewExist = nameTextView.waitForExistence(timeout: 5.0)
       XCTAssertTrue(nameTextViewExist, "Can't find nameTextView")

       let bioTextView = app.textViews["BioTextView"].firstMatch
       let bioTextViewExist = bioTextView.waitForExistence(timeout: 5.0)
       XCTAssertTrue(bioTextViewExist, "Can't find bioTextView")
   }
}
