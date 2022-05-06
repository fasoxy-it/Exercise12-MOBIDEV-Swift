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

class Book: Work {}
class Video: Work {}
class Music: Work {}
