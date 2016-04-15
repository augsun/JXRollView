//
//  JXRollView.m
//  JXRollView
//
//  Created by CoderSun on 9/25/15.
//  Copyright © 2015 AugSun. All rights reserved.
//

#import "JXRollView.h"
#import "UIImageView+WebCache.h"

#define IMGVIEW_TAG_BASE            666         //
#define INTERVAL_ANIM_DEF           3.0f        // 滚动动画间隔
#define SPA_INTERITEM               8           // 滚动图片的间距

#define JXPAGECTL_H                 20.f        // JXPageCtl 的高 (JXPAGECTL_H 要大于 INDICATOR_SIDES)
#define JXPAGECTL_TO_BOTTOM         5.f         // JXPageCtl 到底部的距离

//以下宏定义只对 indicatorImage 有效
#define INDICATOR_SIDES             11.f        // indicator 宽高 (JXPAGECTL_H 要大于 INDICATOR_SIDES)(具体由设计决定)
#define INDICATOR_SPA_INTERITEM     8.f         // 两个 indicator 之间的距离

typedef NS_ENUM(NSInteger, JXRollDirection) {
    JXRollDirectionToLeft = 1,
    JXRollDirectionTORight,
};

//====================================================================================================
#pragma mark -
@interface JXPageControl : UIView

@property (nonatomic, assign) NSUInteger                numberOfPages;
@property (nonatomic, assign) NSUInteger                currentPage;

@property (nonatomic, strong) UIImage                   *imgIndicatorNormal;
@property (nonatomic, strong) UIImage                   *imgIndicatorHighlight;

@end

@implementation JXPageControl {
    NSMutableArray <UIImageView *> *_arrImgViews;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _arrImgViews = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setNumberOfPages:(NSUInteger)numberOfPages {
    _numberOfPages = numberOfPages;
    NSInteger currentNumberOfPages = _arrImgViews.count;
    for (NSInteger i = _arrImgViews.count; i < numberOfPages - currentNumberOfPages; i ++) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                             (self.frame.size.height-INDICATOR_SIDES)/2,
                                                                             INDICATOR_SIDES,
                                                                             INDICATOR_SIDES)];
        [self addSubview:imgView];
        [_arrImgViews addObject:imgView];
    }
    
    CGFloat wIndicator = _arrImgViews.count*(INDICATOR_SPA_INTERITEM + INDICATOR_SIDES) - INDICATOR_SPA_INTERITEM;
    CGFloat xLocFirstImgView = (self.frame.size.width - wIndicator)/2;
    for (NSInteger i = 0; i < _arrImgViews.count; i ++) {
        UIImageView *imgViewTemp = _arrImgViews[i];
        CGRect rectTemp = imgViewTemp.frame;
        rectTemp.origin.x = xLocFirstImgView + i*(INDICATOR_SPA_INTERITEM + INDICATOR_SIDES);
        imgViewTemp.frame = rectTemp;
        imgViewTemp.image = i == _currentPage ? _imgIndicatorHighlight : _imgIndicatorNormal;
    }
}

- (void)setCurrentPage:(NSUInteger)currentPage {
    _arrImgViews[_currentPage].image = _imgIndicatorNormal;
    _arrImgViews[currentPage].image = _imgIndicatorHighlight;
    _currentPage = currentPage;
}

@end

//====================================================================================================
#pragma mark -
@interface JXRollView () <UIScrollViewDelegate>

@property (nonatomic, strong)   NSArray <NSURL *>       *arrUrls;
@property (nonatomic, assign)   CGFloat                 widthSelf;                  //width of JXRollView
@property (nonatomic, assign)   CGFloat                 heightSelf;                 //height of JXRollView
@property (nonatomic, strong)   UIScrollView            *scrollView;
@property (nonatomic, strong)   UIPageControl           *sysPagCtl;                 // 系统 UIPageControl;
@property (nonatomic, strong)   JXPageControl           *jxPageCtl;                 // 自定义 JXPageControl

@property (nonatomic, assign)   NSInteger               pageCurrent;
@property (nonatomic, assign)   NSInteger               pageTotal;
@property (nonatomic, strong)   NSMutableArray          *arrImages;                 //
@property (nonatomic, strong)   UIImage                 *imgPlaceholder;
@property (nonatomic, assign)   NSTimeInterval          animateInterval;
@property (nonatomic, strong)   NSTimer                 *timer;                     //定时器

@property (nonatomic, assign)   BOOL                    isIndicatorImagePageControl;

@end

@implementation JXRollView

