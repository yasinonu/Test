import Vapor
import Fluent
import Queues

struct MatchController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let matches = routes.grouped("matches")
        
        matches.get(use: index)
        matches.post(use: create)
        matches.delete(use: deleteAll)
        
        matches.group(":matchID") { match in
            match.get(use: fetch)
            match.delete(use: delete)
            match.webSocket("ws", onUpgrade: websocket)
        }
        
        matches.group("team") { team in
            team.get(":teamID", use: fetchByTeam)
        }
    }
    
    // MARK: Matches

    func index(req: Request) async throws -> [Match] {
        try await Match.query(on: req.db).all()
    }

    func create(req: Request) async throws -> Match {
        let match = try req.content.decode(Match.self)
        try await match.save(on: req.db)
        
        print("Created and queued match.")
        
        try await req.queue
            .dispatch(MatchJob.self, match, delayUntil: match.date)
        
        return match
    }
    
    func fetch(req: Request) async throws -> Match {
        guard let match = try await Match.find(req.parameters.get("matchID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return match
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let match = try await Match.find(req.parameters.get("matchID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await match.delete(on: req.db)
        return .noContent
    }
    
    func deleteAll(req: Request) async throws -> HTTPStatus {
        try await Match.query(on: req.db).delete()
        return .noContent
    }
    
    func fetchByTeam(req: Request) async throws -> [Match] {
        let teamID = req.parameters.get("teamID")
        return try await Match.query(on: req.db).all()
            .filter({
                $0.home.id?.uuidString == teamID || $0.away.id?.uuidString == teamID
            })
    }
    
    func websocket(req: Request, ws: WebSocket) async {
        print(ws)
        let id = req.parameters.get("matchID")
        
        
    }
}
