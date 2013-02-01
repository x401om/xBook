//
//  XBTranslatePopover.h
//  xBook
//
//  Created by Alexey Goncharov on 01.02.13.
//  Copyright (c) 2013 xomox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XBTranslatePopover : UIView

@property (strong, nonatomic) IBOutlet UILabel *sourceLabel;
@property (strong, nonatomic) IBOutlet UILabel *translateLabel;

- (id)initWithSource:(NSString *)source;

@end
