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

#pragma -mark

- (id)init {
  return [[BookViewController alloc]initWithNibName:@"BookViewController" bundle:[NSBundle mainBundle]];
}

//- (id)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation options:(NSDictionary *)options {
//  self.view.backgroundColor = [UIColor greenColor];
//  return self;
//}

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
  self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(44, 67, 680, 870)];
  self.webView.delegate = self;
  [self.view addSubview:self.webView];
  self.webView.alpha = 0;
  currentTextSize = 100;
  [self loadEpubWithName:@"book"];
}

- (void)viewDidAppear:(BOOL)animated {
  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
  needPaginate = YES;
  [self loadSpine:0 atPageIndex:0];

}

- (void) chapterDidFinishLoad:(Chapter *)chapter{
  totalPagesCount+=chapter.pageCount;
  
	if(chapter.chapterIndex + 1 < [loadedEpub.spineArray count]){
		[[loadedEpub.spineArray objectAtIndex:chapter.chapterIndex+1] setDelegate:self];
		[[loadedEpub.spineArray objectAtIndex:chapter.chapterIndex+1] loadChapterWithWindowSize:webView.bounds fontPercentSize:currentTextSize];
		[currentPageLabel setText:[NSString stringWithFormat:@"?/%d", totalPagesCount]];
	} else {
		[currentPageLabel setText:[NSString stringWithFormat:@"%d/%d",[self getGlobalPageCount], totalPagesCount]];
		[pageSlider setValue:(float)100*(float)[self getGlobalPageCount]/(float)totalPagesCount animated:YES];
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
	
  //webView.hidden = YES;

  
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
  webView.hidden = NO;
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
      //[self loadSpine:currentSpineIndex atPageIndex:currentPageInSpineIndex];
      [[loadedEpub.spineArray objectAtIndex:0] setDelegate:self];
      CGRect size = self.webView.frame;
      Chapter *bufChapter = [loadedEpub.spineArray objectAtIndex:0];
      [bufChapter loadChapterWithWindowSize:size fontPercentSize:currentTextSize];
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


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
  NSLog(@"Loading next page");
  // prepearing for next page loading
  PageViewController *lastPage;
  if ([viewController isKindOfClass:[PageViewController class]]) {
    lastPage = (PageViewController *)viewController;
  } 
  
  // check if lastPage was the last in the whole book
  int pagesInSpine = [loadedEpub.spineArray[lastPage.currentSpineIndex] pageCount];
  if (pagesInSpine <= lastPage.currentPageInSpineIndex) {
    if (lastPage.currentSpineIndex >= loadedEpub.spineArray.count) {
      return nil;
    }
  }
  
  // if all is ok then reinitialize current indexes
  
  currentPageInSpineIndex = lastPage.currentPageInSpineIndex;
  currentSpineIndex = lastPage.currentSpineIndex;
  
  // now creating the istance of new page
  
  // creating of new page parameters
  
  NSDictionary *params = @{@"PageNumber": [NSNumber numberWithInt:[self getGlobalPageCount]]};
  pageForReturn = [[PageViewController alloc]initWithParameters:params];

  // set webview delegate to self for successfully loading page in the next steps
  self.webView = pageForReturn.webView;
  self.webView.delegate = self;
  
  // then turn the last page next
  [self gotoNextPage];
//  pageForReturn.currentSpineIndex = currentSpineIndex;
//  pageForReturn.currentPageInSpineIndex = currentPageInSpineIndex;
  NSLog(@"Returning next page");
  return pageForReturn;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
  NSLog(@"Loading previous page");

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
  
  NSDictionary *params = @{@"PageNumber": [NSNumber numberWithInt:[self getGlobalPageCount]]};
  pageForReturn = [[PageViewController alloc]initWithParameters:params];
  
  // set webview delegate to self for successfully loading page in the next steps
  self.webView = pageForReturn.webView;
  self.webView.delegate = self;
  
  // then turn the last page next
  [self gotoPrevPage];

  NSLog(@"Returning previous page");

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



@end
