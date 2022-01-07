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
    lazy var arr: NSMapTable<AnyObject, ContainerIndexValue> = .weakToWeakObjects()
    @LockWrapper(defaultValue: 0) private var index: Int
    var isEmpty: Bool {
        return arr.count == 0
    }
    
    func append(_ container: ToastContainer) {
        arr.setObject(ContainerIndexValue(index: index), forKey: container)
        index += 1
    }
    
    func remove(where shouldBeRemoved: (ToastContainer) -> Bool) {
        let enumerator = arr.keyEnumerator()
        var key = enumerator.nextObject()
        var removeKey: [ToastContainer] = []
        var removePairs: [(ToastContainer, ContainerIndexValue)] = []
        while key != nil {
            if shouldBeRemoved(key as! ToastContainer) {
                removeKey.append(key as! ToastContainer)
                removePairs.append((key as! ToastContainer, arr.object(forKey: key as! ToastContainer)!))
            }
            key = enumerator.nextObject()
        }
        
        removePairs.sort { (pair1, pair2) -> Bool in
            return pair1.1.index < pair2.1.index
        }
        
        let removeIndexs = removePairs.map { $0.1.index }
        
        for key in removeKey {
            arr.removeObject(forKey: key)
        }
        
        index -= removePairs.count
        
        if removeIndexs.isEmpty {
            return
        }
        
        let leftKeys = arr.keyEnumerator()
        var leftKeyIterator = leftKeys.nextObject()
        var modifys: [(ToastContainer, ContainerIndexValue)] = []
        while leftKeyIterator != nil {
            guard let object = arr.object(forKey: leftKeyIterator as! ToastContainer) else {
                leftKeyIterator = leftKeys.nextObject()
                continue
            }
            let lessThanObjectIndexRemoveCount = removePairs.filter { $0.1.index < object.index }.count
            let newValue = ContainerIndexValue(index: object.index - lessThanObjectIndexRemoveCount)
            modifys.append((leftKeyIterator as! ToastContainer, newValue))
            leftKeyIterator = leftKeys.nextObject()
        }
        for modify in modifys {
            arr.setObject(modify.1, forKey: modify.0)
        }
    }
    
    func contains(_ container: ToastContainer) -> Bool {
        for obj in arr.keyEnumerator() {
            if (obj as! ToastContainer) === container {
                return true
            }
        }
        return false
    }
    
    func forEach(body: (ToastContainer) -> Void) {
        for obj in arr.keyEnumerator() {
            body(obj as! ToastContainer)
        }
    }
    
    func remove(at index: Int) -> ToastContainer? {
        let enumerator = arr.keyEnumerator()
        var key = enumerator.nextObject()
        var removeKey: ToastContainer?
        while key != nil {
            if let object = arr.object(forKey: key as! ToastContainer), object.index == index {
                removeKey = key as? ToastContainer
                break
            }
            key = enumerator.nextObject()
        }
        arr.removeObject(forKey: removeKey)
        self.index -= 1
        
        let leftKeys = arr.keyEnumerator()
        var leftKeyIterator = leftKeys.nextObject()
        var modifys: [(ToastContainer, ContainerIndexValue)] = []
        while leftKeyIterator != nil {
            if let object = arr.object(forKey: leftKeyIterator as! ToastContainer) {
                if object.index > index {
                    modifys.append((leftKeyIterator as! ToastContainer, ContainerIndexValue(index: object.index - 1)))
                } else {
                    continue
                }
            }
            leftKeyIterator = leftKeys.nextObject()
        }
        for modify in modifys {
            arr.setObject(modify.1, forKey: modify.0)
        }
        return removeKey
    }
    
    func removeAll() {
        arr.removeAllObjects()
        index = 0
    }
}

@propertyWrapper
internal struct LockWrapper<T> {
    private let lock: NSRecursiveLock = NSRecursiveLock()
    private var innerValue: T
    var wrappedValue: T {
        get {
            lock.lock(); defer { lock.unlock() }
            return innerValue
        }
        set {
            lock.lock(); defer { lock.unlock() }
            innerValue = newValue
        }
    }
    
    init(defaultValue: T) {
        innerValue = defaultValue
    }
}

final class ContainerIndexValue {
    let index: Int
    init(index: Int) {
        self.index = index
    }
}

