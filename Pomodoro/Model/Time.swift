//
//  Time.swift
//  Pomodoro
//
//  Created by macbook on 01.12.2023.
//

import Foundation
import RealmSwift


class Time: Object {
    
    @Persisted(primaryKey: true) var _id: String = UUID().uuidString
    
    @Persisted var duration: TimeInterval = 25 * 60 // 25 минут
    @Persisted var breakDuration: TimeInterval = 5 * 60 // 5 минут
    @Persisted var longBreakDuration: TimeInterval = 15 * 60 // 15 минут
    @Persisted var remainingTime: TimeInterval //времени прошло
    @Persisted var passedTime: TimeInterval = 0
    @Persisted var completedSessions: Int = 0
    
    @Persisted var soundPlayedForBreak: Bool = false
    @Persisted var soundPlayedForLongBreak: Bool = false
    @Persisted var soundPlayedForSessionEnd: Bool = false
    
    @Persisted var breakSessionSaved: Bool = false
    
    @Persisted var sessionComplete: Bool = false
    
    
    
    override init() {
        super.init()
        self.remainingTime = duration
    }
    
    func getProgress() -> Float {
        let progress = Float(passedTime) / Float(duration)
        return progress
    }
    
    func start() {
        remainingTime -= 1
        passedTime += 1
    }
    
    func completeSession() {
        completedSessions += 1
        sessionComplete = true
        breakSessionSaved = true
        soundPlayedForBreak = true
    }
    
    func startFiveMin() {
        breakDuration -= 1
    }
    
    func getFiveMinProgress() -> Float {
        let breakProgress = Float(1.0) - (Float(breakDuration) / Float(0.5 * 60))
        return breakProgress
    }
    
    func startFifteenMin() {
        longBreakDuration -= 1
    }
    
    func getFifteenMinProgress() -> Float {
        let longBreakProgress = Float(1.0) - (Float(longBreakDuration) / Float(0.5 * 60))
        return longBreakProgress
    }
    
    
    func updateLabelWithTime(timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
        
    }
    
    func endSound() {
        soundPlayedForSessionEnd = true
    }
    
    func resetTimer() {
        remainingTime = duration
        passedTime = 0
        breakDuration = 5 * 60
        longBreakDuration = 15 * 60
        sessionComplete = false
        soundPlayedForBreak = false
        breakSessionSaved = false
    }
}
