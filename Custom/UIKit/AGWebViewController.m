//
//  AGWebViewController.m
//
//  Created by Andrei Gubceac on 4/12/14.
//  Copyright (c) 2014 AndreiGubceac. All rights reserved.
//

#import "AGWebViewController.h"

@interface AGWebViewController ()<UIWebViewDelegate>

@end

@implementation AGWebViewController

- (void)loadView
{
    UIWebView *_w   = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    _w.delegate     = self;
    _w.scalesPageToFit = YES;
    self.view       = _w;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (UIWebView*)webView
{
    return (UIWebView*)self.view;
}

@end

@implementation AGWebViewController (webview)

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
}


@end