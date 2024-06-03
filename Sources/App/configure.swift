import NIOSSL
import Fluent
import FluentSQLiteDriver
import Vapor
import QueuesRedisDriver
import APNS
import VaporAPNS
import APNSCore

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(DatabaseConfigurationFactory.sqlite(.file("db.sqlite")), as: .sqlite)

    app.migrations.add(CreateTeam())
    app.migrations.add(CreatePlayer())
    app.migrations.add(CreateMatch())
    
//     try await app.autoRevert()
    try await app.autoMigrate()
    
    // queues
    try app.queues.use(.redis(url: "redis://127.0.0.1:6379"))

    let matchJob = MatchJob()
    app.queues.add(matchJob)
    
    app.queues.schedule(TrainingJob())
        .daily()
        .at(.midnight)
//        .everySecond()  TODO
    
    try app.queues.startInProcessJobs(on: .default)
    try app.queues.startScheduledJobs()
    
    // apns
//    let apnsConfig = APNSClientConfiguration(
//        authenticationMethod: .jwt(
//            privateKey: try .loadFrom(string: "AuthKey_A77MCC3Y89.p8"),
//            keyIdentifier: "A77MCC3Y89",
//            teamIdentifier: "4C8Y3ZS6C8"
//        ),
//        environment: .sandbox
//    )
//    app.apns.containers.use(
//        apnsConfig,
//        eventLoopGroupProvider: .shared(app.eventLoopGroup),
//        responseDecoder: JSONDecoder(),
//        requestEncoder: JSONEncoder(),
//        as: .default
//    )
    
    // register routes
    try routes(app)
}
