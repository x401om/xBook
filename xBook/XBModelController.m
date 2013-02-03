//
//  XBModelController.m
//  xBook
//
//  Created by Alexey Goncharov on 29.01.13.
//  Copyright (c) 2013 xomox. All rights reserved.
//

#import "XBModelController.h"
//#import "XBDataViewController.h"
//#import "XBDataViewController.h"
#import "EPub.h"
#import "SearchResult.h"
#import "BookViewController.h"


@interface XBModelController()
@property UIWebView *webView;
@property (nonatomic, retain) EPub* loadedEpub;
@property BOOL searching;

@end

@implementation XBModelController
@synthesize pagesInCurrentSpineCount, currentTextSize, currentPageInSpineIndex, webView, searching, loadedEpub;

- (id)init {
    self = [super init];
    if (self) {
      totalCurrentPage = 0;
    }
    return self;
}




#pragma mark - Epub handling

- (void) loadEpubWithName:(NSString *)epubName {
  currentSpineIndex = 0;
  currentPageInSpineIndex = 0;
  pagesInCurrentSpineCount = 0;
  totalPagesCount = 0;
	searching = NO;
  epubLoaded = NO;
  self.loadedEpub = [[EPub alloc]initWithEpubName:epubName];
  epubLoaded = YES;
  NSLog(@"loadEpub");
  [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updatePagination) name:@"WebViewLoaded" object:nil];
  //	[self updatePagination];
}

- (void) chapterDidFinishLoad:(Chapter *)chapter{
  totalPagesCount+=chapter.pageCount;
  
	if(chapter.chapterIndex + 1 < [loadedEpub.spineArray count]){
		[[loadedEpub.spineArray objectAtIndex:chapter.chapterIndex+1] setDelegate:self];
		[[loadedEpub.spineArray objectAtIndex:chapter.chapterIndex+1] loadChapterWithWindowSize:self.webView.bounds fontPercentSize:currentTextSize];
		//[currentPageLabel setText:[NSString stringWithFormat:@"?/%d", totalPagesCount]];
	} else {
		//[currentPageLabel setText:[NSString stringWithFormat:@"%d/%d",[self getGlobalPageCount], totalPagesCount]];
		//[pageSlider setValue:(float)100*(float)[self getGlobalPageCount]/(float)totalPagesCount animated:YES];
		paginating = NO;
		NSLog(@"Pagination Ended!");
	}
}

- (int) getGlobalPageCount{
	int pageCount = 0;
	for(int i=0; i<currentSpineIndex; i++){
		pageCount+= [[loadedEpub.spineArray objectAtIndex:i] pageCount];
	}
	pageCount+=currentPageInSpineIndex+1;
	return pageCount;
}

- (void) loadSpine:(int)spineIndex atPageIndex:(int)pageIndex {
	[self loadSpine:spineIndex atPageIndex:pageIndex highlightSearchResult:nil];
}

- (void) loadSpine:(int)spineIndex atPageIndex:(int)pageIndex highlightSearchResult:(SearchResult*)theResult{
	
  [UIView animateWithDuration:1 animations:^{
    self.webView.hidden = YES;
  }];
  
	//self.currentSearchResult = theResult;
  
	//[chaptersPopover dismissPopoverAnimated:YES];
	//[searchResultsPopover dismissPopoverAnimated:YES];
	
	NSURL* url = [NSURL fileURLWithPath:[[loadedEpub.spineArray objectAtIndex:spineIndex] spinePath]];
	[self.webView loadRequest:[NSURLRequest requestWithURL:url]];
	currentPageInSpineIndex = pageIndex;
	currentSpineIndex = spineIndex;
	if(!paginating){
		//[currentPageLabel setText:[NSString stringWithFormat:@"%d/%d",[self getGlobalPageCount], totalPagesCount]];
		//[pageSlider setValue:(float)100*(float)[self getGlobalPageCount]/(float)totalPagesCount animated:YES];
	}
}

- (void) gotoPageInCurrentSpine:(int)pageIndex{
	if(pageIndex>=pagesInCurrentSpineCount){
		pageIndex = pagesInCurrentSpineCount - 1;
		currentPageInSpineIndex = pagesInCurrentSpineCount - 1;
	}
	
	float pageOffset = pageIndex*self.webView.bounds.size.width;
  
	NSString* goToOffsetFunc = [NSString stringWithFormat:@" function pageScroll(xOffset){ window.scroll(xOffset,0); } "];
	NSString* goTo =[NSString stringWithFormat:@"pageScroll(%f)", pageOffset];
	
	[self.webView stringByEvaluatingJavaScriptFromString:goToOffsetFunc];
	[self.webView stringByEvaluatingJavaScriptFromString:goTo];
	
	if(!paginating){
//		[currentPageLabel setText:[NSString stringWithFormat:@"%d/%d",[self getGlobalPageCount], totalPagesCount]];
//		[pageSlider setValue:(float)100*(float)[self getGlobalPageCount]/(float)totalPagesCount animated:YES];
	}
	[UIView animateWithDuration:1 animations:^{
    self.webView.hidden = NO;
  }];
  [self.webView setOpaque:NO];
	
}

- (void) gotoNextSpine {
	if(!paginating){
		if(currentSpineIndex+1<[loadedEpub.spineArray count]){
			[self loadSpine:++currentSpineIndex atPageIndex:0];
		}
	}
}

- (void) gotoPrevSpine {
	if(!paginating){
		if(currentSpineIndex-1>=0){
			[self loadSpine:--currentSpineIndex atPageIndex:0];
		}
	}
}

- (void) gotoNextPage {
  [[NSNotificationCenter defaultCenter]removeObserver:self name:@"WebViewLoaded" object:nil];
	if(!paginating){
		if(currentPageInSpineIndex+1<pagesInCurrentSpineCount){
			[self gotoPageInCurrentSpine:++currentPageInSpineIndex];
		} else {
			[self gotoNextSpine];
		}
	}
}

- (void) gotoPrevPage {
  [[NSNotificationCenter defaultCenter]removeObserver:self name:@"WebViewLoaded" object:nil];
	if (!paginating) {
		if(currentPageInSpineIndex-1>=0){
			[self gotoPageInCurrentSpine:--currentPageInSpineIndex];
		} else {
			if(currentSpineIndex!=0){
				int targetPage = [[loadedEpub.spineArray objectAtIndex:(currentSpineIndex-1)] pageCount];
				[self loadSpine:--currentSpineIndex atPageIndex:targetPage-1];
			}
		}
	}
}

- (void) updatePagination{
  [[NSNotificationCenter defaultCenter]removeObserver:self name:@"WebViewLoaded" object:nil];
	if(epubLoaded){
    if(!paginating){
      NSLog(@"Pagination Started!");
      paginating = YES;
      totalPagesCount=0;
      [self loadSpine:currentSpineIndex atPageIndex:currentPageInSpineIndex];
      [[loadedEpub.spineArray objectAtIndex:0] setDelegate:self];
      [[loadedEpub.spineArray objectAtIndex:0] loadChapterWithWindowSize:self.webView.bounds fontPercentSize:currentTextSize];
      //[currentPageLabel setText:@"?/?"];
    }
	}
}

#pragma mark Observer Methods



@end
