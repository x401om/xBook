//
//  XBEpubHandler.m
//  xBook
//
//  Created by Alexey Goncharov on 29.01.13.
//  Copyright (c) 2013 xomox. All rights reserved.
//

#import "XBEpubHandler.h"

@implementation XBEpubHandler

- (id)init {
  _handler = [[XMLHandler alloc]init];
  _handler.delegate = self;
  return self;
}

- (EpubContent *)getContentForFile:(NSString *)fileName {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *bookPath = [documentsDirectory stringByAppendingFormat:@"/%@", fileName];
  NSFileManager *fileManager = [[NSFileManager alloc]init];
  _directoryPath = bookPath;
  if (![fileManager fileExistsAtPath:_directoryPath]) {
    NSLog(@"Error: no such parsed file");
    return nil;
  }
  NSDictionary *dictFromSave = [NSDictionary dictionaryWithContentsOfFile:[_directoryPath stringByAppendingString:@"/ContentData.plist"]];
  _content = [[EpubContent alloc]initWithDictionary:dictFromSave];

  return _content;
}

+ (id)sharedInstance {
  static XBEpubHandler *__sharedInstance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    __sharedInstance = [[XBEpubHandler alloc] init];
  });
  return __sharedInstance;
}


+ (void)handleEpubWithName:(NSString *)bookName andDelegate:(id<XBEpubHandlerDelegate>)delegate {
  [[XBEpubHandler sharedInstance]handleEpubWithName:bookName andDelegate:delegate];
}

- (void)handleEpubWithName:(NSString *)bookName andDelegate:(id<XBEpubHandlerDelegate>)delegate{
  _delegate = delegate;
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *bookPath = [documentsDirectory stringByAppendingFormat:@"/%@", bookName];
  NSFileManager *fileManager = [[NSFileManager alloc]init];
  _directoryPath = bookPath;
  BOOL isDir;
  if (![fileManager fileExistsAtPath:bookPath isDirectory:&isDir]) {
    bookPath = [bookPath stringByAppendingString:@".epub"];
    BOOL res = [SSZipArchive unzipFileAtPath:bookPath toDestination:_directoryPath];
    if (res) {
      NSLog(@"File %@.epub successfully unarchieved at %@",bookName, _directoryPath);
    } else {
      NSLog(@"Error occured while %@.epub was unarchieved", bookName);
      return;
    }
    NSString *containerPath = [_directoryPath stringByAppendingString:@"/META-INF/container.xml"];
    [_handler parseXMLFileAt:containerPath];
  } else {
    if (![fileManager fileExistsAtPath:[_directoryPath stringByAppendingString:@"/ContentData.plist"]]) {
      NSLog(@"Error wrong unarchieved book!");
      NSError* error;
      [fileManager removeItemAtPath:_directoryPath error:&error];
      
      [self handleEpubWithName:bookName andDelegate:delegate];
      return;
    }
    NSDictionary *dictFromSave = [NSDictionary dictionaryWithContentsOfFile:[_directoryPath stringByAppendingString:@"/ContentData.plist"]];
    _content = [[EpubContent alloc]initWithDictionary:dictFromSave];
    if ([_delegate respondsToSelector:@selector(handledBook:)]) {
      [_delegate handledBook:_content];
    }
    else {
      NSLog(@"Error: delegate doesn't support protocol method");
    }
  }
}

#pragma mark XMLHandlerDelagete Methods

- (void)foundRootPath:(NSString *)rootPath {
  NSString *OPFFilePath=[_directoryPath stringByAppendingFormat:@"/%@", rootPath];
  [_handler parseXMLFileAt:OPFFilePath];
}

- (void)finishedParsing:(EpubContent *)ePubContents {
  ePubContents._directoryPath = _directoryPath;
  NSDictionary *dataForSave = [ePubContents archiveToDictionary];
  [dataForSave writeToFile:[_directoryPath stringByAppendingString:@"/ContentData.plist"] atomically:YES];
  if ([_delegate respondsToSelector:@selector(handledBook:)]) {
    [_delegate handledBook:ePubContents];
  }
  else {
    NSLog(@"Error: delegate doesn't support protocol method");
  }
}

@end
