//
//  PKWikiPageViewController.m
//  Wikipedia Search
//
//  Created by Pallavi Keskar on 1/30/15.
//  Copyright (c) 2015 pallavi.com. All rights reserved.
//

#import "PKWikiPageViewController.h"

static NSString * const baseURL =@"http://en.wikipedia.org/wiki/%@";

@interface PKWikiPageViewController ()

@property (strong, nonatomic) IBOutlet UIWebView *wikiPage;

@end

@implementation PKWikiPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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

@end
