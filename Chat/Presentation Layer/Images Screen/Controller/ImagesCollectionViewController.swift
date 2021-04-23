//
//  ImagesCollectionViewController.swift
//  Chat
//
//  Created by VB on 20.04.2021.
//

import UIKit

 extension ImagesCollectionViewController {
    fileprivate static var storyboardName: String { "Images" }
    fileprivate static var storyboardIdentifier: String { String(describing: ImagesCollectionViewController.self) }

    static func instantiate() -> ImagesCollectionViewController? {
        guard let controller = UIStoryboard(name: storyboardName, bundle: .main)
                .instantiateViewController(withIdentifier: storyboardIdentifier) as? ImagesCollectionViewController else { return nil }
        return controller
    }
 }

class ImagesCollectionViewController: UICollectionViewController {

    var dismissHandler: ((UIImage?) -> Void)?
    private var model = Images(networkService: NetworkService())
    private var selectedIndexPath: IndexPath?
    private let reuseIdentifier = "Cell"
    private let sectionInsets = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        getImages()
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.imagesCount()
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ImagesCollectionViewCell else {
            return UICollectionViewCell()
        }
        guard let imageView = cell.imageView else { return UICollectionViewCell() }

        let networkImage = model.image(at: indexPath.row)
        if let image = networkImage.previewImage {
            DispatchQueue.main.async {
                imageView.image = image
            }
        } else {
            imageView.image = UIImage(named: "placeholderImage")
            networkImage.getPreview { image in
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        }
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        dismiss(animated: true)
    }
}

extension ImagesCollectionViewController {
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let selectedIndexPath = selectedIndexPath {
            let networkImage = model.image(at: selectedIndexPath.row)
            if networkImage.image != nil {
                dismissHandler?(networkImage.image)
            } else {
                networkImage.getImage { [self] image in
                    self.dismissHandler?(image)
                }
            }
        } else {
            dismissHandler?(nil)
        }
    }
}

extension ImagesCollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 3.0

        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow

        return CGSize(width: widthPerItem, height: widthPerItem)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

extension ImagesCollectionViewController {
    func getImages() {
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        view.addSubview(activityIndicator)
        activityIndicator.frame = view.bounds
        activityIndicator.startAnimating()

        model.getImages { _ in
            DispatchQueue.main.async {
                activityIndicator.removeFromSuperview()
                self.collectionView.reloadData()
            }
        }
    }
}
