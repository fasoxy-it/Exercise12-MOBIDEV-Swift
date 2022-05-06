struct Author {
    var name: String
    var surname: String
    var yob: Int?
    var pseudonym: String?
    var works: Array<Work>
    
    init(name: String, surname: String) {
        self.name = name
        self.surname = surname
        works = [Work]()
    }
}

extension Author: CustomStringConvertible {
    var description: String {
        return "\(name) \(surname)"
    }
}

class Work {
    var title: String
    var year: Int
    var author: Author
    
    init(withTitle title: String, createdBy author: Author, createdInYear year: Int) {
        self.title = title
        self.year = year
        self.author = author
    }
}

extension Work: CustomStringConvertible {
    var description: String {
        return "\(title) \(year) \(author)"
    }
}

class Book: Work {}
class Video: Work {}
class Music: Work {}


enum AvailabilityStatus {
    case available
    case rented
    case booked
    case lost
}

enum WorkType: String {
    case book = "book"
    case video = "video"
    case music = "music"
}

protocol Item {
    var availability: AvailabilityStatus {get set}
    var work: Work {get}
}

var author: Author = Author(name: "Mattia", surname: "Fasoli")
var work: Work = Work(withTitle: "appunti", createdBy: author, createdInYear: 2022)

print(author)
print(work)

class Volume {
    var book: Book
    var availability:
}
