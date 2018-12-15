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
import SafariServices
import UserNotifications

fileprivate let viewActionIdentifier = "VIEW_IDENTIFIER"
fileprivate let newsCategoryIdentifier = "NEWS_CATEGORY"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    
    UITabBar.appearance().barTintColor = UIColor.themeGreenColor
    UITabBar.appearance().tintColor = UIColor.white
    registerForPushNotification()
    
    // Check if launched from notification
    let notificationOption = launchOptions?[.remoteNotification]
    if let notification = notificationOption as? [String: AnyObject],
    let aps = notification["aps"] as? [String: AnyObject]
    {
        NewsItem.makeNewsItem(aps)
        (window?.rootViewController as? UITabBarController)?.selectedIndex = 1
    }
    
    return true
  }
    
    func registerForPushNotification() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
                print("Permission granted: \(granted)")
                guard granted else {
                    // Permission is not granted, show alert user can go to setting page
                    
                    return
                }
                
                let viewAction = UNNotificationAction(identifier: viewActionIdentifier, title: "View", options: [.foreground])
                let newsCategory = UNNotificationCategory(identifier: newsCategoryIdentifier, actions: [viewAction], intentIdentifiers: [], options: [])
                UNUserNotificationCenter.current().setNotificationCategories([newsCategory])
                
                self?.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let aps = userInfo["aps"] as? [String: AnyObject] else {
            completionHandler(.failed)
            return
        }
        
        // 1
        if aps["content-available"] as? Int == 1{
             let podcastStore = PodcastStore.sharedStore
            // 2
            podcastStore.refreshItems { (didLoadNewItems) in
                // 3
                completionHandler(didLoadNewItems ? .newData : .noData)
            }
        } else {
            // 4
            NewsItem.makeNewsItem(aps)
            completionHandler(.newData)
        }
        
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // 1
        let userInfo = response.notification.request.content.userInfo
        
        // 2
        if let aps = userInfo["aps"] as? [String: AnyObject],
            let newsItem = NewsItem.makeNewsItem(aps)
        {
            (window?.rootViewController as? UITabBarController)?.selectedIndex = 1
            
            // 3
            if response.actionIdentifier == viewActionIdentifier,
                let url = URL(string: newsItem.link) {
                let safari = SFSafariViewController(url: url)
                window?.rootViewController?.present(safari, animated: true, completion: nil)
                
            }
            
        }
        
    }
}







































