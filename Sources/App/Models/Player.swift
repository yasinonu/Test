import Fluent
import Vapor

final class Player: Model, Content {
    static let schema = "players"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String
    
    @Field(key: "age")
    var age: Int
    
    @Field(key: "country")
    var country: Country
    
    @Field(key: "image")
    var image: URL?
    
    @Enum(key: "position")
    var position: Position
    
    @Field(key: "score")
    var score: Int
    
    @Field(key: "injury")
    var injury: Date?

    @OptionalParent(key: "team")
    var team: Team?
    
    @Field(key: "price")
    var price: Int?
    
    init() { }

    init(id: UUID? = nil, name: String, age: Int, country: Country, image: URL? = nil, position: Position, score: Int, injury: Date? = nil) {
        self.id = id
        self.name = name
        self.age = age
        self.image = image
        self.country = country
        self.position = position
        self.score = score
        self.injury = injury
    }
}

enum Position: String, Codable {
    case GK, CB, LB, RB, CM, CDM, CAM, RM, LM, ST, CF, LW, RW
}

enum Country: String, Codable {
    case England, Germany, France, Portugal, Spain, Italy, Brazil, Turkey, Morocco, Kosovo, Netherlands, Philippines, Sweden, Israel, Congo, Poland
    case NorthMacedonia = "North Macedonia"
    case BosniaAndHerzegovina = "Bosnia and Herzegovina"
}
