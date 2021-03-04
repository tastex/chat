//
//  ProfileViewController.swift
//  Chat
//
//  Created by VB on 17.02.2021.
//

import UIKit
import AVFoundation

class ProfileViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var profileImageView: UIImageView?
    @IBOutlet weak var editButton: UIButton?

    var imagePickerController = UIImagePickerController()

    @IBAction func imageTap(_ sender: Any) {

        let alert = UIAlertController(title: nil, message: "Change Profile Logo", preferredStyle: .actionSheet)
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

    required init?(coder: NSCoder) {
        super .init(coder: coder)
        title = "Profile"
        print("\(#function) - Button frame: \(String(describing: editButton?.frame))")
        // На момент инициализации ProfileViewController — editButton еще не инициализирована, поэтому не известен и frame кнопки
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePickerController.delegate = self

        if let imageView = profileImageView {
            imageView.image = UserProfile.defaultProfile.image
            imageView.layer.cornerRadius = imageView.frame.width / 2
        }

        editButton?.layer.cornerRadius = 14
        if #available(iOS 13.0, *) {
            editButton?.layer.cornerCurve = .continuous
        }

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTap(_:)))

        print("\(#function) - Button frame: \(String(describing: editButton?.frame))")
    }

    @objc
    func doneButtonTap(_ sender: Any) {
        self.dismiss(animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("\(#function) - Button frame: \(String(describing: editButton?.frame))")
        // В методе viewDidLoad значения свойств frame у editButton равны значениям заданным в Main.storyboard для iPhone SE (2nd genaration)
        // В методе viewDidAppear frame у editButton высчитан относительно ее констрейнтов и размера текущего устройства
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let presentingViewController = self.presentingViewController?.children.first as? ConversationsListViewController {
            if let profileView = presentingViewController.navigationItem.rightBarButtonItem?.customView as? UIImageView {
                profileView.image = UserProfile.defaultProfile.image?.copy(newSize: CGSize(width: 40, height: 40))
            }
        }
    }
}

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

    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage {

            UserProfile.defaultProfile.image = image
            self.profileImageView?.image = UserProfile.defaultProfile.image

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
