//
//  ProfileViewController.swift
//  Chat
//
//  Created by VB on 17.03.2021.
//

import UIKit
import AVFoundation

class ProfileViewController: UIViewController, UINavigationControllerDelegate {

    struct Profile {
        var name: String?
        var bio: String?
        var image: UIImage?
    }

    private var draft: Profile?
    private var profile: UserProfile? {
        didSet {
            configure()
        }
    }

    var image: UIImage? {
        didSet {
            logoContainerView?.configure()
        }
    }

    var imagePickerController = UIImagePickerController()
    var activeTextView: UITextView?
    var lastOffset: CGPoint?

    @IBOutlet weak var logoContainerView: ProfileLogoView?

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var nameTextView: UITextView!
    @IBOutlet weak var bioTextView: UITextView!

    @IBOutlet weak var saveGCDButton: UIButton!
    @IBOutlet weak var saveOperationsButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var editButton: UIButton!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    required init?(coder: NSCoder) {
        super .init(coder: coder)
        title = "Profile"
    }

    func setProfile(profile: UserProfileProtocol) {
        if let profile = profile as? UserProfile {
            self.profile = profile
        }

    }

    func configure() {
        guard let profile = profile else {
            return
        }
        nameTextView?.text = profile.name
        bioTextView?.text = profile.bio
        image = profile.image
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()

        startAvoidingKeyboard()
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(_:))))

        nameTextView.delegate = self
        bioTextView.delegate = self

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTap(_:)))

        imagePickerController.delegate = self

        if let logoContainerView = logoContainerView {
            let logoTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(logoTap(_:)))
            logoContainerView.addGestureRecognizer(logoTapRecognizer)
            logoContainerView.font = UIFont.systemFont(ofSize: 120)
            logoContainerView.configure()
        }

        [editButton, cancelButton, saveGCDButton, saveOperationsButton].forEach { button in
            if let button = button {
                if button != editButton {
                    button.isHidden = true
                }
                button.layer.cornerRadius = 12
                if #available(iOS 13.0, *) {
                    button.layer.cornerCurve = .continuous
                }
            }
        }

        if #available(iOS 13.0, *) {
            activityIndicator.style = .large
        }
    }

    @objc
    func doneButtonTap(_ sender: Any) {
        self.dismiss(animated: true)
    }

    @objc
    func logoTap(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "Change Profile Logo", preferredStyle: .actionSheet)
        alert.pruneNegativeWidthConstraints()
        alert.addAction(.init(title: "Chose Photo", style: .default) { [self]_ in
            showImagePicker(sourceType: .photoLibrary)
        })
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(.init(title: "Take Photo", style: .default) { [self]_ in
                showImagePicker(sourceType: .camera)
            })
        }
        alert.addAction(.init(title: "Cancel", style: .cancel))
        present(alert, animated: true, completion: nil)
    }

    func updateButtonVisibility() {
        isSavingData = false
        activityIndicator.stopAnimating()
        [editButton, cancelButton, saveGCDButton, saveOperationsButton].forEach { button in
            if let button = button {
                button.isHidden.toggle()
            }
        }
    }

    private var isSavingData = false {
        didSet {
            saveGCDButton.isEnabled = !isSavingData
            saveOperationsButton.isEnabled = !isSavingData
            logoContainerView?.isUserInteractionEnabled = !isSavingData
            nameTextView.isEditable = !isSavingData
            bioTextView.isEditable = !isSavingData
        }
    }

    @IBAction func editButtonTap(_ sender: Any) {
        updateButtonVisibility()
        nameTextView.isEditable = true
        bioTextView.isEditable = true
    }

    @IBAction func cancelButtonTap(_ sender: Any) {
        updateButtonVisibility()
        nameTextView.isEditable = false
        bioTextView.isEditable = false

    }

    @IBAction func saveGCDButtonTap(_ sender: Any) {
        activityIndicator.startAnimating()
        isSavingData = true
        print(#function)
    }

    @IBAction func saveOperationsButtonTap(_ sender: Any) {
        activityIndicator.startAnimating()
        isSavingData = true
        print(#function)
    }

}

extension ProfileViewController {
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let presentingViewController = self.presentingViewController?.children.first as? ConversationsListViewController,
           let profileLogoView = presentingViewController.navigationItem.rightBarButtonItem?.customView as? ProfileLogoView {
            profileLogoView.configure()
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopAvoidingKeyboard()
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ProfileViewController: UIImagePickerControllerDelegate {

    func showImagePicker(sourceType: UIImagePickerController.SourceType) {
        imagePickerController.sourceType = sourceType
        imagePickerController.allowsEditing = true
        if sourceType == .camera {
            let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
            switch authorizationStatus {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    guard granted else { return }
                    DispatchQueue.main.async { [self] in
                        present(imagePickerController, animated: true)
                    }
                }
                return
            case .denied:
                let alert = UIAlertController(title: "Unable to access the Camera",
                                              message: "To turn on camera access, choose Settings > Privacy > Camera and turn on Camera access for this app.",
                                              preferredStyle: .alert)
                alert.addAction(.init(title: "OK", style: .cancel))
                alert.addAction(.init(title: "Settings", style: .default) { _ in
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                       UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl)
                    }
                })
                present(alert, animated: true, completion: nil)
                return
            default: break
            }
        }
        present(imagePickerController, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage {

            UserProfile.defaultProfile.image = image
            self.image = UserProfile.defaultProfile.image

            dismiss(animated: true)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }

    // MARK: - Utilities
    private func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map { key, value in (key.rawValue, value) })
    }

    private func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
        return input.rawValue
    }
}

