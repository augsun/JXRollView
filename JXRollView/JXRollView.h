//
//  JXRollView.h
//  JXRollView
//
//  Created by CoderSun on 9/25/15.
//  Copyright © 2015 AugSun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class JXRollView;

@protocol JXRollViewDelegate <NSObject>

@required
- (NSInteger)numberOfItemsInRollView:(nonnull JXRollView *)rollView;
- (nonnull NSURL *)rollView:(nonnull JXRollView *)rollView urlForItemAtIndex:(NSInteger)index;

@optional
- (void)rollView:(nonnull JXRollView *)rollView didSelectItemAtIndex:(NSInteger)index;

@end

NS_CLASS_AVAILABLE_IOS(8_0) @interface JXRollView : UIView

/**
 *  JXRollView's delegate, (Use the delegate similar to UITableView.)
 *  JXRollView 的代理, (使用代理与 UITableView 类似.)
 */
@property (nonatomic, weak, nullable) id <JXRollViewDelegate> delegate;

/**
 *  Custom color for page and current page indicator.
 *  自定义指示器颜色.
 */
@property (nonatomic, strong, nullable) UIColor *pageIndicatorColor;
@property (nonatomic, strong, nullable) UIColor *currentPageIndicatorColor;

/**
 *  Custom image for page and current page indicator, both settings are valid and ignore setting of custom color.(image size[4, 18]pt.)
 *  自定义指示器的图片, 两者同时设置才有效果并且忽略指示器的颜色设置.(图片大小[4, 18]pt.)
 */
@property (nonatomic, strong, nullable) UIImage *pageIndicatorImage;
@property (nonatomic, strong, nullable) UIImage *currentPageIndicatorImage;

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
 *  Similar to UITableView.
 *  与 UITableView 类似
 */
- (void)reloadData;

/**
 *  Invalidate timer of JXRollView.
 *  释放 JXRollView 的定时器.
 */
- (void)free;

@end








