//
//  DetailViewController.swift
//  Horoscope
//
//  Created by yamakadoh on 1/12/15.
//  Copyright (c) 2015 yamakadoh. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var labelGeneral: UILabel!
    //@IBOutlet weak var textGeneral: UITextView!

    let labelMoney = UILabel(frame: CGRectMake(0, 0, 100, 50))
    let textGeneral = UITextView(frame: CGRectMake(0, 0, 200, 100))
    
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail: AnyObject = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.description
            }
        }
        
        // 画面部品の設定
        labelMoney.text = "金運"
        labelMoney.backgroundColor = UIColor.grayColor()
        labelMoney.layer.position = CGPoint(x: self.view.bounds.width/2, y: 100)
        self.view.addSubview(labelMoney)
        
        textGeneral.text = ""
        textGeneral.backgroundColor = UIColor.grayColor()
        textGeneral.layer.position = CGPoint(x: self.view.bounds.width/2, y: 200)
        textGeneral.editable = false
        self.view.addSubview(textGeneral)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        
        let horoscope = self.detailItem as String
        //        self.getHoroscopeData()
        self.showHoroscopeData(horoscope)
        
        // タイトルの設定
        self.navigationItem.title = horoscope
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getHoroscopeData() {
        let url = NSURL(string: "http://api.jugemkey.jp/api/horoscope/free/2015/01/12")!
        var request = NSURLRequest(URL: url)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            
            println(data)
            println(response)
            println(error)
        });
        task.resume()
    }
    
    func showHoroscopeData(horoscope: String) {
        let today = getTodayString()
        let url = NSURL(string: "http://api.jugemkey.jp/api/horoscope/free/" + today)!
        var task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { data, response, error in
            // JSONデータを辞書に変換する
            let dict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
            //println("dictionary=\(dict)")   // 取得データの確認
            
            // パラメータ指定された星座の占い情報を取得する
            var horoscopeData = NSDictionary()
            if var responseData = dict["horoscope"] as? NSDictionary {
                if var entries = responseData[today] as? NSArray {
                    // 検索
                    for dicHoro in entries {
                        if dicHoro["sign"] as String == horoscope {
                            horoscopeData = dicHoro as NSDictionary
                            //println("horoscopeData=\(horoscopeData)")   // データの確認
                            break
                        }
                    }
                }
            }
            
            // TODO: ラベルとテキストにデータをセットする
            // UITextViewのテキストはメインスレッドで変更しないと落ちたので、スイッチする
            dispatch_async(dispatch_get_main_queue(), {
                if horoscopeData.count > 0 {
                    self.textGeneral.text = horoscopeData["content"] as String
                }
            })
        })
        task.resume()
    }
    
    func getTodayString() -> String {
        let date = NSDate()
        let calendar = NSCalendar(identifier: NSGregorianCalendar)!
        var dateComponents:NSDateComponents = calendar.components(NSCalendarUnit.YearCalendarUnit|NSCalendarUnit.MonthCalendarUnit|NSCalendarUnit.DayCalendarUnit, fromDate: date)
        
        let year = dateComponents.year
        let month = NSString(format: "%02d", dateComponents.month)
        let day = NSString(format: "%02d", dateComponents.day)
        let today: String = "\(year)/\(month)/\(day)"
        
        return today
    }
}

