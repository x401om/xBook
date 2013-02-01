//
//  XBRootViewController.m
//  xBook
//
//  Created by Alexey Goncharov on 01.02.13.
//  Copyright (c) 2013 xomox. All rights reserved.
//

#import "XBRootViewController.h"
#import "EPubViewController.h"

@interface XBRootViewController ()

@end

@implementation XBRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)openBookButtonPressed:(id)sender {
  EPubViewController *epub = [[EPubViewController alloc]init];
  [self.navigationController pushViewController:epub animated:YES];
  [epub loadEpubWithName:@"book"];
}

@end
