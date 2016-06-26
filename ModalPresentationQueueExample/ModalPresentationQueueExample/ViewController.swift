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
    
    @IBAction private func updateNumberOfAlerts(sender: UIStepper) {
        numberOfAlerts = Int(sender.value)
    }
    
    @IBAction private func presentAlerts(sender: AnyObject) {
        for index in 0..<numberOfAlerts {
            let alert = createAlert(number: index + 1, total: numberOfAlerts)
            addViewControllerToPresentationQueue(alert)
        }
    }
    
    private func createAlert(number number: Int, total: Int) -> UIAlertController {
        let alert = UIAlertController(title: "Alert \(number)/\(total)", message: "What's up?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Nothing", style: .Default, handler: nil))
        return alert
    }
    
}
