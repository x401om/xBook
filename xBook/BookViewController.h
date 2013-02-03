//
//  BookViewController.h
//  xBook
//
//  Created by Alexey Goncharov on 02.02.13.
//  Copyright (c) 2013 xomox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZipArchive.h"
#import "EPub.h"
#import "Chapter.h"
#import "XBTranslatePopover.h"

@class SearchResultsViewController;
@class SearchResult;

@interface BookViewController : UIPageViewController <UIPageViewControllerDataSource, UIWebViewDelegate, ChapterDelegate> {
  UIToolbar *toolbar;
  
	UIWebView *webView;
  
  UIBarButtonItem* chapterListButton;
	
	UIBarButtonItem* decTextSizeButton;
	UIBarButtonItem* incTextSizeButton;
  
  UISlider* pageSlider;
  UILabel* currentPageLabel;
  
	EPub* loadedEpub;
	int currentSpineIndex;
	int currentPageInSpineIndex;
	int pagesInCurrentSpineCount;
	int currentTextSize;
	int totalPagesCount;
  
  BOOL epubLoaded;
  BOOL paginating;
  BOOL searching;
  
  UIPopoverController* chaptersPopover;
  UIPopoverController* searchResultsPopover;
  
  SearchResultsViewController* searchResViewController;
  SearchResult* currentSearchResult;
}

@property (nonatomic, retain) EPub* loadedEpub;

@property (nonatomic, retain) SearchResult* currentSearchResult;

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

@property (nonatomic, retain) IBOutlet UIWebView *webView;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *chapterListButton;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *decTextSizeButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *incTextSizeButton;

@property (nonatomic, retain) IBOutlet UISlider *pageSlider;
@property (nonatomic, retain) IBOutlet UILabel *currentPageLabel;

- (IBAction)showChapterIndex:(id)sender;
- (IBAction)increaseTextSizeClicked:(id)sender;
- (IBAction)decreaseTextSizeClicked:(id)sender;
- (IBAction)slidingStarted:(id)sender;
- (IBAction)slidingEnded:(id)sender;
- (IBAction)doneClicked:(id)sender;

- (void)gotoNextPage;
- (void)gotoPrevPage;

- (void)loadSpine:(int)spineIndex atPageIndex:(int)pageIndex highlightSearchResult:(SearchResult *)theResult;

- (void)loadEpubWithName:(NSString *)epubName;



@end
