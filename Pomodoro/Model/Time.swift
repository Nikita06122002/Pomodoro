//
//  Time.swift
//  Pomodoro
//
//  Created by macbook on 01.12.2023.
//

import Foundation


struct Time {
    var duration: TimeInterval = 25 * 60 // 25 минут
    var breakDuration: TimeInterval = 5 * 60 // 5 минут
    var longBreakDuration: TimeInterval = 15 * 60 // 15 минут
    var remainingTime: TimeInterval //времени прошло
    var passedTime: TimeInterval = 0
    var state: TimerState = .stopped
    var completedSessions: Int = 0
    
    var soundPlayedForBreak: Bool = false
    var soundPlayedForLongBreak: Bool = false
    var soundPlayedForSessionEnd: Bool = false
    
    enum TimerState {
        case running, paused, stopped
    }
    
    init() {
        self.remainingTime = duration
    }
}
