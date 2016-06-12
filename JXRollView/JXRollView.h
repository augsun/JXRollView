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
 *  JXRollView's delegate, (Use the delegate similar to UITableView.)
 *  JXRollView 的代理, (使用代理与 UITableView 类似.)
 */
@property (nonatomic, weak, nullable) id <JXRollViewDelegate> delegate;

/**
 *  Placeholder image.
 *  占位图.
 */
@property (nonatomic, strong, nonnull) UIImage *placeholderImage;

/**
 *  View content model. Default is UIViewContentModeScaleAspectFill.
 *  视图的内容模式. 默认 UIViewContentModeScaleAspectFill.
 */
@property (nonatomic, assign) UIViewContentMode imageContentMode;

/**
 *  Inter item of image space. Default is 8pt.
 *  图片之间的间距 默认 8pt.
 */
@property (nonatomic, assign) CGFloat interitemSpacing;

/**
 *  Auto-scroll. Default is YES.
 *  自动滚动 默认 YES.
 */
@property (nonatomic, assign) BOOL autoRoll;

/**
 *  Auto scroll time interval(>= 1s && <= 5s). Default is 3s.
 *  自动滚动时间间隔 (>= 1s && <= 5s) 默认 3s.
 */
@property (nonatomic, assign) CGFloat autoRollTimeInterval;

/**
 *  Spacing from the bottom of self to page indicator. Default is 8pt.
 *  页面指示器距底部的距离 默认 8pt.
 */
@property (nonatomic, assign) CGFloat indicatorToBottomSpacing;

/**
 *  Hide the indicator if there is only one item, and then scroll is disabled. Default is NO.
 *  如果只有一张图片时自动隐藏指示器, 同时滚动禁用. 默认 NO.
 */
@property (nonatomic, assign) BOOL hideIndicatorForSinglePage;

/**
 *  Create a JXRollView of system style with custom color🔴 indicator.
 *  创建系统样式页面指示器为自定义颜色的 JXRollView.
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
 *  Create a JXRollView with custom image🌋 indicator.
 *  创建页面指示器为自定义图片的 JXRollView.
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

/**
 *  Similar to UITableView.
 */
- (void)reloadData;

/**
 *  <#Description#>
 */
- (void)free;

@end

@protocol JXRollViewDelegate <NSObject>

@required
- (NSInteger)numberOfItemsInRollView:(nonnull JXRollView *)rollView;
- (nonnull NSURL *)rollView:(nonnull JXRollView *)rollView urlForItemAtIndex:(NSInteger)index;

@optional
- (void)rollView:(nonnull JXRollView *)rollView didSelectItemAtIndex:(NSInteger)index;

@end








