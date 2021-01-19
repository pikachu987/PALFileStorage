//Copyright (c) 2021 pikachu987 <pikachu77769@gmail.com>
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.

import Foundation

open class FileStorage: NSObject {
    public static let shared = FileStorage()

    open class var fileManager: FileManager {
        return self.shared.fileManager
    }
    
    open var fileManager: FileManager {
        return FileManager.default
    }
    
    open class var documentsURL: URL {
        return self.shared.documentsURL
    }
    
    open var documentsURL: URL {
        return self.fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    open class var totalSize: Double {
        return self.shared.totalSize()
    }
    
    open var totalSize: Double {
        return self.totalSize()
    }
    
    open class func fileType(_ path: String) -> FileType {
        return self.shared.fileType(path)
    }
    
    open func fileType(_ path: String) -> FileType {
        let filePath = self.documentsURL.appendingPathComponent(path)
        var isDir: ObjCBool = false
        if self.fileManager.fileExists(atPath: filePath.path, isDirectory: &isDir) {
            return isDir.boolValue ? .folder : .file
        } else {
            return .empty
        }
    }
    
    @discardableResult
    open class func createFolder(_ folderName: String) -> Result<Void, Error> {
        return self.shared.createFolder(folderName)
    }

    @discardableResult
    open func createFolder(_ folderName: String) -> Result<Void, Error> {
        let filePath = self.documentsURL.appendingPathComponent(folderName)
        let fileType = self.fileType(filePath.path)
        if fileType == .empty {
            do {
                try self.fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
                return .success(())
            } catch(let error) {
                return .failure(error)
            }
        } else if fileType == .folder {
            return .success(())
        } else {
            return .failure(NSError(domain: "This file is don't folder", code: 503, userInfo: nil) as Error)
        }
    }
    
    open class func createFolder(_ folderName: [String]) {
        self.shared.createFolder(folderName)
    }
    
    open func createFolder(_ folderNames: [String]) {
        folderNames.forEach({ self.createFolder($0) })
    }
    
    @discardableResult
    open class func save(_ data: Data, fileName: String, folderName: String, options: Data.WritingOptions = [.atomic]) -> Result<Void, Error> {
        return self.shared.save(data, fileName: fileName, folderName: folderName, options: options)
    }
    
    @discardableResult
    open func save(_ data: Data, fileName: String, folderName: String, options: Data.WritingOptions = [.atomic]) -> Result<Void, Error> {
        self.createFolder(folderName)
        let path = self.updateName(fileName: fileName, folderName: folderName)
        let url = self.documentsURL.appendingPathComponent(path)
        do {
            try data.write(to: url, options: options)
            return .success(())
        } catch (let error) {
            return .failure(error)
        }
    }
    
    @discardableResult
    open class func deleteFile(_ fileName: String, folderName: String) -> Result<Void, Error> {
        return self.shared.deleteFile(fileName, folderName: folderName)
    }
    
    @discardableResult
    open func deleteFile(_ fileName: String, folderName: String) -> Result<Void, Error> {
        let path = self.updateName(fileName: fileName, folderName: folderName)
        let filePath = self.documentsURL.appendingPathComponent(path)
        if self.fileManager.fileExists(atPath: filePath.path) {
            do {
                try self.fileManager.removeItem(at: filePath)
                return .success(())
            } catch(let error) {
                return .failure(error)
            }
        } else {
            return .success(())
        }
    }
    
    @discardableResult
    open class func deleteFolder(_ folderName: String) -> Result<[URL], Error> {
        self.shared.deleteFolder(folderName)
    }
    
    @discardableResult
    open func deleteFolder(_ folderName: String) -> Result<[URL], Error> {
        let url = self.documentsURL.appendingPathComponent(folderName)
        let contents: [URL] = (try? self.fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)) ?? []
        do {
            try self.fileManager.removeItem(at: self.documentsURL.appendingPathComponent(folderName))
            return .success(contents)
        } catch (let error) {
            return .failure(error)
        }
    }
    
    open class func makeOverlapFileName(_ fileName: String, folderName: String) -> String {
        return self.shared.makeOverlapFileName(fileName, folderName: folderName)
    }
    
    open func makeOverlapFileName(_ fileName: String, folderName: String) -> String {
        var folderName = folderName
        if folderName.hasSuffix("/") {
            folderName.removeLast()
        }
        let fileNameList = fileName.components(separatedBy: ".")
        var fileName = fileNameList.enumerated().filter({ $0.offset < fileNameList.count - 1 }).map({ $0.element }).joined(separator: ".")
        let fileExt = fileNameList.last ?? ""
        if fileName.hasPrefix("/") {
            fileName.removeFirst()
        }
        return self.makeFilename(fileName, fileExt: fileExt, folderName: folderName)
    }
    
