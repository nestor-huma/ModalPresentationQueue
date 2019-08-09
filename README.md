# ModalPresentationQueue
**UIViewController** extension which lets you present multiple modal view controllers in a serial presentation queue. This means that the next view controller added to the queue will be presented as soon as the last view controller in the queue will be dismissed. (Or immediately, if the presentation queue is empty).

# Demo Preview
![alt tag](https://s31.postimg.org/hfzru6jfv/Modal_Presentation_Queue.gif)

#Usage
The extension provides you with two public functions: `addViewControllerToPresentationQueue(viewControllerToPresent: UIViewController, animated: Bool = true, completion: Action? = nil)` and `emptyPresentationQueue()`. The names are self explanatory :) You can call these functions on any UIViewController.

Code from the example project:
```Swift
    @IBAction private func presentAlerts(sender: AnyObject) {
        for index in 0..<numberOfAlerts {
            let alert = createAlert(number: index + 1, total: numberOfAlerts)
            addViewControllerToPresentationQueue(alert)
        }
    }
```

Please check out the example project to see this extension in action.

#Installation
Add **UIViewController+ModalPresentationQueue.swift** to your project.
Add line to your **AppDelegate.Swift**:
```Swift
UIViewController.swizzleViewDidDisappear()
```


#License
MIT
