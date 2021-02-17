//
//  ViewController.swift
//  QiitaReader
//
//  Created by Yo Higashida on 2021/02/15.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var qiitaData:NSArray!
    
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        
        // QiitaAPIを呼び出す
        getQiitaAPI()
    }
    
    // QiitaAPIを呼び出してデータを取得する
    func getQiitaAPI() {
        // APIKeyの取得
        let apiKey: String = KeyManager().getValue(key: "apiKey") as! String
        // URLの設定
        let url: URL = URL(string: "https://qiita.com/api/v2/items")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // headerの設定
        request.addValue(apiKey, forHTTPHeaderField: "Bearer")
        // タスクの設定
        let task: URLSessionTask = URLSession.shared.dataTask(with: request) {data, response, error in
            if let data = data, let _ = response {
                // print(response)
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                    self.qiitaData = json as? NSArray
                    print("get JSON data")
                    // バックグラウンド処理で、テーブルの内容を更新する
                    DispatchQueue.main.async{
                        self.table.reloadData()
                    }
                } catch {
                    print("Serialize Error")
                }
            } else {
                print(error ?? "Error")
            }
        }
        // タスクの実行
        task.resume()
    }
    
    // セルの数を設定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if qiitaData != nil {
            return qiitaData.count
        } else {
            return 1
        }
    }
    
    // セルの中に表示
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath as IndexPath)
        
        // tableView周りの設定
        tableView.rowHeight = 85
        tableView.separatorInset = .zero
        
        // ラベルと関連付けを行う
        let dateAndTagLabel = cell.viewWithTag(1) as! UILabel
        let titleLabel = cell.viewWithTag(2) as! UILabel
        let userImageView = cell.viewWithTag(3) as! UIImageView
        let userNameLabel = cell.viewWithTag(4) as! UILabel
        
        if qiitaData != nil {
            // 全部のデータ（記事1つ）
            let data: NSDictionary = oneArticle(num: indexPath.row)
            // ユーザーに関するデータ
            let userData: NSDictionary = data["user"] as! NSDictionary
            
            // 写真を表示するための準備
            let imgUrl = URL(string: userData["profile_image_url"] as! String)!
            let imgFile = try! Data(contentsOf: imgUrl)
            
            // 画像を丸くする
            userImageView.layer.cornerRadius = userImageView.frame.size.width * 0.5
            
            // ユーザー名が取得できない問題への対処
            var userName: String!
            if userData["name"] as? String != "" {
                userName = userData["name"] as? String
            } else if userData["id"] as? String != "" {
                userName = userData["id"] as? String
            } else {
                userName = "no name"
            }
            
            // 値をラベルに入れていく
            dateAndTagLabel.text = dateFormatter(inputDate: data["created_at"] as! String) + "   " + tagFormatter(tags: data["tags"] as! NSArray)
            titleLabel.text = data["title"] as? String
            userImageView.image = UIImage(data: imgFile)
            userNameLabel.text = userName
        } else {
            titleLabel.text = "no data"
        }
        
        return cell
    }
    
    // タップされた時の挙動
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data: NSDictionary = oneArticle(num: indexPath.row)
        // Safariに飛ばす
        let url = URL(string: data["url"] as! String)
        UIApplication.shared.open(url!)
    }
    
    // 1つの記事データを返す
    func oneArticle(num: Int) -> NSDictionary {
        return qiitaData[num] as! NSDictionary
    }
    
    // 年月日を切り出して文字列で返却
    func dateFormatter(inputDate: String) -> String {
        let date: String = String(inputDate.prefix(10)) // 年月日を示す部分を切り出し
        let formatDate: String = date.replacingOccurrences(of: "-", with: ".") // -を.に置き換え
        return formatDate
    }
    
    // タグの情報を文字列で返却
    func tagFormatter(tags: NSArray) -> String {
        var returnText: String = ""
        for i in tags {
            let tag: NSDictionary = i as! NSDictionary
            returnText = returnText + " #" + (tag["name"] as! String)
        }
        return returnText
    }
}
