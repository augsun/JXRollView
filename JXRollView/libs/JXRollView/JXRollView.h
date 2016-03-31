//
//  JXRollView.h
//  JXRollView
//
//  Created by CoderSun on 9/25/15.
//  Copyright © 2015 AugSun. All rights reserved.
//

#import <UIKit/UIKit.h>

#define JXROLLVIEW_PLAY             @"JXRollViewPlay"               //JXRollView 播放
#define JXROLLVIEW_PAUSE            @"JXRollViewPause"              //JXRollView 暂停

@interface JXRollView : UIView

@property (nonatomic, strong) NSArray <NSURL *> *arrImgStrUrls;
@property (nonatomic, copy) void (^blockTapAction)(NSInteger);

-(void)jx_Free;

@end
