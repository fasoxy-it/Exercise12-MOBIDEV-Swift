import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

struct Author: CustomStringConvertible {
    var name: String
    var surname: String
    var yob: Int?
    var pseudonym: String?
    var works: Array<Work>
    
    init(name: String, surname: String, yob: Int?, pseudonym: String?) {
        self.name = name
        self.surname = surname
        self.yob = yob
        self.pseudonym = pseudonym
        works = [Work]()
    }
    
    var description: String {
        return "\(name) \(surname) \(yob!)"
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

let url = "https://ewserver.di.unimi.it/mobicomp/esercizi/library.json"
guard let dataUrl = URL(string: url) else {
    fatalError("Wrong Url Format")
}

struct AuthorSupportHelperModel {
    let author: Author
}

let session = URLSession.shared
let request = URLRequest(url: dataUrl)

let task = session.dataTask(with: request, completionHandler: {data, response, error in
    
    guard error == nil else {
        print("Connection error: \(error!)")
        return
    }

    guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode == 200 else {
        print("Status code different from OK")
        return
    }
    
    guard let dataFromServer = data, let dataParsed = try? JSONSerialization.jsonObject(with: dataFromServer, options: []) as? Dictionary<String, Any> else {
        print("Can't deserialised answer from server")
        return
    }
    
    let authorItem = (dataParsed["authors"] as? [[String:Any]])?
        .map{(authorDict:[String:Any]) -> AuthorSupportHelperModel in
            
            let author = Author(
                name: authorDict["name"] as! String,
                surname: authorDict["surname"] as! String,
                yob: authorDict["yob"] as? Int,
                pseudonym: authorDict["pseudonym"] as? String
            )
            
            if let yob = author.yob, let pseudonym = author.pseudonym  {
                print("\(author.name) \(author.surname) \(yob) \(pseudonym)")
            }
            
            return AuthorSupportHelperModel(author: author)
        }
    
})

task.resume()

