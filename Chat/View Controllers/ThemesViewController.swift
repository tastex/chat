//
//  ThemesViewController.swift
//  Chat
//
//  Created by VB on 09.03.2021.
//

import UIKit

class ThemesViewController: UIViewController {

    @IBOutlet weak var topThemeContainer: UIView!
    @IBOutlet weak var middleThemeContainer: UIView!
    @IBOutlet weak var bottomThemeContainer: UIView!

    var themeViews = Array<SelectableView>()
    weak var delegate: ThemesPickerDelegate?

    required init?(coder: NSCoder) {
        super .init(coder: coder)
        title = "Settings"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTap(_:)))
        navigationItem.largeTitleDisplayMode = .never
    }

    @objc
    func cancelButtonTap(_ sender: Any) {
        selectTheme(.current)
    }

    @objc
    func selectThemeAppearanceView(_ sender: UITapGestureRecognizer) {
        if let selectableView = sender.view as? SelectableView,
           let theme = Theme.init(rawValue: selectableView.tag) {
            selectTheme(theme)
        }
    }

    func selectTheme(_ theme: Theme) {
        for view in themeViews {
            view.unselect()
        }
        if let selectableView = themeViews.first(where: { $0.tag == theme.rawValue }) {
            selectableView.select()
        }
        delegate?.didSelectTheme(theme)
        UIView.animate(withDuration: 0.7, delay: 0, options: [.allowUserInteraction, .curveEaseInOut]) {
            self.delegate?.updateAppearance(viewController: self)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)

        if themeViews.isEmpty {
            let containerViews = [topThemeContainer, middleThemeContainer, bottomThemeContainer]
            for theme in Theme.allCases {
                guard let themeView = UINib(nibName: String(describing: ThemeAppearanceView.self), bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? ThemeAppearanceView else { continue }
                guard let container = containerViews[theme.rawValue] else { continue }

                themeView.configure(theme: theme, frame: CGRect(origin: .zero, size: container.frame.size))

                let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectThemeAppearanceView(_:)))
                themeView.addGestureRecognizer(tapRecognizer)
                themeView.tag = theme.rawValue

                themeViews.append(themeView)
                container.addSubview(themeView)
            }
        }
        selectTheme(.current)
    }
}
