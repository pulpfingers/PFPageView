//
//  PFPageView.h
//  iso500
//
//  Created by Jérôme Scheer on 14/12/11.
//  Copyright (c) 2011 Pulpfingers. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PFPageViewDataSource;
@protocol PFPageViewDelegate;

@interface PFPageView : UIView <UIScrollViewDelegate> {
    UIScrollView *rootScrollView;
    NSMutableArray *views;
}

@property (nonatomic, assign) id <PFPageViewDataSource> dataSource;
@property (nonatomic, assign) id <PFPageViewDelegate> delegate;

- (void)startAtPageIndex:(NSInteger)pageIndex;

@end


@protocol PFPageViewDataSource <NSObject>
- (NSInteger)numberOfPagesInPageView:(PFPageView *)pageView;
- (UIView *)pageView:(PFPageView *)pageView atIndex:(NSInteger)index;
@end

@protocol PFPageViewDelegate <NSObject>
- (void)pageView:(PFPageView *)pageView didScrollAtIndex:(NSInteger)index;
@end