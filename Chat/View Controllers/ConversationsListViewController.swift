//
//  ConversationsListViewController.swift
//  Chat
//
//  Created by VB on 28.02.2021.
//

import UIKit
import Firebase

struct Channel {
    let identifier: String?
    let name: String
    let lastMessage: String?
    let lastActivity: Date?
}

class ConversationsListViewController: UITableViewController {
    
    let themeController = ThemeController()
    
    private let cellIdentifier = String(describing: ConversationCell.self)

    lazy var db = Firestore.firestore()
    lazy var reference = db.collection("channels")

    private var channels = [Channel]()

    override init(style: UITableView.Style) {
        super.init(style: style)
        
        title = "Channels"
        tableView.register(UINib(nibName: String(describing: ConversationCell.self), bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        reference.addSnapshotListener { snapshot, _ in
            guard let documents = snapshot?.documents else { return }

            self.channels = documents.map { documentSnapshot -> Channel in
                let data = documentSnapshot.data()
                let name = data["name"] as? String ?? ""
                let lastMessage = data["lastMessage"] as? String
                let lastActivity = data["lastActivity"] as? Timestamp

                return Channel(identifier: documentSnapshot.documentID, name: name, lastMessage: lastMessage, lastActivity: lastActivity?.dateValue())
            }
            // .sorted { $0.lastActivity ?? Date(timeIntervalSince1970: 0) > $1.lastActivity ?? Date(timeIntervalSince1970: 0) }
            self.tableView.reloadData()
        }

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
    
    @objc
    func newChannelButtonTap() {
        let alert = UIAlertController(title: "Create New Channel", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Channel name..." }
        alert.addAction(.init(title: "Cancel", style: .cancel))
        alert.addAction(.init(title: "Create", style: .default, handler: { (_) in
            if let name = alert.textFields?.first?.text,
               !name.isEmpty {
                self.reference.addDocument(data: ["name": name])
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

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ConversationCell else { return UITableViewCell() }

        let channel = channels[indexPath.row]

        cell.configure(with: .init(name: channel.name, message: channel.lastMessage, date: channel.lastActivity))
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let channel = channels[indexPath.row]
        guard let channelID = channel.identifier else { return }

        let messagesCollectionReference = reference.document(channelID).collection("messages")

        let conversationVC = ConversationViewController(title: channel.name, messagesCollectionReference: messagesCollectionReference)
        self.navigationController?.pushViewController(conversationVC, animated: true)
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
