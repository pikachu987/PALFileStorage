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

public protocol FileStorage {
    var rootFolderName: String { get }
    var documentURL: URL { get }
    var fileManager: FileManager { get }
}

extension FileStorage {
    public var rootFolderName: String { "" }
    public var fileManager: FileManager { FileManager.default }
    public var documentURL: URL { fileManager.urls(for: .documentDirectory, in: .userDomainMask).first ?? .init(fileURLWithPath: "") }

    public func fileType(name: String) -> FileType {
        let fullPath = rootFolderPath.append(path: name)
        return fileType(fullPath: fullPath)
    }

    public func fileType(fullPath path: URL) -> FileType {
        fileType(fullPath: path.path)
    }

    public func fileType(fullPath path: String) -> FileType {
        var isDir: ObjCBool = false
        if fileManager.fileExists(atPath: path, isDirectory: &isDir) {
            return isDir.boolValue ? .folder : .file
        } else {
            return .empty
        }
    }

    public func totalSize(name: String = "") -> Double {
        let size = (try? rootFolderPath.append(path: name).directoryTotalAllocatedSize()) ?? 0
        return Double(size)
    }

    public func makeName(name: String = "", parentFolderName: String = "") -> String {
        if name.isEmpty {
            return internalMakeName("", ext: "", parentFolderName: parentFolderName)
        } else {
            let nameList = name.components(separatedBy: ".")
            if nameList.count == 1 {
                return internalMakeName(name, ext: "", parentFolderName: parentFolderName)
            }
            let name = nameList.enumerated()
                .filter { $0.offset < nameList.count - 1 }
                .map { $0.element }
                .joined(separator: ".")
            let ext = nameList.count > 1 ? (nameList.last ?? "") : ""
            let makeExt = ext.isEmpty ? "" : ".\(ext)"
            return internalMakeName(name, ext: makeExt, parentFolderName: parentFolderName)
        }
    }

    @discardableResult
    public func createFolder(name: String) -> Result<URL, FileError> {
        let filePath = rootFolderPath.append(path: name)
        switch fileType(fullPath: filePath.path) {
        case .empty:
            if let error = internalCreateRootFolder() {
                return .failure(error)
            }
            var path = rootFolderPath
            for folderPath in name.removeSlash.components(separatedBy: "/") {
                path = path.append(path: folderPath)
                if let error = internalCreateFolder(fullPath: path) {
                    return .failure(error)
                }
            }
            return .success(filePath)
        case .folder:
            return .success(filePath)
        case .file:
            return .failure(.thisIsFile)
        }
    }

    @discardableResult
    public func copy(fromURL: URL, fileName: String, parentFolderName: String) -> Result<URL, FileError> {
        if fileName.isEmpty {
            return .failure(.emptyFileName)
        }
        if fileName.contains("/") {
            return .failure(.noSlashInFileName)
        }
        if case .failure(let error) = createFolder(name: parentFolderName) {
            return .failure(error)
        }
        let path = parentFolderName.appendSlash(path: fileName)
        let fullPath = rootFolderPath.append(path: path)
        let fileType = fileType(fullPath: fullPath)
        if fileType == .folder {
            return .failure(.thisIsFolder)
        } else if fileType == .file {
            return .failure(.overlap)
        }
        do {
            try fileManager.copyItem(at: fromURL, to: fullPath)
            return .success(fullPath)
        } catch (let error) {
            return .failure(.default(error: error))
        }
    }

    @discardableResult
    public func save(data: Data, fileName: String, parentFolderName: String, allowOverlap: Bool = true, options: Data.WritingOptions = [.atomic]) -> Result<URL, FileError> {
        if fileName.isEmpty {
            return .failure(.emptyFileName)
        }
        if fileName.contains("/") {
            return .failure(.noSlashInFileName)
        }
        if case .failure(let error) = createFolder(name: parentFolderName) {
            return .failure(error)
        }
        let path = parentFolderName.appendSlash(path: fileName)
        let fullPath = rootFolderPath.append(path: path)
        let fileType = fileType(fullPath: fullPath)
        if fileType == .folder {
            return .failure(.thisIsFolder)
        } else if fileType == .file && !allowOverlap {
            return .failure(.overlap)
        }
        do {
            try data.write(to: fullPath, options: options)
            return .success(fullPath)
        } catch (let error) {
            return .failure(.default(error: error))
        }
    }

    @discardableResult
    public func deleteFile(name fileName: String, parentFolderName: String) -> Result<Void, FileError> {
        if fileName.isEmpty {
            return .failure(.emptyFileName)
        }
        let path = parentFolderName.appendSlash(path: fileName)
        return internalDelete(path: path)
    }

    @discardableResult
    public func deleteFolder(name folderName: String) -> Result<Void, FileError> {
        if folderName.isEmpty {
            return .failure(.emptyFolderName)
        }
        return internalDelete(path: folderName)
    }

    @discardableResult
    public func deleteFolder(fullPath: URL) -> Result<Void, FileError> {
        internalDelete(fullPath: fullPath)
    }

    @discardableResult
    public func deleteRootFolder() -> Result<Void, FileError> {
        internalDelete(fullPath: rootFolderPath)
    }

