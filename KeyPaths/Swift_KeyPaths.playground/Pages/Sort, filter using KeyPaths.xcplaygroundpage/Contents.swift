import Foundation

enum Order {
    case ascending
    case descending
}

enum CompareCondition {
    case equal
    case greater
    case less
}

func printListPersonsDescription(_ listPersons: [Person]) {
    for person in listPersons {
        print("\(person.firstName) - \(person.lastName) - \(person.age)" )
    }
}

class Person {
    var firstName: String
    var lastName: String
    var age: Int
    var workingYear: Int
    
    init(_ firstName: String, _ lastName: String, _ age: Int) {
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
        self.workingYear = 0
    }
}

extension Sequence {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>, order: Order) -> [Element] {
        return sorted { a, b in
            switch order {
            case .ascending:
                return a[keyPath: keyPath] < b[keyPath: keyPath]
            case .descending:
                fallthrough
            default:
                return a[keyPath: keyPath] > b[keyPath: keyPath]
            }
        }
    }
    
    func filter(by keyPath: KeyPath<Element, Int>, condition: CompareCondition, compareValue: Int) -> [Element] {
        switch condition {
        case .greater:
            return filter { $0[keyPath: keyPath] > compareValue }
        case .less:
            return filter { $0[keyPath: keyPath] < compareValue }
        default:
            return filter { $0[keyPath: keyPath] == compareValue}
        }
        
    }
}

let listPersons: [Person] = [Person("Alex", "X", 1),
                             Person("Bosh", "Bucus", 12),
                             Person("David", "Lipis", 20),
                             Person("Why", "Always Me", 69),
                             Person("Granado", "Espada", 45),
                             Person("Granado", "Espada", 46)]

let sortedPersons = listPersons.sorted {
    $0.firstName < $1.firstName
}
printListPersonsDescription(sortedPersons)
print("-----")
var sortedFirstNamePersons = listPersons.sorted(by: \.firstName, order: .descending)
printListPersonsDescription(sortedFirstNamePersons)
print("-----")
var filteredPersons = listPersons.filter(by: \.age, condition: .greater, compareValue: 18)
printListPersonsDescription(filteredPersons)
