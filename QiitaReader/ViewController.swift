//
//  ViewController.swift
//  QiitaReader
//
//  Created by Yo Higashida on 2021/02/15.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource {
    
    var qiitaData:NSArray!
    
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell")
        
        if qiitaData != nil {
            let data: NSDictionary = qiitaData[indexPath.row] as! NSDictionary
            cell?.textLabel?.text = "get Data"
            cell?.textLabel?.text = data["title"] as? String
        } else {
            cell?.textLabel?.text = "no data"
        }
        
        return cell!
    }
}

