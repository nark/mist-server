import Fluent
import Vapor
import NIOCore

struct FilesController: RouteCollection {
    let logger = Logger(label: "FilesController")

    func boot(routes: RoutesBuilder) throws {
        let files = routes.grouped("files")
        routes.on(.POST, "files", body: .stream, use: upload)
        routes.on(.GET,  "files", use: index)
        routes.on(.GET,  "files", ":fileID", use: getOne)
        routes.on(.GET,  "files", ":fileID", "download", use: downloadOne)
        files.group(":fileID") { file in
            file.delete(use: delete)
        }
    }
    
    
    func index(req: Request) async throws -> [StreamModel] {
        try req.auth.require(User.self)
        
        return try await StreamModel.query(on: req.db).all()
    }
    
    
    func getOne(req: Request) async throws -> StreamModel {
        guard let model = try await StreamModel.find(req.parameters.get("fileID"), on: req.db) else {
            throw Abort(.badRequest)
        }
        return model
    }
    
    /// Streaming download comes with Vapor “out of the box”.
    /// Call `req.fileio.streamFile` with a path and Vapor will generate a suitable Response.
    func downloadOne(req: Request) async throws -> Response {
        let upload = try await getOne(req: req)
        return req.fileio.streamFile(at: upload.filePath(for: req.application))
    }

    
    func upload(req: Request) async throws -> some AsyncResponseEncodable {
        try req.auth.require(User.self)
        
        let logger = Logger(label: "FilesController.upload")
        // Create a file on disk based on our `Upload` model.
        let fileName = filename(with: req.headers)
        let upload = StreamModel(fileName: fileName)
        let filePath = upload.filePath(for: req.application)
        
        // Remove any file with the same name
        try? FileManager.default.removeItem(atPath: filePath)
        guard FileManager.default.createFile(atPath: filePath,
                                       contents: nil,
                                       attributes: nil) else {
            logger.critical("Could not upload \(upload.fileName)")
            throw Abort(.internalServerError)
        }
        let nioFileHandle = try NIOFileHandle(path: filePath, mode: .write)
        defer {
            do {
                try nioFileHandle.close()
            } catch {
                logger.error("\(error.localizedDescription)")
            }
        }
        do {
            var offset: Int64 = 0
            for try await byteBuffer in req.body {
                do {
                    try await req.application.fileio.write(fileHandle: nioFileHandle,
                                                           toOffset: offset,
                                                           buffer: byteBuffer,
                                                           eventLoop: req.eventLoop).get()
                    offset += Int64(byteBuffer.readableBytes)
                } catch {
                    logger.error("\(error.localizedDescription)")
                }
            }
            try await upload.save(on: req.db)
        } catch {
            try FileManager.default.removeItem(atPath: filePath)
            logger.error("File save failed for \(filePath)")
            throw Abort(.internalServerError)
        }
        logger.info("saved \(upload)")
        return "Saved \(upload)"
    }
    

    func delete(req: Request) async throws -> HTTPStatus {
        try req.auth.require(User.self)
        
//        let path = try req.query.get(String.self, at: "path")
//        let fullpath = req.application.directory.publicDirectory + path
//        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
//            throw Abort(.notFound)
//        }
//        try await user.delete(on: req.db)

        return .noContent
    }
}
