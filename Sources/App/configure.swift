import Fluent
import FluentSQLiteDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    let logger = Logger(label: "configure")

    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

    app.migrations.add(StreamModel.Migration())
    
    app.migrations.add(Chat.Migration())
    
    app.migrations.add(Role.Migration())
    app.migrations.add(UserRole.Migration())

    app.migrations.add(User.Migration())
    app.migrations.add(UserToken.Migration())
    
    app.migrations.add(Chat.Seed())
    app.migrations.add(User.Seed())
    
    try app.autoMigrate().wait()
    
    // configure upload dir
    let configuredDir = configureUploadDirectory(for: app)
    configuredDir.whenFailure { err in
        logger.error("Could not create uploads directory \(err.localizedDescription)")
    }
    configuredDir.whenSuccess { dirPath in
        logger.info("created upload directory at \(dirPath)")
    }
    
    // register routes
    try routes(app)
}
