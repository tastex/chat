//
//  ConversationViewController.swift
//  Chat
//
//  Created by VB on 02.03.2021.
//

import UIKit
import Firebase

struct Message {
    let identifier: String
    let content: String
    let created: Date
    let senderId: String
    let senderName: String
}

class ConversationViewController: UIViewController {

    var channel: Channel?
    var store: FirestoreStack?
    var coreDataStack: CoreDataStack?
    var dismissHandler: (() -> Void)?

    private var messages = [Message]()
    private let cellIdentifierIncoming = "MessageCellIncoming"
    private let cellIdentifierOutgoing = "MessageCellOutgoing"

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageInputView: UITextView!
    @IBOutlet weak var messageInputBackgroundView: UIView!
    @IBOutlet weak var messageInputContainer: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = channel?.name
        navigationItem.largeTitleDisplayMode = .never

        tableView.allowsSelection = false
        tableView.register(UINib(nibName: cellIdentifierIncoming, bundle: nil), forCellReuseIdentifier: cellIdentifierIncoming)
        tableView.register(UINib(nibName: cellIdentifierOutgoing, bundle: nil), forCellReuseIdentifier: cellIdentifierOutgoing)

        tableView.dataSource = self

        var scrollToBottomAnimated = false
        store?.listenForNewContent { (messages: [Message]) in
            let queue = DispatchQueue(label: "UpdatingMessagesContentQueue", qos: .userInitiated)
            queue.async {
                self.messages = messages.sorted { $0.created < $1.created }

                DispatchQueue.main.async {
                    self.title = "\(self.channel?.name ?? "") \(messages.count)"
                    self.tableView.reloadData()
                    self.scrollToBottom(animated: scrollToBottomAnimated)
                    scrollToBottomAnimated = true
                }

                self.performCoreDataSave(messages: messages)
            }
        }

        messageInputView.text = ""
        messageInputView.delegate = self
        messageInputViewShowPlaceholder()

        startAvoidingKeyboard()
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(_:))))

        sendButton.layer.cornerRadius = sendButton.frame.height / 2
        messageInputBackgroundView.layer.cornerRadius = messageInputBackgroundView.frame.height / 2
        if #available(iOS 13.0, *) {
            messageInputBackgroundView.layer.cornerCurve = .continuous
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopAvoidingKeyboard()
        store?.stopListening()
        dismissHandler?()
    }

    @IBAction func sendButtonTap(_ sender: Any) {
        if let message = messageInputView.text,
           !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           !isMessageInputViewPlaceholderVisible,
           let senderName = UserProfile.defaultProfile.name {
            store?.addMessage(message, senderName: senderName, senderId: UserProfile.defaultProfile.id)
            messageInputView.text = ""
        }
    }

    func scrollToBottom(animated: Bool) {
        let numberOfSections = tableView.numberOfSections
        let numberOfRows = tableView.numberOfRows(inSection: numberOfSections - 1)
        if numberOfRows > 0 {
            tableView.scrollToRow(at: IndexPath(row: numberOfRows - 1, section: (numberOfSections - 1)), at: .bottom, animated: animated)
        }
    }
}

extension ConversationViewController {
    func performCoreDataSave(messages: [Message]) {
        guard let channel = channel,
              let coreDataStack = coreDataStack else { return }

        coreDataStack.performSave { context in
            let channelDb = ChannelDb(channel: channel, in: context)
            messages.forEach { message in
                let messageDb = MessageDb(message: message, in: context)
                channelDb.addToMessages(messageDb)
            }
        }
    }
}

// MARK: - Table view data source
extension ConversationViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        var cellIdentifier = cellIdentifierIncoming
        if message.senderId == UserProfile.defaultProfile.id {
            cellIdentifier = cellIdentifierOutgoing
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MessageCell else {
            return UITableViewCell()
        }

        var senderName: String? = message.senderName
        if message.senderId == UserProfile.defaultProfile.id {
            senderName = nil
        }

        cell.configure(with: .init(text: message.content, senderName: senderName))
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

// MARK: UITextViewDelegate
extension ConversationViewController: UITextViewDelegate {

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        messageInputViewHidePlaceholder()
        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        messageInputViewShowPlaceholder()
    }

}

// MARK: - Handle placeholder in messageInputView
extension ConversationViewController {

    private var messageInputViewPlaceholderText: String { "Message" }

    var isMessageInputViewPlaceholderVisible: Bool {
        messageInputView.text == messageInputViewPlaceholderText && messageInputView.textColor == .lightGray
    }

    func messageInputViewShowPlaceholder() {
        if messageInputView.text.isEmpty {
            sendButton.isHidden = true
            messageInputView.text = messageInputViewPlaceholderText
            messageInputView.textColor = .lightGray
        }
    }

    func messageInputViewHidePlaceholder() {
        if isMessageInputViewPlaceholderVisible {
            sendButton.isHidden = false
            messageInputView.text = ""
            messageInputView.textColor = .black
            if #available(iOS 13.0, *) {
                messageInputView.textColor = .label
            }
        }
    }
}

// MARK: - Handle Keyboard
extension ConversationViewController {

    @objc func hideKeyboard(_ sender: UIGestureRecognizer?) {
        self.messageInputView.resignFirstResponder()
    }

    func startAvoidingKeyboard() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onKeyboardFrameWillChangeNotificationReceived),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    func stopAvoidingKeyboard() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    @objc
    private func onKeyboardFrameWillChangeNotificationReceived(notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {
            return
        }

        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        guard keyboardFrameInView.origin.x == 0 else { return }

        let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame.insetBy(dx: 0, dy: -additionalSafeAreaInsets.bottom)
        let intersection = safeAreaFrame.intersection(keyboardFrameInView)
        guard additionalSafeAreaInsets.bottom != intersection.height else { return }

        let previousIntersectionHeight = additionalSafeAreaInsets.bottom
        additionalSafeAreaInsets.bottom = intersection.height

        UIView.animate(withDuration: 0.7,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
                        self.view.layoutIfNeeded()
                       })

        var scrollOffset = intersection.height
        let contentOverScroll = tableView.contentSize.height - tableView.contentOffset.y - tableView.frame.height
        if scrollOffset == 0, contentOverScroll > 0 {
            scrollOffset = -previousIntersectionHeight
        } else if contentOverScroll < 0 {
            scrollOffset = contentOverScroll
        }
        tableView.scrollRectToVisible(CGRect(origin: CGPoint(x: 0, y: tableView.contentOffset.y + scrollOffset), size: tableView.frame.size), animated: false)

    }
}
