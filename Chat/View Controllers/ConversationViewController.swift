//
//  ConversationViewController.swift
//  Chat
//
//  Created by VB on 02.03.2021.
//

import UIKit
import Firebase

class ConversationViewController: UITableViewController {

    struct Message {
        let content: String
        let created: Date
        let senderId: String
        let senderName: String
    }

    private var messagesCollectionReference: CollectionReference

    private var messages = [Message]()
    private let cellIdentifierIncoming = "MessageCellIncoming"
    private let cellIdentifierOutgoing = "MessageCellOutgoing"
    
    init(title: String, messagesCollectionReference: CollectionReference) {

        self.messagesCollectionReference = messagesCollectionReference
        
        super.init(style: .plain)
        
        self.title = title
        tableView.register(UINib(nibName: cellIdentifierIncoming, bundle: nil),
                           forCellReuseIdentifier: cellIdentifierIncoming)
        tableView.register(UINib(nibName: cellIdentifierOutgoing, bundle: nil),
                           forCellReuseIdentifier: cellIdentifierOutgoing)
        tableView.dataSource = self
        tableView.delegate = self
        
        self.tableView.separatorStyle = .none
        self.tableView.allowsSelection = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Message", style: .plain, target: self, action: #selector(newMessageButtonTap))

        messagesCollectionReference.addSnapshotListener { snapshot, _ in
            guard let documents = snapshot?.documents else { return }

            self.messages = documents.compactMap { documentSnapshot -> Message? in
                let data = documentSnapshot.data()
                if let content = data["content"] as? String,
                   let created = data["created"] as? Timestamp,
                   let senderId = data["senderId"] as? String,
                   let senderName = data["senderName"] as? String {

                    return Message(content: content, created: created.dateValue(), senderId: senderId, senderName: senderName)
                }
                return nil
            }
            .sorted { $0.created < $1.created }

            self.tableView.reloadData()
        }
    }

    @objc
    func newMessageButtonTap() {
        let alert = UIAlertController(title: "New Message", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Message" }
        alert.addAction(.init(title: "Cancel", style: .cancel))
        alert.addAction(.init(title: "Create", style: .default, handler: { (_) in
            if let message = alert.textFields?.first?.text,
               !message.isEmpty,
               let senderName = UserProfile.defaultProfile.name {
                self.messagesCollectionReference.addDocument(data: ["content": message,
                                                                    "created": Timestamp(date: Date()),
                                                                    "senderId": UserProfile.defaultProfile.id,
                                                                    "senderName": senderName])
            }
        }))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        var cellIdentifier = cellIdentifierIncoming
        if message.senderId == UserProfile.defaultProfile.id {
            cellIdentifier = cellIdentifierOutgoing
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MessageCell else {
            return UITableViewCell()
        }
        let content = """
        \(DateFormatter.stringDescribingMessage(date: message.created)): \(message.senderName)
        \(message.content)
        """
        cell.configure(with: .init(text: content))
        return cell
    }
}

extension DateFormatter {
    static func stringDescribingMessage(date: Date?) -> String {
        guard let date = date else { return "Sometime" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM HH:mm"
        if Calendar.current.isDateInToday(date) {
            formatter.dateFormat = "HH:mm"
        }
        return formatter.string(from: date)
    }
}
