//
//  XBModelController.m
//  xBook
//
//  Created by Alexey Goncharov on 29.01.13.
//  Copyright (c) 2013 xomox. All rights reserved.
//

#import "XBModelController.h"

#import "XBDataViewController.h"

/*
 A controller object that manages a simple model -- a collection of month names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */

static NSString *kPageFontName = @"FontName";
static NSString *kPageFontSize = @"FontSize";

#warning change 

#define kWebVeiwHeightPortret 940
#define kWebVeiwWidthPortret 730
#define kWebVeiwHeightLandscape 730
#define kWebVeiwWidthLandscape 470


@interface XBModelController()
@property (readonly, strong, nonatomic) NSArray *pageData;
@end

@implementation XBModelController

@synthesize loadedEpub, toolbar, webView;
@synthesize chapterListButton, decTextSizeButton, incTextSizeButton;
@synthesize currentPageLabel, pageSlider, searching;
@synthesize currentSearchResult;

- (id)initWithWebView:(UIWebView *)view {
    self = [super init];
    if (self) {
    // Create the data model.
      currentIndex = 0;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    _pageData = [[dateFormatter monthSymbols] copy];
      webView = view;
      webView.delegate = self;
      currentTextSize = 100;
      [self loadEpub:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"book" ofType:@"epub"]]];
    }
    return self;
}

- (XBDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard {

  XBDataViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:@"XBDataViewController"];
  pageView = dataViewController.webView;
  pageView.delegate = dataViewController;
  dataViewController.webView.delegate = self;
  if (index == -1) {
    return dataViewController;
  }
  if (index == 0) {
    index++;
  }
	int pageSum = 0;
	int chapterIndex = 0;
	int pageIndex = 0;
	for(chapterIndex = 0; chapterIndex < [loadedEpub.spineArray count]; chapterIndex++){
		pageSum += [[loadedEpub.spineArray objectAtIndex:chapterIndex] pageCount];
    //		NSLog(@"Chapter %d, targetPage: %d, pageSum: %d, pageIndex: %d", chapterIndex, targetPage, pageSum, (pageSum-targetPage));
		if(pageSum >= index){
			pageIndex = [[loadedEpub.spineArray objectAtIndex:chapterIndex] pageCount] - 1 - pageSum + index;
			break;
		}
	}

	[self loadSpine:chapterIndex atPageIndex:pageIndex];
  dataViewController.webView = self.webView;

  return dataViewController;
}

- (NSUInteger)indexOfViewController:(XBDataViewController *)viewController
{   
    
    return 1;
}


#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
   // NSUInteger index = [self indexOfViewController:(XBDataViewController *)viewController];
    if (currentIndex == 0) {
        return nil;
    }
    
    currentIndex--;
    return [self viewControllerAtIndex:currentIndex storyboard:viewController.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
  [self gotoNextPage];
    return [self viewControllerAtIndex:-1 storyboard:viewController.storyboard];
}


- (void) loadEpub:(NSURL*) epubURL{
  currentSpineIndex = 0;
  currentPageInSpineIndex = 0;
  pagesInCurrentSpineCount = 0;
  totalPagesCount = 0;
	searching = NO;
  epubLoaded = NO;
  self.loadedEpub = [[EPub alloc] initWithEPubPath:[epubURL path]];
  epubLoaded = YES;
  NSLog(@"loadEpub");
	[self updatePagination];
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
    [[NSNotificationCenter defaultCenter]postNotificationName:@"Paged" object:nil];
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
	
	webView.hidden = YES;
	
	self.currentSearchResult = theResult;
  
//	[chaptersPopover dismissPopoverAnimated:YES];
//	[searchResultsPopover dismissPopoverAnimated:YES];
	
	NSURL* url = [NSURL fileURLWithPath:[[loadedEpub.spineArray objectAtIndex:spineIndex] spinePath]];
	[webView loadRequest:[NSURLRequest requestWithURL:url]];
  [pageView loadRequest:[NSURLRequest requestWithURL:url]];
	currentPageInSpineIndex = pageIndex;
	currentSpineIndex = spineIndex;
	if(!paginating){
		[currentPageLabel setText:[NSString stringWithFormat:@"%d/%d",[self getGlobalPageCount], totalPagesCount]];
		[pageSlider setValue:(float)100*(float)[self getGlobalPageCount]/(float)totalPagesCount animated:YES];
	}
}

- (void) gotoPageInCurrentSpine:(int)pageIndex {
	if(pageIndex>=pagesInCurrentSpineCount){
		pageIndex = pagesInCurrentSpineCount - 1;
		currentPageInSpineIndex = pagesInCurrentSpineCount - 1;
	}
	
	float pageOffset = pageIndex*webView.bounds.size.width;
  
	NSString* goToOffsetFunc = [NSString stringWithFormat:@" function pageScroll(xOffset){ window.scroll(xOffset,0); } "];
	NSString* goTo =[NSString stringWithFormat:@"pageScroll(%f)", pageOffset];
	
	[webView stringByEvaluatingJavaScriptFromString:goToOffsetFunc];
	[webView stringByEvaluatingJavaScriptFromString:goTo];
  [pageView stringByEvaluatingJavaScriptFromString:goToOffsetFunc];
	[pageView stringByEvaluatingJavaScriptFromString:goTo];
	
	if(!paginating){
		[currentPageLabel setText:[NSString stringWithFormat:@"%d/%d",[self getGlobalPageCount], totalPagesCount]];
		[pageSlider setValue:(float)100*(float)[self getGlobalPageCount]/(float)totalPagesCount animated:YES];
	}
	
	webView.hidden = NO;
	
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
			[self gotoPageInCurrentSpine:++currentPageInSpineIndex];
		} else {
			[self gotoNextSpine];
		}
	}
}

