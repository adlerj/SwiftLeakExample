//
//  ViewController.swift
//  CombineExample
//
//  Created by Jeffrey Adler on 10/11/19.
//  Copyright © 2019 Jeffrey Adler. All rights reserved.
//

import UIKit
import Combine

class ViewController: UIViewController {
    let subject = PassthroughSubject<Int, Error>()

    override func viewDidLoad() {
        super.viewDidLoad()

        let button = UIButton()
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Push!", for: .normal)
        button.setTitleColor(.black, for: .normal)

        view.addSubview(button)
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    @objc private func buttonTapped() {
        let badVC = BadViewController(subject)
        navigationController?.pushViewController(badVC, animated: true)
    }
}

class BadViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()

    init(_ subject: PassthroughSubject<Int, Error>) {
        super.init(nibName: nil, bundle: nil)

        let sequence = Publishers.Sequence<[Int], Error>(sequence: [1, 2, 3])
        Publishers
            .Concatenate(prefix: sequence, suffix: subject)
            .map(stringify(_:))
            .receive(on: DispatchQueue.global(qos: .background))
            .sink(
                receiveCompletion: {_ in }) { value in
                print(value)
            }
            .store(in: &cancellables)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func stringify(_ number: Int) -> String {
        return "\(number)"
    }

    deinit {
        print("never called")
    }
}

