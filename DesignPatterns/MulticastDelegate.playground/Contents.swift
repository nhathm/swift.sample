import UIKit

class MulticastDelegate<ProtocolType> {
    private let delegates: NSHashTable<AnyObject> = NSHashTable.weakObjects()
    
    func add(_ delegate: ProtocolType) {
        delegates.add(delegate as AnyObject)
    }
    
    func remove(_ delegateToRemove: ProtocolType) {
        for delegate in delegates.allObjects.reversed() {
            if delegate === delegateToRemove as AnyObject {
                delegates.remove(delegate)
            }
        }
    }
    
    func invokeDelegates (_ invocation: (ProtocolType) -> Void) {
        for delegate in delegates.allObjects.reversed() {
            invocation(delegate as! ProtocolType)
        }
    }
}

protocol SampleDelegate: class {
    func sendSampleDelegateWithoutData()
    func sendSampleDelegate(with string: String)
}

extension SampleDelegate {
    func sendSampleDelegateWithoutData() {
        
    }
}

class SampleClass {
    var delegate = MulticastDelegate<SampleDelegate>()
    
    func didGetData() {
        delegate.invokeDelegates {
            $0.sendSampleDelegate(with: "Sample Data")
        }
    }
}

class ReceivedDelegate1: SampleDelegate {
    func sendSampleDelegate(with string: String) {
        print("ReceivedDelegate === 1 === \(string)")
    }
    
    deinit {
        print("deinit ReceivedDelegate1")
    }
}

class ReceivedDelegate2: SampleDelegate {
    func sendSampleDelegate(with string: String) {
        print("ReceivedDelegate === 2 === \(string)")
    }
    
    deinit {
        print("deinit ReceivedDelegate2")
    }
}

let sendDelegate = SampleClass()
let received1 = ReceivedDelegate1()
sendDelegate.delegate.add(received1)

do {
    let received2 = ReceivedDelegate2()
    sendDelegate.delegate.add(received2)
    sendDelegate.didGetData()
}
print("Đợi cho object received2 trong block do được release")
DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    sendDelegate.didGetData()
}
