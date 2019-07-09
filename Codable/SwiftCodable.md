# Swift Codable

**Codable** được giới thiệu cùng với phiên bản 4.0 của Swift, đem lại sự thuận tiện cho người dùng mỗi khi cần encode/decode giữa JSON và Swift object.

**Codable** là alias của 2 protocols: *Decodable & Encodable*
- Decodable: chuyển data dạng string, bytes...sang instance (decoding/deserialization)
- Encodable: chuyển instace sang string, bytes... (encoding/serialization)

## Table of contents
- [Swift Codable basic](#Swift-Codable-basic)
- [Swift Codable manual encode decode](#Swift-Codable-manual-encode-decode)
- [Swift Codable coding key](#Swift-Codable-coding-key)
- [Swift Codable key decoding strategy](#Swift-Codable-key-decoding-strategy)
- [Swift Codable date decoding strategy](#Swift-Codable-date-decoding-strategy)
- [Swift Codable nested unkeyed container](#Swift-Codable-nested-unkeyed-container)

## Swift Codable basic
Chúng ta sẽ đi vào ví dụ đầu tiên của Swift Codable, mục tiêu sẽ là convert đoạn JSON sau sang Swift object (struct)

```json
{
    "name": "NhatHM",
    "age": 29,
    "page": "https://magz.techover.io/"
}
```

**Cách làm:**

Đối với các JSON có dạng đơn giản thế này, công việc của chúng ta chỉ là *define Swift struct conform to Codable protocol* cho chính xác, sau đó dùng *JSONDecoder()* để decode về instance là được.
Note: Nếu không cần phải chuyển ngược lại thành string/bytes (không cần encode) thì chỉ cần conform protocol Decodable là đủ.

**Implementation:**

Define Swift struct:
```Swift
struct Person: Codable {
    let name: String
    let age: Int
    let page: URL
    let bio: String?
}
```

Convert string to instance:
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
thì chỉ cần define loại data sẽ decode cho chính xác là được:

``` Swift
let personEntity = try? decoder.decode([Person].self, from: data)
```
Ở đây ta đã định nghĩa được data decode ra sẽ là array của struct Person.

## Swift Codable manual encode decode
Trong một vài trường hợp, data trả về mà chúng ta cần có thể nằm trong một key khác như dưới:
```json
{
    "person": {
        "name": "NhatHM",
        "age": 29,
        "page": "https://magz.techover.io/"
    }
}
```
Trong trường hợp này, nếu define Swift struct đơn giản như phần 1 chắc chắn sẽ không thể decode được. Do đó cách làm sẽ là define struct sao cho nó tương đồng nhất có thể với format của JSON.
Ví dụ như đối với JSON ở trên, chúng ta có thể define struct như dưới:

**Implementation**
```Swift
struct PersonData: Codable {
    struct Person: Codable {
        let name: String
        let age: Int
        let page: URL
        let bio: String?
    }

    let person: Person
}
```
Đối với trường hợp này, chúng ta vẫn sử dụng JSONDecoder() để decode string về instance như thường, tuy nhiên lúc sử dụng value của struct thì sẽ hơi bất tiện:

```Swift
let data = Data(json.utf8)
let decoder = JSONDecoder()
let personEntity = try? decoder.decode(PersonData.self, from: data)
if let personEntity = personEntity {
    print(personEntity)
    print(personEntity.person.name)
}
```
**Manual encode decode**

Đối với dạng JSON data như này, chúng ta còn có một cách khác để xử lý data cho phù hợp, dễ dùng hơn như dưới:

Define struct (chú ý, lúc này không thể hiện struct conform to Codable nữa, mà sẽ conform to Encodable và Decodable một cách riêng biệt):
```Swift
struct Person {
    var name: String
    var age: Int
    var page: URL
    var bio: String?

    enum PersonKeys: String, CodingKey {
        case person
    }

    enum PersonDetailKeys: String, CodingKey {
        case name
        case age
        case page
        case bio
    }
}
```
> Ở đây có một khái niệm mới là `CodingKey`. Về cơ bản, CodingKey chính là enum define các "key" mà chúng ta muốn Swift sử dụng để decode các value tương ứng. Ở đây key PersonKeys.person sẽ tương ứng với key "person" trong JSON string, các enum khác cũng tương tự (đọc thêm về CodingKey ở phần sau)

Với trường hợp này, ta sử dụng `nestedContainer` để đọc các value ở phía sâu của JSON, sau đó gán giá trị tương ứng cho properties của Struct.

**Implementation**
```Swift
extension Person: Decodable {
    init(from decoder: Decoder) throws {
        let personContainer = try decoder.container(keyedBy: PersonKeys.self)

        let personDetailContainer = try personContainer.nestedContainer(keyedBy: PersonDetailKeys.self, forKey: .person)
        name = try personDetailContainer.decode(String.self, forKey: .name)
        age = try personDetailContainer.decode(Int.self, forKey: .age)
        page = try personDetailContainer.decode(URL.self, forKey: .page)
        bio = try personDetailContainer.decodeIfPresent(String.self, forKey: .bio)
    }
}
```
Đây chính là phần implement để đọc ra các value ở tầng sâu của JSON, sau đó gán lại vào các properties tương ứng của struct. Các đoạn code trên có ý nghĩa như sau:
- `personContainer` là container tương ứng với toàn bộ JSON string
- `personDetailContainer` là container tương ứng với value của key `person`
- Nếu có các level sâu hơn thì ta lại tiếp tục sử dụng `nestedContainer` để đọc sau vào trong
- Nếu một property nào đó (key value nào đó của json) mà có thể không trả về, thì sử dụng `decodeIfPresent` để decode (nếu không có value thì gán bằng nil)

Note: Đối với việc Encode thì cũng làm tương tự, tham khảo source code đi kèm (link cuối bài)

Với cách làm này, thì khi gọi đến properties của struct, đơn giản ta chỉ cần `personEntity.name` là đủ.

## Swift Codable coding key
Trong đa số các trường hợp thì client sẽ sử dụng json format mà server đã định sẵn, do đó có thể gặp các kiểu json có format như sau:
```json
{
    "person_detail": {
        "first_name": "Nhat",
        "last_name": "Hoang",
        "age": 29,
        "page": "https://magz.techover.io/"
    }
}
```
Đối với kiểu json như này, để Struct có thể codable được thì cần phải define properties dạng `person_detail`, `first_name`. Điều này vi phạm vào coding convention của Swift. Trong trường hợp này chúng ta sử dụng Coding key để mapping giữa properties của Struct và key của JSON.

**Implementation**
```Swift
struct Person {
    var firstName: String
    var lastName: String
    var age: Int
    var page: URL
    var bio: String?

    enum PersonKeys: String, CodingKey {
        case person = "person_detail"
    }

    enum PersonDetailKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case age
        case page
        case bio
    }
}
```
Với trường hợp này, khi sử dụng đoạn code decode như

`var personDetailContainer = personContainer.nestedContainer(keyedBy: PersonDetailKeys.self, forKey: .person)`

hay

`try personDetailContainer.encode(firstName, forKey: .firstName)`

thì khi đó, Swift sẽ sử dụng các key json tương ứng là `person_detail` hoặc `first_name`.

Cách implement cụ thể tham khảo file playground cuối bài

## Swift Codable key decoding strategy
Nếu json format từ server trả về là snake case (example_about_snake_case) thì chúng ta không cần phải define Coding key, mà chỉ cần dùng `keyDecodingStrategy` của `JSONDecoder` là đủ. Ví dụ:
```Swift
let json = """
{
    "first_name": "Nhat",
    "last_name": "Hoang",
    "age": 29,
    "page": "https://magz.techover.io/"
}
"""

struct Person: Codable {
    var firstName: String
    var lastName: String
    var age: Int
    var page: URL
    var bio: String?
}

let data = Data(json.utf8)
let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase

let personEntity = try? decoder.decode(Person.self, from: data)
if let personEntity = personEntity {
    print(personEntity)
} else {
    print("Decode entity failed")
}
```

Với trường hợp này, Swift decoder sẽ tự hiểu để decode key `first_name` thành property `firstName`. Điều kiện duy nhất là sử dụng `keyDecodingStrategy` là `convertFromSnakeCase` và server trả về format JSON đúng theo format của snake case.

**Custom key decoding strategy**

 Ngoài ra cũng có thể define custom keyDecodingStategy bằng cách sử dụng:
 ```Swift
 jsonDecoder.keyDecodingStrategy = .custom { keys -> CodingKey in
	let key = /* logic for custom key here */
	return CodingKey(stringValue: String(key))!
}
```
## Swift Codable date decoding strategy
Trong rất nhiều trường hợp thì JSON trả về từ server sẽ bao gồm cả date time string. Và `JSONDecoder` cũng cung cấp phương pháp để decode date time từ string một cách nhanh gọn bằng `dateDecodingStrategy`.
Ví dụ, với date time string đúng chuẩn 8601 thì chỉ cần define:
```Swift
let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .iso8601
```
là có thể convert date time dạng `1990-01-01T14:12:41+0700` sang Swift date time `1990-01-01 07:12:41 +0000` một cách đơn giản.

Trong trường hợp muốn decode một vài string date time có format khác đi, thì có thể làm bằng cách:

```Swift
func dateFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
    return formatter
}

let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .formatted(dateFormatter())
```
Với ví dụ này, thì chúng ta có thể tự define date formatter và sử dụng cho `dateDecodingStrategy` của JSONDecoder

## Swift Codable nested unkeyed container

```json
{
    "persons": [
        {
            "name": "NhatHM",
            "age": 29,
            "page": "https://magz.techover.io/"
        },
        {
            "name": "RioV",
            "age": 19,
            "page": "https://nhathm.com/"
        }
    ]
}
```

Với dạng JSON như trên thì values của persons là một array chứa các thông tin của person. Và các item trong array thì không có key tương ứng. Do đó để Decode được trường hợp này thì ta dùng `nestedUnkeyedContainer`.

**Implementation**
```Swift
extension ListPerson: Decodable {
    init(from decoder: Decoder) throws {
        let personContainer = try decoder.container(keyedBy: PersonKeys.self)
        listPerson = [Person]()

        var personDetailContainer = try personContainer.nestedUnkeyedContainer(forKey: .persons)
        while (!personDetailContainer.isAtEnd) {
            if let person = try? personDetailContainer.decode(Person.self) {
                listPerson.append(person)
            }
        }
    }
}
```

Sample playground: [Swift_Codable.playground](https://github.com/RioV/swift.sample/tree/master/Codable/Swift_Codable.playground)
