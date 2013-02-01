//
//  XBTranslator.m
//  xBook
//
//  Created by Alexey Goncharov on 01.02.13.
//  Copyright (c) 2013 xomox. All rights reserved.
//

#import "XBTranslator.h"

#define kLang @"en-ru"

@implementation NSString (NSString_Extend)

- (NSString *)urlencode {
  NSMutableString *output = [NSMutableString string];
  const unsigned char *source = (const unsigned char *)[self UTF8String];
  int sourceLen = strlen((const char *)source);
  for (int i = 0; i < sourceLen; ++i) {
    const unsigned char thisChar = source[i];
    if (thisChar == ' '){
      [output appendString:@"+"];
    } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
               (thisChar >= 'a' && thisChar <= 'z') ||
               (thisChar >= 'A' && thisChar <= 'Z') ||
               (thisChar >= '0' && thisChar <= '9')) {
      [output appendFormat:@"%c", thisChar];
    } else {
      [output appendFormat:@"%%%02X", thisChar];
    }
  }
  return output;
}

@end

@implementation XBTranslator

+ (NSString *)translateString:(NSString *)strForTranslate {
  return [[[XBTranslator alloc]init]translateString:strForTranslate];
}

- (NSString *)makeRequestStringForString:(NSString *)searchString {
  NSString *requestString = [NSString stringWithFormat:@"http://translate.yandex.net/api/v1/tr.json/translate?lang=%@&text=%@",kLang, [searchString urlencode]];
  return requestString;
}

- (NSString *)handleResponce:(NSData *)response {
  NSError *requestError = nil;
  if (!response) {
    NSLog(@"responce data = nil");
    return nil;
  }
  NSDictionary *responceDict = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&requestError];
  if (responceDict[@"error"]) {
    NSLog(@"Yandex Translation API error = %@", responceDict[@"code"]);
  }
  return responceDict[@"text"][0];
}


- (NSString *)translateString:(NSString *)strForTranslate {
  
  // http://translate.yandex.net/api/v1/tr.json/translate?lang=en-ru&text=To+be,+or+not+to+be%3F&text=That+is+the+question
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self makeRequestStringForString:strForTranslate]]
                                                         cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                     timeoutInterval:10];
  [request setHTTPMethod: @"GET"];
  NSError *requestError = nil;
  NSURLResponse *urlResponse = nil;
  NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
  if (requestError) {
    NSLog(@"Twitter rquest error %@", requestError);
    return nil;
    
  }
  return [self handleResponce:response];
  
}


@end
