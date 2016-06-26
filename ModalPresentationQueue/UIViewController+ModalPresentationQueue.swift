//
//  UIViewController+ModalPresentationQueue.swift
//  ModalPresentationQueueExample
//
//  Created by Nestor on 6/24/16.
//  Copyright © 2016 Nestor. All rights reserved.
//

import UIKit


/** Associated keys for stored properties */
private struct AssociatedKeys {
    static var PresentationQueueName = "np_PresentationQueueName"
    static var DismissCompletion = "np_DismissCompletion"
}

public extension UIViewController {
    /**
     Simple block which takes no parameters and returns nothing.
     */
    typealias Action = () -> Void
    
    /**
     Adds view controller to the presentation queue.
     New view controller will be presented immediately if the queue is empty or right after the last added view controller will be dismissed.
     */
    func addViewControllerToPresentationQueue(viewControllerToPresent: UIViewController, animated: Bool = true, completion: Action? = nil) {
        
        // Create new block operation
        let newOperation = NSBlockOperation {
            let semaphore = dispatch_semaphore_create(0)
            
            // Set view controller's dismissal completion in order to get notified when it will be dismissed
            viewControllerToPresent.dismissCompletion = {
                dispatch_semaphore_signal(semaphore)
            }
            
            // Present view controller in main queue
            NSOperationQueue.mainQueue().addOperationWithBlock{
                self.presentViewController(viewControllerToPresent, animated: animated, completion: completion)
            }
            
            // Wait until view controller will be dismissed
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        }
        newOperation.queuePriority = .VeryHigh
        
        // Make sure that new operation won't start until all previous operations will finish
        if let lastOperation = presentationQueue.operations.last {
            newOperation.addDependency(lastOperation)
        }
        
        
        // Add the new operation to the queue
        presentationQueue.addOperation(newOperation)
    }
    
    /** Removes all view controllers which were not yet presented from presentation queue */
    func emptyPresentationQueue() {
        presentationQueue.cancelAllOperations()
    }
    
    /**
     Queue of view controllers.
     */
    private var presentationQueue: NSOperationQueue {
        struct Static {
            static var onceToken: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.onceToken) {
            let presentationQueue = NSOperationQueue()
            objc_setAssociatedObject(self, &AssociatedKeys.PresentationQueueName, presentationQueue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return objc_getAssociatedObject(self, &AssociatedKeys.PresentationQueueName) as! NSOperationQueue
    }
    
}

extension UIViewController {
    /**
     This block is called after the view controller becomes dismissed.
     */
    private var dismissCompletion: Action? {
        get {
            return dismissCompletionWrapper?.action
        }
        set {
            dismissCompletionWrapper = ActionWrapper(action: newValue)
        }
    }
    
    /**
     Class used to wrap block.
     Is needed because you can only associate with objects which are kind of AnyObject.
     */
    private class ActionWrapper {
        var action: Action?
        init(action: Action?) {
            self.action = action
        }
    }
    
    /**
     Wrapped dismiss completion.
     */
    private var dismissCompletionWrapper: ActionWrapper? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.DismissCompletion) as? ActionWrapper
        } set {
            if let value = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.DismissCompletion, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    // MARK: method swizzling
    public override class func initialize() {
        struct Static {
            static var token: dispatch_once_t = 0
        }
        
        // make sure this isn't a subclass
        if self !== UIViewController.self {
            return
        }
        
        // Replace viewWillDissappear with np_viewWillDissappear
        dispatch_once(&Static.token) {
            let originalSelector = #selector(UIViewController.viewDidDisappear(_:))
            let swizzledSelector = #selector(UIViewController.np_viewDidDisappear(_:))
            
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            
            let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            
            if didAddMethod {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
        }
    }
    
    /**
     Swizzled viewWillDisappear.
     */
    @objc private func np_viewDidDisappear(animated: Bool) {
        self.np_viewDidDisappear(animated)
        if isBeingDismissed() {
            dismissCompletion?()
        }
    }
}
