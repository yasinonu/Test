import Vapor

struct TransferRequest: Content {
    let playerID: Player.IDValue
    let cost: Int
    
    let buyer: Team.IDValue
    let seller: Team.IDValue
}
