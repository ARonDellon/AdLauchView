//
//  LocalStorageManager.swift
//  adLaunchViewDemo
//
//  Created by wangweiyi on 2017/3/30.
//  Copyright © 2017年 wwy. All rights reserved.
//

import Foundation

//图片本地缓存
class LocalStorageManager {

    func saveFile(data: Data, atFilePath path: String) {

        DispatchQueue.global().async {

            var writePath = path
            var fileName: String = ""
            var dirArr = path.components(separatedBy: "/")
            fileName = dirArr.removeLast()
            if dirArr[0] == "Documents" {//默认存在Document下
                _ = dirArr.removeFirst()
            }
            if dirArr.count > 0 {//还有除文件名外的文件夹
                let dirPath = NSHomeDirectory() + "/Documents/" + dirArr.joined(separator: "/")
                try! FileManager.default.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
                writePath = dirPath
            }else {
                writePath = "/Documents"
            }



            if FileManager.default.fileExists(atPath: writePath + "/\(fileName)") {
                try! FileManager.default.removeItem(atPath: writePath + "/\(fileName)")
            }
            if FileManager.default.isWritableFile(atPath: writePath) {
                let url = URL(fileURLWithPath: writePath + "/\(fileName)")
                try! data.write(to: url)
            }
        }

    }

    func getFile(byFilePAth path: String, result: ((_ file: Data?)->Void)) {
        let filePath: String = NSHomeDirectory() + "/\(path)"
        if FileManager.default.fileExists(atPath: filePath) {
            let data = try! Data(contentsOf: URL(fileURLWithPath: filePath))
            result(data)
            return
        }
        result(nil)
        
    }
}




//json解析
public typealias JSONDictionary = [String: Any]

public func decodeJSON(data: Data) -> JSONDictionary? {

    if data.count > 0 {
        guard let result = try? JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions()) else {
            return JSONDictionary()
        }

        if let dictionary = result as? JSONDictionary {
            return dictionary
        } else if let array = result as? [JSONDictionary] {
            return ["data": array as Any]
        } else {
            return JSONDictionary()
        }

    } else {
        return JSONDictionary()
    }
}
