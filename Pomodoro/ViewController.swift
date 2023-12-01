//
//  ViewController.swift
//  Pomodoro
//
//  Created by macbook on 01.12.2023.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    private let tomato = UIImageView(image: UIImage(named: "tomat")!)
    private let button = UIButton()
    private let time = UILabel()
    private let progressView = UIProgressView()
    private var timer = Timer()
    private var player = AVAudioPlayer()
    
    private var timeModel = Time()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupConst()
        
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    private func setupView() {
        view.addSubview(tomato)
        view.addSubview(button)
        view.addSubview(time)
        view.addSubview(progressView)
        progressView.progress = 0.5
        view.backgroundColor = UIColor(named: "light")
        button.setTitle("Запуск", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 30)
        button.backgroundColor = UIColor(named: "lightPurple")
        button.layer.cornerRadius = 15
        
        time.text = String(format: "%02d:%02d", timeModel.duration / 60)
        time.font = .boldSystemFont(ofSize: 30)
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
        if sender.title(for: .normal) == "Запуск" {
            button.setTitle("Стоп", for: .normal)
            resetTimer()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        } else {
            button.setTitle("Запуск", for: .normal)
            timer.invalidate()
            resetTimer()
            
            
        }
       
    }
    
    @objc private func updateTimer() {
        if timeModel.remainingTime > 0 {
            timeModel.remainingTime -= 1
            timeModel.passedTime += 1
            
            let progress = Float(timeModel.passedTime) / Float(timeModel.duration)
            progressView.setProgress(progress, animated: true)
            
            updateLabelWithTime(timeInterval: timeModel.remainingTime)
            
          } else if timeModel.completedSessions < 5 && timeModel.breakDuration > 0 {
              if !timeModel.soundPlayedForBreak {
                  playSound()
                  timeModel.soundPlayedForBreak = true
              }
              // Логика короткого перерыва
            timeModel.breakDuration -= 1
            let breakProgress = Float(1.0) - (Float(timeModel.breakDuration) / Float(2 * 60)) // 5 минут - начальная длительность
            progressView.setProgress(breakProgress, animated: true)
            updateLabelWithTime(timeInterval: timeModel.breakDuration)
        } else if timeModel.completedSessions == 5 && timeModel.longBreakDuration > 0 {
            if !timeModel.soundPlayedForLongBreak {
                playSound()
                timeModel.soundPlayedForBreak = true
            }
            // Логика длинного перерыва
            timeModel.longBreakDuration -= 1
            let longBreakProgress = Float(1.0) - (Float(timeModel.longBreakDuration) / Float(3 * 60)) // 15 минут - начальная длительность
            progressView.setProgress(longBreakProgress, animated: true)
            updateLabelWithTime(timeInterval: timeModel.longBreakDuration)
        } else {
            if timeModel.soundPlayedForSessionEnd {
                playSound()
                timeModel.soundPlayedForSessionEnd = true
            }
            timer.invalidate()
            // Сброс или подготовка к новому циклу
        }
    }
    
    private func updateLabelWithTime(timeInterval: TimeInterval) {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        time.text = String(format: "%02d:%02d", minutes, seconds)

    }
    
    private func resetTimer() {
        timeModel.remainingTime = timeModel.duration
        timeModel.passedTime = 0
        timeModel.breakDuration = 5 * 60 // или ваше начальное значение
        timeModel.longBreakDuration = 15 * 60 // или ваше начальное значение
        progressView.progress = 0
        updateLabelWithTime(timeInterval: timeModel.duration)
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

