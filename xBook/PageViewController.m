//
//  PageViewController.m
//  xBook
//
//  Created by Alexey Goncharov on 03.02.13.
//  Copyright (c) 2013 xomox. All rights reserved.
//

#import "PageViewController.h"

@interface PageViewController ()

@end

@implementation PageViewController
@synthesize pageNumberLabel, webView, titleLabel, parameters;

- (id)init {
  self = [[PageViewController alloc]initWithNibName:@"PageViewController" bundle:[NSBundle mainBundle]];
  return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(44, 67, 680, 870)];
      self.webView.backgroundColor = [UIColor clearColor];
      self.webView.scrollView.scrollEnabled = NO;
      self.webView.opaque = NO;
    }
    return self;
}


- (void)viewDidLoad {
  [super viewDidLoad];
  [self.view addSubview:self.webView];
  pageNumber = [parameters[@"PageNumber"] integerValue];
  self.pageNumberLabel.text = [NSString stringWithFormat:@"%d", pageNumber];
}

- (void)viewDidAppear:(BOOL)animated {
  [[NSNotificationCenter defaultCenter]postNotificationName:@"WebViewLoaded" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
  [self setWebView:nil];
  [self setTitleLabel:nil];
  [self setDecTextSizeButton:nil];
  [self setIncTextSizeButton:nil];
  [self setPageNumberLabel:nil];
  [super viewDidUnload];
}

- (IBAction)decTextSizePressed:(id)sender {
}
- (IBAction)incTextSizePressed:(id)sender {
}
- (IBAction)backButtonPressed:(id)sender {
  [[NSNotificationCenter defaultCenter]postNotificationName:@"Back" object:nil];
}

@end
