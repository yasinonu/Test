import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    try app.register(collection: TeamController())
    try app.register(collection: PlayerController())
    try app.register(collection: MatchController())
}
