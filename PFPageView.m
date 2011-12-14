//
//  PFPageView.m
//  iso500
//
//  Created by Jérôme Scheer on 14/12/11.
//  Copyright (c) 2011 Pulpfingers. All rights reserved.
//

#import "PFPageView.h"

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
        [rootScrollView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
                                                                          UIViewAutoresizingFlexibleWidth |
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
    
    [rootScrollView setContentSize:CGSizeMake([dataSource numberOfPagesInPageView:self] * 320, 480)];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)unloadScrollViewAtIndex:(NSInteger)index {
	if (index < 0) return;
    if (index >= [views count]) return;
    
    UIView *currentView = [views objectAtIndex:index];
    
	if ((NSNull *)currentView != [NSNull null]) {
        [currentView removeFromSuperview];
        NSLog(@"REMOVE");
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    CGFloat screenWidth;
    
    if(UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        screenWidth = 320.0f;
    } else {
        screenWidth = 480.0f;
    }
    
    int index = floor((scrollView.contentOffset.x - screenWidth / 2) / screenWidth) + 1;
    
    
    if(index - 2 >= 0)[self unloadScrollViewAtIndex:index - 2];
    if(index -1  >= 0)[self loadView:[self.dataSource pageView:self atIndex:index - 1] AtIndex:index - 1];
    [self loadView:[self.dataSource pageView:self atIndex:index] AtIndex:index];
    [self loadView:[self.dataSource pageView:self atIndex:index + 1] AtIndex:index + 1];
    [self unloadScrollViewAtIndex:index + 2];
}



@end
