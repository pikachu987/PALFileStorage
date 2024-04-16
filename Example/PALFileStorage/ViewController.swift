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


        let fileStorage = DefaultFileStorage()
        if let file = fileStorage.file(recursion: true) {
            print(file)
        }
        if let data = "test data".data(using: .utf8) {
            print(fileStorage.save(data: data, fileName: fileStorage.makeName(name: "test.txt", parentFolderName: "test"), parentFolderName: "test"))
            print(fileStorage.save(data: data, fileName: fileStorage.makeName(name: "test.txt", parentFolderName: "test"), parentFolderName: "test"))
            print(fileStorage.save(data: data, fileName: fileStorage.makeName(name: "test.txt", parentFolderName: "test"), parentFolderName: "test"))
            print(fileStorage.save(data: data, fileName: fileStorage.makeName(name: "test.txt", parentFolderName: "test"), parentFolderName: "test"))
            print(fileStorage.save(data: data, fileName: fileStorage.makeName(name: "test.txt", parentFolderName: "test"), parentFolderName: "test"))
            print(fileStorage.save(data: data, fileName: fileStorage.makeName(name: "test.txt", parentFolderName: "test"), parentFolderName: "test"))
        }
        if let file = fileStorage.file(recursion: true) {
            print(file)
        }
        print(fileStorage.deleteRootFolder())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
