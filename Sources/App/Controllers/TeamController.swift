import Fluent
import Vapor

struct TeamController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let teams = routes.grouped("teams")
        teams.get(use: index)
        teams.post(use: create)
        teams.group(":teamID") { team in
            team.get(use: fetch)
            team.get("players", use: fetchPlayers)
            team.post("reorder", use: reorderPlayers)
            team.delete(use: delete)
            
            team.post("upload", use: uploadPlayers)
        }
        teams.post("upload", use: uploadTeams)
        teams.get("free", use: fetchFree)
        teams.post("purchase", use: purchaseClub)
    }

    func index(req: Request) async throws -> [Team] {
        try await Team.query(on: req.db).all()
    }

    func create(req: Request) async throws -> Team {
        let team = try req.content.decode(Team.self)
        try await team.save(on: req.db)
        return team
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let team = try await Team.find(req.parameters.get("teamID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await team.delete(on: req.db)
        return .noContent
    }
    
    func fetch(req: Request) async throws -> Team {
        guard let team = try await Team.find(req.parameters.get("teamID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        return team
    }
    
    func fetchPlayers(req: Request) async throws -> [Player] {
        guard let team = try await Team.find(req.parameters.get("teamID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        let order = team.order
        print("Order: \(order)")
        let players = try await team.$players.query(on: req.db).all()
        
        return players.sorted(by: { a, b in
            return order.firstIndex(where: { $0 == a.id }) ?? 0 < order.firstIndex(where: { $0 == b.id }) ?? 0
        })
    }
    
    func reorderPlayers(req: Request) async throws -> Team {
        guard let team = try await Team.find(req.parameters.get("teamID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        let order = try req.content.decode([UUID].self)
        
        print("Reordering.")
        print(order)
        
        team.order = order
        // team.players = order
        try await team.update(on: req.db)
        
        return team
    }
    
    // MARK: Setup
    
    func uploadTeams(req: Request) async throws -> HTTPStatus {
        struct Input: Content {
            var file: File
        }
        let input = try req.content.decode(Input.self)
        
        let str = String(buffer: input.file.data)
        let lines = str.split(separator: "\r\n")
        for line in lines {
            let elements = line.split(separator: ";")
            let title = String(elements[0])
            print("Saved: \(title)")
            let abr = String(elements[1])
            let image = URL(string: String(elements[2]))
            let budget = Int(elements[3]) ?? 0
            
            let team = Team(title: title, abr: abr, image: image, budget: budget)
            try await team.save(on: req.db)
        }
        
        return .created
    }
    
    func uploadPlayers(req: Request) async throws -> HTTPStatus {
        struct Input: Content {
            var file: File
        }
        let teamID = UUID(uuidString: req.parameters.get("teamID")!)
        
        guard let _ = try await Team.find(teamID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        let input = try req.content.decode(Input.self)
        
        let str = String(buffer: input.file.data)
        let lines = str.split(separator: "\r\n")
        for line in lines {
            let elements = line.split(separator: ";")
            let name = String(elements[0])
            print("Saved: \(name)")
            let age = Int(elements[1]) ?? 0
            let country = Country(rawValue: (String(elements[2])))!
            let image = URL(string: String(elements[3]))
            let position = Position(rawValue: String(elements[4]))!
            let score = Int(elements[5]) ?? 0
            
            let player = Player(name: name, age: age, country: country, image: image, position: position, score: score)
            player.$team.id = teamID
            try await player.save(on: req.db)
        }
        
        return .created
    }
    
    func fetchFree(req: Request) async throws -> [Team] {
        let teams = try await Team.query(on: req.db)
            .all()
        
        return teams.filter({$0.owned == false})
    }
    
    func purchaseClub(req: Request) async throws -> Team {
        let contract = try req.content.decode(PurchaseTeam.self)
        
        guard let team = try await Team.query(on: req.db)
            .filter(\.$title == contract.team)
            .first()
        else {
            throw Abort(.notFound)
        }
        
        team.owned = true
        try await team.save(on: req.db)
        
        return team
    }
}
