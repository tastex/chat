//
//  ChatTests.swift
//  ChatTests
//
//  Created by VB on 06.05.2021.
//

@testable import Chat
import XCTest

class ChatNetworkTests: XCTestCase {

    func testSendNetworkRequest() throws {
        // Arrange
        let networkServiceMock = NetworkServiceMock()

        // Act
        let images = Images(networkService: networkServiceMock)
        images.getImages { _ in }

        // Assert
        let spaceImageConfig = RequestsFactory.PixabayRequests.spaceImagesConfig()
        XCTAssertEqual(networkServiceMock.requestURLs,
                       [spaceImageConfig.request.urlRequest?.url])
        XCTAssertEqual(networkServiceMock.callsCount, 1)
    }

}
