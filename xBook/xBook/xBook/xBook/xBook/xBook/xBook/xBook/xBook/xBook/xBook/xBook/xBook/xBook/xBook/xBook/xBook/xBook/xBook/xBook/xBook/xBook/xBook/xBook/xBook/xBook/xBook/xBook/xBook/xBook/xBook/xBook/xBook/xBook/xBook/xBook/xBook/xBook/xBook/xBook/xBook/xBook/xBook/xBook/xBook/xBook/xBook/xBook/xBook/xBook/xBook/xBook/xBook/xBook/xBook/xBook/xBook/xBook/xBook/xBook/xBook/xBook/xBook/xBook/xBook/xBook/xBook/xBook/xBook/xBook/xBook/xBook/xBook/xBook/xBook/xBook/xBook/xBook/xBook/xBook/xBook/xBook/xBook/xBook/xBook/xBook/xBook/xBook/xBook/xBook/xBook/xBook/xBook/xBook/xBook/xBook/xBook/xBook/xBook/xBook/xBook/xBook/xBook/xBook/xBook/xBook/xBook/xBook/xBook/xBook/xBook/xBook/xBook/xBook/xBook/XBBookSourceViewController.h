//
//  XBBookSourceViewController.h
//  xBook
//
//  Created by Alexey Goncharov on 04.02.13.
//  Copyright (c) 2013 xomox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookViewController.h"

static NSString *XBBookSourceOptionName = @"BookName";


@interface XBBookSourceViewController : UIViewController <UIPageViewControllerDelegate, BookViewControllerDelegate> {
  NSString *bookName;
  float startingBrigtness;
}

@property BookViewController *pageViewController;

- (id)initWithFile:(NSString *)fileName;

- (id)initWithOptions:(NSDictionary *)options;

@end
