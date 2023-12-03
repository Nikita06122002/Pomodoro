//
//  Sessions.swift
//  Pomodoro
//
//  Created by macbook on 03.12.2023.
//

import Foundation
import RealmSwift

class Sessions: Object {
    @Persisted(primaryKey: true) var _id: String = UUID().uuidString
    @Persisted var completesSession: Int
    
    
    func saveSessionsCount() {
        RealmManager.shared.save(word: self)
    }
    
    func updateSessionCount(count: Int) {
        RealmManager.shared.updateSessionsCount(session: self, count: count)
    }
}
