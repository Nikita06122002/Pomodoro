//
//  ViewController.swift
//  Pomodoro
//
//  Created by macbook on 01.12.2023.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    private let realm = RealmManager.shared
    
    private let timerView = TimerView()
    private var timer = Timer()
    private var player = AVAudioPlayer()
    
    private var timeModel = Time()
    private var sessionsCount = Sessions()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConst()
        timerView.isUserInteractionEnabled = true
        timerView.addTarget(self, action: #selector(buttonTapped(_ :)))
        
        
        print(RealmManager.shared.realm.configuration.fileURL)
    }
    
    private func setupView() {
        view.addSubview(timerView)
    }
    
    private func setupConst() {
        timerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timerView.topAnchor.constraint(equalTo: view.topAnchor),
            timerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            timerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        
        timerView.setText(text: timeModel.updateLabelWithTime(timeInterval: timeModel.duration))
        timerView.setProgress(progress: 0)
        
        if sender.title(for: .normal) == "Запуск" {
            sender.setTitle("Стоп", for: .normal)
            
            timeModel.resetTimer()
            
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updates), userInfo: nil, repeats: true)

        } else {
            
            sender.setTitle("Запуск", for: .normal)
            
            timer.invalidate()
            
            stopTimer()
        }
    }
    
    
    @objc private func updates() {
        if timeModel.remainingTime > 0 {
            startSession()
            if timeModel.remainingTime == 0 {
                sessionsCount.updateSessionCount(count: 1)
                print(sessionsCount.completesSession)
            }
        } else if sessionsCount.completesSession % 5 != 0 {
            if !timeModel.soundPlayedForBreak && !timeModel.sessionComplete {
                playSound()
                timeModel.completeSession()
                realm.save(word: sessionsCount)
                realm.save(word: timeModel)
            }
            // Здесь логика короткого перерыва
            shortBreak()
            if timeModel.breakDuration == 0 {
                isShortBreakEnd()
            }
        } else if sessionsCount.completesSession % 5 == 0 {
            if !timeModel.soundPlayedForBreak && !timeModel.sessionComplete {
                playSound()
                timeModel.completeSession()
                realm.save(word: sessionsCount)
                realm.save(word: timeModel)
            }
            // Здесь логика длинного перерыва
            longBreak()
            if timeModel.longBreakDuration == 0 {
               isLongBreakEnd()
            }
        }
    }
    

    
    //MARK: - SetTimer
    private func setTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updates), userInfo: nil, repeats: true)
    }
    
    //MARK: - Start session
    
    private func startSession() {
         timeModel.start()
         print("start session")
         let progress = timeModel.getProgress()

        timerView.setProgress(progress: progress)
        timerView.setText(text: timeModel.updateLabelWithTime(timeInterval: timeModel.remainingTime))
     }
    
    //MARK: - IsShortBreakEnd?
    private func isShortBreakEnd() {
        if timeModel.breakDuration == 0 {
            timeModel.resetShortBreakDuration()
            timeModel.startNewSession()   // Начинаем новую сессию работы
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updates), userInfo: nil, repeats: true)
            print("короткий перерыв закончен")
            return
        }
    }

    //MARK: - ShortBreak
    
    private func shortBreak() {
        if !timeModel.soundPlayedForBreak && !timeModel.breakSessionSaved && !timeModel.sessionComplete {
            print(timeModel.soundPlayedForBreak && timeModel.breakSessionSaved && timeModel.sessionComplete)
            playSound()
            timeModel.completeSession()
            realm.save(word: sessionsCount)
            realm.save(word: timeModel)
        }
        timeModel.startFiveMin()
//        print("перерыв 5 мин")

        let progress = timeModel.getFiveMinProgress()
        timerView.setProgress(progress: progress)
        timerView.setText(text: timeModel.updateLabelWithTime(timeInterval: timeModel.breakDuration))
    }
    
    //MARK: - IsLongBrealEnd?
    private func isLongBreakEnd() {
        if timeModel.longBreakDuration == 0 { // Проверяем, заканчивается ли длинный перерыв
            print("короткий перерыв закончен")
            timeModel.resetLongBreakDuration()
            timer.invalidate()
            timeModel.startNewSession() // Начинаем новую сессию работы
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updates), userInfo: nil, repeats: true)
            return
        }
    }
    
    //MARK: - LongBreak
    private func longBreak() {
        
        if !timeModel.soundPlayedForLongBreak && !timeModel.breakSessionSaved && !timeModel.sessionComplete {
            print(timeModel.soundPlayedForBreak && timeModel.breakSessionSaved && timeModel.sessionComplete)
            playSound()
            timeModel.completeSession()
            realm.save(word: sessionsCount)
            realm.save(word: timeModel)
        }

        timeModel.startFifteenMin()
        print("Длинный перерыв")
        let progress = timeModel.getFifteenMinProgress()
        timerView.setProgress(progress: progress)
        timerView.setText(text: timeModel.updateLabelWithTime(timeInterval: timeModel.longBreakDuration))
    }
    
    //MARK: - StopTimer
    private func stopTimer() {
    
        if !timeModel.soundPlayedForSessionEnd {
            playSound()
            timeModel.endSound()
        }
        print("stop timer")
        saveModels()// сохраянем модель в реалм
        resetModels() //делаем новую модель(обнуляем)
        timer.invalidate()
        timeModel.resetTimer()
    }
    
    //MARK: - PlaySound
    private func playSound() {
        if let url = Bundle.main.url(forResource: "time", withExtension: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player.play()
                player.play(atTime: 2)
            } catch {
                print("Error")
            }
        } else {
            print("URL for sound not found.")
            
        }
    }
    
    
    //MARK: - Reset Models
    private func resetModels() {
        timeModel = Time()
        sessionsCount = Sessions()
    }
    
    
    //MARK: - Save Models
    private func saveModels() {
        realm.save(word: timeModel)
        realm.save(word: sessionsCount)
    }
    
}




//MARK: - SwiftUI
import SwiftUI
struct Provider_ViewController : PreviewProvider {
    static var previews: some View {
        ContainterView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainterView: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> UIViewController {
            return ViewController()
        }
        
        typealias UIViewControllerType = UIViewController
        
        
        let viewController = ViewController()
        func makeUIViewController(context: UIViewControllerRepresentableContext<Provider_ViewController            .ContainterView>) -> ViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: Provider_ViewController.ContainterView.UIViewControllerType, context: UIViewControllerRepresentableContext<Provider_ViewController.ContainterView>) {
            
        }
    }
    
}