- (JXRollView *)initWithFrame:(CGRect)frame
         indicatorColorNormal:(UIColor *)indicatorColorNormal
      indicatorColorHighlight:(UIColor *)indicatorColorHighlight
              animateInterval:(NSTimeInterval)animateInterval
                    tapAction:(JXBlockTapAction)tapAction {
    if (self = [super initWithFrame:frame]) {
        [self createComponentWithFrame:frame
                  indicatorColorNormal:indicatorColorNormal
               indicatorColorHighlight:indicatorColorHighlight
                  indicatorImageNormal:nil
               indicatorImageHighlight:nil
                       animateInterval:(NSTimeInterval)animateInterval
                             tapAction:tapAction];
    }
    return self;
}

- (JXRollView *)initWithFrame:(CGRect)frame
         indicatorImageNormal:(UIImage *)indicatorImageNormal
      indicatorImageHighlight:(UIImage *)indicatorImageHighlight
              animateInterval:(NSTimeInterval)animateInterval
                    tapAction:(JXBlockTapAction)tapAction {
    if (self = [super initWithFrame:frame]) {
        [self createComponentWithFrame:frame
                  indicatorColorNormal:nil
               indicatorColorHighlight:nil
                  indicatorImageNormal:indicatorImageNormal
               indicatorImageHighlight:indicatorImageHighlight
                       animateInterval:(NSTimeInterval)animateInterval
                             tapAction:tapAction];
    }
    return self;
}

- (void)createComponentWithFrame:(CGRect)frame
            indicatorColorNormal:(UIColor *)indicatorColorNormal
         indicatorColorHighlight:(UIColor *)indicatorColorHighlight
            indicatorImageNormal:(UIImage *)indicatorImageNormal
         indicatorImageHighlight:(UIImage *)indicatorImageHighlight
                 animateInterval:(NSTimeInterval)animateInterval
                       tapAction:(JXBlockTapAction)tapAction {
    _widthSelf = frame.size.width;
    _heightSelf = frame.size.height;
    _isIndicatorImagePageControl = indicatorImageNormal && indicatorImageHighlight;
    _animateInterval = animateInterval < 1 ? INTERVAL_ANIM_DEF : animateInterval;
    _blockTapAction = tapAction;
    
    _arrImages = [[NSMutableArray alloc] init];
    _imgPlaceholder = [[UIImage alloc] init];
    
    // _scrollView
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _widthSelf + SPA_INTERITEM, _heightSelf)];
    [self addSubview:_scrollView];
    [_scrollView setContentSize:CGSizeMake(3*(_widthSelf + SPA_INTERITEM), _heightSelf)];
    [_scrollView setContentOffset:CGPointMake(_widthSelf + SPA_INTERITEM, 0)];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setPagingEnabled:YES];
    [_scrollView setScrollsToTop:NO];
    [_scrollView setDelegate:self];
    
    // _pagCtl
    CGRect rectPageCtlFrame = CGRectMake(0, _heightSelf - JXPAGECTL_H - JXPAGECTL_TO_BOTTOM, _widthSelf, JXPAGECTL_H);
    if (_isIndicatorImagePageControl) {
        _jxPageCtl = [[JXPageControl alloc] initWithFrame:rectPageCtlFrame];
        [self addSubview:_jxPageCtl];
        [_jxPageCtl setImgIndicatorNormal:indicatorImageNormal];
        [_jxPageCtl setImgIndicatorHighlight:indicatorImageHighlight];
    }
    else {
        _sysPagCtl = [[UIPageControl alloc] initWithFrame:rectPageCtlFrame];
        if (indicatorColorNormal) {
            [_sysPagCtl setPageIndicatorTintColor:indicatorColorNormal];
        }
        if (indicatorColorHighlight) {
            [_sysPagCtl setCurrentPageIndicatorTintColor:indicatorColorHighlight];
        }
        [self addSubview:_sysPagCtl];
        [_sysPagCtl setUserInteractionEnabled:NO];
    }
    
    // 3 个复用的 UIImageView
    for (NSInteger i = 0; i < 3; i ++) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(i * (_widthSelf + SPA_INTERITEM), 0, _widthSelf, _heightSelf)];
        [_scrollView addSubview:imgView];
        [imgView setContentMode:UIViewContentModeScaleAspectFill];
        [imgView setClipsToBounds:YES];
        [imgView setTag:IMGVIEW_TAG_BASE + i];
        [imgView setImage:_imgPlaceholder];
    }
    
    // _timer
    _timer = [[NSTimer alloc] initWithFireDate:[NSDate distantFuture]
                                      interval:_animateInterval
                                        target:self
                                      selector:@selector(timerTicking)
                                      userInfo:nil
                                       repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
    // 背景颜色
    self.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0f];
    
    // 事件响应链条
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self addGestureRecognizer:tap];
    
    // 当 JXRollView 不在屏幕上显示的时候(push 或 present 新视图控制器 或 程序进入后台)，应该暂停滚动。
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jxRollViewPause) name:JXROLLVIEW_PAUSE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jxRollViewPlay) name:JXROLLVIEW_PLAY object:nil];
    
    
}


