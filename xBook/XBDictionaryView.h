//
//  XBDictionaryView.h
//  xBook
//
//  Created by Alexey Goncharov on 04.02.13.
//  Copyright (c) 2013 xomox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XBDictionaryView : UIView

@property (strong, nonatomic) IBOutlet UILabel *wordLabel;
@property (strong, nonatomic) IBOutlet UITextView *translationTextView;


- (void)loadText:(NSString *)text;
- (void)moveViewLeft;
- (void)moveViewRight;

@end
