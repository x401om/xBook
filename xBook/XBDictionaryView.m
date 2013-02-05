//
//  XBDictionaryView.m
//  xBook
//
//  Created by Alexey Goncharov on 04.02.13.
//  Copyright (c) 2013 xomox. All rights reserved.
//

#import "XBDictionaryView.h"
#import "XBTranslator.h"

@implementation XBDictionaryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      float height = 0.0;
      height = [UIScreen mainScreen].bounds.size.height;
      
      //  if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
      //    height = [UIScreen mainScreen].bounds.size.height;
      //  }
      
      
      self.frame = CGRectMake(- self.frame.size.width, 0, self.frame.size.width, height);
      UISwipeGestureRecognizer *swipeGR = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRecognized:)];
      [self addGestureRecognizer:swipeGR];
    }
    return self;
}


- (void)loadText:(NSString *)text {
  self.wordLabel.text = text;
  NSString *translation = [XBTranslator translateString:text];
  if (translation) {
    self.translationTextView.text = translation;
  }
}



- (void)swipeRecognized:(UISwipeGestureRecognizer *)sender {
  if (sender.numberOfTouches == 1 && sender.direction == UISwipeGestureRecognizerDirectionLeft) {
    [self moveViewLeft];
  }
}

- (void)moveViewLeft {
  [UIView animateWithDuration:0.5 animations:^{
    self.frame = CGRectMake(- self.frame.size.width, 0, self.frame.size.width, self.frame.size.height);
  }];
}

- (void)moveViewRight {
  [UIView animateWithDuration:0.5 animations:^{
    self.frame = CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height);
  }];
}

@end