    private func makeFilename(_ fileName: String, fileExt: String, folderName: String, seperator: Int = 0) -> String {
        let afterExt = seperator == 0 ? ".\(fileExt)" : "_\(seperator).\(fileExt)"
        let makeFileName = "\(fileName)\(afterExt)"
        let path = folderName != "" && makeFileName != "" ? "\(folderName)/\(makeFileName)" : "\(folderName)\(makeFileName)"
        let filePath = self.documentsURL.appendingPathComponent(path)
        if !self.fileManager.fileExists(atPath: filePath.path) {
            return makeFileName
        } else {
            return self.makeFilename(fileName, fileExt: fileExt, folderName: folderName, seperator: seperator + 1)
        }
    }
    
    open class func totalSize(_ folderName: String = "") -> Double {
        return self.shared.totalSize(folderName)
    }
    
    open func totalSize(_ folderName: String = "") -> Double {
        let size = (try? self.documentsURL.appendingPathComponent(folderName).directoryTotalAllocatedSize()) ?? 0
        return Double(size)
    }
    
    open class func totalSize(_ folderName: [String]) -> Double {
        return self.shared.totalSize(folderName)
    }
    
    open func totalSize(_ folderNames: [String]) -> Double {
        let size = folderNames.map({ self.totalSize($0) }).reduce(0, +)
        return Double(size)
    }
    
    private func updateName(fileName: String, folderName: String) -> String {
        var folderName = folderName
        if folderName.hasSuffix("/") {
            folderName.removeLast()
        }
        var fileName = fileName
        if fileName.hasPrefix("/") {
            fileName.removeFirst()
        }
        if folderName != "" && fileName != "" {
            return "\(folderName)/\(fileName)"
        } else {
            return "\(folderName)\(fileName)"
        }
    }
    
    private func pathSplit(_ path: String) -> (fileName: String, folderName: String) {
        var path = path
        if path.hasSuffix("/") {
            path.removeLast()
        }
        var folderName = ""
        var fileName = ""
        if path.contains("/") {
            let paths = path.components(separatedBy: "/")
            fileName = paths.last ?? path
            folderName = paths.enumerated().filter({ $0.offset < paths.count - 1 }).map({ $0.element }).joined(separator: "/")
        } else {
            folderName = ""
            fileName = path
        }
        return (fileName: fileName, folderName: folderName)
    }
    
    open class func file(_ path: String, recursion: Bool = false) -> FileNode? {
        return self.shared.file(path, recursion: recursion)
    }
    
    open func file(_ path: String, recursion: Bool = false) -> FileNode? {
        let path = self.pathSplit(path)
        return self.file(path.fileName, folderName: path.folderName, recursion: recursion)
    }
    
    open class func file(_ fileName: String, folderName: String, recursion: Bool = false) -> FileNode? {
        return self.shared.file(fileName, folderName: folderName, recursion: recursion)
    }
    
    open func file(_ fileName: String, folderName: String, recursion: Bool = false) -> FileNode? {
        let path = self.updateName(fileName: fileName, folderName: folderName)
        let fileType = self.fileType(path)
        if fileType == .empty {
            return nil
        } else if fileType == .file {
            let url = self.documentsURL.appendingPathComponent(path)
            guard let data = self.fileManager.contents(atPath: url.path) else { return nil }
            return File(fileName: fileName, folderName: folderName, data: data)
        } else {
            let url = self.documentsURL.appendingPathComponent(path)
            var folder = Folder(fileName: fileName, folderName: folderName)
            guard let directorys = try? self.fileManager.contentsOfDirectory(atPath: url.path) else { return folder }
            if recursion {
                folder.files = directorys.compactMap({ self.file($0, folderName: path, recursion: recursion) })
            } else {
                folder.files = directorys.compactMap({
                    let fileType = self.fileType("\(path)/\($0)")
                    if fileType == .file {
                        let url = self.documentsURL.appendingPathComponent("\(path)/\($0)")
                        guard let data = self.fileManager.contents(atPath: url.path) else { return nil }
                        return File(fileName: $0, folderName: path, data: data)
                    } else if fileType == .folder {
                        return Folder(fileName: $0, folderName: path)
                    } else {
                        return nil
                    }
                })
            }
            return folder
        }
    }
}
