import UIKit
import Foundation

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

