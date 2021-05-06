//
//  ChatCoreDataTest.swift
//  ChatTests
//
//  Created by VB on 07.05.2021.
//

@testable import Chat
import XCTest

class ChatCoreDataTest: XCTestCase {

    func testPerformCoreDataSave() throws {
        // Arrange
        let coreDataService = CoreDataServiceMock(coreDataStack: CoreDataStack())
        guard let conversationsListVC = ConversationsListViewController.instantiate(coreDataService: coreDataService) else {
            XCTFail("ConversationsListViewController couldn't be created")
            return
        }
        let newChannels = [
            Channel(identifier: "1", name: "New Channel", lastMessage: nil, lastActivity: nil),
            Channel(identifier: "2", name: "Test Channel", lastMessage: "Test message", lastActivity: Date())
        ]

        // Act
        conversationsListVC.performCoreDataSave(channels: newChannels, deleted: [])

        // Assert
        XCTAssertEqual(coreDataService.savedChannels.count, 2)
        XCTAssertEqual(coreDataService.savedChannels[0].identifier, newChannels[0].identifier)
        XCTAssertEqual(coreDataService.savedChannels[0].name, newChannels[0].name)

        XCTAssertNil(coreDataService.deletedChannels.first)

    }

}
