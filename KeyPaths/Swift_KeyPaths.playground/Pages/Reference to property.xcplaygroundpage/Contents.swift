import Foundation

class Person {
    var firstName: String
    var lastName: String
    var age: Int
    
    init(_ firstName: String, _ lastName: String, _ age: Int) {
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
    }
}

var firstPerson: Person? = Person("Nhat", "Hoang", 10)

var nameKeyPaths = \Person.firstName
var refVar = firstPerson?.firstName

print("refVar value = \(refVar ?? "refVar nil")")
print("KeyPaths value = \(firstPerson?[keyPath: nameKeyPaths] ?? "nil")")
print("----------")

firstPerson = nil
print("refVar value = \(refVar ?? "refVar nil")")
print("KeyPaths value = \(firstPerson?[keyPath: nameKeyPaths] ?? "nil")")
print("----------")

refVar = nil
print("refVar value = \(refVar ?? "refVar nil")")
