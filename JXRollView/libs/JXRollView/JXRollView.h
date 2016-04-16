//
//  JXRollView.h
//  JXRollView
//
//  Created by CoderSun on 9/25/15.
//  Copyright © 2015 AugSun. All rights reserved.
//

//  JXRollView (https://github.com/augsun/JXRollView)
//  JXRollView 是一个依赖于 SDWebImage 无限循环滚动（轮播）视图，内部由 3 个 UIImageView 复用实现。
//  JXRollView 实现方式极其简单，可创建两种不同 pageControl 的 JXRollView（详见Demo，可自行选择一种实现）。
//  JXRollView 只要传入 图片 url 数组即可。


#import <UIKit/UIKit.h>

@interface JXRollView : UIView

typedef void (^JXBlockTapAction)(NSInteger tapIndex);

@property (nonatomic, copy) JXBlockTapAction blockTapAction;

/**
 *  创建 pageControl 为自定义图片 的 JXRollView
 *
 *  @param frame                   frame
 *  @param indicatorImageNormal    非当前 indicator 图片 (图片默认宽高 11，需要修改在 .m 文件中修改宏 INDICATOR_SIDES) （为空则生成 pageControl 为自定义颜色 的 JXRollView）
 *  @param indicatorImageHighlight 当前 indicator 图片 （为空则生成 pageControl 为自定义颜色 的 JXRollView）
 *  @param animateInterval         滚动动画间隔 (不 <1, 不 >8)
 *  @param tapAction               tap 事件回调 （回调块中应该注意循环引用问题）
 *
 *  @return JXRollView 实例
 */
- (JXRollView *)initWithFrame:(CGRect)frame
         indicatorImageNormal:(UIImage *)indicatorImageNormal
      indicatorImageHighlight:(UIImage *)indicatorImageHighlight
              animateInterval:(NSTimeInterval)animateInterval
                    tapAction:(JXBlockTapAction)tapAction;

/**
 *  创建 pageControl 为自定义颜色 的 JXRollView
 *
 *  @param frame                   frame
 *  @param indicatorColorNormal    非当前 indicator 颜色 （为空则使用系统默认）
 *  @param indicatorColorHighlight 当前 indicator 颜色 （为空则使用系统默认）
 *  @param animateInterval         滚动动画间隔 (不 <1, 不 >8)
 *  @param tapAction               tap 事件回调 （回调块中应该注意循环引用问题）
 *
 *  @return JXRollView 实例
 */
- (JXRollView *)initWithFrame:(CGRect)frame
         indicatorColorNormal:(UIColor *)indicatorColorNormal
      indicatorColorHighlight:(UIColor *)indicatorColorHighlight
              animateInterval:(NSTimeInterval)animateInterval
                    tapAction:(JXBlockTapAction)tapAction;

/**
 *  开始 或 刷新 JXRollView
 *
 *  @param urls 图片 url 数组
 */
- (void)jx_RefreshRollViewByUrls:(NSArray <NSURL *> *)urls;

/**
 *  父类释放的时候调用，以释放 JXRollView
 */
-(void)jx_Free;

@end









