//
//  JXRollView.h
//  JXRollView
//
//  Created by CoderSun on 9/25/15.
//  Copyright © 2015 AugSun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol JXRollViewDelegate;

NS_CLASS_AVAILABLE_IOS(8_0) @interface JXRollView : UIView

/**
 *  代理 (使用与 UITableView 代理类似)
 */
@property (nonatomic, weak, nullable) id <JXRollViewDelegate> delegate;

/**
 *  占拉图片
 */
@property (nonatomic, strong, nonnull) UIImage *placeholderImage;

/**
 *  图片模式 默认 UIViewContentModeScaleAspectFill
 */
@property (nonatomic, assign) UIViewContentMode imageContentMode;

/**
 *  图片之间的间距 默认 8pt
 */
@property (nonatomic, assign) CGFloat interitemSpacing;

/**
 *  是否自动滚动 默认 YES
 */
@property (nonatomic, assign) BOOL autoRoll;

/**
 *  自动滚动时间间隔 (>= 1 && <= 5) 默认 3s
 */
@property (nonatomic, assign) CGFloat autoRollTimeInterval;

/**
 *  页面指示器距底部的距离 默认 8pt
 */
@property (nonatomic, assign) CGFloat indicatorToBottomSpace;

/**
 *  Hide the indicator if there is only one item. default is NO
 */
@property (nonatomic, assign) BOOL hidesForSinglePage;

/**
 *  Create a JXRollView with color indicator.
 *
 *  @param frame                     Frame
 *  @param pageIndicatorColor        Custom color for page indicator.
 *  @param currentPageIndicatorColor Custom color for current page indicator.
 *
 *  @return An instance of JXRollView with the indicator is color.
 */
- (nonnull JXRollView *)initWithFrame:(CGRect)frame
                   pageIndicatorColor:(nullable UIColor *)pageIndicatorColor
            currentPageIndicatorColor:(nullable UIColor *)currentPageIndicatorColor;

/**
 *  Create a JXRollView with image indicator.
 *
 *  @param frame                      Frame
 *  @param pageIndicatorImage         Custom iamge for page indicator, image size ( >= 4 && <= 18)pt.
 *  @param currentPageIndicatorImage  Custom iamge for current page indicator,image size ( >= 4 && <= 18)pt
 *
 *  @return An instance of JXRollView with the indicator is image.
 */
- (nonnull JXRollView *)initWithFrame:(CGRect)frame
                   pageIndicatorImage:(nullable UIImage *)pageIndicatorImage
            currentPageIndicatorImage:(nullable UIImage *)currentPageIndicatorImage;

- (void)reloadData;
- (void)free;

@end

@protocol JXRollViewDelegate <NSObject>

@required
- (NSInteger)numberOfItemsInRollView:(nonnull JXRollView *)rollView;
- (nonnull NSURL *)rollView:(nonnull JXRollView *)rollView urlForItemAtIndex:(NSInteger)index;

@optional
- (void)rollView:(nonnull JXRollView *)rollView didSelectItemAtIndex:(NSInteger)index;

@end








