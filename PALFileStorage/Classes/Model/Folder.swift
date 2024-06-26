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

public struct Folder: FileNode {
    public var fileType: FileType = .folder
    public var fileName: String
    public var parentFolderName: String
    public var fullPath: URL
    public var creationDate: Date?
    public var modificationDate: Date?
    public var fileSize: Int?
    public var files: [FileNode]
    
    public init(fileName: String, parentFolderName: String, fullPath: URL, attributes: [FileAttributeKey: Any]?, files: [FileNode] = []) {
        self.fileName = fileName
        self.parentFolderName = parentFolderName
        self.fullPath = fullPath
        self.files = files
        self.creationDate = attributes?[FileAttributeKey.creationDate] as? Date
        self.modificationDate = attributes?[FileAttributeKey.modificationDate] as? Date
        self.fileSize = attributes?[FileAttributeKey.size] as? Int
    }
}
