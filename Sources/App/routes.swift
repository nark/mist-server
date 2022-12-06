import Fluent
import Vapor




func routes(_ app: Application) throws {
    var apiRoutes = app.grouped("api", "v1")
    
    apiRoutes = apiRoutes.grouped(User.authenticator())
    apiRoutes.post("login") { req async throws -> UserToken in
        let user = try req.auth.require(User.self)
        let token = try user.generateToken()
        try await token.save(on: req.db)
        return token
    }
    
    
    apiRoutes = apiRoutes.grouped(UserToken.authenticator())
    apiRoutes.get("me") { req -> User in
        try req.auth.require(User.self)
    }
    
    
    apiRoutes.webSocket("chat") { req, ws in
        ws.onText { ws, text in
            print(req)
            
            ws.send("hello")
            ws.sendPing()
        }
        
        ws.onPing { ws in
            print("ping")
        }
        
        ws.onPong { ws in
            print("pong")
        }
    }
    
    
    try apiRoutes.register(collection: UsersController())
    try apiRoutes.register(collection: FilesController())
}
