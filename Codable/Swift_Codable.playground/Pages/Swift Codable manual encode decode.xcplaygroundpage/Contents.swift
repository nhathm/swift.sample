import UIKit
import Foundation

let json = """
{
    "person": {
        "name": "NhatHM",
        "age": 29,
        "page": "https://magz.techover.io/"
    }
}
"""

//struct PersonData: Codable {
//    struct Person: Codable {
//        let name: String
//        let age: Int
//        let page: URL
//        let bio: String?
//    }
//
//    let person: Person
//}
//
//let data = Data(json.utf8)
//let decoder = JSONDecoder()
//let personEntity = try? decoder.decode(PersonData.self, from: data)
//if let personEntity = personEntity {
//    print(personEntity)
//    print(personEntity.person.name)
//}

/* =============== */

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

extension Person: Encodable {
    func encode(to encoder: Encoder) throws {
        var personContainer = encoder.container(keyedBy: PersonKeys.self)
        var personDetailContainer = personContainer.nestedContainer(keyedBy: PersonDetailKeys.self, forKey: .person)

        try personDetailContainer.encode(name, forKey: .name)
        try personDetailContainer.encode(age, forKey: .age)
        try personDetailContainer.encode(page, forKey: .page)
        try personDetailContainer.encodeIfPresent(bio, forKey: .bio)
    }
}

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

let data = Data(json.utf8)
let decoder = JSONDecoder()
let personEntity = try? decoder.decode(Person.self, from: data)
if let personEntity = personEntity {
    print(personEntity)
}

