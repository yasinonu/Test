import Fluent
import Vapor

final class Team: Model, Content {
    static let schema = "teams"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String
    
    @Field(key: "abbreviation")
    var abr: String
    
    @Field(key: "image")
    var image: URL?
    
    // MARK: Changing
    
    @Field(key: "formation")
    var formation: Formation
    
    @Field(key: "budget")
    var budget: Int
    
    @Children(for: \.$team)
    var players: [Player]
    
    @Field(key: "order")
    var order: [UUID]
    
    // MARK: League
    
    @Field(key: "owned")
    var owned: Bool

    init() { }

    init(id: UUID? = nil, title: String, abr: String, image: URL? = nil, formation: Formation = .l422, budget: Int, owned: Bool = false, order: [UUID] = []) {
        self.id = id
        self.title = title
        self.abr = abr
        self.image = image
        self.formation = formation
        self.budget = budget
        self.owned = owned
        self.order = order
    }
}

enum Formation: Int, Codable {
    case l422 = 422
    case l4141 = 4141
    case l532 = 532
    
    var list: [Int] {
        String(rawValue).compactMap(\.wholeNumberValue)
    }
    
    var def: Int {
        switch self {
        case .l422:
            4
        case .l532:
            5
        case .l4141:
            4
        }
    }
    
    var mid: Int {
        switch self {
        case .l422:
            2
        case .l532:
            3
        case .l4141:
            5
        }
    }
    
    var atk: Int {
        switch self {
        case .l422:
            2
        case .l532:
            2
        case .l4141:
            1
        }
    }
}

