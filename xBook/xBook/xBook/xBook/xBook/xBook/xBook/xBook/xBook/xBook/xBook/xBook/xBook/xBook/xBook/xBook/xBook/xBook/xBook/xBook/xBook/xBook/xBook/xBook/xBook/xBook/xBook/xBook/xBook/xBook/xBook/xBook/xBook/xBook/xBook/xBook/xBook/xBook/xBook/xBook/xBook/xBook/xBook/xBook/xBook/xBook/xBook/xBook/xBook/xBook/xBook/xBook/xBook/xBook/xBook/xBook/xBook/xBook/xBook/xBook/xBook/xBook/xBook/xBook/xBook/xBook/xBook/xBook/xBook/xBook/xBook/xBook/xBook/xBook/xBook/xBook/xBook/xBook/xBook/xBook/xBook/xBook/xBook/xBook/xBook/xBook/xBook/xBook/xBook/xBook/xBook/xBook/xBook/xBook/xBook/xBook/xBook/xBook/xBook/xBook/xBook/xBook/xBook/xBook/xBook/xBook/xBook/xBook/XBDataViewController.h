//
//  XBDataViewController.h
//  xBook
//
//  Created by Alexey Goncharov on 29.01.13.
//  Copyright (c) 2013 xomox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMLHandler.h"
#import "XBModelController.h"

@interface XBDataViewController : UIViewController <XMLHandlerDelegate, UIWebViewDelegate> {
  NSURL *_url;
  int textFontSize;
}

@property (strong, nonatomic) IBOutlet UILabel *dataLabel;
@property (strong, nonatomic) XBModelController *dataObject;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSURL *url;
@property int page;


@end
