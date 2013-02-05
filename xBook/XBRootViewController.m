//
//  XBRootViewController.m
//  xBook
//
//  Created by Alexey Goncharov on 01.02.13.
//  Copyright (c) 2013 xomox. All rights reserved.
//

#import "XBRootViewController.h"
#import "XBBookSourceViewController.h"

@implementation XBRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)book1:(id)sender {

  XBBookSourceViewController *bookSource = [[XBBookSourceViewController alloc]initWithFile:@"book.epub"];
  [self.navigationController pushViewController:bookSource animated:YES];
}
- (IBAction)book2:(id)sender {
  XBBookSourceViewController *bookSource = [[XBBookSourceViewController alloc]initWithFile:@"book1.epub"];
  [self.navigationController pushViewController:bookSource animated:YES];
}
- (IBAction)book3:(id)sender {
  XBBookSourceViewController *bookSource = [[XBBookSourceViewController alloc]initWithFile:@"book2.epub"];
  [self.navigationController pushViewController:bookSource animated:YES];
}
- (IBAction)book4:(id)sender {
  XBBookSourceViewController *bookSource = [[XBBookSourceViewController alloc]initWithFile:@"book3.epub"];
  [self.navigationController pushViewController:bookSource animated:YES];
}

@end
