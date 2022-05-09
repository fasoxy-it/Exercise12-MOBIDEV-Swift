import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

struct Author: CustomStringConvertible {
    var name: String
    var surname: String
    var yob: Int?
    var pseudonym: String?
    var works: Array<Work>
    
//    init(name: String, surname: String, yob: Int?, pseudonym: String?) {
//        self.name = name
//        self.surname = surname
//        self.yob = yob
//        self.pseudonym = pseudonym
//        works = [Work]()
//    }
    
    var description: String {
        return "\(name) \(surname) \(yob!)"
    }
}

class Work: CustomStringConvertible {
    var title: String
    var year: Int
    var author: Author?
    
    init(withTitle title: String, createdInYear year: Int) {
        self.title = title
        self.year = year
    }
    
    var description: String {
        return "\(title) \(year)"
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
struct Model {
    let authors: [Author] = []
}

struct AuthorSupportHelperModel {
    let author: Author
    let supports: [Item]
}

struct Library {
    let authors: [Author]
    let supports: [Item]
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
    
    let authorsSupports = (dataParsed["authors"] as? [[String:Any]])?
        .map{(authorDict:[String:Any]) -> AuthorSupportHelperModel in
            
            var works = [Work]()
            var supports = [Item]()
            
            if let workDicts = authorDict["works"] as? [[String:Any]] {
                workDicts.forEach {
                    let workType = WorkType(rawValue: $0["type"] as! String)!
                    switch workType {
                    case .book:
                        works.append(Book(withTitle: $0["title"] as! String, createdInYear: $0["year"] as! Int))
                    case .video:
                        works.append(Video(withTitle: $0["title"] as! String, createdInYear: $0["year"] as! Int))
                    case .music:
                        works.append(Music(withTitle: $0["title"] as! String, createdInYear: $0["year"] as! Int))
                    }
                    if let supportDicts = $0["supports"] as? [[String:Any]] {
                        supportDicts.forEach { supportDict in
                            let associatedWork = works.last!
                            switch associatedWork {
                            case is Book:
                                let numberOfSameSupports = supportDict["item"] as? Int ?? 1
                                for _ in stride(from: 0, to: numberOfSameSupports, by: 1) {
                                    supports.append(((supportDict["digital"] as! Bool) == true) ?
                                        Ebook(forBook: associatedWork as! Book, withSize: (supportDict["size"] as! NSNumber).floatValue) :
                                        Volume(forBook: associatedWork as! Book, pubishedBy: supportDict["publisher"] as! String, withPosition: Position(shelfNumber: Int(supportDict["shelfNumber"] as! String)!, shelfPosition: Int(supportDict["shelfPosition"] as! String)!))
                                    )
                                }
                            case is Video:
                                let numberOfSameSupports = supportDict["item"] as? Int ?? 1
                                for _ in stride(from: 0, to: numberOfSameSupports, by: 1) {
                                    supports.append(Dvd(forVideo: associatedWork as! Video, dvdNumber: supportDict["number"] as! Int, withPosition: Position(shelfNumber: Int(supportDict["shelfNumber"] as! String)!, shelfPosition: Int(supportDict["shelfPosition"] as! String)!)))
                                }
                            case is Music:
                                let numberOfSameSupports = supportDict["item"] as? Int ?? 1
                                for _ in stride(from: 0, to: numberOfSameSupports, by: 1) {
                                    supports.append(Cd(forMusic: associatedWork as! Music, withTracksNumber: supportDict["tracks"] as! Int, withPosition: Position(shelfNumber: Int(supportDict["shelfNumber"] as! String)!, shelfPosition: Int(supportDict["shelfPosition"] as! String)!)))
                                }
                            default:
                                break
                            }
                        }
                    }
                }
            }
            
            let author = Author(
                name: authorDict["name"] as! String,
                surname: authorDict["surname"] as! String,
                yob: authorDict["yob"] as? Int,
                pseudonym: authorDict["pseudonym"] as? String,
                works: works
            )
            
            author.works.forEach{$0.author = author}
            
            return AuthorSupportHelperModel(author: author, supports: supports)
        }
    
    guard let authorsSupportsRecords = authorsSupports else {return}

    let allAuthors = authorsSupportsRecords
        .compactMap{$0.author}
    let allSupports = authorsSupportsRecords
        .compactMap{$0.supports}
        .flatMap{$0}

    let myLibrary = Library(authors: allAuthors, supports: allSupports)
})

task.resume()



