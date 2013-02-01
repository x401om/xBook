//
//  XBModelController.h
//  xBook
//
//  Created by Alexey Goncharov on 29.01.13.
//  Copyright (c) 2013 xomox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EpubContent.h"
#import "EPub.h"
#import "SearchResultsViewController.h"

@class XBDataViewController;

@interface XBModelController : NSObject <UIPageViewControllerDataSource, UIWebViewDelegate, ChapterDelegate> {
  int currentIndex; // old
//  
//  UIToolbar *toolbar;
//  
//	UIWebView *webView;
//  
//  UIBarButtonItem* chapterListButton;
//	
//	UIBarButtonItem* decTextSizeButton;
//	UIBarButtonItem* incTextSizeButton;
//  
//  UISlider* pageSlider;
//  UILabel* currentPageLabel;
  
	EPub* loadedEpub;
	int currentSpineIndex;
	int currentPageInSpineIndex;
	int pagesInCurrentSpineCount;
	int currentTextSize;
	int totalPagesCount;
  
  BOOL epubLoaded;
  BOOL paginating;
  BOOL searching;
  
  UIWebView *pageView;
  
//  UIPopoverController* chaptersPopover;
//  UIPopoverController* searchResultsPopover;
  
//  SearchResultsViewController* searchResViewController;
//  SearchResult* currentSearchResult;

}

@property int currentTextSize, pagesInCurrentSpineCount, currentPageInSpineIndex;

@property (nonatomic, retain) EPub* loadedEpub;

@property (nonatomic, retain) SearchResult* currentSearchResult;

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

@property (nonatomic, retain) IBOutlet UIWebView *webView;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *chapterListButton;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *decTextSizeButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *incTextSizeButton;

@property (nonatomic, retain) IBOutlet UISlider *pageSlider;
@property (nonatomic, retain) IBOutlet UILabel *currentPageLabel;

@property (strong) EpubContent *ePubContent;

@property BOOL searching;

- (id)initWithWebView:(UIWebView *)view;

- (XBDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(XBDataViewController *)viewController;

- (void) loadSpine:(int)spineIndex atPageIndex:(int)pageIndex;
- (void) loadSpine:(int)spineIndex atPageIndex:(int)pageIndex highlightSearchResult:(SearchResult*)theResult;
- (void) loadEpub:(NSURL*) epubURL;

- (void) gotoPageInCurrentSpine:(int)pageIndex;

@end