- (void)jx_RefreshRollViewByUrls:(NSArray<NSURL *> *)urls {
    _arrUrls = urls;
    _pageTotal = urls.count;
    if (_pageTotal > 0) {
        if (_isIndicatorImagePageControl) {
            _jxPageCtl.numberOfPages = _pageTotal;
        }
        else {
            _sysPagCtl.numberOfPages = _pageTotal;
        }
        for (NSInteger i = 0; i < _arrUrls.count; i ++) {
            UIImageView *imgView = [[UIImageView alloc] init];
            [_arrImages addObject:_imgPlaceholder];
            [imgView sd_setImageWithURL:_arrUrls[i] placeholderImage:_imgPlaceholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image) [_arrImages setObject:image atIndexedSubscript:i];
            }];
        }
        [self setImgs];
        [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:_animateInterval]];
    }
}

#pragma mark - <UIScrollViewDelegate>
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_timer setFireDate:[NSDate distantFuture]];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:_animateInterval]];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat xOffSet = scrollView.contentOffset.x;
    if (xOffSet < _widthSelf / 2.f + SPA_INTERITEM / 2.f) {
        scrollView.contentOffset = CGPointMake(_widthSelf + xOffSet + SPA_INTERITEM, 0);
        [self rollPageByMethod:JXRollDirectionTORight];
    }
    if (xOffSet > _widthSelf * 1.5f + SPA_INTERITEM * 1.5) {
        scrollView.contentOffset = CGPointMake(xOffSet - _widthSelf - SPA_INTERITEM, 0);
        [self rollPageByMethod:JXRollDirectionToLeft];
    }
}

#pragma mark - 偏移过半进行移位复用
-(void)rollPageByMethod:(JXRollDirection)rollDirection {
    switch (rollDirection) {
        case JXRollDirectionTORight: {
            _pageCurrent --;
            if (_pageCurrent < 0) {
                _pageCurrent = _pageTotal - 1;
            }
        } break;
            
        case JXRollDirectionToLeft: {
            _pageCurrent ++;
            if (_pageCurrent > _pageTotal-1) {
                _pageCurrent = 0;
            }
        } break;
            
        default: break;
    }
    if (_isIndicatorImagePageControl) {
        _jxPageCtl.currentPage = _pageCurrent;
    }
    else {
        _sysPagCtl.currentPage = _pageCurrent;
    }
    [self setImgs];
}

-(void)setImgs {
    for (NSInteger i = 0; i < 3; i ++) {
        NSInteger getIndex = _pageCurrent-1+i;
        if (getIndex < 0)
            getIndex = _pageTotal-1;
        if (getIndex > _pageTotal-1)
            getIndex = 0;
        UIImageView *imgView = (UIImageView *)[_scrollView viewWithTag:i + IMGVIEW_TAG_BASE];
        imgView.image = _imgPlaceholder;
        if (_arrImages.count > getIndex) {
            if (_arrImages[getIndex] == _imgPlaceholder) {
                [imgView sd_setImageWithURL:_arrUrls[getIndex] placeholderImage:_imgPlaceholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (image) {
                        [_arrImages setObject:image atIndexedSubscript:getIndex];
                    }
                }];
            }
            else imgView.image = _arrImages[getIndex];
        }
    }
}

#pragma mark - timerTicking
-(void)timerTicking {
    CGPoint tempOffSet = self.scrollView.contentOffset;
    tempOffSet.x = (self.widthSelf + SPA_INTERITEM) * 2;
    [self.scrollView setContentOffset:tempOffSet animated:YES];
}

#pragma mark - 收到 暂停/播放 通知
-(void)jxRollViewPause {
    [self.timer setFireDate:[NSDate distantFuture]];
}

-(void)jxRollViewPlay {
    [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:_animateInterval]];
}

#pragma mark - tap 事件回调
-(void)tapAction {
    if (self.blockTapAction)
        if (self.arrImages[self.pageCurrent] != self.imgPlaceholder)
            self.blockTapAction (self.pageCurrent);
}

#pragma mark - 释放定时器以释放 JXRollView
-(void)jx_Free {
    self.scrollView.delegate = nil;
    [self.timer invalidate];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"dealloc -> %@",NSStringFromClass([self class]));
}

















/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end









