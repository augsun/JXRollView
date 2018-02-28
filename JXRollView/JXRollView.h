//
//  JXRollView.h
//  JXRollView
//
//  Created by CoderSun on 9/25/15.
//  Copyright © 2015 AugSun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JXRollView;

@protocol JXRollViewDelegate <NSObject>

@required

/**
 *  Ask the delegate to return the number of items in the JXRollView.
 *  返回 JXRollView 的图片张数.
 *
 *  @param rollView  An object representing the JXRollview requesting this information.
 *  @param rollView  一个表示请求该信息的 JXRollview 对象.
 *
 *  @return The number of items in the JXRollView.
 *  @return 返回 JXRollView 的图片张数
 */
- (NSInteger)numberOfItemsInRollView:(nonnull JXRollView *)rollView;

/**
 *  Set image. Recommend use [[SDWebImageManager sharedManager] downloadImageWithURL:options:progress:completed:] method to set image, Because [sd_setImageWithURL:] will call [sd_cancelCurrentImageLoad] and interrupt the half of downloading, and the half of image downloaded will be discarded, it will cause great waste while JXRollView frequent rolling in poor network condition. And you don't have to worry about imageView reused.
 *  设置图片, 推荐使用 [[SDWebImageManager sharedManager] downloadImageWithURL:options:progress:completed:] 方法设置图片, 因为 [sd_setImageWithURL:] 方法会调用 [sd_cancelCurrentImageLoad] 而中断当前正在下载的图片, 下载到一半的图片将被忽略, 如果 JXRollView 在差的网络情形下快速滑动将造成极大的浪费. 同时你不必担心 imageView 的复用问题.
 *
 *  @param rollView  The JXRollView object requesting this information.
 *  @param rollView  请求该信息的 JXRollView 对象.
 *  @param imageView The UIImageView who ask for image.
 *  @param imageView 请求图片的 UIImageView.
 *  @param index     The index of imageView in JXRollView.
 *  @param index     imageView 的位置.
 */
- (void)rollView:(nonnull JXRollView *)rollView setImageForImageView:(nonnull UIImageView *)imageView atIndex:(NSInteger)index;

@optional

/**
 *  Tap action call back.
 *  点击事件回调
 *
 *  @param rollView  The JXRollView object requesting this information.
 *  @param rollView  请求该信息的 JXRollView 对象.
 *  @param index     Index of tap.
 *  @param index     点击所在位置.
 */
- (void)rollView:(nonnull JXRollView *)rollView didTapItemAtIndex:(NSInteger)index;

@end

NS_CLASS_AVAILABLE_IOS(8_0) @interface JXRollView : UIView

/**
 *  JXRollView's delegate, (Similar to UITableView.)
 *  JXRollView 代理, (与 UITableView 类似.)
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
@property (nonatomic, assign) BOOL autoRolling;

/**
 *  Auto scroll time interval[1.6, 6.0]s. Default is 3s.
 *  自动滚动时间间隔 [1.6, 6.0]s 默认 3s.
 */
@property (nonatomic, assign) CGFloat autoRollingTimeInterval;

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

// 隐藏后可自定义页面指示器
@property (nonatomic, assign) BOOL hideIndicatorOrUseCustom;

/**
 *  Similar to UITableView.
 *  与 UITableView 类似
 */
- (void)reloadData;

// 由子类实现
- (void)pageDidChanged:(NSInteger)currentPage totalPages:(NSInteger)totalPages;

@end

@interface JXRollView (deprecated)

/**
 *  Invalidate timer of JXRollView.
 *  释放 JXRollView 的定时器.
 */
- (void)free __deprecated_msg("不再需要调用该方法.");

@end


















