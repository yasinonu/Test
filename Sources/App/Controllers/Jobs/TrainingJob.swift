import Vapor
import Queues

struct TrainingJob: AsyncScheduledJob {
    // Add extra services here via dependency injection, if you need them.

    func run(context: QueueContext) async throws {
        let db = context.application.db
        
        let count = try await Player.query(on: db).count()
        
        let players = try await Player.query(on: db)
            .sort(\.$age)
            .limit(20)
            .all()
        
        print(players.map( { "\($0.name): \($0.score)" } ))
        
        for player in players.randomSample(count: 5) {
            player.score += (1...3).randomElement()!
            try await player.update(on: db)
        }
    }
}
