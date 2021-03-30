//
//  FirestoreStack.swift
//  Chat
//
//  Created by VB on 29.03.2021.
//

import Foundation
import Firebase

class FirestoreStack {

    private let collectionPath: String
    private lazy var db = Firestore.firestore()
    private lazy var reference = db.collection(collectionPath)
    var listener: ListenerRegistration?

    init(with collectionPath: String) {
        self.collectionPath = collectionPath
    }

    func listenForNewContent(closure: @escaping ([Channel]) -> Void) {
        listener = reference.addSnapshotListener { snapshot, _ in
            guard let documents = snapshot?.documents else { return }

            let channels = documents.map { documentSnapshot -> Channel in
                return Channel(with: documentSnapshot)
            }.sorted { first, second in
                guard let first = first.lastActivity else { return false }
                guard let second = second.lastActivity else { return true }
                return first > second
            }
            closure(channels)
        }
    }
}
