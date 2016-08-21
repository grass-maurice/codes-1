//
//  ViewController.swift
//  zipAddress
//
//  Created by takayoshi on 2015/11/29.
//  Copyright © 2015年 takayoshi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var zipTextField: UITextField!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var prefLabel: UILabel!
    @IBAction func tapReturn() {
        zipTextField.resignFirstResponder()
    }
    @IBAction func tapSearch(sender: AnyObject) {
        guard let ziptext = zipTextField.text else{
            return
        }
        // zipTextField.resignFirstResponder()
        let urlStr =  "http://api.zipaddress.net/?zipcode=\(ziptext)"
        //URLエンコーディング済みのアドレスを生成する。
        //        let searchWord:String! = ziptext.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        
        //API IDは等は固定
        //       let urlStr:String =  "http://api.e-stat.go.jp/rest/1.0/app/getStatsList?appId=06fda75545814849359a97c59da6501ee6844adb&searchWord=\(searchWord)"
        print(urlStr)
        
        
        
        
        //URLオブジェクトを生成する。nilの場合はエラーにする。
        if let url:NSURL = NSURL(string: urlStr){
            let request = NSURLRequest(URL: url)
            //NSURLConnection.sendAsynchronousRequest(request, queue: .mainQueue(), completionHandler: self.dispXML)
            let urlSession = NSURLSession.sharedSession()
            let task = urlSession.dataTaskWithURL(url,completionHandler: self.onGetAddress)
            task.resume()
        }else{
            print("URLError")
        }
    }
    //dispXML
    func dispXML(response:NSURLResponse?,data:NSData?,error:NSError?){
        if data != nil {
            // チェックのため、読み込んだデータをそのまま表示
            let myString = NSString(data:data!, encoding: NSUTF8StringEncoding) as! String
            print(myString)
            
            // XMLの解析を開始
            let parser:NSXMLParser? = NSXMLParser(data: data!)
            if parser != nil   {
                // 解析が進んだら、parser関数を呼び出すようにする
                //parser!.delegate = self
                parser!.parse()
            }
        }
    }
    // 1階層目のタグを覚えておく変数を用意
    var XMLtag1: String! = ""
    // 表示するメッセージを入れる変数
    var msg:String = ""
    // タグの最初が見つかったら呼ばれる関数
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        // タグが「data」なら「dataタグ」に入ったことをXMLtag1に覚えておく
        if elementName == "data" {
            XMLtag1 = "data"
        }
        // タグが「tea」で、すでに「dataタグ」に入った状態なら、その中のデータを取り出す
        if elementName == "tea" && XMLtag1 == "data" {
            // 属性「name」の文字を取りだしてmsg変数に追加
            if let teaName = attributeDict["name"] as? String {
                msg += "名前=\(teaName)\n"
            }
            // 属性「price」の文字を取りだしてmsg変数に追加
            if let teaPrice = attributeDict["price"] as? String {
                msg += "価格=\(teaPrice)\n"
            }
        }
    }
    //XMLパーサ
    // タグの終わりが見つかったら呼ばれる関数
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        // タグが「data」なら タグが閉じられたので、XMLtag1をリセットして、メッセージを表示
        if elementName == "data" {
            XMLtag1 = ""
            prefLabel.text = msg
        }
    }
    
    func onGetAddress(data: NSData?, res: NSURLResponse?, error: NSError?){
        do{
            let jsonDic = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers) as! NSDictionary
            if let code = jsonDic["code"] as? Int {
                if code != 200{
                    if let errmsg = jsonDic["message"] as? String {
                        print(errmsg)
                    }
                }
            }
            if let data = jsonDic["data"] as? NSDictionary {
                if let pref = data["pref"] as? String{
                    print("zipPrefGot")
                    self.prefLabel.text = pref
                }
                if let address = data["address"] as? String{
                    self.addressLabel.text = address
                }
                
            }
        }catch{
            self.addressLabel.text = "エラーです"
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

