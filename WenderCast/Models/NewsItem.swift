/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish, 
 * distribute, sublicense, create a derivative work, and/or sell copies of the 
 * Software in any work that is designed, intended, or marketed for pedagogical or 
 * instructional purposes related to programming, coding, application development, 
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works, 
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
import UIKit

final class NewsItem: NSObject {
  let title: String
  let date: Date
  let link: String
  
  init(title: String, date: Date, link: String) {
    self.title = title
    self.date = date
    self.link = link
  }
  
  class func makeNewsItem(_ notificationDictionary: [String: AnyObject]) -> NewsItem? {
    if let news = notificationDictionary["alert"] as? String,
      let url = notificationDictionary["link_url"] as? String {
      let date = Date()
      
      let newsItem = NewsItem(title: news, date: date, link: url)
      let newsStore = NewsStore.shared
      newsStore.add(item: newsItem)
      
      NotificationCenter.default.post(name: Notification.Name(rawValue: NewsFeedTableViewController.RefreshNewsFeedNotification), object: self)
      return newsItem
    }
    return nil
  }
}

extension NewsItem: NSCoding {
  struct CodingKeys {
    static let Title = "title"
    static let Date = "date"
    static let Link = "link"
  }
  
  convenience init?(coder aDecoder: NSCoder) {
    if let title = aDecoder.decodeObject(forKey: CodingKeys.Title) as? String,
      let date = aDecoder.decodeObject(forKey: CodingKeys.Date) as? Date,
      let link = aDecoder.decodeObject(forKey: CodingKeys.Link) as? String {
      self.init(title: title, date: date, link: link)
    } else {
      return nil
    }
  }
  
  func encode(with aCoder: NSCoder) {
    aCoder.encode(title, forKey: CodingKeys.Title)
    aCoder.encode(date, forKey: CodingKeys.Date)
    aCoder.encode(link, forKey: CodingKeys.Link)
  }
}
