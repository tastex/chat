//
//  ConversationViewController.swift
//  Chat
//
//  Created by VB on 02.03.2021.
//

import UIKit
import Firebase

struct Message {
    let content: String
    let created: Date
    let senderId: String
    let senderName: String
}

class ConversationViewController: UIViewController {

    var reference: CollectionReference?
    var dismissHandler: (() -> Void)?

    private var listener: ListenerRegistration?

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

        navigationItem.largeTitleDisplayMode = .never

        tableView.allowsSelection = false
        tableView.register(UINib(nibName: cellIdentifierIncoming, bundle: nil), forCellReuseIdentifier: cellIdentifierIncoming)
        tableView.register(UINib(nibName: cellIdentifierOutgoing, bundle: nil), forCellReuseIdentifier: cellIdentifierOutgoing)

        tableView.dataSource = self

        listenForNewContent()

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
        listener?.remove()
        dismissHandler?()
    }

    @IBAction func sendButtonTap(_ sender: Any) {
        if let message = messageInputView.text,
           !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           !isMessageInputViewPlaceholderVisible,
           let senderName = UserProfile.defaultProfile.name {
            reference?.addDocument(data: ["content": message,
                                          "created": Timestamp(date: Date()),
                                          "senderId": UserProfile.defaultProfile.id,
                                          "senderName": senderName])
            messageInputView.text = ""
        }
    }

    func listenForNewContent() {

        var scrollToBottomAnimated = false

        listener = reference?.addSnapshotListener { [weak self]  snapshot, _ in
            guard let documents = snapshot?.documents else { return }

            self?.messages = documents.compactMap { documentSnapshot -> Message? in
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

            DispatchQueue.main.async {
                guard let self = self else { return }
                self.tableView.reloadData()
                self.scrollToBottom(animated: scrollToBottomAnimated)
                scrollToBottomAnimated = true
            }
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
