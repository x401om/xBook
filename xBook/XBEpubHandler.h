//
//  XBEpubHandler.h
//  xBook
//
//  Created by Alexey Goncharov on 29.01.13.
//  Copyright (c) 2013 xomox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EpubContent.h"
#import "SSZipArchive.h"
#import "XMLHandler.h"

@protocol XBEpubHandlerDelegate <NSObject>

@optional

- (void)handledBook:(EpubContent *)book;

@end

@interface XBEpubHandler : NSObject <XMLHandlerDelegate, XBEpubHandlerDelegate> {
  NSString *_directoryPath;
  XMLHandler *_handler;
  id<XBEpubHandlerDelegate> _delegate;
  EpubContent *_content;
  NSString *_OPFDirectory;
}



+ (void)handleEpubWithName:(NSString *)bookName andDelegate:(id<XBEpubHandlerDelegate>)delegate;
// This method takes a filename of .epub file which destination is documents folder of current application
- (EpubContent *)getContentForFile:(NSString *)fileName;

@end
