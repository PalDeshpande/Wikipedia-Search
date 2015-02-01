//
//  PKWikiPageViewController.m
//  Wikipedia Search
//
//  Created by Pallavi Keskar on 1/30/15.
//  Copyright (c) 2015 pallavi.com. All rights reserved.
//

#import "PKWikiPageViewController.h"

static NSString * const baseURL =@"http://en.wikipedia.org/wiki/%@";

@interface PKWikiPageViewController ()<UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *wikiPage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation PKWikiPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.wikiPage.delegate = self;
    
    NSString *encodedText = [self.searchTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // Do any additional setup after loading the view.
    NSString *urlToDisplay = [NSString stringWithFormat:baseURL, encodedText];
    NSURL *url = [NSURL URLWithString:urlToDisplay];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [self.wikiPage loadRequest:request];
    [self.wikiPage setScalesPageToFit:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
}

@end
