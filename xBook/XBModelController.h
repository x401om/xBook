//
//  XBModelController.h
//  xBook
//
//  Created by Alexey Goncharov on 29.01.13.
//  Copyright (c) 2013 xomox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chapter.h"

@class SearchResult;
@class EPub;
@class BookViewController;

@interface XBModelController : NSObject <UIPageViewControllerDataSource, ChapterDelegate> {
  EPub* loadedEpub;
	int currentSpineIndex;
	int currentPageInSpineIndex;
	int pagesInCurrentSpineCount;
	int currentTextSize;
	int totalPagesCount;
  int totalCurrentPage;
  
  BOOL epubLoaded;
  BOOL paginating;
  BOOL searching;
}

@property int currentTextSize, currentPageInSpineIndex;
@property int pagesInCurrentSpineCount;

- (BookViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(BookViewController *)viewController;
- (void) gotoPageInCurrentSpine:(int)pageIndex;

@end
