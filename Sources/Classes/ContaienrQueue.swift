//
//  ContaienrQueue.swift
//  Splice-Toast-Demo
//
//  Created by 郑桂杰 on 2022/1/7.
//

import UIKit

private var shownToastContainerQueueKey = 0
private var inQueueContainerQueueKey = 0

extension UIView {
    var shownContaienrQueue: ContaienrQueue {
        get {
            return containerQueue(for: &shownToastContainerQueueKey)
        }
    }
    
    private var inQueueContaienrQueue: ContaienrQueue {
        get {
            return containerQueue(for: &inQueueContainerQueueKey)
        }
    }
    
    private func containerQueue(for key: UnsafeRawPointer) -> ContaienrQueue {
        if let queue = objc_getAssociatedObject(self, key) as? ContaienrQueue {
            return queue
        }
        let queue = ContaienrQueue()
        objc_setAssociatedObject(self, key, queue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return queue
    }
}

internal final class ContaienrQueue {
    lazy var arr: NSHashTable<AnyObject> = NSHashTable.weakObjects()
    func append(_ container: ToastContainer) {
        arr.add(container)
    }
    
    func remove(where shouldBeRemoved: (ToastContainer) -> Bool) {
        for object in arr.allObjects {
            if let obj = object as? ToastContainer, shouldBeRemoved(obj) {
                arr.remove(obj)
            }
        }
    }
    
    func contains(_ container: ToastContainer) -> Bool {
        return arr.contains(container)
    }
    
    func forEach(body: (ToastContainer) -> Void) {
        for obj in arr.allObjects {
            body(obj as! ToastContainer)
        }
    }
    
    func removeAll() {
        arr.removeAllObjects()
    }
}
