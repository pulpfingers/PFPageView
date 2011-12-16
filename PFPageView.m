//
//  PFPageView.m
//  iso500
//
//  Created by Jérôme Scheer on 14/12/11.
//  Copyright (c) 2011 Pulpfingers. All rights reserved.
//

#import "PFPageView.h"

@interface PFPageView (Private)
- (void)unloadScrollViewAtIndex:(NSInteger)index; 
- (void)loadViewAtIndex:(NSInteger)index;
- (NSInteger)visiblePage;
- (CGSize)screenSize;
- (void)didRotate;
- (void)showPageAtIndex:(NSInteger)index;
@end

@implementation PFPageView

@synthesize delegate;
@synthesize dataSource;
@synthesize pageIndex;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        views = [[NSMutableArray alloc] init];
        pageScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [pageScrollView setPagingEnabled:YES];
        [pageScrollView setDelegate:self];
        [pageScrollView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [pageScrollView setShowsHorizontalScrollIndicator:NO];
        [pageScrollView setShowsVerticalScrollIndicator:NO];
        [self addSubview:pageScrollView];
        
        //[self setBackgroundColor:[UIColor redColor]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
        previousPageIndex = -1;
    }
    return self;
}

- (void)didRotate {
    [self setPageIndex:previousPageIndex];
    [pageScrollView setContentSize:CGSizeMake(pageCount * self.bounds.size.width, self.bounds.size.height)];
}

- (void)setDataSource:(id<PFPageViewDataSource>)newDataSource {

    dataSource = newDataSource;
    pageCount = [dataSource numberOfPagesInPageView:self];
    
    for (unsigned i = 0; i < pageCount; i++) {
        [views addObject:[NSNull null]];
    }
    
    [pageScrollView setContentSize:CGSizeMake(pageCount * self.bounds.size.width, self.bounds.size.height)];
}

- (CGSize)screenSize {
    if(UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        return CGSizeMake(320.f, 480.0f);
    } else {
        return CGSizeMake(480.0f, 320.f);
    }
}

- (void)setPageIndex:(NSInteger)newPageIndex {
    
    [self showPageAtIndex:newPageIndex];
    [pageScrollView scrollRectToVisible:CGRectMake(self.screenSize.width * newPageIndex, 0.0, self.screenSize.width, self.screenSize.height) animated:NO];

}

- (NSInteger)pageIndex {
    CGFloat screenWidth;
    
    if(UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        screenWidth = 320.0f;
    } else {
        screenWidth = 480.0f;
    }
    
    int index = floor((pageScrollView.contentOffset.x - screenWidth / 2) / screenWidth) + 1;
    return index;
}

#pragma mark -
#pragma mark Private methods

- (void)unloadScrollViewAtIndex:(NSInteger)index {
	if (index < 0) return;
    if (index >= [views count]) return;
    
    UIView *currentView = [views objectAtIndex:index];
    
	if ((NSNull *)currentView != [NSNull null]) {
        [currentView removeFromSuperview];
    }
	
	[views replaceObjectAtIndex:index withObject:[NSNull null]];
}

- (void)loadViewAtIndex:(NSInteger)index {

	if (index < 0) return;
    if (index >= [views count]) return;
    
    UIView *currentView = [views objectAtIndex:index];
    
    if ((NSNull *)currentView == [NSNull null]) {
        [views replaceObjectAtIndex:index withObject:[self.dataSource pageView:self atIndex:index]];
        currentView = [views objectAtIndex:index];
    }
    
	CGRect frame = self.bounds;		
	frame.origin.x = frame.size.width * index;
	frame.origin.y = 0;
	currentView.frame = frame;
	
    if (currentView.superview != pageScrollView) {
		[pageScrollView addSubview:currentView];
	}
}

#pragma mark -
#pragma ScrollView delegate methods
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self loadViewAtIndex:[self pageIndex]];

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {    
    int index = [self pageIndex];    
    [self showPageAtIndex:index];
}

- (void)showPageAtIndex:(NSInteger)index {
    // Unload page -2
    [self unloadScrollViewAtIndex:index - 2];
    
    [self loadViewAtIndex:index - 1];    
    [self loadViewAtIndex:index];
    [self loadViewAtIndex:index + 1];        
    
    [self unloadScrollViewAtIndex:index + 2];
    
    // Send didScrollAtIndex 
    if([self.delegate respondsToSelector:@selector(pageView:didScrollAtIndex:)]) {
        [self.delegate pageView:self didScrollAtIndex:index];
    }
    
    previousPageIndex = index;

    [self insertSubview:[views objectAtIndex:index] aboveSubview:pageScrollView];
    [[views objectAtIndex:index] setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    [pageScrollView release];
    [views release];
    [super dealloc];
}

@end
