//
//  XBBookSourceViewController.h
//  xBook
//
//  Created by Alexey Goncharov on 04.02.13.
//  Copyright (c) 2013 xomox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookViewController.h"


@interface XBBookSourceViewController : UIViewController <UIPageViewControllerDelegate, BookViewControllerDelegate> {
  NSString *bookName;
}

@property BookViewController *pageViewController;

- (id)initWithFile:(NSString *)fileName;

@end
