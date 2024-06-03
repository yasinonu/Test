import Vapor
import Fluent

final class Match: Model, Content {
    static let schema = "matches"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "home")
    var home: Team
    
    @Field(key: "away")
    var away: Team
    
    @Field(key: "date")
    var date: Date
    
    @Field(key: "actions")
    var actions: [Action]
    
    // MARK: Changing
    
    init() { }
    
    init(id: UUID? = nil, home: Team, away: Team, date: Date) {
        self.id = id
        self.home = home
        self.away = away
        self.date = date
    }
    
    public var homeScore: Int {
        var score = 0
        
        for action in actions {
            switch action {
            case .goal(_, _, let team, _):
                if team.id == home.id {
                    score += 1
                }
            default:
                break
            }
        }
        return score
    }
    
    public var awayScore: Int {
        var score = 0
        
        for action in actions {
            switch action {
            case .goal(_, _, let team, _):
                if team.id == away.id {
                    score += 1
                }
            default:
                break
            }
        }
        return score
    }
}

enum Action: Codable, Identifiable {
    case goal(player: Player, assist: Player?, team: Team, minute: Int)
    case yellowCard(player: Player, team: Team, minute: Int)
    case redCard(player: Player, team: Team, minute: Int)
    case change(in: Player, out: Player, team: Team, minute: Int)
    case over
    
    var id: UUID {
        return UUID()
    }
}
