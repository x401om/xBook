//
//  XMLHandler.h
//  xBook
//
//  Created by Alexey Goncharov on 29.01.13.
//  Copyright (c) 2013 xomox. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "EpubContent.h"

@protocol XMLHandlerDelegate <NSObject>

@optional
- (void)foundRootPath:(NSString*)rootPath;
- (void)finishedParsing:(EpubContent*)ePubContents;
@end


@interface XMLHandler : NSObject <NSXMLParserDelegate>{
  NSString *_bufString;
	NSXMLParser *_parser;
	NSString *_rootPath;
	id<XMLHandlerDelegate> delegate;
	EpubContent *_epubContent;
	NSMutableDictionary *_itemDictionary, *_metaInfo;
	NSMutableArray *_spineArray;
  NSString *_tableOfContents, *_titlePage;

}

@property (nonatomic, retain) id<XMLHandlerDelegate> delegate;
- (void)parseXMLFileAt:(NSString*)strPath;
- (EpubContent *)getContent;
@end
