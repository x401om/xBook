//
//  XBTranslatePopover.m
//  xBook
//
//  Created by Alexey Goncharov on 01.02.13.
//  Copyright (c) 2013 xomox. All rights reserved.
//

#import "XBTranslatePopover.h"
#import "XBTranslator.h"

@implementation XBTranslatePopover

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithSource:(NSString *)source {
  self = [[[NSBundle mainBundle]loadNibNamed:@"XBTranslatePopover" owner:self options:nil]objectAtIndex:0];
  NSString *trStr = [XBTranslator translateString:source];
  if (trStr) {
    self.translateLabel.text = trStr;
  }
  self.sourceLabel.text = source;
  return self;
}
- (IBAction)closeButtonPressed:(id)sender {
  [self removeFromSuperview];
}

@end
