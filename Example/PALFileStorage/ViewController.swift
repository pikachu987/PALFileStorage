//
//  ViewController.swift
//  PALFileStorage
//
//  Created by pikachu987 on 01/16/2021.
//  Copyright (c) 2021 pikachu987. All rights reserved.
//

import UIKit
import PALFileStorage

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let file = FileStorage.file("", recursion: true) {
            print(file)
        }
        if let data = "test data".data(using: .utf8) {
            print(FileStorage.save(data, fileName: FileStorage.makeOverlapFileName("test.txt", folderName: "test"), folderName: "test"))
            print(FileStorage.save(data, fileName: FileStorage.makeOverlapFileName("test.txt", folderName: "test"), folderName: "test"))
            print(FileStorage.save(data, fileName: FileStorage.makeOverlapFileName("test.txt", folderName: "test"), folderName: "test"))
            print(FileStorage.save(data, fileName: FileStorage.makeOverlapFileName("test.txt", folderName: "test"), folderName: "test"))
            print(FileStorage.save(data, fileName: FileStorage.makeOverlapFileName("test.txt", folderName: "test"), folderName: "test"))
            print(FileStorage.save(data, fileName: FileStorage.makeOverlapFileName("test.txt", folderName: "test"), folderName: "test"))
        }
        if let file = FileStorage.file("", recursion: true) {
            print(file)
        }
        print(FileStorage.deleteFolder("test"))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
