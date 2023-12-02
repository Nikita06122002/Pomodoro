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
    
    private let tomato = UIImageView(image: UIImage(named: "tomat")!)
    private let button = UIButton()
    private lazy var time: UILabel = {
        let label = UILabel()
        let minutes = Int(timeModel.duration) / 60
        let seconds = Int(timeModel.duration) % 60
        label.text = String(format: "%02d:%02d", minutes, seconds)
        label.font = .boldSystemFont(ofSize: 30)
        return label
    }()
    private let progressView = UIProgressView()
    private var timer = Timer()
    private var player = AVAudioPlayer()
    
    private var timeModel = Time()
    private var count = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConst()
        
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
//        print(RealmManager.shared.realm.configuration.fileURL)
    }
    
    private func setupView() {
        view.addSubview(tomato)
        view.addSubview(button)
        view.addSubview(time)
        view.addSubview(progressView)
        progressView.progress = 0
        view.backgroundColor = UIColor(named: "light")
        button.setTitle("Запуск", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 30)
        button.backgroundColor = UIColor(named: "lightPurple")
        button.layer.cornerRadius = 15
    }
    
    private func setupConst() {
        tomato.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        time.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            progressView.topAnchor.constraint(equalTo: time.bottomAnchor, constant: 20),
            progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressView.widthAnchor.constraint(equalToConstant: 300),
            progressView.heightAnchor.constraint(equalToConstant: 6),
            
            
            time.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            time.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tomato.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 30),
            tomato.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tomato.heightAnchor.constraint(equalToConstant: 350),
            tomato.widthAnchor.constraint(equalToConstant: 350),
            
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        
        time.text = timeModel.updateLabelWithTime(timeInterval: timeModel.duration)
        progressView.progress = 0
        
        if sender.title(for: .normal) == "Запуск" {
            button.setTitle("Стоп", for: .normal)
            
            timeModel.resetTimer()
            
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update), userInfo: nil, repeats: true)
            
        } else {
            
            button.setTitle("Запуск", for: .normal)
            
            timer.invalidate()
            
            stopTimer()
        }
    }
    
//    @objc private func updateTimer() {
//        if timeModel.remainingTime > 0 {
//            //MARK: - Начало сессии
//            startSession()
//            
//        } else if timeModel.completedSessions < 5 && timeModel.breakDuration > 0 {
//            //MARK: - Логика короткого перерыва
//            shortBreak()
//            
//            //MARK: - Проверяем, заканчивается ли короткий перерыв
//            isShortBreakEnd()
//            
//
//        } else if timeModel.completedSessions == 5 && timeModel.longBreakDuration > 0 {
//            //MARK: - Проверяем, заканчивается ли длинный перерыв
//            isLongBreakEnd()
//            //MARK: - Логика длинного перерыва
//            longBreak()
//
//        } else {
//            //MARK: - Остановка таймера и сброс
//            stopTimer()
//        }
//    }
    
//    @objc private func update() {
//        
//        if timeModel.remainingTime > 0 {
//            startSession()
//            
//        } else if timeModel.breakDuration > 0 && count % 5 != 0 {
//            if !timeModel.soundPlayedForBreak && !timeModel.sessionComplete {
//                playSound()
//                timeModel.completeSession()
//                count += 1
//                realm.save(word: timeModel)
//            }
//            shortBreak()
//            isShortBreakEnd()
//        } else if count % 5 == 0 {
//            if !timeModel.soundPlayedForBreak && !timeModel.sessionComplete {
//                playSound()
//                timeModel.completeSession()
//                count += 1
//                realm.save(word: timeModel)
//            }
//            longBreak()
//            isLongBreakEnd()
//        }
//    }
    
    @objc private func update() {
        if timeModel.remainingTime > 0 {
            startSession()
            if timeModel.remainingTime == 0 {
                count += 1
                print(count)
            }
        } else if count % 5 != 0 {
            if !timeModel.soundPlayedForBreak && !timeModel.sessionComplete {
                playSound()
                timeModel.completeSession()
                realm.save(word: timeModel)
            }
            // Здесь логика короткого перерыва
            shortBreak()
            if timeModel.breakDuration == 0 {
                isShortBreakEnd()
            }
        } else if count % 5 == 0 {
            if !timeModel.soundPlayedForBreak && !timeModel.sessionComplete {
                playSound()
                timeModel.completeSession()
                realm.save(word: timeModel)
            }
            // Здесь логика длинного перерыва
            longBreak()
            if timeModel.longBreakDuration == 0 {
               isLongBreakEnd()
            }
        }
    }
    

    
    private func startSession() {
        timeModel.start()
        print("start session")
        let progress = timeModel.getProgress()

        progressView.setProgress(progress, animated: true)
        time.text = timeModel.updateLabelWithTime(timeInterval: timeModel.remainingTime)
    }
    
    
    private func isShortBreakEnd() {
        if timeModel.breakDuration == 0 {
            timeModel.resetShortBreakDuration()
            timeModel.startNewSession()   // Начинаем новую сессию работы
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update), userInfo: nil, repeats: true)
            print("короткий перерыв закончен")
            return
        }
    }

    
    private func shortBreak() {
        if !timeModel.soundPlayedForBreak && !timeModel.breakSessionSaved && !timeModel.sessionComplete {
            print(timeModel.soundPlayedForBreak && timeModel.breakSessionSaved && timeModel.sessionComplete)
            playSound()
            timeModel.completeSession()
            realm.save(word: timeModel)
        }
        timeModel.startFiveMin()
        print("перерыв 5 мин")

        let progress = timeModel.getFiveMinProgress()
        progressView.setProgress(progress, animated: true)
        time.text = timeModel.updateLabelWithTime(timeInterval: timeModel.breakDuration)
    }
    
    private func isLongBreakEnd() {
        if timeModel.longBreakDuration == 0 { // Проверяем, заканчивается ли длинный перерыв
            print("короткий перерыв закончен")
            timeModel.resetLongBreakDuration()
            timer.invalidate()
            timeModel.startNewSession() // Начинаем новую сессию работы
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update), userInfo: nil, repeats: true)
            return
        }
    }
    
    private func longBreak() {
        
        if !timeModel.soundPlayedForLongBreak && !timeModel.breakSessionSaved && !timeModel.sessionComplete {
            print(timeModel.soundPlayedForBreak && timeModel.breakSessionSaved && timeModel.sessionComplete)
            playSound()
            timeModel.completeSession()
            realm.save(word: timeModel)
        }

        timeModel.startFifteenMin()
        print("Длинный перерыв")
        let longBreakProgress = timeModel.getFifteenMinProgress()
        progressView.setProgress(longBreakProgress, animated: true)
        time.text = timeModel.updateLabelWithTime(timeInterval: timeModel.longBreakDuration)
    }
    
    
    private func stopTimer() {
        
        if !timeModel.soundPlayedForSessionEnd {
            playSound()
            timeModel.endSound()
        }
        print("stop timer")
        timer.invalidate()
        timeModel.resetTimer()
    }
    
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

