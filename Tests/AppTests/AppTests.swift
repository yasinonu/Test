@testable import App
import XCTVapor

final class AppTests: XCTestCase {
    func testHelloWorld() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configure(app)
        
        // MARK: Create Player, Team, Transfer
        
        // Player
        
        var playerID: UUID? = nil
        
        try app.test(.POST, "players", beforeRequest: { req in
            let player = Player(name: "Noni Madueke", age: 21, country: .England, position: .LM, score: 81)
            
            try req.content.encode(player)
        }, afterResponse: { res in
            let player = try res.content.decode(Player.self)
            playerID = player.id
        })
        
        try app.test(.GET, "players") { res in
            let players = try res.content.decode([Player].self)
            XCTAssertEqual(players.count, 1)
        }
        
        // Team
        
        var teamID: UUID? = nil
        
        try app.test(.POST, "teams", beforeRequest: { req in
            try req.content.encode(["title": "Beşiktaş JK"])
        }, afterResponse: { res in
            let team = try res.content.decode(Team.self)
            teamID = team.id
        })
        
        try app.test(.GET, "teams") { res in
            let teams = try res.content.decode([Team].self)
            XCTAssertEqual(teams.count, 1)
        }
        
        // Transfer
        
        try app.test(.POST, "players/transfer", beforeRequest: { req in
            try req.content.encode([
                "playerID": playerID!.uuidString,
                "teamID": teamID!.uuidString
            ])
        }, afterResponse: { res in
            let transferredPlayer = try res.content.decode(Player.self)
            
            XCTAssertEqual(transferredPlayer.$team.id, teamID)
            
            print("Transferred Player: \(transferredPlayer.name)")
        })
        
//        try app.test(.GET, "teams/\(String(describing: teamID))/players") { res in
//            
//        }
    }
}
