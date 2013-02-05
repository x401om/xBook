//
//  BookViewController.m
//  xBook
//
//  Created by Alexey Goncharov on 02.02.13.
//  Copyright (c) 2013 xomox. All rights reserved.
//

#import "BookViewController.h"
#import "ChapterListViewController.h"
#import "SearchResultsViewController.h"
#import "SearchResult.h"
#import "UIWebView+SearchWebView.h"
#import "Chapter.h"
#import "XBTranslator.h"

@implementation BookViewController
@synthesize toolbar, webView;
@synthesize chapterListButton, decTextSizeButton, incTextSizeButton;
@synthesize currentPageLabel, pageSlider, searching;
@synthesize currentSearchResult;
@synthesize bookDelegate;

#pragma -mark

- (void)setOptions:(NSDictionary *)options {
  currentTextSize = [options[@"FontSize"] intValue];
  if (currentTextSize < 100 || !options[@"FontSize"]) {
    currentTextSize = 100;
  }
  if (options[@"StartingPage"]) {
    startingPage = [options[@"StartingPage"] intValue];
  } else startingPage = 0;
  if (options[@"BookName"]) {
    bookName = options[@"BookName"];
  }
}

- (id)init {
  return [[BookViewController alloc]initWithNibName:@"BookViewController" bundle:[NSBundle mainBundle]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark
#pragma mark View Life Cycle

- (void)viewDidLoad {
  [super viewDidLoad];
  self.dataSource = self;
  UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
  tapGestureRecognizer.delegate = self;
  [self.view addGestureRecognizer:tapGestureRecognizer];
  if (!bookName) {
    //NSLog(@"BookName was't set");
    [NSException raise:@"Can't load book - the bookName value is set to nil" format:nil];
  }
  [self loadEpubWithName:bookName];
  dictionaryView = [[XBDictionaryView alloc]initWithFrame:CGRectNull];
}

- (void)viewDidAppear:(BOOL)animated {
  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
  return YES;
}

- (void)tap:(UITapGestureRecognizer *)sender {
  NSLog(@"tap");
}

#pragma mark
#pragma mark Epub Methods

- (void) loadEpubWithName:(NSString *)epubName {
  currentSpineIndex = 0;
  currentPageInSpineIndex = 0;
  pagesInCurrentSpineCount = 0;
  totalPagesCount = 0;
	searching = NO;
  epubLoaded = NO;
  loadedEpub = [[EPub alloc]initWithEpubName:epubName];
  epubLoaded = YES;
  NSLog(@"loadEpub");
  [self updatePagination];
}

- (void) chapterDidFinishLoad:(Chapter *)chapter{
  totalPagesCount+=chapter.pageCount;
  CGRect bounds = CGRectMake(44, 67, 680, 870);
	if(chapter.chapterIndex + 1 < [loadedEpub.spineArray count]){
		[[loadedEpub.spineArray objectAtIndex:chapter.chapterIndex+1] setDelegate:self];
		[[loadedEpub.spineArray objectAtIndex:chapter.chapterIndex+1] loadChapterWithWindowSize:bounds fontPercentSize:currentTextSize];
		[currentPageLabel setText:[NSString stringWithFormat:@"?/%d", totalPagesCount]];
	} else {
		[currentPageLabel setText:[NSString stringWithFormat:@"%d/%d",[self getGlobalPageCount], totalPagesCount]];
		[pageSlider setValue:(float)100*(float)[self getGlobalPageCount]/(float)totalPagesCount animated:YES];
		paginating = NO;
		NSLog(@"Pagination Ended!");
    [[NSNotificationCenter defaultCenter]postNotificationName:@"PagingnationDone" object:self];
    if (bookDelegate && [bookDelegate respondsToSelector:@selector(paginationDone)]) {
      [bookDelegate paginationDone];
    }
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
	
	self.currentSearchResult = theResult;
  
	[chaptersPopover dismissPopoverAnimated:YES];
	[searchResultsPopover dismissPopoverAnimated:YES];
	
	NSURL* url = [NSURL fileURLWithPath:[[loadedEpub.spineArray objectAtIndex:spineIndex] spinePath]];
	[webView loadRequest:[NSURLRequest requestWithURL:url]];
	currentPageInSpineIndex = pageIndex;
	currentSpineIndex = spineIndex;
	if(!paginating){
		[currentPageLabel setText:[NSString stringWithFormat:@"%d/%d",[self getGlobalPageCount], totalPagesCount]];
		[pageSlider setValue:(float)100*(float)[self getGlobalPageCount]/(float)totalPagesCount animated:YES];
	}

}

- (void) gotoPageInCurrentSpine:(int)pageIndex{
	if(pageIndex>=pagesInCurrentSpineCount){
		pageIndex = pagesInCurrentSpineCount - 1;
		currentPageInSpineIndex = pagesInCurrentSpineCount - 1;
	}
	
	float pageOffset = pageIndex*webView.bounds.size.width;
  
	NSString* goToOffsetFunc = [NSString stringWithFormat:@" function pageScroll(xOffset){ window.scroll(xOffset,0); } "];
	NSString* goTo =[NSString stringWithFormat:@"pageScroll(%f)", pageOffset];
	
	[webView stringByEvaluatingJavaScriptFromString:goToOffsetFunc];
	[webView stringByEvaluatingJavaScriptFromString:goTo];
	
	if(!paginating){
		[currentPageLabel setText:[NSString stringWithFormat:@"%d/%d",[self getGlobalPageCount], totalPagesCount]];
		[pageSlider setValue:(float)100*(float)[self getGlobalPageCount]/(float)totalPagesCount animated:YES];
	}
  pageForReturn.currentSpineIndex = currentSpineIndex;
  pageForReturn.currentPageInSpineIndex = currentPageInSpineIndex;
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
	if(!paginating){
		if(currentPageInSpineIndex+1<pagesInCurrentSpineCount){
      [self loadSpine:currentSpineIndex atPageIndex:++currentPageInSpineIndex];
		} else {
			[self gotoNextSpine];
		}
	}
}

- (void) gotoPrevPage {
	if (!paginating) {
		if(currentPageInSpineIndex - 1 >= 0){
      [self loadSpine:currentSpineIndex atPageIndex:--currentPageInSpineIndex];
		} else {
			if(currentSpineIndex!=0){
				int targetPage = [[loadedEpub.spineArray objectAtIndex:(currentSpineIndex-1)] pageCount];
				[self loadSpine:--currentSpineIndex atPageIndex:targetPage-1];
			}
		}
	}
}


- (IBAction) increaseTextSizeClicked:(id)sender{
	if(!paginating){
		if(currentTextSize+25<=200){
			currentTextSize+=25;
			[self updatePagination];
			if(currentTextSize == 200){
				[incTextSizeButton setEnabled:NO];
			}
			[decTextSizeButton setEnabled:YES];
		}
	}
}

- (IBAction) decreaseTextSizeClicked:(id)sender{
	if(!paginating){
		if(currentTextSize-25>=50){
			currentTextSize-=25;
			[self updatePagination];
			if(currentTextSize==50){
				[decTextSizeButton setEnabled:NO];
			}
			[incTextSizeButton setEnabled:YES];
		}
	}
}

- (IBAction) doneClicked:(id)sender{
  [self dismissModalViewControllerAnimated:YES];
}


- (IBAction) slidingStarted:(id)sender{
  int targetPage = ((pageSlider.value/(float)100)*(float)totalPagesCount);
  if (targetPage==0) {
    targetPage++;
  }
	[currentPageLabel setText:[NSString stringWithFormat:@"%d/%d", targetPage, totalPagesCount]];
}

- (IBAction) slidingEnded:(id)sender{
	int targetPage = (int)((pageSlider.value/(float)100)*(float)totalPagesCount);
  if (targetPage==0) {
    targetPage++;
  }
	int pageSum = 0;
	int chapterIndex = 0;
	int pageIndex = 0;
	for(chapterIndex=0; chapterIndex<[loadedEpub.spineArray count]; chapterIndex++){
		pageSum+=[[loadedEpub.spineArray objectAtIndex:chapterIndex] pageCount];
    //		NSLog(@"Chapter %d, targetPage: %d, pageSum: %d, pageIndex: %d", chapterIndex, targetPage, pageSum, (pageSum-targetPage));
		if(pageSum>=targetPage){
			pageIndex = [[loadedEpub.spineArray objectAtIndex:chapterIndex] pageCount] - 1 - pageSum + targetPage;
			break;
		}
	}
	[self loadSpine:chapterIndex atPageIndex:pageIndex];
}

- (IBAction) showChapterIndex:(id)sender{
	if(chaptersPopover==nil){
		ChapterListViewController* chapterListView = [[ChapterListViewController alloc] initWithNibName:@"ChapterListViewController" bundle:[NSBundle mainBundle]];
		[chapterListView setEpubViewController:self];
		chaptersPopover = [[UIPopoverController alloc] initWithContentViewController:chapterListView];
		[chaptersPopover setPopoverContentSize:CGSizeMake(400, 600)];
	}
	if ([chaptersPopover isPopoverVisible]) {
		[chaptersPopover dismissPopoverAnimated:YES];
	}else{
		[chaptersPopover presentPopoverFromBarButtonItem:chapterListButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
}


- (void)updatePagination{
	if(epubLoaded){
    if(!paginating){
      NSLog(@"Pagination Started!");
      paginating = YES;
      totalPagesCount=0;
      [[loadedEpub.spineArray objectAtIndex:0] setDelegate:self];
      CGRect bounds = CGRectMake(44, 67, 680, 870);
      Chapter *bufChapter = [loadedEpub.spineArray objectAtIndex:0];
      [bufChapter loadChapterWithWindowSize:bounds fontPercentSize:currentTextSize];
      [currentPageLabel setText:@"?/?"];
    }
	}
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
	if(searchResultsPopover==nil){
		searchResultsPopover = [[UIPopoverController alloc] initWithContentViewController:searchResViewController];
		[searchResultsPopover setPopoverContentSize:CGSizeMake(400, 600)];
	}
	if (![searchResultsPopover isPopoverVisible]) {
		[searchResultsPopover presentPopoverFromRect:searchBar.bounds inView:searchBar permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
  //	NSLog(@"Searching for %@", [searchBar text]);
	if(!searching){
		searching = YES;
		[searchResViewController searchString:[searchBar text]];
    [searchBar resignFirstResponder];
	}
}

#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  NSLog(@"shouldAutorotate");
  [self updatePagination];
	return YES;
}



#pragma mark
#pragma mark PageViewController Data Source Methods

- (PageViewController *)pageWithIndex:(int)index {
  pageForReturn = [[PageViewController alloc]init];
  // set webview delegate to self for successfully loading page in the next steps
  
  self.webView = pageForReturn.webView;
  self.webView.delegate = self;
  
  // now we should make some calculus for defining spine index and nmber of page in spine index

  int pageCount = 0, i = 0;
	for(i = 0; i < loadedEpub.spineArray.count; i++){
		pageCount += [loadedEpub.spineArray[i] pageCount];
    if (pageCount >= index) {
      break;
    }
	}
  currentSpineIndex = i;
  pagesInCurrentSpineCount = [loadedEpub.spineArray[i] pageCount];
  currentPageInSpineIndex = pagesInCurrentSpineCount - pageCount + index;
  
  // after defining all pages indexes we can call loading of requested page
  
  [self loadSpine:currentSpineIndex atPageIndex:currentPageInSpineIndex];
  pageForReturn.currentSpineIndex = currentSpineIndex;
  pageForReturn.currentPageInSpineIndex = currentPageInSpineIndex;
//  NSLog(@"Returning page with %d spineIndex and %d page", pageForReturn.currentSpineIndex, currentPageInSpineIndex);
  pageForReturn.parameters = @{@"PageNumber": [NSNumber numberWithInt:index]};
  return pageForReturn;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
  // prepearing for next page loading
  
  PageViewController *lastPage;
  if ([viewController isKindOfClass:[PageViewController class]]) {
    lastPage = (PageViewController *)viewController;
  } 
  
  // check if lastPage was the last in the whole book
  
  int pagesInSpine = [loadedEpub.spineArray[lastPage.currentSpineIndex] pageCount];
  if (pagesInSpine <= lastPage.currentPageInSpineIndex + 1) {
    if (lastPage.currentSpineIndex + 1 >= loadedEpub.spineArray.count) {
      return nil;
    }
  }
  
  // if all is ok then reinitialize current indexes
  
  currentPageInSpineIndex = lastPage.currentPageInSpineIndex;
  currentSpineIndex = lastPage.currentSpineIndex;
  
  // now creating the istance of new page
  
  // creating of new page parameters
  
  pageForReturn = [[PageViewController alloc]init];

  // set webview delegate to self for successfully loading page in the next steps
  self.webView = pageForReturn.webView;
  self.webView.delegate = self;
  
  // then turn the last page next
  [self gotoNextPage];
  pageForReturn.currentSpineIndex = currentSpineIndex;
  pageForReturn.currentPageInSpineIndex = currentPageInSpineIndex;
//  NSLog(@"Returning page with %d spineIndex and %d page", pageForReturn.currentSpineIndex, currentPageInSpineIndex);
  pageForReturn.parameters = @{@"PageNumber": [NSNumber numberWithInt:[self getGlobalPageCount]]};
  return pageForReturn;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
  // prepearing for previous page loading
  PageViewController *lastPage;
  if ([viewController isKindOfClass:[PageViewController class]]) {
    lastPage = (PageViewController *)viewController;
  }
  
  // check if lastPage was the first in the whole book
  if (lastPage.currentSpineIndex == 0 && lastPage.currentPageInSpineIndex == 0) {
    return nil;
  }
  
  // if all is ok then reinitialize current indexes
  
  currentPageInSpineIndex = lastPage.currentPageInSpineIndex;
  currentSpineIndex = lastPage.currentSpineIndex;
  
  // now creating the istance of new page
  
  // creating of new page parameters
  
  pageForReturn = [[PageViewController alloc]init];
  
  // set webview delegate to self for successfully loading page in the next steps
  self.webView = pageForReturn.webView;
  self.webView.delegate = self;
  
  // then turn the last page next
  [self gotoPrevPage];
  pageForReturn.currentSpineIndex = currentSpineIndex;
  pageForReturn.currentPageInSpineIndex = currentPageInSpineIndex;
//  NSLog(@"Returning page with %d spineIndex and %d page", pageForReturn.currentSpineIndex, currentPageInSpineIndex);
  pageForReturn.parameters = @{@"PageNumber": [NSNumber numberWithInt:[self getGlobalPageCount]]};
  return pageForReturn;
}

#pragma mark
#pragma mark UIWebViewDelegate Methods

- (void)webViewDidFinishLoad:(UIWebView *)theWebView{
  if (needPaginate) {
    needPaginate = NO;
    [self updatePagination];
    return;
  }
	//[self updatePagination];
	NSString *varMySheet = @"var mySheet = document.styleSheets[0];";
	
	NSString *addCSSRule =  @"function addCSSRule(selector, newRule) {"
	"if (mySheet.addRule) {"
	"mySheet.addRule(selector, newRule);"								// For Internet Explorer
	"} else {"
	"ruleIndex = mySheet.cssRules.length;"
	"mySheet.insertRule(selector + '{' + newRule + ';}', ruleIndex);"   // For Firefox, Chrome, etc.
	"}"
	"}";
	
	NSString *insertRule1 = [NSString stringWithFormat:@"addCSSRule('html', 'padding: 0px; height: %fpx; -webkit-column-gap: 0px; -webkit-column-width: %fpx;')", webView.frame.size.height, webView.frame.size.width];
	NSString *insertRule2 = [NSString stringWithFormat:@"addCSSRule('p', 'text-align: justify;')"];
	NSString *setTextSizeRule = [NSString stringWithFormat:@"addCSSRule('body', '-webkit-text-size-adjust: %d%%;')", currentTextSize];
	NSString *setHighlightColorRule = [NSString stringWithFormat:@"addCSSRule('highlight', 'background-color: yellow;')"];
  
	
	[webView stringByEvaluatingJavaScriptFromString:varMySheet];
	
	[webView stringByEvaluatingJavaScriptFromString:addCSSRule];
  
	[webView stringByEvaluatingJavaScriptFromString:insertRule1];
	
	[webView stringByEvaluatingJavaScriptFromString:insertRule2];
	
	[webView stringByEvaluatingJavaScriptFromString:setTextSizeRule];
	
	[webView stringByEvaluatingJavaScriptFromString:setHighlightColorRule];
	
	if(currentSearchResult!=nil){
    //	NSLog(@"Highlighting %@", currentSearchResult.originatingQuery);
    [webView highlightAllOccurencesOfString:currentSearchResult.originatingQuery];
	}
	
	
	int totalWidth = [[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollWidth"] intValue];
	pagesInCurrentSpineCount = (int)((float)totalWidth/webView.bounds.size.width);
	
	[self gotoPageInCurrentSpine:currentPageInSpineIndex];
}

#pragma mark- PageViewControllerDelegate

- (void)showTranslationForText:(NSString *)text {
  [self.view addSubview:dictionaryView];
  [dictionaryView loadText:text];
  [dictionaryView moveViewRight];
}

@end
