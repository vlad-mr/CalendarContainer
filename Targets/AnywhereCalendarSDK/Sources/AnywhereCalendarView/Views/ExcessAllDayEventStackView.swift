//
//  ExcessAllDayEventStackView.swift
//  AnywhereCalendarSDK
//
//  Created by Deepika on 26/08/20.
//

import UIKit
#if canImport(CalendarUtils)
    import CalendarUtils
#endif

protocol HeaderExpansionDelegate: class {
    func didTap(onView view: UIView)
}

class ExcessAllDayEventStackView: CalendarHeaderStackView {
    weak var delegate: HeaderExpansionDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAction()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupAction()
    }

    func setupAction() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }

    @objc func didTap() {
        delegate?.didTap(onView: self)
    }

    override func updateView() {
        distribution = .fill
        if !subviews.isEmpty {
            for subview in subviews {
                subview.removeFromSuperview()
            }
        }

        for date in dates {
            let excessIndicatorView = getExcessAllDayEventView(forDate: date)

            addArrangedSubview(excessIndicatorView)
        }
        addVerticalSeparators(color: AnywhereCalendarView.mainSDK.theme.daySeparatorColor)
    }

    private func getExcessAllDayEventView(forDate date: Date) -> UIView {
        let label = configure(UILabel()) {
            $0.textColor = AnywhereCalendarView.mainSDK.theme.subHeading
            $0.font = AnywhereCalendarView.mainSDK.font.subHeader
            $0.textAlignment = .center
            $0.setupWidthAnchor(withConstant: self.contentWidth)
            $0.backgroundColor = AnywhereCalendarView.mainSDK.theme.backgroundColor
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setupHeightAnchor(withConstant: 20, priority: .dragThatCanResizeScene)
        }
        guard let numberOfAllDayEvents = customizationProvider?.getNoOfAllDayEvents(forDate: date), numberOfAllDayEvents > config.numberOfAllDayEventInCollapsedMode else {
            return label
        }

        switch config.moreAllDayEventConfiguration {
        case .count:
            label.text = "+\(numberOfAllDayEvents - config.numberOfAllDayEventInCollapsedMode)"
        case .more:
            label.text = "+ more"
        case let .custom(text):
            label.text = text
        }
        return label
    }
}