    public func file(fullPath: URL, recursion: Bool = true) -> FileNode? {
        if fullPath.path == documentURL.path {
            return file()
        }
        let path = fullPath.path.replacingOccurrences(of: documentURL.path, with: "")
        var folders = path.components(separatedBy: "/")
        if folders.count < 1, let name = folders.last {
            return file(name: name)
        }
        let name = folders[folders.count - 1]
        folders.removeLast()
        let parentFolderName = folders.joined(separator: "/")
        return file(name: name, parentFolderName: parentFolderName)
    }

    public func file(name: String = "", parentFolderName: String = "", recursion: Bool = true) -> FileNode? {
        let path = parentFolderName.appendSlash(path: name)
        switch fileType(name: path) {
        case .empty:
            return nil
        case .file:
            return internalGetFile(path: parentFolderName.appendSlash(path: name))
        case .folder:
            let fullPath = rootFolderPath.append(path: path)
            var folder = internalGetFolder(path: parentFolderName.appendSlash(path: name))
            guard let directorys = try? self.fileManager.contentsOfDirectory(atPath: fullPath.path) else { return folder }
            if !recursion {
                folder.files = directorys.compactMap {
                    let appendPath = path.appendSlash(path: $0)
                    switch fileType(name: appendPath) {
                    case .empty:
                        return nil
                    case .file:
                        return internalGetFile(path: name.appendSlash(path: $0))
                    case .folder:
                        return internalGetFolder(path: name.appendSlash(path: $0))
                    }
                }
                return folder
            }
            folder.files = directorys
                .compactMap { file(name: $0, parentFolderName: path, recursion: recursion) }
            return folder
        }
    }
}

extension FileStorage {
    var rootFolderPath: URL {
        documentURL.append(path: rootFolderName.removeLastSlash)
    }

    func internalMakeName(_ name: String, ext: String, parentFolderName: String, seperator: Int = 0) -> String {
        let seperatorStr = seperator == 0 ? "" : "_\(seperator)"
        let makeName = "\(name)\(seperatorStr)\(ext)"
        let path = parentFolderName.appendSlash(path: makeName)
        let fullPath = rootFolderPath.append(path: path)
        if fileManager.fileExists(atPath: fullPath.path) {
            return internalMakeName(name, ext: ext, parentFolderName: parentFolderName, seperator: seperator + 1)
        } else {
            return makeName
        }
    }

    func internalCreateRootFolder() -> FileError? {
        guard !rootFolderName.isEmpty else { return nil }
        var path = documentURL
        for rootPath in rootFolderName.removeSlash.components(separatedBy: "/") {
            path = path.append(path: rootPath)
            if let error = internalCreateFolder(fullPath: path) {
                return error
            }
        }
        return nil
    }

    func internalCreateFolder(fullPath path: URL) -> FileError? {
        switch fileType(fullPath: path) {
        case .empty:
            do {
                try fileManager.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
                return nil
            } catch(let error) {
                return .default(error: error)
            }
        case .folder:
            return nil
        case .file:
            return .thisIsFile
        }
    }

    func internalDelete(path: String) -> Result<Void, FileError> {
        let fullPath = rootFolderPath.append(path: path)
        return internalDelete(fullPath: fullPath)
    }

    func internalRemoveItem(fullPath: URL) -> Result<Void, FileError> {
        do {
            try fileManager.removeItem(at: fullPath)
            return .success(())
        } catch(let error) {
            return .failure(.default(error: error))
        }
    }

    @discardableResult
    func internalDelete(fullPath: URL) -> Result<Void, FileError> {
        switch fileType(fullPath: fullPath) {
        case .file:
            return internalRemoveItem(fullPath: fullPath)
        case .folder:
            (file(fullPath: fullPath, recursion: false) as? Folder)?.files.forEach {
                internalDelete(fullPath: $0.fullPath)
            }
            if fullPath != documentURL {
                return internalRemoveItem(fullPath: fullPath)
            }
            return .success(())
        case .empty:
            return .success(())
        }
    }

    func interanlNameAndParentFolderName(fullPath: URL) -> (name: String, parentFolderName: String) {
        let fullPathList = fullPath.path.components(separatedBy: "/")
        if fullPathList.count > 1 {
            let name = fullPathList[fullPathList.count - 1]
            let parentFolderName = fullPathList[fullPathList.count - 2]
            return (name, parentFolderName)
        }
        return ("", "")
    }

    func internalGetFile(path: String) -> File {
        let fullPath = rootFolderPath.append(path: path)
        let (name, parentFolderName) = interanlNameAndParentFolderName(fullPath: fullPath)
        let data = fileManager.contents(atPath: fullPath.path)
        let attributes = try? self.fileManager.attributesOfItem(atPath: fullPath.path)
        return File(fileName: name, parentFolderName: parentFolderName, fullPath: fullPath, data: data, attributes: attributes)
    }

    func internalGetFolder(path: String) -> Folder {
        let fullPath = rootFolderPath.append(path: path)
        let (name, parentFolderName) = interanlNameAndParentFolderName(fullPath: fullPath)
        let attributes = try? self.fileManager.attributesOfItem(atPath: fullPath.path)
        return Folder(fileName: name, parentFolderName: parentFolderName, fullPath: fullPath, attributes: attributes)
    }
}
