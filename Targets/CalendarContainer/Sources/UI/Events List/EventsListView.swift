//
//  EventsListView.swift
//  CalendarContainerTests
//
//  Created by Volodymyr Kravchenko on 24.08.2021.
//  Copyright © 2021 Anywhere. All rights reserved.
//

import UIKit

public class EventsListView: UIView {

  public init() {
    super.init(frame: .zero)
    setup()
  }

  required init?(coder: NSCoder) { nil }

  let picker = UIView(frame: .zero)
  let list = UIView(frame: .zero)

  private func setup() {
    addSubview(picker)
    addSubview(list)
    picker.translatesAutoresizingMaskIntoConstraints = false
    list.translatesAutoresizingMaskIntoConstraints = false
    backgroundColor = .white
    picker.backgroundColor = .blue
    list.backgroundColor = .yellow
    NSLayoutConstraint.activate([
      picker.leftAnchor.constraint(equalTo: leftAnchor),
      picker.rightAnchor.constraint(equalTo: rightAnchor),
      picker.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
      picker.bottomAnchor.constraint(equalTo: list.topAnchor),
      picker.heightAnchor.constraint(equalToConstant: 300),
      list.leftAnchor.constraint(equalTo: leftAnchor),
      list.rightAnchor.constraint(equalTo: rightAnchor),
      list.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
  }
}
