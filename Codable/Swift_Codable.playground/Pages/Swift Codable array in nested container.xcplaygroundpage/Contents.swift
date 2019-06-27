import UIKit
import Foundation

let json = """
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
"""
struct ListPerson {
    struct Person: Codable {
        var name: String?
        var age: Int?
        var page: URL?
        var bio: String?
        
        enum PersonDetailKeys: String, CodingKey {
            case name
            case age
            case page
            case bio
        }
    }
    
    var listPerson: [Person]
    
    enum PersonKeys: String, CodingKey {
        case persons
    }
}

extension ListPerson: Encodable {
    func encode(to encoder: Encoder) throws {
        var personContainer = encoder.container(keyedBy: PersonKeys.self)
        var personDetailContainer = personContainer.nestedUnkeyedContainer(forKey: .persons)
        
        listPerson.forEach {
            try? personDetailContainer.encode($0)
        }
    }
}

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

let data = Data(json.utf8)
let decoder = JSONDecoder()

do {
    var personEntity = try decoder.decode(ListPerson.self, from: data)
    print(personEntity)
    
    // Change property
    for i in 0..<personEntity.listPerson.count {
        personEntity.listPerson[i].name = "New name"
    }
    
    // Error if use this way with message Swift Codable array in nested container.xcplaygroundpage:84:12: error: cannot assign to property: '$0' is immutable ==>> WHY?
    //personEntity.listPerson.forEach {
    //    $0.name = "New Name"
    //}
    
    let encoder = JSONEncoder()
    let dataencoded = try encoder.encode(personEntity)
    let str = String(decoding: dataencoded, as: UTF8.self)
    print(str)
} catch {
    print(error)
}
