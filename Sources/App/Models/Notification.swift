import Vapor
import Fluent

final class Notification: Model, Content {
    static let schema = "notifications"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "team")
    var team: Team.IDValue
    
    @Field(key: "content")
    var content: String
    
    @Field(key: "type")
    var type: NotificationType
}

enum NotificationType: String, Codable {
    case general, training, transfer
}
