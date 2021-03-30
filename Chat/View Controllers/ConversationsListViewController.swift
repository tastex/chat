//
//  ConversationsListViewController.swift
//  Chat
//
//  Created by VB on 28.02.2021.
//

import UIKit
import Firebase
import CoreData

struct Channel {
    let identifier: String
    let name: String
    let lastMessage: String?
    let lastActivity: Date?

    init(identifier: String, name: String, lastMessage: String?, lastActivity: Date?) {
        self.identifier = identifier
        self.name = name
        self.lastMessage = lastMessage
        self.lastActivity = lastActivity
    }
}

extension Channel {
    init(with documentSnapshot: QueryDocumentSnapshot) {
        let data = documentSnapshot.data()
        let name = data["name"] as? String ?? ""
        let lastMessage = data["lastMessage"] as? String
        let lastActivity = data["lastActivity"] as? Timestamp

        self.identifier = documentSnapshot.documentID
        self.name = name
        self.lastMessage = lastMessage
        self.lastActivity = lastActivity?.dateValue()
    }
}

class ConversationsListViewController: UITableViewController {

    let coreDataStack: CoreDataStack
    let themeController = ThemeController()
    
    private let cellIdentifier = String(describing: ConversationCell.self)

    private enum Keys: String {
        case channelsPath = "channels"
        case messagesPath = "messages"
    }

    lazy var db = Firestore.firestore()
    lazy var reference = db.collection(Keys.channelsPath.rawValue)
    private var listener: ListenerRegistration?

    private lazy var store = FirestoreStack(with: Keys.channelsPath.rawValue)
    private var channels = [Channel]()

    func performCoreDataSave() {
        channels.forEach { channel in
            let messagesReference = reference.document(channel.identifier).collection(Keys.messagesPath.rawValue)
            messagesReference.getDocuments { (snapshot, _) in
                guard let documents = snapshot?.documents else { return }
                self.coreDataStack.performSave { context in
                    let channelDb = ChannelDb(channel: channel, in: context)
                    documents.forEach {
                        guard let message = Message(with: $0) else { return }
                        let messageDb = MessageDb(message: message, in: context)
                        channelDb.addToMessages(messageDb)
                    }
                }
            }
        }
    }

    init(style: UITableView.Style, coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
        super.init(style: style)

        title = "Channels"
        tableView.register(UINib(nibName: String(describing: ConversationCell.self), bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var listenerCompletion: ([Channel]) -> Void {
        return { [weak self] channels in
            guard let self = self else { return }

            self.channels = channels
            self.performCoreDataSave()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        store.listenForNewContent(closure: listenerCompletion)

        let profileView = ProfileLogoView(frame: CGRect(origin: .zero, size: CGSize(width: 40, height: 40)))
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileButtonTap(_:)))
        profileView.addGestureRecognizer(tapGestureRecognizer)
        let profileBarButtonItem = UIBarButtonItem(customView: profileView)

        let newChannelButton = UIBarButtonItem(image: UIImage(named: "square.and.pencil"),
                                               style: .plain,
                                               target: self,
                                               action: #selector(newChannelButtonTap))
        self.navigationItem.rightBarButtonItems = [profileBarButtonItem, newChannelButton]

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "gear"),
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(settingsButtonTap))
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        store.listener?.remove()
    }
    
    @objc
    func newChannelButtonTap() {
        let alert = UIAlertController(title: "Create New Channel", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Channel name" }
        alert.addAction(.init(title: "Cancel", style: .cancel))
        alert.addAction(.init(title: "Create", style: .default, handler: { (_) in
            if let name = alert.textFields?.first?.text,
               !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let document = self.reference.addDocument(data: ["name": name])
                self.presentMessages(in: Channel(identifier: document.documentID, name: name, lastMessage: nil, lastActivity: nil))
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @objc
    func profileButtonTap(_ sender: UITapGestureRecognizer) {
        guard let profileVC = UIStoryboard(name: "Main", bundle: .main)
                .instantiateViewController(withIdentifier: String(describing: ProfileViewController.self)) as? ProfileViewController else { return }
        
        profileVC.setProfile(profile: UserProfile.defaultProfile)
        let navigationVC = UINavigationController(rootViewController: profileVC)
        navigationVC.navigationBar.prefersLargeTitles = true
        self.navigationController?.present(navigationVC, animated: true, completion: nil)
    }
    
    @objc
    func settingsButtonTap() {
        guard let themesVC = UIStoryboard(name: "Main", bundle: .main)
                .instantiateViewController(withIdentifier: String(describing: ThemesViewController.self)) as? ThemesViewController else { return }
        themesVC.themePickerDelegate = themeController
        self.navigationController?.pushViewController(themesVC, animated: true)
    }
}

// MARK: - Table view data source
extension ConversationsListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ConversationCell else { return UITableViewCell() }

        let channel = channels[indexPath.row]

        cell.configure(with: .init(name: channel.name, message: channel.lastMessage, date: channel.lastActivity))
        return cell
    }
}

// MARK: - Table view delegate
extension ConversationsListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = channels[indexPath.row]
        presentMessages(in: channel)
    }
}

// MARK: - Navigation
extension ConversationsListViewController {
    func presentMessages(in channel: Channel) {
        guard let conversationVC = UIStoryboard(name: "Main", bundle: .main)
                .instantiateViewController(withIdentifier:
                                            String(describing: ConversationViewController.self))
                as? ConversationViewController else {
            return
        }
        conversationVC.title = channel.name
        let messagesCollectionReference = reference.document(channel.identifier).collection(Keys.messagesPath.rawValue)
        conversationVC.reference = messagesCollectionReference
        conversationVC.dismissHandler = { [weak self] in
            guard let self = self else { return }
            self.store.listenForNewContent(closure: self.listenerCompletion)
        }
        store.listener?.remove()
        navigationController?.pushViewController(conversationVC, animated: true)
    }
}

public extension UIImage {
    func copy(newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
