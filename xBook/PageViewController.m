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
@synthesize pageNumberLabel, webView, parameters;

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
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSelectedText:) name:UIMenuControllerWillShowMenuNotification object:nil];

  //[[UIScreen mainScreen]setBrightness:1];
  [self.view addSubview:self.webView];
  pageNumber = [parameters[@"PageNumber"] integerValue];
  self.pageNumberLabel.text = [NSString stringWithFormat:@"%d", pageNumber];
  
  UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
  tapGestureRecognizer.delegate = self;
  //[self.view addGestureRecognizer:tapGestureRecognizer];//
  //[self.webView addGestureRecognizer:tapGestureRecognizer];
  
  UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(userSelectedText:)];
  longPressGR.delegate = self;
  //[self.view addGestureRecognizer:longPressGR];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
  return YES;
}

- (void)tap:(UITapGestureRecognizer *)sender {
  NSLog(@"tap page");
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
  [self setPageNumberLabel:nil];
  [super viewDidUnload];
}


- (IBAction)backButtonPressed:(id)sender {
  [[NSNotificationCenter defaultCenter]postNotificationName:@"Back" object:nil];
}

- (void)userSelectedText:(UILongPressGestureRecognizer *)sender {
//  if (sender.state != UIGestureRecognizerStateBegan) {
//    return;
//  }
  NSString *selection = [self.webView stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];
  UIMenuController *menu = [UIMenuController sharedMenuController];
	[menu setMenuVisible:NO];
	[menu performSelector:@selector(setMenuVisible:) withObject:[NSNumber numberWithBool:NO] afterDelay:0.15];
  if ([self.delegate respondsToSelector:@selector(showTranslationForText:)]) {
    [self.delegate showTranslationForText:selection];
  }
}

@end
