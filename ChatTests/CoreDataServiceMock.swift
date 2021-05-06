//
//  CoreDataServiceMock.swift
//  ChatTests
//
//  Created by VB on 07.05.2021.
//

@testable import Chat
import CoreData

class CoreDataServiceMock: CoreDataServiceProtocol {

    var savedChannels: [Channel] = []
    var deletedChannels: [Channel] = []

    private var coreDataStack: CoreDataStack

    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }

    var mainContext: NSManagedObjectContext {
        coreDataStack.mainContext
    }

    func enableObservers() {
    }

    func printDatabaseStatistice() {
    }

    func performSave(dataController: DataController, channels: [Channel], deleted: [Channel]) {
        channels.forEach { (channel) in
            savedChannels.append(channel)
        }
        deleted.forEach { channels in
            deletedChannels.append(channels)
        }
    }

    func performSave(dataController: DataController, channel: Channel, messages: [Message], deleted: [Message]) {
    }

}
