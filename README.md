Synopsys:

This is an universal iOS application,  Wikipedia search app.
User can enter any search term. The app  queries the Wikipedia Search API* and displays the results in a UITableView.

Each cell in the table view displays the page title from the API response as well as the last time it was edited (in a user-friendly date format in the device’s time zone).

When a user taps any row in the search results, it opens the Wikipedia page for that result in a UIWebView.

Testing:

Code is unit tested using XCTest.

Third party library:
 1. AFNetworking : For networking and caching.
 2. SVPullToRefresh: For infinite scrolling.