- (void) gotoPrevPage {
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

//- (IBAction) doneClicked:(id)sender{
//  [self dismissModalViewControllerAnimated:YES];
//}


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

//- (IBAction) showChapterIndex:(id)sender{
//	if(chaptersPopover==nil){
//		ChapterListViewController* chapterListView = [[ChapterListViewController alloc] initWithNibName:@"ChapterListViewController" bundle:[NSBundle mainBundle]];
//		[chapterListView setEpubViewController:self];
//		chaptersPopover = [[UIPopoverController alloc] initWithContentViewController:chapterListView];
//		[chaptersPopover setPopoverContentSize:CGSizeMake(400, 600)];
//		[chapterListView release];
//	}
//	if ([chaptersPopover isPopoverVisible]) {
//		[chaptersPopover dismissPopoverAnimated:YES];
//	}else{
//		[chaptersPopover presentPopoverFromBarButtonItem:chapterListButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//	}
//}


- (void)webViewDidFinishLoad:(UIWebView *)theWebView{
	
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
    //[webView highlightAllOccurencesOfString:currentSearchResult.originatingQuery];
	}
	
	
	int totalWidth = [[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollWidth"] intValue];
	pagesInCurrentSpineCount = (int)((float)totalWidth/webView.bounds.size.width);
	
	[self gotoPageInCurrentSpine:currentPageInSpineIndex];
}

- (void) updatePagination{
	if(epubLoaded){
    if(!paginating){
      NSLog(@"Pagination Started!");
      paginating = YES;
      totalPagesCount=0;
      [self loadSpine:currentSpineIndex atPageIndex:currentPageInSpineIndex];
      [[loadedEpub.spineArray objectAtIndex:0] setDelegate:self];
      [[loadedEpub.spineArray objectAtIndex:0] loadChapterWithWindowSize:webView.bounds fontPercentSize:currentTextSize];
      [currentPageLabel setText:@"?/?"];
    }
	}
}


//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
//	if(searchResultsPopover==nil){
//		searchResultsPopover = [[UIPopoverController alloc] initWithContentViewController:searchResViewController];
//		[searchResultsPopover setPopoverContentSize:CGSizeMake(400, 600)];
//	}
//	if (![searchResultsPopover isPopoverVisible]) {
//		[searchResultsPopover presentPopoverFromRect:searchBar.bounds inView:searchBar permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//	}
//  //	NSLog(@"Searching for %@", [searchBar text]);
//	if(!searching){
//		searching = YES;
//		[searchResViewController searchString:[searchBar text]];
//    [searchBar resignFirstResponder];
//	}
//}


#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//  NSLog(@"shouldAutorotate");
//  [self updatePagination];
//	return YES;
//}

#pragma mark -
#pragma mark View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
//- (void)viewDidLoad {
//  [super viewDidLoad];
//	[webView setDelegate:self];
//  
//	UIScrollView* sv = nil;
//	for (UIView* v in  webView.subviews) {
//		if([v isKindOfClass:[UIScrollView class]]){
//			sv = (UIScrollView*) v;
//			sv.scrollEnabled = NO;
//			sv.bounces = NO;
//		}
//	}
//	currentTextSize = 100;
//	
//	UISwipeGestureRecognizer* rightSwipeRecognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gotoNextPage)] autorelease];
//	[rightSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
//	
//	UISwipeGestureRecognizer* leftSwipeRecognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gotoPrevPage)] autorelease];
//	[leftSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
//	
//	[webView addGestureRecognizer:rightSwipeRecognizer];
//	[webView addGestureRecognizer:leftSwipeRecognizer];
//	
//	[pageSlider setThumbImage:[UIImage imageNamed:@"slider_ball.png"] forState:UIControlStateNormal];
//	[pageSlider setMinimumTrackImage:[[UIImage imageNamed:@"orangeSlide.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateNormal];
//	[pageSlider setMaximumTrackImage:[[UIImage imageNamed:@"yellowSlide.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateNormal];
//  
//	searchResViewController = [[SearchResultsViewController alloc] initWithNibName:@"SearchResultsViewController" bundle:[NSBundle mainBundle]];
//	searchResViewController.epubViewController = self;
//}
//
//- (void)viewDidUnload {
//	self.toolbar = nil;
//	self.webView = nil;
//	self.chapterListButton = nil;
//	self.decTextSizeButton = nil;
//	self.incTextSizeButton = nil;
//	self.pageSlider = nil;
//	self.currentPageLabel = nil;
//}



@end
