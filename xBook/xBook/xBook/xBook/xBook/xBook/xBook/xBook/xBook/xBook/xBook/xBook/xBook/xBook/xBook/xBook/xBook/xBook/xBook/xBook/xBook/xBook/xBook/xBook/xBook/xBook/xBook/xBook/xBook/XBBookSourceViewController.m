//
//  XBBookSourceViewController.m
//  xBook
//
//  Created by Alexey Goncharov on 04.02.13.
//  Copyright (c) 2013 xomox. All rights reserved.
//

#import "XBBookSourceViewController.h"


@implementation XBBookSourceViewController
@synthesize pageViewController;

- (id)initWithOptions:(NSDictionary *)options {
  
}

- (id)initWithFile:(NSString *)fileName {
  bookName = [fileName componentsSeparatedByString:@"."][0];
  return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.pageViewController = [[BookViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{UIPageViewControllerOptionInterPageSpacingKey: @30}];
  self.pageViewController.delegate = self;
  self.pageViewController.bookDelegate = self;
  [self.pageViewController setOptions:@{@"BookName": bookName, @"FontSize": @120}];
  
  [self addChildViewController:self.pageViewController];
  [self.view addSubview:self.pageViewController.view];
  
  // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
  self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
  pageViewController.view.userInteractionEnabled = NO;
  
  // using UIPanGestureRecognizer to provide swiping brightness level changing
  
  UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(changeBrightness:)];
  panGestureRecognizer.minimumNumberOfTouches = 1;
  panGestureRecognizer.maximumNumberOfTouches = 1;
  [self.view addGestureRecognizer:panGestureRecognizer];
}


- (void)changeBrightness:(UIPanGestureRecognizer *)sender {
  if (sender.state == UIGestureRecognizerStateBegan) {
    startingBrigtness = [[UIScreen mainScreen] brightness];
  }
  if (sender.state == UIGestureRecognizerStateChanged) {
    float delta = [sender translationInView:self.view].y/[UIScreen mainScreen].bounds.size.height;
    [UIScreen mainScreen].brightness = startingBrigtness - 3*delta;
  }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation {
  //  if (UIInterfaceOrientationIsPortrait(orientation)) {
  //    // In portrait orientation: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
  //    UIViewController *currentViewController = self.pageViewController.viewControllers[0];
  //    NSArray *viewControllers = @[currentViewController];
  //    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
  //
  //    self.pageViewController.doubleSided = NO;
  //    return UIPageViewControllerSpineLocationMin;
  //  }
  //
  //  // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
  //  BookViewController *currentViewController = self.pageViewController.viewControllers[0];
  //  NSArray *viewControllers = nil;
  //
  //    viewControllers = @[previousViewController, currentViewController];
  //  }
  //  [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
  //
  
  return UIPageViewControllerSpineLocationMid;
}

- (void)paginationDone {
  
  PageViewController *startingViewController = [pageViewController pageWithIndex:0];
  
  NSArray *viewControllers = @[startingViewController];
  [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
  pageViewController.view.userInteractionEnabled = YES;
  [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(back) name:@"Back" object:nil];
}

- (void)back {
  [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
