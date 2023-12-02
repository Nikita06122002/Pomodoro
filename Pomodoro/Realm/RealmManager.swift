//
//  RealmManager.swift
//  Pomodoro
//
//  Created by macbook on 01.12.2023.
//

import RealmSwift

final class RealmManager {
    static let shared = RealmManager()
    let realm: Realm!
    
    private init() {
        do {
            realm = try Realm()
        } catch {
            realm = nil
            print(error.localizedDescription)
        }
    }
    //get
    var times: [Time] {
        let set = realm.objects(Time.self)
        return Array(set)
    }
    
    //delete
    
    func delete(word: Object) {
        do {
            try realm.write {
                realm.delete(word)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //edit
    
    func edit(word: Object) {
        do {
            try realm.write {
                realm.add(word, update: .modified)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //save
    
    func save(word: Object) {
        do {
            try realm.write {
                realm.add(word)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    func startSession(time: Time) {
        do {
            try realm .write {
                time.remainingTime = time.duration  // Устанавливаем время для новой сессии работы
                time.passedTime = 0           // Обнуляем прошедшее время
                time.sessionComplete = false
                time.breakSessionSaved = false
                time.soundPlayedForBreak = false
                time.soundPlayedForLongBreak = false
                time.soundPlayedForSessionEnd = false
            }
        } catch {
            print("Error completing session: \(error.localizedDescription)")

        }
    }
    
    func completedSession(time: Time) {
        do {
            try realm .write {
                time.completedSessions += 1
                time.sessionComplete = true
                time.soundPlayedForBreak = true
            }
        } catch {
            print("Error completing session: \(error.localizedDescription)")
        }
    }
    
    func updateTimer(time: Time) {
        do {
            try realm .write {
                time.remainingTime -= 1
                time.passedTime += 1
            }
        } catch {
            print("Error completing session: \(error.localizedDescription)")
        }
        
    }
    
    func startFiveMin(time: Time) {
        do {
            try realm .write {
                time.breakDuration -= 1
            }
        } catch {
            print("Error completing session: \(error.localizedDescription)")
            
        }
    }
    
    func startFifteenMin(time: Time) {
        do {
            try realm .write {
                time.longBreakDuration -= 1
            }
        } catch {
            print("Error completing session: \(error.localizedDescription)")
        }
    }
    
    func resetTimer(time: Time) {
        do {
            try realm .write {
                time.remainingTime = time.duration
                time.passedTime = 0
                time.breakDuration = 0.2 * 60
                time.longBreakDuration = 0.3 * 60
                time.sessionComplete = false
                time.soundPlayedForBreak = false
                time.breakSessionSaved = false
            }
        } catch {
            print("Error completing session: \(error.localizedDescription)")
        }
    }
    
    func endSound(time: Time) {
        do {
            try realm .write {
                time.soundPlayedForSessionEnd = true
            }
        } catch {
            print("Error completing session: \(error.localizedDescription)")
        }
    }
 
    
    
    
    
    
    func resetShortBreakDuration(time: Time) {
        do {
            try realm .write {
                time.breakDuration = 0.2 * 60 // Сбросить короткий перерыв до начального значения
            }
        } catch {
            print("Error completing session: \(error.localizedDescription)")

        }
    }

    func resetLongBreakDuration(time: Time) {
        do {
            try realm .write {
                time.longBreakDuration = 0.3 * 60 // Сбросить длинный перерыв до начального значения
            }
        } catch {
            print("Error completing session: \(error.localizedDescription)")

        }
    }
    
    
    
    
}
