//
//  ConversationsListViewController.swift
//  Chat
//
//  Created by VB on 28.02.2021.
//

import UIKit

class ConversationsListViewController: UITableViewController {

    let themeController = ThemeController()

    private let cellIdentifier = String(describing: ConversationCell.self)

    override init(style: UITableView.Style) {
        super.init(style: style)
        
        title = "Tinkoff Chat"
        tableView.register(UINib(nibName: String(describing: ConversationCell.self), bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let profileView = ProfileLogoView(frame: CGRect(origin: .zero, size: CGSize(width: 40, height: 40)))
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileButtonTap(_:)))
        profileView.addGestureRecognizer(tapGestureRecognizer)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileView)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "SettingsIcon"), style: .plain, target: self, action: #selector(settingsButtonTap))
    }

    @objc
    func profileButtonTap(_ sender: UITapGestureRecognizer) {
        guard let profileVC = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: String(describing: ProfileViewController.self)) as? ProfileViewController
        else { return }
        profileVC.setProfile(profile: UserProfile.defaultProfile)

        let navigationVC = UINavigationController(rootViewController: profileVC)
        navigationVC.navigationBar.prefersLargeTitles = true
        self.navigationController?.present(navigationVC, animated: true, completion: nil)
    }

    @objc
    func settingsButtonTap() {
        guard let themesVC = UIStoryboard(name: "Main", bundle: .main)
                .instantiateViewController(withIdentifier: String(describing: ThemesViewController.self)) as? ThemesViewController else { return }
        //themesVC.themePickerDelegate = themeController
        themesVC.themeChangeHandler = { [self] (theme, viewController) in
            themeController.didSelectTheme(theme)
            themeController.updateAppearance(viewController: viewController)
        }
        self.navigationController?.pushViewController(themesVC, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return UserProfile.defaultProfile.offlineConversations.count
        }
        return UserProfile.defaultProfile.onlineConversations.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "History"
        }
        return "Online"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ConversationCell else { return UITableViewCell() }

        var conversations = UserProfile.defaultProfile.onlineConversations
        if indexPath.section == 1 {
            conversations = UserProfile.defaultProfile.offlineConversations
        }
        let conversation = conversations[indexPath.row]

        cell.configure(with: .init(name: conversation.name, message: conversation.messages.last?.text, date: conversation.messages.last?.date, online: conversation.online, hasUndeadMessages: conversation.hasUnreadMessages))
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var conversations = UserProfile.defaultProfile.onlineConversations
        if indexPath.section == 1 {
            conversations = UserProfile.defaultProfile.offlineConversations
        }
        let conversation = conversations[indexPath.row]
        let conversationVC = ConversationViewController(title: conversation.name ?? "Unknown contact", messages: conversation.messages)
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
