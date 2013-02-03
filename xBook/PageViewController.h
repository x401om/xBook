//
//  PageViewController.h
//  xBook
//
//  Created by Alexey Goncharov on 03.02.13.
//  Copyright (c) 2013 xomox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageViewController : UIViewController {
  int pageNumber;
}

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *decTextSizeButton;
@property (strong, nonatomic) IBOutlet UIButton *incTextSizeButton;
@property (strong, nonatomic) IBOutlet UILabel *pageNumberLabel;
@property NSDictionary *parameters;
@property int currentSpineIndex, currentPageInSpineIndex;

- (id)initWithParameters:(NSDictionary *)params;

@end
