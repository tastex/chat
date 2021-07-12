//
//  CoreDataService.swift
//  Chat
//
//  Created by VB on 16.04.2021.
//

import Foundation
import CoreData

protocol CoreDataServiceProtocol {
    var mainContext: NSManagedObjectContext { get }
    func enableObservers()
    func printDatabaseStatistice()
    func performSave(dataController: DataController, channels: [Channel], deleted: [Channel])

    func performSave(dataController: DataController, channel: Channel, messages: [Message], deleted: [Message])
}

class CoreDataService: CoreDataServiceProtocol {

    private var coreDataStack: CoreDataStack

    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }

    var mainContext: NSManagedObjectContext {
        coreDataStack.mainContext
    }

    func enableObservers() {
        coreDataStack.enableObservers()
        coreDataStack.didUpdateDataBase = { stack in
            stack.printDatabaseStatistice()
        }
    }

    func printDatabaseStatistice() {
        coreDataStack.printDatabaseStatistice()
    }

    func performSave(dataController: DataController, channels: [Channel], deleted: [Channel]) {
        coreDataStack.performSave { context in
            channels.forEach { channel in
                if let channelDb = dataController.getChannelDb(channel: channel, context: context) {
                    channelDb.update(with: channel)
                } else {
                    _ = ChannelDb(channel: channel, in: context)
                }
            }
            deleted.forEach { channel in
                if let channelDb = dataController.getChannelDb(channel: channel, context: context) {
                    context.delete(channelDb)
                }
            }
        }
    }

    func performSave(dataController: DataController, channel: Channel, messages: [Message], deleted: [Message]) {
        coreDataStack.performSave { context in
            var channelDb = dataController.getChannelDb(channel: channel, context: context)
            if channelDb == nil {
                channelDb = ChannelDb(channel: channel, in: context)
            }

            guard let channelDbUnwrapped = channelDb else { return }

            messages.forEach { message in
                if dataController.getMessageDb(message: message, context: context) == nil {
                    let messageDb = MessageDb(message: message, in: context)
                    channelDbUnwrapped.addToMessages(messageDb)
                }
            }

            deleted.forEach { message in
                if let messageDb = dataController.getMessageDb(message: message, context: context) {
                    channelDbUnwrapped.removeFromMessages(messageDb)
                    context.delete(messageDb)
                }
            }
        }
    }

}
