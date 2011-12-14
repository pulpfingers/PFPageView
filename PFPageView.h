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

@interface PFPageView : UIView {
    
}

@property (nonatomic, assign) id <PFPageViewDataSource> dataSource;
@property (nonatomic, assign) id <PFPageViewDelegate> delegate;

@end


@protocol PFPageViewDataSource <NSObject>
- (NSInteger)pageView:(PFPageView *)pageView numberOfPages:(UIView *)pagingView;
- (UIView *)pageView:(PFPageView *)pageView viewForPage:(UIView *)newView atIndex:(NSInteger)index;
@end

@protocol PFPageViewDelegate <NSObject>
- (void)pageView:(PFPageView *)pageView didScrollAtIndex:(NSInteger)index;
@end