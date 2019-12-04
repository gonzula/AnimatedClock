//
//  ViewController.swift
//  ClockView
//
//  Created by Gonzo Fialho on 03/12/19.
//  Copyright © 2019 Gonzo Fialho. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let clockView = ClockView()

    let startTime = (0, 0, 0)
    let endTime = (22, 30, 0)

    override func viewDidLoad() {
        super.viewDidLoad()

        clockView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(clockView)
        clockView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        clockView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        clockView.time = startTime

        let button = UIButton()
        button.setTitle("Animate", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)

        button.topAnchor.constraint(equalTo: clockView.bottomAnchor, constant: 44).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        button.addTarget(self, action: #selector(animate), for: .touchUpInside)
    }

    @objc func animate() {
        self.clockView.time = startTime
        UIView.animate(withDuration: 3,
                       delay: 0,
                       options: .preferredFramesPerSecond60,
                       animations: {
                        self.clockView.time = self.endTime
        },
                       completion: nil)
    }
}
