//
//  TimerViewDelegate.swift
//  Pomodoro
//
//  Created by macbook on 03.12.2023.
//

import UIKit

@objc protocol TimerViewDelegate: AnyObject {
    @objc func addTarget(_ sender: UIButton)
}
