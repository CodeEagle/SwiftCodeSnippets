//
//  SwiftCodeSnippets.swift
//
//  Created by LawLincoln on 15/5/21.
//  Copyright (c) 2015年 LawLincoln. All rights reserved.
//

import AppKit
let rawUrl = "https://raw.githubusercontent.com"
let directoryUrl = "https://github.com/burczyk/XcodeSwiftSnippets/tree/master/plist"
let codeSnippetDirectory = "/Library/Developer/Xcode/UserData/CodeSnippets/"
let configureDirectory = "/Library/Application Support/SelfStudio"
var sharedPlugin: SwiftCodeSnippetsManager?

class SwiftCodeSnippetsManager: NSObject {
    var bundle: NSBundle
    let NTC = NSNotificationCenter.defaultCenter()
    init(bundle: NSBundle) {
        self.bundle = bundle
        super.init()
        updateCodeSnippets()
    }

    deinit {
        NTC.removeObserver(self)
    }
}

// MARK: - UpdateCodeSnippets
extension SwiftCodeSnippetsManager {
    func updateCodeSnippets(){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            var data = NSData(contentsOfURL: NSURL(string: directoryUrl)!)
            if let aDat = data ,
                let content = NSString(data: aDat, encoding: NSUTF8StringEncoding) as? String{
                    let start = "<td class=\"content\">"
                    let end = "</td>"
                    let matches = content.matchesOf(start, endPattern: end)
                    var urls = [String]()
                    for item in matches{
                        let hrefMatch = item.matchesOf("href=\"", endPattern: "\"")
                        if hrefMatch.count > 0 {
                            let url = hrefMatch[0]
                            if (url as NSString).hasSuffix(".codesnippet") {
                                urls.append(url)
                            }
                        }
                    }
                    let filePath = self.appConfigure()
                    var toDownloads = [String]()
                    var toDeletes = [String]()
                    var nowArray = urls as NSArray
                    if let oldArray = NSArray(contentsOfFile: filePath) {
                        for item in oldArray {
                            if !nowArray.containsObject(item) {
                                toDeletes.append(item as! String)
                            }
                        }
                        for item in nowArray {
                            if !oldArray.containsObject(item) {
                                toDownloads.append(item as! String)
                            }
                        }
                    }
                    
                    if urls.count > 0 {
                        nowArray.writeToFile(filePath, atomically: true)
                    }
                    
                    if toDownloads.count > 0 {
                        self.downloadFrom(toDownloads, done: { () -> () in
                            println("😀😀😀😀😀😀SwiftCodeSnippetsManager updat done")
                        })
                    }else{
                        println("😀😀😀😀😀😀SwiftCodeSnippetsManager not downloading")
                    }
                    
                    if toDeletes.count > 0 {
                        self.deleteFiles(toDeletes)
                    }else{
                        println("😀😀😀😀😀😀SwiftCodeSnippetsManager not delete files")
                    }

                    
            }
        })
    }
    
    func appConfigure()->String{
        let dir = NSHomeDirectory().stringByAppendingPathComponent(configureDirectory)
        let fm = NSFileManager.defaultManager()
        var isDir : ObjCBool = true
        if !fm.fileExistsAtPath(dir, isDirectory: &isDir) {
            fm.createDirectoryAtPath(dir, withIntermediateDirectories: false, attributes: nil, error: nil)
        }
        var configureFile = dir.stringByAppendingPathComponent("conf")
        return configureFile
    }
    
    func deleteFiles(items:[String]){
        for item in items {
            let fm = NSFileManager.defaultManager()
            let home = NSHomeDirectory().stringByAppendingPathComponent(codeSnippetDirectory)
            let path = home.stringByAppendingPathComponent(item)
            fm.removeItemAtPath(path, error: nil)
        }
    }
    
    func downloadFrom(var urls:[String],done:()->()){
        if urls.count > 0 {
            if let alast = urls.last {
            var last = alast as NSString
            last = last .stringByReplacingOccurrencesOfString("/blob", withString: "")
            if let  aurl = NSURL(string: "https://raw.githubusercontent.com" + (last as String)) ,
                let data = NSData(contentsOfURL: aurl){
                    let fileName = alast.fileName()
                    data.write(fileName)
                    urls.removeLast()
                    if urls.count > 0 {
                        downloadFrom(urls, done: done)
                    }else{
                        done()
                    }
                }
            }
        }else{
            done()
        }
    }
}

extension NSData {
    func write(name:String){
        let fm = NSFileManager.defaultManager()
        let home = NSHomeDirectory().stringByAppendingPathComponent(codeSnippetDirectory)
        let path = home.stringByAppendingPathComponent(name)
        var isDir : ObjCBool = false
        if !fm.fileExistsAtPath(path, isDirectory: &isDir) {
            self.writeToFile(path, atomically: true)
        }
    }
}
extension String {
    func fileName()->String{
        return self.lastPathComponent
    }
    
    func matchesOf(startPattern:String,endPattern:String)->[String]{
        let startRx = NSRegularExpression(pattern: startPattern, options: NSRegularExpressionOptions.allZeros, error: nil)
        let endRx = NSRegularExpression(pattern: endPattern, options: NSRegularExpressionOptions.allZeros, error: nil)
        let selfLen = count(self.utf16)
        var range = NSMakeRange(0, selfLen)
        var codeSnippets: [String]! = [String]()
        startRx?.enumerateMatchesInString(self, options: NSMatchingOptions.allZeros, range: range, usingBlock: { (match, flags, stop) -> Void in
            if let startMatch = match {
                let startLen = startMatch.range.location + startMatch.range.length
                let len = selfLen - startLen
                let subRange = NSMakeRange(startLen, len)
                if let endMatch = endRx?.firstMatchInString(self, options: NSMatchingOptions.allZeros, range: subRange) {
                    let dataRangeLen = endMatch.range.location - startLen
                    let dataRange = NSMakeRange(startLen, dataRangeLen)
                    let aData = (self as NSString).substringWithRange(dataRange)
                    codeSnippets.append(aData)
                }
            }
        })
        return codeSnippets
    }
}