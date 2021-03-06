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
    NSMutableArray *views;
    NSInteger pageCount;
    UIScrollView *pageScrollView;
    NSInteger previousPageIndex;
}

@property (nonatomic, assign) id <PFPageViewDataSource> dataSource;
@property (nonatomic, assign) id <PFPageViewDelegate> delegate;
@property (nonatomic, assign) NSInteger pageIndex;

- (UIView *)viewForPageIndex:(NSInteger)index;
@end


@protocol PFPageViewDataSource <NSObject>
- (NSInteger)numberOfPagesInPageView:(PFPageView *)pageView;
- (UIView *)viewForPageView:(PFPageView *)pageView atIndex:(NSInteger)index;
@end

@protocol PFPageViewDelegate <NSObject>
@optional
- (void)pageView:(PFPageView *)pageView willUnloadView:(UIView *)view atIndex:(NSInteger)index;
- (void)viewWillDisappear:(UIView *)view atIndex:(NSInteger)index;
- (void)viewWillAppear:(UIView *)view atIndex:(NSInteger)index;
@end