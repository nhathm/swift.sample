# Multicast delegate

## Khái niệm

- Chúng ta đều biết rằng delegate là mối quan hệ 1 - 1 giữa 2 objects, trong đó 1 ọbject sẽ gửi data/event và object còn lại sẽ nhận data hoặc thực thi event
- Multicast delegate, về cơ bản chỉ là mối quan hệ 1 - n, trong đó, 1 object sẽ gửi dataevent đi, và có n class đón nhận data, event đó.

## Ứng dụng của multicase delegate, lúc nào thì dùng?

- Dùng multicast delegate khi mà bạn muốn xây dựng một mô hình delegate có mối quan hệ 1 - nhiều.
- Ví dụ: bạn có 1 class chuyên lấy thông tin data và các logic liên quan, và bạn muốn mỗi khi data của class được update và muốn implement các logic tương ứng của class này trên nhiều view/view controller khác nhau. Thì multicast delegate có thể dùng để xử lý bài toán này.

## So sánh với observer và notification

- Tại sao không dùng observer: chủ yếu chúng ta dùng obverver để theo dõi data hoặc event nào đó xảy ra, và thực hiện logic sau khi nó đã xảy ra. Còn nếu dùng delegate, chúng ta còn có thể xử lý data hoặc event, hay nói cách khác, chúng ta có thể quyết định xem có cho phép event đó xảy ra hay không, ví dụ như các delegate của Table view như tableView:willSelectRowAtIndexPath:
- Tại sao không dùng Notification thay vì multicast delegate? Về cơ bản, notification là thông tin một chiều từ 1 object gửi sang nhiều object nhận, chứ không thể có tương tác ngược lại. Ngoài ra, việc gửi data từ object gửi sang các object nhận thông qua userInfo thực sự là một điểm trừ rất lớn của Notifiction. Hơn nữa, việc quản lý Notification sẽ tốn công sức hơn là delegate, và chúng ta khá là khó khăn để nhìn ra mối quan hệ giữa object gửi và nhận khi dùng Notification.

## Implementation

- Vì Swift không có sẵn phương pháp tạo multicast delegate nên chúng ta cần phải tạo ra 1 class helper, nhằm quản lý các object muốn nhận delegate cũng như gọi các method delegate muốn gửi.

Đầu tiên, chúng ta tạo class helper như dưới:

```Swift
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
```

Class này là helper class có các method là add:(:) dùng để add và remove các object muốn nhận delegate. Ngoài ra nó có method invokeDelegates(:)->Void để gửi method delegate sang toàn bộ các object muốn nhận delegate.

Tiếp theo, define protocol (các delegate method) muốn implement:

```Swift
protocol SampleDelegate: class {
    func sendSampleDelegateWithoutData()
    func sendSampleDelegate(with string: String)
}

extension SampleDelegate {
    func sendSampleDelegateWithoutData() {        
    }
}
```

Ở đây, protocol `SampleDelegate` có 2 method là để ví dụ thêm rõ ràng rằng multicast delegate có thể thoải mái gửi các delegate tuỳ ý. Phần extention của `SampleDelegate` chỉ là để khiến cho method `sendSampleDelegateWithoutData` trở thành optional, không cần phải "conform" đến SampleDelegate. Đây là cách khá Swift, thay vì dùng cách sử dụng @objC và keywork optional

Tiếp theo, define ra class sẽ gửi các method của delegate

```Swift
class SampleClass {
    var delegate = MulticastDelegate<SampleDelegate>()
    
    func didGetData() {
        delegate.invokeDelegates {
            $0.sendSampleDelegate(with: "Sample Data")
        }
    }
}
```

Ở đây, có thể thấy rằng delegate của class "SampleClass" thực chất là object của helpper "MulticastDelegate", và nó chỉ chấp nhận delegate là objects của các class mà conform đến protocol "SampleDelegate"

Khai báo vài class conform đến protocol "SampleDelegate"

```Swift
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
```

OK, bây giờ test thử:

```Swift
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

```

Sau khi run đoạn source code này, ta được log như dưới:
```
ReceivedDelegate === 2 === Sample Data
ReceivedDelegate === 1 === Sample Data
Đợi cho object received2 trong block do được release
deinit ReceivedDelegate2
ReceivedDelegate === 1 === Sample Data
```

Giờ cùng phân tích:

Trong block `do` thì object "sendDelegate" đã append được 2 delegate objects vào biến delegate của nó, tiến hành send delegate thì ta thấy rằng cả object của cả 2 class `ReceivedDelegate1` và `ReceivedDelegate2` đều nhận được.

Sau block `do` thì object `received2` sẽ được release, vì việc release sẽ tốn một chút thời gian cho nên chúng ta sẽ thử thực hiện việc send delegate sau khoảng thời gian 1s, sau khi `received2` đã được release (bằng cách check log của method deinit)

Lúc này, ta thấy rằng chỉ có object của class `ReceivedDelegate1` là còn nhận được delegate, object của class `ReceivedDelegate2` đã bị release nên không còn nhận được object nữa. Như vậy, cách làm này vẫn đảm bảo các delegate vẫn là weak reference, không gây ra leak memory.

Đề làm được điều này thì ta đã sử dụng NSHashTable.weakObjects() để lưu weak reference đến các delegate được gán vào biến `delegates` của helper `MulticastDelegate`. Do đó đảm bảo được việc keep weak reference của class helper, nhằm tránh memory leak.

Ví dụ xem file: [MulticastDelegate.playground](https://github.com/RioV/swift.sample/tree/master/Design Patterns/MulticastDelegate.playground)