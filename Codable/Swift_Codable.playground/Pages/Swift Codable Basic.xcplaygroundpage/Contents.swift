import UIKit
import Foundation

let json = """
{
    "name": "NhatHM",
    "age": 29,
    "page": "https://magz.techover.io/"
}
"""
struct Person: Codable {
    let name: String
    let age: Int
    let page: URL
    let bio: String?
}


var data = Data(json.utf8)
let decoder = JSONDecoder()
// Decode json with dic
let personEntity = try? decoder.decode(Person.self, from: data)
if let personEntity = personEntity {
    print(personEntity)
}

let jsonArray = """
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
"""

data = Data(jsonArray.utf8)
// Decode json with array
let personArray = try? decoder.decode([Person].self, from: data)
if let personArray = personArray {
    print(personArray[0])
    print(personArray[0].age)
}
