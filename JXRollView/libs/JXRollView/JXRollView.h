//
//  JXRollView.h
//  JXRollView
//
//  Created by CoderSun on 9/25/15.
//  Copyright © 2015 AugSun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JXRollView : UIView

typedef void (^JXBlockTapAction)(NSInteger tapIndex);

@property (nonatomic, copy)     JXBlockTapAction    blockTapAction;

/**
 *  创建 indicatorImage 的 JXRollView
 *
 *  @param frame                   frame
 *  @param indicatorImageNormal    非当前 indicator 图片 (图片默认宽高 11，需要修改在 .m 文件中修改宏 INDICATOR_SIDES)
 *  @param indicatorImageHighlight 当前 indicator 图片
 *  @param animateInterval         滚动动画间隔
 *  @param tapAction               tap 事件回调
 *
 *  @return JXRollView 实例
 */
- (JXRollView *)initWithFrame:(CGRect)frame
         indicatorImageNormal:(UIImage *)indicatorImageNormal
      indicatorImageHighlight:(UIImage *)indicatorImageHighlight
              animateInterval:(NSTimeInterval)animateInterval
                    tapAction:(JXBlockTapAction)tapAction;

/**
 *  创建 indicatorColor 的 JXRollView
 *
 *  @param frame                   frame
 *  @param indicatorColorNormal    非当前 indicator 颜色
 *  @param indicatorColorHighlight 当前 indicator 颜色
 *  @param animateInterval         滚动动画间隔
 *  @param tapAction               tap 事件回调
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









