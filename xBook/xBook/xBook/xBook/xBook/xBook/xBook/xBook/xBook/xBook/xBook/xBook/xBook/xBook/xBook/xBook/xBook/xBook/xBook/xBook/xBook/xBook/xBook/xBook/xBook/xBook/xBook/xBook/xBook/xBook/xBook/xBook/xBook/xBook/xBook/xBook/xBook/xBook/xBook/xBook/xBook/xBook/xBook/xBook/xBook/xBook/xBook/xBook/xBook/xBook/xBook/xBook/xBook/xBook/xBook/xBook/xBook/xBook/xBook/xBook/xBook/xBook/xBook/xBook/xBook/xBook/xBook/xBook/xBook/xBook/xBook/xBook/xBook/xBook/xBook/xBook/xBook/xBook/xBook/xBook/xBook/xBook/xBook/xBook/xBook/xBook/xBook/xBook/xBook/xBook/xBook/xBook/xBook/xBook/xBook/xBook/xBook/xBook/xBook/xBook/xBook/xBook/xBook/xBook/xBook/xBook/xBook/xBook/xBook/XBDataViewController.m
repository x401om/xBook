//
//  XBDataViewController.m
//  xBook
//
//  Created by Alexey Goncharov on 29.01.13.
//  Copyright (c) 2013 xomox. All rights reserved.
//

#import "XBDataViewController.h"
#import "XMLHandler.h"

@interface XBDataViewController ()

@end

@implementation XBDataViewController
@synthesize webView, url, page;



- (void)viewDidLoad
{
    [super viewDidLoad];
  webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 700, 1000)];
  [self.view addSubview:webView];
  self.view.backgroundColor = [UIColor greenColor];
  url = [NSURL URLWithString:@"http://ya.ru"];
  [webView loadRequest:[NSURLRequest requestWithURL:url]];

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
  [[NSNotificationCenter defaultCenter]postNotificationName:@"WebViewLoaded" object:nil];
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
	NSString *setTextSizeRule = [NSString stringWithFormat:@"addCSSRule('body', '-webkit-text-size-adjust: %d%%;')",self.dataObject.currentTextSize];
	NSString *setHighlightColorRule = [NSString stringWithFormat:@"addCSSRule('highlight', 'background-color: yellow;')"];
  
	
	[webView stringByEvaluatingJavaScriptFromString:varMySheet];
	
	[webView stringByEvaluatingJavaScriptFromString:addCSSRule];
  
	[webView stringByEvaluatingJavaScriptFromString:insertRule1];
	
	[webView stringByEvaluatingJavaScriptFromString:insertRule2];
	
	[webView stringByEvaluatingJavaScriptFromString:setTextSizeRule];
	
	[webView stringByEvaluatingJavaScriptFromString:setHighlightColorRule];
	
//	if(currentSearchResult!=nil){
//    //	NSLog(@"Highlighting %@", currentSearchResult.originatingQuery);
//    [webView highlightAllOccurencesOfString:currentSearchResult.originatingQuery];
//	}
	
	
	int totalWidth = [[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollWidth"] intValue];
	self.dataObject.pagesInCurrentSpineCount = (int)((float)totalWidth/webView.bounds.size.width);
	[self.dataObject gotoPageInCurrentSpine:self.dataObject.currentPageInSpineIndex];
  
}


@end