import UIKit
import Foundation

let json = """
{
    "person_detail": {
        "first_name": "Nhat",
        "last_name": "Hoang",
        "age": 29,
        "page": "https://magz.techover.io/"
    }
}
"""

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

extension Person: Encodable {
    func encode(to encoder: Encoder) throws {
        var personContainer = encoder.container(keyedBy: PersonKeys.self)
        var personDetailContainer = personContainer.nestedContainer(keyedBy: PersonDetailKeys.self, forKey: .person)
        
        try personDetailContainer.encode(firstName, forKey: .firstName)
        try personDetailContainer.encode(lastName, forKey: .lastName)
        try personDetailContainer.encode(page, forKey: .page)
        try personDetailContainer.encodeIfPresent(bio, forKey: .bio)
    }
}

extension Person: Decodable {
    init(from decoder: Decoder) throws {
        let personContainer = try decoder.container(keyedBy: PersonKeys.self)
        
        let personDetailContainer = try personContainer.nestedContainer(keyedBy: PersonDetailKeys.self, forKey: .person)
        firstName = try personDetailContainer.decode(String.self, forKey: .firstName)
        lastName = try personDetailContainer.decode(String.self, forKey: .lastName)
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
