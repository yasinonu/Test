import Vapor

struct TransferPlayer: Content {
    let playerID: UUID
    let teamID: UUID
}
