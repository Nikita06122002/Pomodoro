//
//  timerView.swift
//  Pomodoro
//
//  Created by macbook on 03.12.2023.
//

import UIKit

final class TimerView: UIView {
    
    init() {
        super.init(frame: .infinite)
        setupView()
        setupConst()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let tomato = UIImageView(image: UIImage(named: "tomat")!)
    private let button = UIButton()
    private let progressView = UIProgressView()
    private let model = Time()
    private lazy var time: UILabel = {
        let label = UILabel()
        let minutes = Int(model.duration) / 60
        let seconds = Int(model.duration) % 60
        label.text = String(format: "%02d:%02d", minutes, seconds)
        label.font = .boldSystemFont(ofSize: 30)
        return label
    }()
    
    private func setupView() {
        self.addSubview(tomato)
        self.addSubview(button)
        self.addSubview(time)
        self.addSubview(progressView)
        progressView.progress = 0
        self.backgroundColor = UIColor(named: "light")
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
            progressView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            progressView.widthAnchor.constraint(equalToConstant: 300),
            progressView.heightAnchor.constraint(equalToConstant: 6),
            
            
            time.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 100),
            time.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            tomato.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 30),
            tomato.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            tomato.heightAnchor.constraint(equalToConstant: 350),
            tomato.widthAnchor.constraint(equalToConstant: 350),
            
            button.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            button.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func setProgress(progress: Float) {
        progressView.setProgress(progress, animated: true)
    }
    
    func setText(text: String) {
        time.text = text
    }
    
    func addTarget(_ target: Any, action: Selector) {
        button.addTarget(target, action: action, for: .touchUpInside)
    }
    

}
