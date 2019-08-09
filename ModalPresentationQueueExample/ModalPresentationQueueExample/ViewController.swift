//
//  ViewController.swift
//  ModalPresentationQueueExample
//
//  Created by Nestor on 6/26/16.
//  Copyright © 2016 Nestor. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var label: UILabel!
    
    private var numberOfAlerts: Int! {
        didSet {
            label.text = "Number of alerts: \(numberOfAlerts)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numberOfAlerts = 1
    }
    
    @IBAction private func updateNumberOfAlerts(_ sender: UIStepper) {
        numberOfAlerts = Int(sender.value)
    }
    
    @IBAction private func presentAlerts(_ sender: Any) {
        for index in 0..<numberOfAlerts {
            let alert = createAlert(number: index + 1, total: numberOfAlerts)
            addViewControllerToPresentationQueue(viewControllerToPresent: alert)
        }
    }
    
    
    private func createAlert(number: Int, total: Int) -> UIAlertController {
        let alert = UIAlertController(title: "Alert \(number)/\(total)", message: "What's up?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Nothing", style: .default, handler: nil))
        return alert
    }
    
}
