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
    
    @Persisted var duration: TimeInterval = 0.1 * 60 // 25 минут
    @Persisted var breakDuration: TimeInterval = 0.2 * 60 // 5 минут
    @Persisted var longBreakDuration: TimeInterval = 0.3 * 60 // 15 минут
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
    
    func resetShortBreakDuration() {
        RealmManager.shared.resetShortBreakDuration(time: self)
    }

    func resetLongBreakDuration() {
        RealmManager.shared.resetLongBreakDuration(time: self)
    }
    
    func getProgress() -> Float {
        let progress = Float(passedTime) / Float(duration)
        return progress
    }
    
    func startNewSession() {
        RealmManager.shared.startSession(time: self)
    }
    
    func start() {
        RealmManager.shared.updateTimer(time: self)
    }
    
    func completeSession() {
        RealmManager.shared.completedSession(time: self)
    }
    
 
    
    func startFiveMin() {
        RealmManager.shared.startFiveMin(time: self)
    }
    
    func getFiveMinProgress() -> Float {
        let breakProgress = Float(1.0) - (Float(breakDuration) / Float(0.2 * 60))
        return breakProgress
    }
    
    func startFifteenMin() {
        RealmManager.shared.startFifteenMin(time: self)
    }
    

    
    func getFifteenMinProgress() -> Float {
        let longBreakProgress = Float(1.0) - (Float(longBreakDuration) / Float(0.3 * 60))
        return longBreakProgress
    }
    
    
    func updateLabelWithTime(timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
        
    }
    
    func endSound() {
        RealmManager.shared.endSound(time: self)
    }
    

    func resetTimer() {
        RealmManager.shared.resetTimer(time: self)
    }
}
