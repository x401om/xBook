//
//  EPub.m
//  AePubReader
//
//  Created by Federico Frappi on 05/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EPub.h"
#import "ZipArchive.h"
#import "Chapter.h"

@interface EPub()

- (void)parseEpub;
- (void)unzipAndSaveFileNamed:(NSString *)fileName;
- (NSString *)applicationDocumentsDirectory;
- (NSString *)parseManifestFile;
- (void)parseOPF:(NSString *)opfPath;

@end

@implementation EPub

@synthesize spineArray;

- (id)initWithEpubName:(NSString *)name {
  self = [super init];
  if(self){
    epubName = name;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *bookPath = [documentsDirectory stringByAppendingFormat:@"/%@.epub", name];
    NSString *bookDirPath = [documentsDirectory stringByAppendingFormat:@"/%@", name];
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    if ([fileManager fileExistsAtPath:bookDirPath]) {
      NSString *parsedPlistPath = [bookDirPath stringByAppendingFormat:@"/Parsed.plist"];
      if ([fileManager fileExistsAtPath:parsedPlistPath]) {
        NSDictionary *epubDict = [NSDictionary dictionaryWithContentsOfFile:parsedPlistPath];
        if (epubDict) {
          NSArray *spins = epubDict[@"SpineArray"];
          NSMutableArray *newSpineArray = [NSMutableArray arrayWithCapacity:spins.count];
          for (NSDictionary *chapterDict in spins) {
            Chapter *newChapter = [[Chapter alloc]initWithDictionary:chapterDict];
            [newSpineArray addObject:newChapter];
          }
          spineArray = newSpineArray;
          epubFilePath = epubDict[@"FilePath"];
          epubName = epubDict[@"Name"];
          paged = [epubDict[@"Paged"] boolValue];
          return self;
        }
      }
    }
    NSLog(@"Need parse new directory");

		epubFilePath = bookPath;
		spineArray = [[NSMutableArray alloc] init];
		[self parseEpub];
	}
	return self;
}

- (void)parseEpub {
	[self unzipAndSaveFileNamed:epubFilePath];
	NSString* opfPath = [self parseManifestFile];
	[self parseOPF:opfPath];
}

- (void)unzipAndSaveFileNamed:(NSString *)fileName{
	ZipArchive* za = [[ZipArchive alloc] init];
	if([za UnzipOpenFile:epubFilePath]) {
		NSString *strPath=[NSString stringWithFormat:@"%@/%@",[self applicationDocumentsDirectory], epubName];
		//Delete all the previous files
		NSFileManager *filemanager=[[NSFileManager alloc] init];
		if ([filemanager fileExistsAtPath:strPath]) {
			NSError *error;
			[filemanager removeItemAtPath:strPath error:&error];
		}
		filemanager=nil;
		//start unzip
		BOOL ret = [za UnzipFileTo:[NSString stringWithFormat:@"%@/",strPath] overWrite:YES];
		if(!ret){
			// error handler here
			NSLog(@"Error while unzipping the epub");
		}
		[za UnzipCloseFile];
	}					
}

- (NSString *)applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

- (NSString *)parseManifestFile {
	NSString* manifestFilePath = [NSString stringWithFormat:@"%@/%@/META-INF/container.xml", [self applicationDocumentsDirectory], epubName];
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	if ([fileManager fileExistsAtPath:manifestFilePath]) {
		//		Epub is valid
		CXMLDocument* manifestFile = [[CXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:manifestFilePath] options:0 error:nil];
		CXMLNode* opfPath = [manifestFile nodeForXPath:@"//@full-path[1]" error:nil];
		return [NSString stringWithFormat:@"%@/%@/%@", [self applicationDocumentsDirectory], epubName, [opfPath stringValue]];
	} else {
		NSLog(@"ERROR: ePub not Valid");
		return nil;
	}
}

- (void)parseOPF:(NSString *)opfPath{
	CXMLDocument* opfFile = [[CXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:opfPath] options:0 error:nil];
	NSArray* itemsArray = [opfFile nodesForXPath:@"//opf:item" namespaceMappings:[NSDictionary dictionaryWithObject:@"http://www.idpf.org/2007/opf" forKey:@"opf"] error:nil];
  NSString* ncxFileName;
  NSMutableDictionary* itemDictionary = [[NSMutableDictionary alloc] init];
	for (CXMLElement* element in itemsArray) {
		[itemDictionary setValue:[[element attributeForName:@"href"] stringValue] forKey:[[element attributeForName:@"id"] stringValue]];
    if([[[element attributeForName:@"media-type"] stringValue] isEqualToString:@"application/x-dtbncx+xml"]){
        ncxFileName = [[element attributeForName:@"href"] stringValue];
    }
    if([[[element attributeForName:@"media-type"] stringValue] isEqualToString:@"application/xhtml+xml"]){
        ncxFileName = [[element attributeForName:@"href"] stringValue];
    }
	}
	
  int lastSlash = [opfPath rangeOfString:@"/" options:NSBackwardsSearch].location;
	NSString* ebookBasePath = [opfPath substringToIndex:(lastSlash +1)];
  CXMLDocument* ncxToc = [[CXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", ebookBasePath, ncxFileName]] options:0 error:nil];
  NSMutableDictionary* titleDictionary = [[NSMutableDictionary alloc] init];
  for (CXMLElement* element in itemsArray) {
      NSString* href = [[element attributeForName:@"href"] stringValue];
      NSString* xpath = [NSString stringWithFormat:@"//ncx:content[@src='%@']/../ncx:navLabel/ncx:text", href];
      NSArray* navPoints = [ncxToc nodesForXPath:xpath namespaceMappings:[NSDictionary dictionaryWithObject:@"http://www.daisy.org/z3986/2005/ncx/" forKey:@"ncx"] error:nil];
      if([navPoints count]!=0){
          CXMLElement* titleElement = [navPoints objectAtIndex:0];
         [titleDictionary setValue:[titleElement stringValue] forKey:href];
      }
  }

	NSArray* itemRefsArray = [opfFile nodesForXPath:@"//opf:itemref" namespaceMappings:[NSDictionary dictionaryWithObject:@"http://www.idpf.org/2007/opf" forKey:@"opf"] error:nil];
	NSMutableArray* tmpArray = [[NSMutableArray alloc] init];
  int count = 0;
	for (CXMLElement* element in itemRefsArray) {
        NSString* chapHref = [itemDictionary valueForKey:[[element attributeForName:@"idref"] stringValue]];
        Chapter* tmpChapter = [[Chapter alloc] initWithPath:[NSString stringWithFormat:@"%@%@", ebookBasePath, chapHref]
                                                       title:[titleDictionary valueForKey:chapHref] 
                                                chapterIndex:count++];
		[tmpArray addObject:tmpChapter];
	}
	self.spineArray = [NSArray arrayWithArray:tmpArray];

  NSMutableArray *spins = [NSMutableArray arrayWithCapacity:spineArray.count];
  for (Chapter *curChapter in spineArray) {
    [spins addObject:[curChapter dictionary]];
  }
  NSDictionary *dictToSave = @{@"SpineArray": spins, @"FilePath": epubFilePath, @"Name": epubName, @"Paged": @NO };

  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *bookDirPath = [documentsDirectory stringByAppendingFormat:@"/%@", epubName];
  NSString *parsedPlistPath = [bookDirPath stringByAppendingFormat:@"/Parsed.plist"];
  [dictToSave writeToFile:parsedPlistPath atomically:YES];
}

@end
