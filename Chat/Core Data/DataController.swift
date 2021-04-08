//
//  ChannelsDataController.swift
//  Chat
//
//  Created by VB on 07.04.2021.
//

import UIKit
import CoreData

class DataController: NSObject {

    enum DataCollection {
        case channels
        case messages(channelId: String)
        case channel(channelId: String)
        case message(messageId: String)
    }

    var didChangeContentClosure: (() -> Void)?
    private var collection: DataCollection
    private var context: NSManagedObjectContext
    private var tableView: UITableView
    private lazy var fetchedResultsController = collection.getFetchedResultsController(context: context, delegate: self)

    init(for collection: DataCollection, tableView: UITableView, in context: NSManagedObjectContext) {
        self.collection = collection
        self.context = context
        self.tableView = tableView
    }

    func stopTrackChanges() {
        fetchedResultsController.delegate = nil
    }

    func startTrackChanges() {
        fetchedResultsController.delegate = self
    }

}

extension DataController.DataCollection {
    func getFetchedResultsController(context: NSManagedObjectContext, delegate: NSFetchedResultsControllerDelegate? = nil) -> NSFetchedResultsController<NSFetchRequestResult> {

        let request: NSFetchRequest<NSFetchRequestResult>
        switch self {
        case .channels:
            request = ChannelDb.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "lastActivity", ascending: false)
            request.sortDescriptors = [sortDescriptor]
        case .messages(let channelID):
            request = MessageDb.fetchRequest()
            request.predicate = NSPredicate(format: "channel.identifier == %@", channelID)
            let sortDescriptor = NSSortDescriptor(key: "created", ascending: true)
            request.sortDescriptors = [sortDescriptor]
        case .channel(let channelID):
            request = ChannelDb.fetchRequest()
            request.predicate = NSPredicate(format: "identifier == %@", channelID)
            request.fetchLimit = 1
            let sortDescriptor = NSSortDescriptor(key: "lastActivity", ascending: false)
            request.sortDescriptors = [sortDescriptor]
        case .message(let messageId):
            request = MessageDb.fetchRequest()
            request.predicate = NSPredicate(format: "identifier == %@", messageId)
            request.fetchLimit = 1
            let sortDescriptor = NSSortDescriptor(key: "created", ascending: false)
            request.sortDescriptors = [sortDescriptor]
        }

        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        if let delegate = delegate {
            frc.delegate = delegate
        }

        do {
            try frc.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        return frc
    }
}

extension DataController {
    func numberOfRowsInSection(section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchResultsController")
        }
        let sectionsInfo = sections[section]
        return sectionsInfo.numberOfObjects
    }

    func getChannel(at indexPath: IndexPath) -> Channel? {
        guard let fetchedResultsController = fetchedResultsController as? NSFetchedResultsController<ChannelDb> else { return nil }
        let channelDb = fetchedResultsController.object(at: indexPath)
        guard let identifier = channelDb.identifier,
              let name = channelDb.name else { return nil }

        let channel = Channel(identifier: identifier,
                              name: name,
                              lastMessage: channelDb.lastMessage,
                              lastActivity: channelDb.lastActivity)
        return channel

    }

    func getChannelDb(channel: Channel, context: NSManagedObjectContext) -> ChannelDb? {

        let frc = DataCollection.channel(channelId: channel.identifier).getFetchedResultsController(context: context)
        guard let channelDb = frc.fetchedObjects?.first as? ChannelDb else { return nil }
        channelDb.name = channel.name
        channelDb.lastActivity = channel.lastActivity
        channelDb.lastMessage = channel.lastMessage

        return channelDb

    }

    func getMessage(at indexPath: IndexPath) -> Message? {
        guard let fetchedResultsController = fetchedResultsController as? NSFetchedResultsController<MessageDb> else { return nil }

        let messageDb = fetchedResultsController.object(at: indexPath)
        guard let identifier = messageDb.identifier,
              let content = messageDb.content,
              let created = messageDb.created,
              let senderId = messageDb.senderId,
              let senderName = messageDb.senderName else { return nil }

        let message = Message(identifier: identifier,
                              content: content,
                              created: created,
                              senderId: senderId,
                              senderName: senderName)
        return message
    }
}

extension DataController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
         self.tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
        print("end updates from DataController - \(self.tableView.tag)")
        didChangeContentClosure?()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print("insert")
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .move:
            print("move")
            guard let indexPath = indexPath,
                  let newIndexPath = newIndexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            print("update")
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .delete:
            print("delete")
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        default:
            print("unknown")
            return
        }
    }
}
