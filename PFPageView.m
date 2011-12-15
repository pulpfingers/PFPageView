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
- (void)loadView:(UIView *)newView AtIndex:(NSInteger)index;
- (NSInteger)visiblePage;
@end

@implementation PFPageView

@synthesize delegate;
@synthesize dataSource;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        views = [[NSMutableArray alloc] init];
        rootScrollView = [[UIScrollView alloc] initWithFrame:frame];
        [rootScrollView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth |
                                             UIViewAutoresizingFlexibleHeight)];
        [rootScrollView setPagingEnabled:YES];
        [rootScrollView setDelegate:self];
        [self addSubview:rootScrollView];
    }
    return self;
}

- (void)setDataSource:(id<PFPageViewDataSource>)newDataSource {
    dataSource = newDataSource;
    
    for (unsigned i = 0; i < [dataSource numberOfPagesInPageView:self]; i++) {
        [views addObject:[NSNull null]];
    }
    
    [rootScrollView setContentSize:CGSizeMake([dataSource numberOfPagesInPageView:self] * 480, 320)];
}

- (void)startAtPageIndex:(NSInteger)pageIndex {
    CGFloat screenWidth;
    CGFloat screenHeight;
    
    if(UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        screenWidth = 320.0f;
        screenHeight = 480.0f;        
    } else {
        screenWidth = 480.0f;
        screenHeight = 320.0f;
    }

    [self loadView:[self.dataSource pageView:self atIndex:pageIndex] AtIndex:pageIndex];
    [rootScrollView scrollRectToVisible:CGRectMake(320.0 * pageIndex, 0.0, screenWidth, screenHeight) animated:NO];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark -
#pragma mark Private methods

- (NSInteger)visiblePageIndex {
    CGFloat screenWidth;
    
    if(UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        screenWidth = 320.0f;
    } else {
        screenWidth = 480.0f;
    }
    
    int index = floor((rootScrollView.contentOffset.x - screenWidth / 2) / screenWidth) + 1;
    return index;
}

- (void)unloadScrollViewAtIndex:(NSInteger)index {
	if (index < 0) return;
    if (index >= [views count]) return;
    
    UIView *currentView = [views objectAtIndex:index];
    
	if ((NSNull *)currentView != [NSNull null]) {
        [currentView removeFromSuperview];
    }
	
	[views replaceObjectAtIndex:index withObject:[NSNull null]];
}

- (void)loadView:(UIView *)newView AtIndex:(NSInteger)index {

	if (index < 0) return;
    if (index >= [views count]) return;
    
    UIView *currentView = [views objectAtIndex:index];
    
    if ((NSNull *)currentView == [NSNull null]) {
        [views replaceObjectAtIndex:index withObject:newView];
    }
    
	CGRect frame = rootScrollView.bounds;		
	frame.origin.x = frame.size.width * index;
	frame.origin.y = 0;
	newView.frame = frame;
	
    if (newView.superview == nil) {
		[rootScrollView addSubview:newView];
	}
}

#pragma mark -
#pragma ScrollView delegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    int index = [self visiblePageIndex];
    
    if(index - 2 >=0)[self unloadScrollViewAtIndex:index - 2];
    if(index - 1 >=0)[self loadView:[self.dataSource pageView:self atIndex:index - 1] AtIndex:index - 1];
    
    if(index < [self.dataSource numberOfPagesInPageView:self]) {
        [self loadView:[self.dataSource pageView:self atIndex:index] AtIndex:index];
    }
    
    if(index + 1 < [self.dataSource numberOfPagesInPageView:self]) {
        [self loadView:[self.dataSource pageView:self atIndex:index + 1] AtIndex:index + 1];
    }
    
    if(index + 2 < [self.dataSource numberOfPagesInPageView:self]) {
        [self unloadScrollViewAtIndex:index + 2];
    }
    
    // Send didScrollAtIndex 
    if([self.delegate respondsToSelector:@selector(pageView:didScrollAtIndex:)]) {
        [self.delegate pageView:self didScrollAtIndex:index];
    }
    
}

- (void)dealloc {
    [views release];
    [rootScrollView release];
    [super dealloc];
}

@end