extension UIAlertController {
    func pruneNegativeWidthConstraints() {
        for subView in self.view.subviews {
            for constraint in subView.constraints where constraint.debugDescription.contains("width == - 16") {
                subView.removeConstraint(constraint)
            }
        }
    }
}

// MARK: UITextViewDelegate
extension ProfileViewController: UITextViewDelegate {

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        activeTextView = textView
        lastOffset = self.scrollView.contentOffset
        print("last offset = \(String(describing: lastOffset))")
        return true
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        returnTextView(nil)
        return true
    }

}

// MARK: KeyboardHandle
extension ProfileViewController {

    @objc func returnTextView(_ sender: UIGestureRecognizer?) {
        guard let activeTextView = activeTextView else { return }

        activeTextView.resignFirstResponder()
        self.activeTextView = nil
    }

    func startAvoidingKeyboard() {
        NotificationCenter.default.addObserver(self,
                         selector: #selector(onKeyboardFrameWillChangeNotificationReceived(_:)),
                         name: UIResponder.keyboardWillChangeFrameNotification,
                         object: nil)
    }

    func stopAvoidingKeyboard() {
        NotificationCenter.default.removeObserver(self,
                            name: UIResponder.keyboardWillChangeFrameNotification,
                            object: nil)
    }

    @objc
    private func onKeyboardFrameWillChangeNotificationReceived(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {
            return
        }

        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame.insetBy(dx: 0, dy: -additionalSafeAreaInsets.bottom)
        let intersection = safeAreaFrame.intersection(keyboardFrameInView)

        UIView.animate(withDuration: 0.7,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
                        self.additionalSafeAreaInsets.bottom = intersection.height
                        self.view.layoutIfNeeded()
                       })

        guard self.scrollView.contentOffset == .zero else { return }

        guard let activeTextView = activeTextView else { return }

        let distanceToBottom = self.scrollView.frame.size.height - activeTextView.frame.origin.y - activeTextView.frame.size.height

        let collapseSpace = intersection.height - distanceToBottom
        if collapseSpace < 0 { return }

        UIView.animate(withDuration: 0.7,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
                        self.scrollView.contentOffset = CGPoint(x: self.lastOffset?.x ?? 0, y: collapseSpace)

                       })
    }
}
