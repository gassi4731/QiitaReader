//
//  ViewController.swift
//  QiitaReader
//
//  Created by Yo Higashida on 2021/02/15.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // QiitaAPIを呼び出してデータを取得する
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
            if let data = data, let response = response {
                print(response)
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                    print(json)
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
    
    
}

