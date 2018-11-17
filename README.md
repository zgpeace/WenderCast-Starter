# WenderCast-Starter

This is the  starter project of WenderCast from [Push Notifications Tutorial: Getting Started](https://www.raywenderlich.com/584-push-notifications-tutorial-getting-started),
Because the starter project is built error, I correct it. Finally can run. The correct solution is below.
 1. change the ``` SWXMLHash.swift ``` file from [drmohundro/SWXMLHash](https://github.com/drmohundro/SWXMLHash), for the problem <br> ``` .Element Ambiguous use of Element SWXMLHash swift ```
 2. correct the code in file ``` PodcastFeedLoader.swift ``` in line 48 to   <br>   ```let feedItems = items.all.flatMap { (indexer: XMLIndexer) -> PodcastItem? in``` , <br>   the origin code is <br> ``` let feedItems = items.flatMap { (indexer: XMLIndexer) -> PodcastItem? in```

the result picture:
![](https://koenig-media.raywenderlich.com/uploads/2017/04/initial_list.png)
