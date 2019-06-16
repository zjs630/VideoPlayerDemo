

import UIKit
enum ErrorViewDisplayType: Int {
    case hidden = 0
    case error = 1
    case nothing = 2
    case web_loading = 3
    case web_failed = 4
}

class ErrorView: UIView {
    weak var delegate: ErrorViewable?

    public var displayType: ErrorViewDisplayType = .hidden {
        didSet {
            superview?.bringSubviewToFront(self)

            if displayType == .hidden {
                isHidden = true

            } else {
                isHidden = false
            }
        }
    }

    lazy var contentView: UIView = {
        let contentView = UIView()

        return contentView

    }()

    lazy var iv: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "error")
        iv.contentMode = .center
        return iv

    }()

    lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(0x666666)
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "点击刷新重试"
        return label

    }()

    lazy var reTry: UIButton = {
        let reTry = UIButton()
        reTry.setTitleColor(UIColor(0x666666), for: .normal)
        reTry.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        reTry.setTitle("刷新", for: .normal)
        reTry.layer.borderColor = UIColor(0x666666).cgColor
        reTry.layer.borderWidth = 1
        reTry.layer.cornerRadius = 25 / 2
        reTry.addTarget(self, action: #selector(didCilicked), for: .touchUpInside)
        return reTry

    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

//        backgroundColor = .mainBG

        addSubview(contentView)

        contentView.addSubview(iv)

        contentView.addSubview(label)

        contentView.addSubview(reTry)

        iv.snp.makeConstraints { maker in

            maker.top.equalToSuperview()

            maker.centerX.equalToSuperview()
        }

        label.snp.makeConstraints { maker in

            maker.top.equalTo(iv.snp.bottom).offset(10)

            maker.centerX.equalToSuperview()
        }

        reTry.snp.makeConstraints { maker in

            maker.top.equalTo(label.snp.bottom).offset(15)

            maker.size.equalTo(CGSize(width: 77, height: 25))

            maker.centerX.equalToSuperview()
        }

        contentView.snp.makeConstraints { maker in

            maker.size.equalTo(CGSize(width: 180, height: 180))

            maker.center.equalToSuperview()
        }
    }

    @objc func didCilicked() {
        if displayType != .web_loading {
            delegate?.didCilicked(errorView: self)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
