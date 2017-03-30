//
//  LaunchADView.swift
//  seller
//
//  Created by wangweiyi on 2017/3/30.
//  Copyright © 2017年 com.metasolo. All rights reserved.
//

import Foundation
import UIKit

typealias adFinishHandle = ((_ isSkip: Bool, _ adHref: String?) -> Void)

let adImageFileDir = "Documents/adImage" //存储没加路径前斜杠判定，所以这里的文件夹路径开头没有  /  
private let screen = UIScreen.main
let k_KEY_WINDOW = UIApplication.shared.keyWindow

class LaunchADView {

    private var imageView: UIImageView?
    private var skipButton: UIButton?

    private var timer: DispatchSourceTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
    private var timeout: Int = 5
    private var handle: adFinishHandle?

    private var adHref: String = "默认地址"

    init() {
        self.setup()
    }

    private func setup() {

        imageView = UIImageView.init(frame: UIScreen.main.bounds)
        imageView?.alpha = 0
        imageView?.contentMode = .scaleAspectFit
        imageView?.backgroundColor = UIColor.white
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(adClick))
        imageView?.addGestureRecognizer(tap)
        imageView?.isUserInteractionEnabled = true

        skipButton = UIButton.init(frame: CGRect.init(x: screen.bounds.width - 100, y: 50, width: 70, height: 30))
        skipButton?.backgroundColor = UIColor.white
        skipButton?.setTitleColor(UIColor.black, for: .normal)
        skipButton?.addTarget(self, action: #selector(skipClick), for: .touchUpInside)
        skipButton?.setTitle("\(self.timeout)s跳过", for: .normal)
        imageView?.addSubview(skipButton!)

        self.fetchAD()
    }


    func show(finishHandle: @escaping adFinishHandle) {
        handle = finishHandle
        k_KEY_WINDOW?.addSubview(self.imageView!)
        self.imageView?.alpha = 1
        self.startCount()


    }


    private func fetchAD() {
        let req = URLRequest.init(url: URL.init(string: "http://zhuangbeiku.com/article/banners")!)//测试地址
        let session = URLSession.shared
        let task = session.dataTask(with: req) { (data, response, error) in
            if let data = data {
                let dic = decodeJSON(data: data)
                //************测试
                let arr = dic!["data"] as! [[String: Any]]
                let unit = arr[1]
                let href = unit["photo"] as! String
                self.adHref = unit["href"] as! String
                //***************

                LocalStorageManager().getFile(byFilePAth: adImageFileDir + "\(URL(string: href)!.path)", result: { (fileData) in

                    if fileData != nil {
                        DispatchQueue.main.async {
                            self.imageView?.image = UIImage.init(data: fileData!)
                        }
                    }else {
                        self.downLoadImage(with: href)
                    }
                })
            }
        }
        task.resume()
    }

    private func downLoadImage(with href: String){
        //下载地址
        let url = URL(string: href)
        //请求
        let request = URLRequest(url: url!)
        let session = URLSession.shared
        //下载任务
        let downloadTask = session.downloadTask(with: request,
                                                completionHandler: { (location: URL?, response:URLResponse?, error:Error?)
                                                    -> Void in
                                                    
                                                    let fileManager = FileManager.default
                                                    let imageData = fileManager.contents(atPath: location!.path)
                                                    if let imageData = imageData {
                                                        DispatchQueue.main.async {
                                                            self.imageView?.image = UIImage.init(data: imageData)
                                                        }
                                                        LocalStorageManager().saveFile(data: imageData, atFilePath: adImageFileDir + "\(url!.path)")
                                                    }
        })

        downloadTask.resume()
    }

    


    @objc private func skipClick() {
        self.handle?(true,nil)
        UIView.animate(withDuration: 0.25, animations: { 
            self.imageView?.alpha = 0
        }) { (finish) in
            self.imageView?.removeFromSuperview()
            self.timer.cancel()
        }
    }


    @objc private func adClick() {
        self.handle?(false,self.adHref)
        UIView.animate(withDuration: 0.25, animations: {
            self.imageView?.alpha = 0
        }) { (finish) in
            self.imageView?.removeFromSuperview()
            self.timer.cancel()
        }
    }

    private func startCount() {

        timer.scheduleRepeating(deadline: .now(), interval: DispatchTimeInterval.seconds(1), leeway: DispatchTimeInterval.milliseconds(100))
        timer.setEventHandler{
            print(self.timeout)
            self.timeout -= 1
            if self.timeout <= 0 {
                print("结束")
                self.timer.cancel()
                DispatchQueue.main.async {
                    self.skipClick()
                }
            } else {
                DispatchQueue.main.async {
                    self.skipButton?.setTitle("\(self.timeout)s跳过", for: .normal)
                }
            }

        }
        timer.resume()
    }


}







