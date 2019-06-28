# Swift Codable

**Codable** được giới thiệu cùng với phiên bản 4.0 của Swift, đem lại sự thuận tiện cho người dùng mỗi khi cần encode/decode giữa JSON và Swift object. </br>
**Codable** là alias của 2 protocols là *Decodable & Encodable*
- Decodable: chuyển data dạng string, bytes...sang instance (decoding/deserialization)
- Encodable: chuyển instace sang string, bytes... (encoding/serialization)

## Table of contents
- Swift Codable basic
- Swift Codable manual encode decode

## Swift Cobale basic
Chúng ta sẽ đi vào ví dụ đầu tiên của Swift Codable, mục tiêu sẽ là convert đoạn JSON sau sang Swift object (struct)

```json
{
    "name": "NhatHM",
    "age": 29,
    "page": "https://magz.techover.io/"
}
```

Cách làm:</br>
Đối với các JSON có dạng đơn giản thế này, công việc của chúng ta chỉ là *define Swift struct conform to Codable protocol* cho chính xác, sau đó dùng *JSONDecoder()* để decode về instance là được. </br>
Note: Nếu không cần phải chuyển ngược lại thành string/bytes (không cần encode) thì chỉ cần conform protocol Decodable là đủ.

Implementation: </br>
Define Swift struct:
```Swift
struct Person: Codable {
    let name: String
    let age: Int
    let page: URL
    let bio: String?
}
```

Convert string to instance: </br>
```Swift
// Convert json string to data
var data = Data(json.utf8)
let decoder = JSONDecoder()
// Decode json with dictionary
let personEntity = try? decoder.decode(Person.self, from: data)
if let personEntity = personEntity {
    print(personEntity)
}
```

Chú ý: đối với dạng json trả về là array như dưới:
```json
[{
    "name": "NhatHM",
    "age": 29,
    "page": "https://magz.techover.io/"
},
{
    "name": "RioV",
    "age": 19,
    "page": "https://nhathm.com/"
}]
```
thì chỉ cần define loại data sẽ decode cho chính xác là được: </br>
``` Swift
let personEntity = try? decoder.decode([Person].self, from: data)
```
Ở đây ta đã định nghĩa được data decode ra sẽ là array của struct Person.
