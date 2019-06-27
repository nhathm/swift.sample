import UIKit
import Foundation

let json = """
{
    "first_name": "Nhat",
    "last_name": "Hoang",
    "age": 29,
    "dob": "1990-01-01T14:12:41+0700",
    "page": "https://magz.techover.io/"
}
"""

struct Person: Codable {
    var firstName: String
    var lastName: String
    var age: Int
    var dob: Date
    var page: URL
    var bio: String?
}

let data = Data(json.utf8)
let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase
decoder.dateDecodingStrategy = .iso8601

do {
    let personEntity = try decoder.decode(Person.self, from: data)
    print(personEntity)
} catch {
    print(error)
}

/* =============== */

//func dateFormatter() -> DateFormatter {
//    let formatter = DateFormatter()
//    formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
//    return formatter
//}

//let json = """
//{
//    "first_name": "Nhat",
//    "last_name": "Hoang",
//    "age": 29,
//    "dob": "1990/01/01 14:12:41",
//    "page": "https://magz.techover.io/"
//}
//"""
//
//struct Person: Codable {
//    var firstName: String
//    var lastName: String
//    var age: Int
//    var dob: Date
//    var page: URL
//    var bio: String?
//}
//
//let data = Data(json.utf8)
//let decoder = JSONDecoder()
//decoder.keyDecodingStrategy = .convertFromSnakeCase
//decoder.dateDecodingStrategy = .formatted(dateFormatter())
//
//do {
//    let personEntity = try decoder.decode(Person.self, from: data)
//    print(personEntity)
//} catch {
//    print(error)
//}
//
