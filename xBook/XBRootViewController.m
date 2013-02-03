//
//  XBRootViewController.m
//  xBook
//
//  Created by Alexey Goncharov on 01.02.13.
//  Copyright (c) 2013 xomox. All rights reserved.
//

#import "XBRootViewController.h"
#import "EPubViewController.h"
//#import "XBDataViewController.h"
#import "XBModelController.h"
#import "BookViewController.h"
@interface XBRootViewController ()
@property (readonly, strong, nonatomic) XBModelController *modelController;

@end

@implementation XBRootViewController
@synthesize modelController = _modelController;
@synthesize pageViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  self.pageViewController = [[BookViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
  self.pageViewController.delegate = self;
  loaded = NO;
//  startingVC = [[EPubViewController alloc]init];
//  [self addChildViewController:startingVC];
//  [self.view addSubview:startingVC.view];
//  startingVC.webView.delegate = self;
//  [startingVC loadEpubWithName:@"book"];
//  
  UIViewController *startingViewController = [[UIViewController alloc]init];
  
  NSArray *viewControllers = @[startingViewController];
  [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
  
//  self.pageViewController.dataSource = self.modelController;
//  
  [self addChildViewController:self.pageViewController];
  [self.view addSubview:self.pageViewController.view];
  
  // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
  self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
    // Do any additional setup after loading the view from its nib.
}

- (XBModelController *)modelController
{
  // Return the model controller object, creating it if necessary.
  // In more complex implementations, the model controller may be passed to the view controller.
  if (!_modelController) {
    //_modelController = [[XBModelController alloc] init];
  }
  return _modelController;
}

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
  if (UIInterfaceOrientationIsPortrait(orientation)) {
    // In portrait orientation: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
    UIViewController *currentViewController = self.pageViewController.viewControllers[0];
    NSArray *viewControllers = @[currentViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
    
    self.pageViewController.doubleSided = NO;
    return UIPageViewControllerSpineLocationMin;
  }
  
  // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
  BookViewController *currentViewController = self.pageViewController.viewControllers[0];
  NSArray *viewControllers = nil;
  
  NSUInteger indexOfCurrentViewController = [self.modelController indexOfViewController:currentViewController];
  if (indexOfCurrentViewController == 0 || indexOfCurrentViewController % 2 == 0) {
    UIViewController *nextViewController = [self.modelController pageViewController:self.pageViewController viewControllerAfterViewController:currentViewController];
    viewControllers = @[currentViewController, nextViewController];
  } else {
    UIViewController *previousViewController = [self.modelController pageViewController:self.pageViewController viewControllerBeforeViewController:currentViewController];
    viewControllers = @[previousViewController, currentViewController];
  }
  [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
  
  
  return UIPageViewControllerSpineLocationMid;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)openBookButtonPressed:(id)sender {
//  EPubViewController *epub = [[EPubViewController alloc]init];
//  [self.navigationController pushViewController:epub animated:YES];
//  [epub loadEpubWithName:@"book"];
  
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
  if (loaded) {
    return;
  }
  loaded = YES;
  self.pageViewController.dataSource = self.modelController;
  
  [self addChildViewController:self.pageViewController];
  [self.view addSubview:self.pageViewController.view];
  
  // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
  CGRect pageViewRect = self.view.bounds;
  pageViewRect = CGRectInset(pageViewRect, 0, 0);
  self.pageViewController.view.frame = pageViewRect;
  
  [self.pageViewController didMoveToParentViewController:self];
}

@end
