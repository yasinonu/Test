import Fluent
import Vapor

struct PlayerController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let players = routes.grouped("players")
        players.get(use: index)
        players.post(use: create)
        players.group(":playerID") { player in
            player.get("team", use: fetchTeam)
            player.delete(use: delete)
        }
        players.group("transfer") { transfer in
            transfer.get(use: fetchTransfers)
            transfer.post(use: make)
        }
    }
    
    // MARK: Player

    func index(req: Request) async throws -> [Player] {
        try await Player.query(on: req.db)
            .all()
    }

    func create(req: Request) async throws -> Player {
        let player = try req.content.decode(Player.self)
        try await player.save(on: req.db)
        return player
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let player = try await Player.find(req.parameters.get("playerID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await player.delete(on: req.db)
        return .noContent
    }
    
    func fetchTeam(_ req: Request) async throws -> Team {
        guard let player = try await Player.find(req.parameters.get("playerID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        let team = try await player.$team.get(on: req.db)
        
        return team!
    }
    
    // MARK: Transfer
    
    func fetchTransfers(req: Request) async throws -> [Player] {
        try await Player.query(on: req.db)
            .filter("price", .notEqual, "nil")
            .all()
    }
    
    func make(req: Request) async throws -> Player {
        let transfer = try req.content.decode(TransferPlayer.self)
        
        let player = try await Player.find(transfer.playerID, on: req.db)!
        
        guard let price = player.price else { throw TestError.PlayerNotTransferable }
                                           
        let team = try await Team.find(transfer.teamID, on: req.db)!
        
        guard team.budget >= price else { throw TestError.NotEnoughBudgetError }
        
        team.budget -= price
        player.$team.id = team.id
        player.price = nil
        
        try await player.save(on: req.db)
        try await team.save(on: req.db)
        
        return player
    }
}
