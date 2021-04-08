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

class ConversationsListViewController: UITableViewController {

    let coreDataStack: CoreDataStack
    let themeController = ThemeController()

    private lazy var store = FirestoreStack(collection: .channels)
    private lazy var dataController: DataController = {
        tableView.tag = 1
        return DataController(for: .channels, tableView: tableView, in: coreDataStack.mainContext)
    }()

    private let cellIdentifier = String(describing: ConversationCell.self)

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
        return { channels in
            self.performCoreDataSave(channels: channels)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        store.listenForNewContent(closure: listenerCompletion)

        store.listenForContentChanges { (_: [Channel]) in  }

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
        store.stopListening()
    }
    
    @objc
    func newChannelButtonTap() {
        let alert = UIAlertController(title: "Create New Channel", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Channel name" }
        alert.addAction(.init(title: "Cancel", style: .cancel))
        alert.addAction(.init(title: "Create", style: .default, handler: { (_) in
            if let name = alert.textFields?.first?.text,
               !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
               let document = self.store.addChannel(name: name) {
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

 extension ConversationsListViewController {
    func performCoreDataSave(channels: [Channel]) {
        self.coreDataStack.performSave { context in
            channels.forEach { _ = ChannelDb(channel: $0, in: context) }
        }
    }
 }

// MARK: - Table view data source
extension ConversationsListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataController.numberOfRowsInSection(section: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ConversationCell,
              let channel = dataController.getChannel(at: indexPath)
        else {
            return UITableViewCell()
        }

        cell.configure(with: .init(name: channel.name, message: channel.lastMessage, date: channel.lastActivity))
        return cell
    }
}

// MARK: - Table view delegate
extension ConversationsListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let channel = dataController.getChannel(at: indexPath) else { return }
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
        store.stopListening()
        dataController.stopTrackChanges()

        conversationVC.channel = channel
        conversationVC.coreDataStack = coreDataStack
        conversationVC.dismissHandler = { [weak self] in
            guard let self = self else { return }
            self.store.listenForNewContent(closure: self.listenerCompletion)
            self.dataController.startTrackChanges()
        }
        navigationController?.pushViewController(conversationVC, animated: true)
    }
}

// extension ConversationsListViewController: NSFetchedResultsControllerDelegate {
//
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        self.tableView.beginUpdates()
//    }
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        self.tableView.endUpdates()
//        print("end updates from ConversationsListViewController")
//
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
//                    didChange anObject: Any,
//                    at indexPath: IndexPath?,
//                    for type: NSFetchedResultsChangeType,
//                    newIndexPath: IndexPath?) {
//
//        switch type {
//        case .insert:
//            guard let newIndexPath = newIndexPath else { return }
//            tableView.insertRows(at: [newIndexPath], with: .automatic)
//        case .move:
//            guard let indexPath = indexPath,
//                  let newIndexPath = newIndexPath else { return }
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//            tableView.insertRows(at: [newIndexPath], with: .automatic)
//        case .update:
//            guard let indexPath = indexPath else { return }
//            tableView.reloadRows(at: [indexPath], with: .automatic)
//        case .delete:
//            guard let indexPath = indexPath else { return }
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//        default:
//            return
//        }
//    }
// }
