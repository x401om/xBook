//
//  XBRootViewController.h
//  xBook
//
//  Created by Alexey Goncharov on 01.02.13.
//  Copyright (c) 2013 xomox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EPubViewController.h"

@interface XBRootViewController : UIViewController <UIPageViewControllerDelegate, UIWebViewDelegate> {
  EPubViewController *startingVC;
  BOOL loaded;
}

@property UIPageViewController *pageViewController;

@end
