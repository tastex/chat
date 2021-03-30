//
//  CoreDataStack.swift
//  Chat
//
//  Created by VB on 28.03.2021.
//

import Foundation
import CoreData

class CoreDataStack {
    var didUpdateDataBase: ((CoreDataStack) -> Void)?

    private var storeURL: URL = {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory,
                                                          in: .userDomainMask).last else {
            fatalError("documents path not found")
        }
        return documentsURL.appendingPathComponent("Chat.sqlite")
    }()

    private let dataModelName = "Chat"
    private let dataModelExtension = "momd"

    private(set) lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(forResource: dataModelName, withExtension: dataModelExtension) else {
            fatalError("model not found")
        }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("managedObjectModel couldn't be created")
        }
        return managedObjectModel
    }()

    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
        return coordinator
    }()

    // MARK: - Contexts

    private lazy var writerContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        context.mergePolicy = NSOverwriteMergePolicy
        return context
    }()

    private(set) lazy var mainContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = writerContext
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        return context
    }()
}

// MARK: - SaveContext
extension CoreDataStack {
    private func saveContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = mainContext
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    func performSave(_ block: (NSManagedObjectContext) -> Void) {
        let context = saveContext()
        context.performAndWait {
            block(context)
            if context.hasChanges {
                performSave(in: context)
            }
        }
    }

    private func performSave(in context: NSManagedObjectContext) {
        context.performAndWait {
            do {
                try context.save()
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
        if let parent = context.parent { performSave(in: parent)}
    }
}

// MARK: - CoreData Observers

extension CoreDataStack {
    func enableObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(managedObjectContextObjectsDidChange(notification:)),
                                       name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                       object: mainContext)
    }

    @objc
    private func managedObjectContextObjectsDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }

        didUpdateDataBase?(self)

        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>,
           inserts.count > 0 {
            print("Добавлено объектов: ", inserts.count)
        }

        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>,
           updates.count > 0 {
            print("Обновлено объектов: ", updates.count)
        }

        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>,
           deletes.count > 0 {
            print("Удалено объектов: ", deletes.count)
        }
    }
}

// MARK: - Core Data Logs
extension CoreDataStack {
    func printDatabaseStatistice() {
        mainContext.perform {
            do {
                let count = try self.mainContext.count(for: ChannelDb.fetchRequest())
                print("    Сохранено \(count) каналов")
                let messagesCount = try self.mainContext.count(for: MessageDb.fetchRequest())
                print("    Сохранено \(messagesCount) cooбщений")
//                let array = try self.mainContext.fetch(ChannelDb.fetchRequest()) as? [ChannelDb] ?? []
//                array.forEach {
//                    print($0.about)
//                }
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}
