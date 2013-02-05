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
#import "PageViewController.h"

@protocol BookViewControllerDelegate <NSObject>

@optional

- (void)paginationDone;

@end

@class SearchResultsViewController;
@class SearchResult;


@interface BookViewController : UIPageViewController <UIPageViewControllerDataSource, UIWebViewDelegate, ChapterDelegate, UIGestureRecognizerDelegate> {
  UIToolbar *toolbar;
  PageViewController *pageForReturn;
  
  // parameters
  int currentTextSize;
  NSString *bookName;
  int startingPage;
  CGRect shownRect;
  
  UIBarButtonItem* chapterListButton;
	
	UIBarButtonItem* decTextSizeButton;
	UIBarButtonItem* incTextSizeButton;
  
  UISlider* pageSlider;
  UILabel* currentPageLabel;
  
	EPub* loadedEpub;
	int currentSpineIndex;
	int currentPageInSpineIndex;
	int pagesInCurrentSpineCount;
	int totalPagesCount;
  
  BOOL epubLoaded;
  BOOL paginating;
  BOOL searching;
  BOOL needPaginate;
  
  UIPopoverController* chaptersPopover;
  UIPopoverController* searchResultsPopover;
  
  SearchResultsViewController* searchResViewController;
  SearchResult* currentSearchResult;
  
  NSArray *saveSpiningArray;
}

//@property  EPub* loadedEpub;

@property (nonatomic, retain) SearchResult* currentSearchResult;

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

@property (nonatomic, retain) IBOutlet UIWebView *webView;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *chapterListButton;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *decTextSizeButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *incTextSizeButton;

@property (nonatomic, retain) IBOutlet UISlider *pageSlider;
@property (nonatomic, retain) IBOutlet UILabel *currentPageLabel;

@property BOOL searching;

@property id<BookViewControllerDelegate> bookDelegate;

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

- (void)setOptions:(NSDictionary *)options;

- (PageViewController *)pageWithIndex:(int)index;

@end
