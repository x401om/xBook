//
//  EPubParser.h
//  AePubReader
//
//  Created by Federico Frappi on 05/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TouchXML.h"
		

@interface EPub : NSObject {
  NSString *epubName;

	NSArray* spineArray;
	NSString* epubFilePath;
}

@property(nonatomic, retain) NSArray* spineArray;

- (id)initWithEpubName:(NSString *)name;


@end
