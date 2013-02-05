//
//  EpubContent.h
//  xBook
//
//  Created by Alexey Goncharov on 29.01.13.
//  Copyright (c) 2013 xomox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EpubContent : NSObject {
  NSDictionary *_metaInfo;
	NSDictionary *_manifest;
	NSArray *_spine;
  NSString *_tableOfContents, *_titlePage;
  NSString *_directoryPath;
}

@property (nonatomic, retain) NSDictionary *_manifest;
@property (nonatomic, retain) NSArray *_spine;
@property (nonatomic, retain) NSDictionary *_metaInfo;
@property (nonatomic, retain) NSString *_tableOfContents;
@property (nonatomic, retain) NSString *_titlePage;
@property (nonatomic, retain) NSString *_directoryPath;


- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)archiveToDictionary;


@end
