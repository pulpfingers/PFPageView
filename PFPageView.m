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
- (void)loadView:(UIView *)newView atIndex:(NSInteger)index;
- (NSInteger)visiblePage;
@end

@implementation PFPageView

@synthesize pageViewDelegate;
@synthesize pageViewDataSource;
@synthesize pageIndex;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        views = [[NSMutableArray alloc] init];
        //[self setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        //[self setPagingEnabled:YES];
        [self setDelegate:self];
        [self setUserInteractionEnabled:YES];
        [self setBackgroundColor:[UIColor redColor]];
    }
    return self;
}

- (void)setDataSource:(id<PFPageViewDataSource>)newDataSource {
    pageViewDataSource = newDataSource;
    
    for (unsigned i = 0; i < [pageViewDataSource numberOfPagesInPageView:self]; i++) {
        [views addObject:[NSNull null]];
    }
        
    [self setContentSize:CGSizeMake([pageViewDataSource numberOfPagesInPageView:self] * 320, 480)];
}

- (void)setPageIndex:(NSInteger)newPageIndex {
    
    pageIndex = newPageIndex;
    
#warning Toute la partie taille de l'écran est à factoriser
    CGFloat screenWidth;
    CGFloat screenHeight;
    
    if(UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        screenWidth = 320.0f;
        screenHeight = 480.0f;        
    } else {
        screenWidth = 480.0f;
        screenHeight = 320.0f;
    }
    
    [self loadView:[self.pageViewDataSource pageView:self atIndex:pageIndex] atIndex:pageIndex];
    [self scrollRectToVisible:CGRectMake(320.0 * pageIndex, 0.0, screenWidth, screenHeight) animated:NO];
}

- (NSInteger)pageIndex {
    CGFloat screenWidth;
    
    if(UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        screenWidth = 320.0f;
    } else {
        screenWidth = 480.0f;
    }
    
    int index = floor((self.contentOffset.x - screenWidth / 2) / screenWidth) + 1;
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

- (void)loadView:(UIView *)newView atIndex:(NSInteger)index {

	if (index < 0) return;
    if (index >= [views count]) return;
    
    UIView *currentView = [views objectAtIndex:index];
    
    if ((NSNull *)currentView == [NSNull null]) {
        [views replaceObjectAtIndex:index withObject:newView];
    }
    
	CGRect frame = self.bounds;		
	frame.origin.x = frame.size.width * index;
	frame.origin.y = 0;
	newView.frame = frame;
	
    if (newView.superview == nil) {
		[self addSubview:newView];
	}
}

#pragma mark -
#pragma ScrollView delegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    int index = [self pageIndex];
    
    if(index - 2 >=0)[self unloadScrollViewAtIndex:index - 2];
    if(index - 1 >=0)[self loadView:[self.pageViewDataSource pageView:self atIndex:index - 1] atIndex:index - 1];
    
    if(index < [self.pageViewDataSource numberOfPagesInPageView:self]) {
        [self loadView:[self.pageViewDataSource pageView:self atIndex:index] atIndex:index];
    }
    
    if(index + 1 < [self.pageViewDataSource numberOfPagesInPageView:self]) {
        [self loadView:[self.pageViewDataSource pageView:self atIndex:index + 1] atIndex:index + 1];
    }
    
    if(index + 2 < [self.pageViewDataSource numberOfPagesInPageView:self]) {
        [self unloadScrollViewAtIndex:index + 2];
    }
    
    // Send didScrollAtIndex 
    if([self.pageViewDelegate respondsToSelector:@selector(pageView:didScrollAtIndex:)]) {
        [self.pageViewDelegate pageView:self didScrollAtIndex:index];
    }
}

- (void)dealloc {
    [views release];
    [super dealloc];
}

@end
