//
//  EpubContent.m
//  xBook
//
//  Created by Alexey Goncharov on 29.01.13.
//  Copyright (c) 2013 xomox. All rights reserved.
//


#import "EpubContent.h"

@implementation EpubContent

@synthesize _manifest;
@synthesize _spine, _titlePage, _tableOfContents, _metaInfo, _directoryPath;

- (id)initWithDictionary:(NSDictionary *)dictionary {
  _manifest = dictionary[@"Manifest"];
  _spine = dictionary[@"Spine"];
  _titlePage = dictionary[@"TitlePage"];
  _tableOfContents = dictionary[@"TableOfContents"];
  _metaInfo = dictionary[@"MetaInfo"];
  _directoryPath = dictionary[@"DirectoryPath"];
  return self;
}

- (NSDictionary *)archiveToDictionary {
  return @{@"Manifest": _manifest, @"Spine": _spine, @"TitlePage": _titlePage, @"TableOfContents": _tableOfContents, @"MetaInfo": _metaInfo, @"DirectoryPath": _directoryPath};
}

- (NSString *)description {
  return _metaInfo.description;
}

@end
