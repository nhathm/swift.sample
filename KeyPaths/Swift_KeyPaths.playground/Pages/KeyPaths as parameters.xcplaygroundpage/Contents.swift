import Foundation

func printPersonName(_ person: Person, _ path: KeyPath<Person, String>) {
    print("Person name = \(person[keyPath: path])")
}

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
class Student: Person {
    var className: String
    
    init(_ firstName: String, _ lastName: String, _ age: Int, _ className: String) {
        self.className = className
        super.init(firstName, lastName, age)
    }
}

var firstPerson = Person("Nhat", "Hoang", 10)
var firstStudent = Student("Rio", "Vincente", 20, "Mẫu giáo lớn")
var nameKeyPath = \Person.lastName
var agekeyPath = \Person.age
var studentNameKeyPath = \Student.lastName

printPersonName(firstPerson, nameKeyPath)
//printPersonName(firstPerson, agekeyPath)
//printPersonName(firstStudent, studentNameKeyPath)

print(firstStudent)
