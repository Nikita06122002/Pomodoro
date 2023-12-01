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
    
}
