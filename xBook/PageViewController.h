//
//  PageViewController.h
//  xBook
//
//  Created by Alexey Goncharov on 03.02.13.
//  Copyright (c) 2013 xomox. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PageViewControllerDelegate <NSObject>

@optional

- (void)showTranslationForText:(NSString *)text;

@end

@interface PageViewController : UIViewController <UIGestureRecognizerDelegate> {
  int pageNumber;
}

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *pageNumberLabel;
@property NSDictionary *parameters;
@property int currentSpineIndex, currentPageInSpineIndex;
@property id<PageViewControllerDelegate> delegate;


@end
