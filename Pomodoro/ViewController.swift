//
//  ViewController.swift
//  Pomodoro
//
//  Created by macbook on 01.12.2023.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    private let realm = RealmManager.shared.realm
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConst()
        
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        print(RealmManager.shared.realm.configuration.fileURL)
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
            
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            
        } else {
            
            button.setTitle("Запуск", for: .normal)
            
            timer.invalidate()
            
            timeModel.resetTimer()
        }
    }
    
    
    @objc private func updateTimer() {
        if timeModel.remainingTime > 0 {
            
            timeModel.start()
            
            let progress = timeModel.getProgress()
            
            progressView.setProgress(progress, animated: true)
            
            time.text = timeModel.updateLabelWithTime(timeInterval: timeModel.remainingTime)
            
            //MARK: -  Логика короткого перерыва
        } else if timeModel.completedSessions < 5 && timeModel.breakDuration > 0 {
            
            if !timeModel.soundPlayedForBreak && !timeModel.breakSessionSaved && !timeModel.sessionComplete {
                
                playSound()
                
                timeModel.completeSession()
                
            }
            
            timeModel.startFiveMin()
            
            let progress = timeModel.getFiveMinProgress()
            
            progressView.setProgress(progress, animated: true)
            
            time.text = timeModel.updateLabelWithTime(timeInterval: timeModel.breakDuration)
            
            //MARK: - Логика длинного перерыва
        } else if timeModel.completedSessions == 5 && timeModel.longBreakDuration > 0 {
            
            if !timeModel.soundPlayedForLongBreak && !timeModel.breakSessionSaved && !timeModel.sessionComplete {
                
                playSound()
                
                timeModel.completeSession()
            }
            
            timeModel.startFifteenMin()
            
            let longBreakProgress = timeModel.getFifteenMinProgress()
            
            progressView.setProgress(longBreakProgress, animated: true)
            
            time.text = timeModel.updateLabelWithTime(timeInterval: timeModel.longBreakDuration)
            
            //MARK: - Остановка таймера и сброс
        } else {
            if timeModel.soundPlayedForSessionEnd {
                playSound()
                timeModel.endSound()
            }
            timer.invalidate()
        }
    }
    
    
    private func saveSession() {
        RealmManager.shared.save(word: timeModel)
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

