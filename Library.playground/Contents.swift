struct Author: CustomStringConvertible {
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
    
    var description: String {
        return "\(name) \(surname)"
    }
}

class Work: CustomStringConvertible {
    var title: String
    var year: Int
    var author: Author
    
    init(withTitle title: String, createdBy author: Author, createdInYear year: Int) {
        self.title = title
        self.year = year
        self.author = author
    }
    
    var description: String {
        return "\(title) \(author) \(year)"
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

struct Position: CustomStringConvertible {
    var shelfNumber: Int
    var shelfPosition: Int
    
    var description: String {
        return "\(shelfNumber) \(shelfPosition)"
    }
}

protocol PhysicalItem: Item {
    var position: Position {get set}
}

var author: Author = Author(name: "Mattia", surname: "Fasoli")
var work: Work = Work(withTitle: "Appunti MOBIDEV", createdBy: author, createdInYear: 2022)
var book: Book = Book(withTitle: "Appunti MC", createdBy: author, createdInYear: 2019)
var position: Position = Position(shelfNumber: 2, shelfPosition: 3)

class Volume: PhysicalItem, CustomStringConvertible {
    var book: Book
    var publisher: String
    var position: Position
    var availability: AvailabilityStatus
    
    init(forBook book: Book, pubishedBy publisher: String, withPosition position: Position) {
        self.book = book
        self.publisher = publisher
        self.position = position
        self.availability = .available
    }
    
    var work: Work {
        return book
    }
    
    var description: String {
        return "\(book) \(publisher) \(position)"
    }
}

var volume: Volume = Volume(forBook: book, pubishedBy: "UNIMI", withPosition: position)

print(volume)

class Ebook: Item, CustomStringConvertible {
    var book: Book
    var size: Float
    var availability: AvailabilityStatus

    init(forBook book: Book, withSize size: Float) {
        self.book = book
        self.size = size
        self.availability = .available
    }
    
    var work: Work {
        return book
    }
    
    var description: String {
        return "\(book) \(size)"
    }
}

var ebook: Ebook = Ebook(forBook: book, withSize: 35.55)

print(ebook)

class Dvd: PhysicalItem, CustomStringConvertible {
    var video: Video
    var number: Int
    var position: Position
    var availability: AvailabilityStatus
    
    init(forVideo video: Video, dvdNumber number: Int, withPosition position: Position) {
        self.video = video
        self.number = number
        self.position = position
        self.availability = .available
    }
    
    var work: Work {
        return video
    }
    
    var description: String {
        return "\(video) \(number) \(position)"
    }
}

var video: Video = Video(withTitle: "Appunti MC: Swift", createdBy: author, createdInYear: 2002)
var dvd: Dvd = Dvd(forVideo: video, dvdNumber: 7, withPosition: Position(shelfNumber: 20, shelfPosition: 30))

print(dvd)

class Cd: PhysicalItem, CustomStringConvertible {
    var music: Music
    var tracks: Int
    var position: Position
    var availability: AvailabilityStatus
    
    init(forMusic music: Music, withTracksNumber tracks: Int, withPosition position: Position) {
        self.music = music
        self.tracks = tracks
        self.position = position
        self.availability = .available
    }
    
    var work: Work {
        return music
    }
    
    var description: String {
        return "\(music) \(tracks) \(position)"
    }
}

var music: Music = Music(withTitle: "Appunti MC: Android", createdBy: author, createdInYear: 2022)
var cd: Cd = Cd(forMusic: music, withTracksNumber: 1, withPosition: Position(shelfNumber: 13, shelfPosition: 13))

print(cd)
