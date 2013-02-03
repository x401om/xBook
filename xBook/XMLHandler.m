//
//  XMLHandler.m
//  xBook
//
//  Created by Alexey Goncharov on 29.01.13.
//  Copyright (c) 2013 xomox. All rights reserved.
//


#import "XMLHandler.h"
#import "Chapter.h"


@implementation XMLHandler
@synthesize delegate;

- (EpubContent *)getContent {
  return _epubContent;
}

- (NSString *)getPathForFileWithPath:(NSString *)filePath {
  NSMutableArray *components = [[filePath componentsSeparatedByString:@"/"] mutableCopy];
  [components removeLastObject];
  NSString *path = @"";
  for (int i = 0; i < components.count; ++i) {
    path = [path stringByAppendingFormat:@"%@/", components[i]];
  }
  return path;
}

- (void)parseXMLFileAt:(NSString*)strPath{
  _currentDirPath = [self getPathForFileWithPath:strPath];
	_parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:strPath]];
	_parser.delegate=self;
  [_parser parse];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	
	NSLog(@"Error Occured : %@",[parseError description]);

}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
	
  if ([elementName isEqualToString:@"metadata"]){
		_metaInfo = [[NSMutableDictionary alloc]init];
	}
  
	if ([elementName isEqualToString:@"rootfile"]) {
		
		_rootPath=[attributeDict valueForKey:@"full-path"];
		if ((delegate!=nil)&&([delegate respondsToSelector:@selector(foundRootPath:)])) {
			
			[delegate foundRootPath:_rootPath];
		}
	}
  
  if ([elementName isEqualToString:@"reference"]){
    if ([attributeDict[@"title"] isEqualToString:@"Table of Contents"]) {
      _tableOfContents = attributeDict[@"href"];
    }
    if ([attributeDict[@"title"] isEqualToString:@"Cover"]) {
      _titlePage = attributeDict[@"href"];
    }  
	}
	
	if ([elementName isEqualToString:@"package"]){
		_epubContent=[[EpubContent alloc] init];
	}
	
	if ([elementName isEqualToString:@"manifest"]) {
		
		_itemDictionary=[[NSMutableDictionary alloc] init];
	}
	
	if ([elementName isEqualToString:@"item"]) {
		// media-type="application/xhtml+xml"
    if ([attributeDict[@"media-type"] isEqualToString:@"application/xhtml+xml"]) {
      [_itemDictionary setValue:[attributeDict valueForKey:@"href"] forKey:[attributeDict valueForKey:@"id"]];
    }
	}
	
	if ([elementName isEqualToString:@"spine"]) {
		
		_spineArray=[[NSMutableArray alloc] init];
	}
	
	if ([elementName isEqualToString:@"itemref"]) {
    NSString *idref = attributeDict[@"idref"];
    if (_itemDictionary[idref]) {
      NSString *href = [_currentDirPath stringByAppendingFormat:@"%@", _itemDictionary[idref]];
      Chapter *newChapter = [[Chapter alloc]initWithPath:href title:nil chapterIndex:_spineArray.count];
      [_spineArray addObject:newChapter];
    }
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{     
	if ([elementName isEqualToString:@"metadata"]){
		_epubContent._metaInfo = _metaInfo;
	}
  if ([elementName isEqualToString:@"dc:language"]){
		_metaInfo[@"lang"] = _bufString;
	}
  if ([elementName isEqualToString:@"dc:creator"]){
		_metaInfo[@"creator"] = _bufString;
	}
  if ([elementName isEqualToString:@"dc:publisher"]){
		_metaInfo[@"publisher"] = _bufString;
	}
  if ([elementName isEqualToString:@"dc:contributor"]){
		_metaInfo[@"contributor"] = _bufString;
	}
  
		if ([elementName isEqualToString:@"manifest"]) {
			
			_epubContent._manifest=_itemDictionary;
		}
		if ([elementName isEqualToString:@"spine"]) {
			
			_epubContent._spine=_spineArray;
		}
  
  if ([elementName isEqualToString:@"guide"]){
    _epubContent._tableOfContents = _tableOfContents;
    _epubContent._titlePage = _titlePage;
	}
	
		if ([elementName isEqualToString:@"package"]) {
		
			if ((delegate!=nil)&&([delegate respondsToSelector:@selector(finishedParsing:)])) {
				
				[delegate finishedParsing:_epubContent];
			}
		}

}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
  _bufString = string;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
  
}
@end
