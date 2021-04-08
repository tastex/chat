//
//  FirestoreStack.swift
//  Chat
//
//  Created by VB on 29.03.2021.
//

import Foundation
import Firebase

class FirestoreStack {

    var collection: DocumentCollection
    private lazy var db = Firestore.firestore()
    private(set) lazy var reference = collection.getCollectionReference(db: db)

    var listener: ListenerRegistration?

    init(collection: DocumentCollection) {
        self.collection = collection
    }

    enum DocumentCollection {
        case channels
        case messages(channelId: String)

        func getCollectionReference(db: Firestore) -> CollectionReference {
            switch self {
            case .channels:
                return db.collection("channels")
            case .messages(let channelId):
                return db.collection("channels").document(channelId).collection("messages")
            }
        }
    }

    func listenForNewContent<Item: FirestoreItem>(closure: @escaping ([Item]) -> Void) {
        listener = reference.addSnapshotListener { snapshot, _ in
            guard let documents = snapshot?.documents else { return }

            let items = documents.compactMap { documentSnapshot -> Item? in
                return Item(with: documentSnapshot)
            }
            closure(items)
        }
    }

    func listenForContentChanges<Item: FirestoreItem>(closure: @escaping ([Item]) -> Void) {
        listener = reference.addSnapshotListener { snapshot, _ in
            guard let documentChanges = snapshot?.documentChanges else { return }

            documentChanges.forEach { (change) in

                let item = Item(with: change.document)
                switch change.type {
                case .added:
                    print("added item: \(String(describing: item))")
                case .modified:
                    print("modified item: \(String(describing: item))")
                case .removed:
                    print("removed item: \(String(describing: item))")
                }

            }
//            let items = documents.compactMap { documentSnapshot -> Item? in
//                return Item(with: documentSnapshot)
//            }
//            closure(items)
        }
    }

    func stopListening() {
        listener?.remove()
    }
}

extension FirestoreStack {
    func addChannel(name: String) -> DocumentReference? {
        switch collection {
        case .channels:
            return reference.addDocument(data: ["name": name])
        default:
            return nil
        }
    }
}

extension FirestoreStack {
    func addMessage(_ message: String, senderName: String, senderId: String, created: Date? = nil) {
        switch collection {
        case .messages:
            reference.addDocument(data: ["content": message,
                                         "created": Timestamp(date: created ?? Date()),
                                         "senderId": senderId,
                                         "senderName": senderName])
        default:
            return
        }
    }
}

protocol FirestoreItem {
    init?(with documentSnapshot: QueryDocumentSnapshot)
}

extension Channel: FirestoreItem {
    init?(with documentSnapshot: QueryDocumentSnapshot) {
        let data = documentSnapshot.data()
        if let name = data["name"] as? String {

        let lastMessage = data["lastMessage"] as? String
        let lastActivity = data["lastActivity"] as? Timestamp

        self.identifier = documentSnapshot.documentID
        self.name = name
        self.lastMessage = lastMessage
        self.lastActivity = lastActivity?.dateValue()
        } else {
            return nil
        }
    }
}

extension Message: FirestoreItem {
    init?(with documentSnapshot: QueryDocumentSnapshot) {
        let data = documentSnapshot.data()
        if let content = data["content"] as? String,
           let created = data["created"] as? Timestamp,
           let senderId = data["senderId"] as? String,
           let senderName = data["senderName"] as? String {
            self.identifier = documentSnapshot.documentID
            self.content = content
            self.created = created.dateValue()
            self.senderId = senderId
            self.senderName = senderName
        } else {
            return nil
        }
    }
}
