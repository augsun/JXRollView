//
//  JXRollView.m
//  JXRollView
//
//  Created by CoderSun on 9/25/15.
//  Copyright © 2015 AugSun. All rights reserved.
//

#import "JXRollView.h"
#import "UIImageView+WebCache.h"

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

typedef NS_ENUM(NSUInteger, JXRollViewPageType) {
    JXRollViewPageTypeImage = 1,
    JXRollViewPageTypeColor
};

//====================================================================================================
#pragma mark -
@interface JXPageControl : UIView

@property (nonatomic, assign) NSUInteger        currentPage;
@property (nonatomic, assign) NSUInteger        numberOfPages;

@property (nonatomic, strong) UIImage           *imgIndicatorNormal;
@property (nonatomic, strong) UIImage           *imgIndicatorHighlight;

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
    for (NSInteger i = _arrImgViews.count; i < _numberOfPages - currentNumberOfPages; i ++) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                             (self.frame.size.height-INDICATOR_SIDES)/2,
                                                                             INDICATOR_SIDES,
                                                                             INDICATOR_SIDES)];
        [self addSubview:imgView];
        [_arrImgViews addObject:imgView];
    }
    
    CGFloat wIndicator = _arrImgViews.count*(INDICATOR_SPA_INTERITEM + INDICATOR_SIDES) - INDICATOR_SPA_INTERITEM;
    CGFloat xLocFirstImgView = (self.frame.size.width - wIndicator) / 2;
    for (NSInteger i = 0; i < _arrImgViews.count; i ++) {
        UIImageView *imgViewTemp = _arrImgViews[i];
        CGRect rectTemp = imgViewTemp.frame;
        rectTemp.origin.x = xLocFirstImgView + i * (INDICATOR_SPA_INTERITEM + INDICATOR_SIDES);
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
@property (nonatomic, assign)   CGFloat                 selfWidth;              //width of JXRollView
@property (nonatomic, assign)   CGFloat                 selfHeight;             //height of JXRollView
@property (nonatomic, strong)   UIScrollView            *scrollView;
@property (nonatomic, strong)   JXPageControl           *pageControlImage;      // 自定义图片 pageControl
@property (nonatomic, strong)   UIPageControl           *pageControlColor;      // 自定义颜色 pageControl
@property (nonatomic, assign)   JXRollViewPageType      rollViewPageType;       // pageControl 类型

@property (nonatomic, assign)   NSInteger               currentPage;            // 当前页
@property (nonatomic, assign)   NSInteger               numberOfPages;          // 总页数
@property (nonatomic, strong)   NSMutableArray <UIImage *>      *arrImages;     //
@property (nonatomic, strong)   NSMutableArray <UIImageView *>  *arrImvViews;   //
@property (nonatomic, strong)   UIImage                 *imgPlaceholder;
@property (nonatomic, assign)   NSTimeInterval          animateInterval;
@property (nonatomic, strong)   NSTimer                 *timer;                 //定时器

@end

@implementation JXRollView {
    
}

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

// xib
- (void)createComponentWithFrame:(CGRect)frame
            indicatorColorNormal:(UIColor *)indicatorColorNormal
         indicatorColorHighlight:(UIColor *)indicatorColorHighlight
            indicatorImageNormal:(UIImage *)indicatorImageNormal
         indicatorImageHighlight:(UIImage *)indicatorImageHighlight
                 animateInterval:(NSTimeInterval)animateInterval
                       tapAction:(JXBlockTapAction)tapAction {
    _selfWidth = frame.size.width;
    _selfHeight = frame.size.height;
    _rollViewPageType = indicatorImageNormal && indicatorImageHighlight ? JXRollViewPageTypeImage : JXRollViewPageTypeColor;
    _animateInterval = animateInterval < 1 || animateInterval > 8 ? INTERVAL_ANIM_DEF : animateInterval;
    _blockTapAction = tapAction;
    
    _arrImages = [[NSMutableArray alloc] init];
    _arrImvViews = [[NSMutableArray alloc] init];
    _imgPlaceholder = [[UIImage alloc] init];
    
    // _scrollView
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _selfWidth + SPA_INTERITEM, _selfHeight)];
    [self addSubview:_scrollView];
    [_scrollView setContentSize:CGSizeMake(3*(_selfWidth + SPA_INTERITEM), _selfHeight)];
    [_scrollView setContentOffset:CGPointMake(_selfWidth + SPA_INTERITEM, 0)];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setPagingEnabled:YES];
    [_scrollView setScrollsToTop:NO];
    [_scrollView setDelegate:self];
    
    // _pagCtl
    CGRect rectPageCtlFrame = CGRectMake(0, _selfHeight - JXPAGECTL_H - JXPAGECTL_TO_BOTTOM, _selfWidth, JXPAGECTL_H);
    if (_rollViewPageType == JXRollViewPageTypeImage) {
        _pageControlImage = [[JXPageControl alloc] initWithFrame:rectPageCtlFrame];
        [self addSubview:_pageControlImage];
        [_pageControlImage setImgIndicatorNormal:indicatorImageNormal];
        [_pageControlImage setImgIndicatorHighlight:indicatorImageHighlight];
    }
    else {
        _pageControlColor = [[UIPageControl alloc] initWithFrame:rectPageCtlFrame];
        [self addSubview:_pageControlColor];
        if (indicatorColorNormal) {
            [_pageControlColor setPageIndicatorTintColor:indicatorColorNormal];
        }
        if (indicatorColorHighlight) {
            [_pageControlColor setCurrentPageIndicatorTintColor:indicatorColorHighlight];
        }
        [_pageControlColor setUserInteractionEnabled:NO];
    }
    
    // 3 个复用的 UIImageView
    for (NSInteger i = 0; i < 3; i ++) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(i * (_selfWidth + SPA_INTERITEM), 0, _selfWidth, _selfHeight)];
        [_scrollView addSubview:imgView];
        [imgView setBackgroundColor:[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0f]];
        [imgView setContentMode:UIViewContentModeScaleAspectFill];
        [imgView setClipsToBounds:YES];
        [imgView setImage:self.imgPlaceholder];
        [self.arrImvViews addObject:imgView];
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
    self.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1.0f];
    
    // 事件响应链条
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self addGestureRecognizer:tap];
    
    // 当 JXRollView 不在屏幕上显示的时候(push 或 present 新视图控制器 或 程序进入后台)，应该暂停滚动。
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(rollViewPause)
                                                 name:JXROLLVIEW_PAUSE
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(rollViewPlay)
                                                 name:JXROLLVIEW_PLAY
                                               object:nil];
    
    
}

#pragma mark
- (void)jx_RefreshRollViewByUrls:(NSArray<NSURL *> *)urls {
    if (urls.count > 0) {
        [self rollViewPause];
        self.arrUrls = urls;
        self.currentPage = 0;
        self.numberOfPages = self.arrUrls.count;
        
        if (self.rollViewPageType == JXRollViewPageTypeImage) {
            self.pageControlImage.numberOfPages = self.numberOfPages;
        }
        else {
            self.pageControlColor.numberOfPages = self.numberOfPages;
        }
        
        [self.arrImages removeAllObjects];
        for (NSInteger i = 0; i < self.numberOfPages; i ++) {
            [self.arrImages addObject:self.imgPlaceholder];
        }
        
        [self refreshImages];
        [self rollViewPlay];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_timer setFireDate:[NSDate distantFuture]];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:_animateInterval]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.arrImages.count > 0) {
        CGFloat xOffSet = scrollView.contentOffset.x;
        if (xOffSet < _selfWidth / 2.f + SPA_INTERITEM / 2.f) {
            scrollView.contentOffset = CGPointMake(_selfWidth + xOffSet + SPA_INTERITEM, 0);
            [self changePageByDirection:JXRollDirectionTORight];
        }
        if (xOffSet > _selfWidth * 1.5f + SPA_INTERITEM * 1.5) {
            scrollView.contentOffset = CGPointMake(xOffSet - _selfWidth - SPA_INTERITEM, 0);
            [self changePageByDirection:JXRollDirectionToLeft];
        }
    }
}

-(void)changePageByDirection:(JXRollDirection)rollDirection {
    switch (rollDirection) {
        case JXRollDirectionTORight: {
            _currentPage --;
            if (_currentPage < 0) {
                _currentPage = _numberOfPages - 1;
            }
        } break;
            
        case JXRollDirectionToLeft: {
            _currentPage ++;
            if (_currentPage > _numberOfPages - 1) {
                _currentPage = 0;
            }
        } break;
            
        default: break;
    }
    if (_rollViewPageType == JXRollViewPageTypeImage) {
        _pageControlImage.currentPage = _currentPage;
    }
    else {
        _pageControlColor.currentPage = _currentPage;
    }
    [self refreshImages];
}

- (void)refreshImages {
    for (NSInteger i = 0; i < 3; i ++) {
        NSInteger getIndex = (self.numberOfPages + self.currentPage - 1 + i) % self.numberOfPages;
        if (self.arrImages[getIndex] == self.imgPlaceholder) {
            [self.arrImvViews[i] sd_setImageWithURL:self.arrUrls[getIndex] placeholderImage:_imgPlaceholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image) {
                    @try {
                        [self.arrImages replaceObjectAtIndex:getIndex withObject:image];
                    }
                    @catch (NSException *exception) { }
                    @finally { }
                }
            }];
        }
        else {
            self.arrImvViews[i].image = self.arrImages[getIndex];
        }
    }
    
    for (NSInteger i = 0; i < (self.numberOfPages - 3 > 1 ? 2 : self.numberOfPages - 3) ; i ++) {
        NSInteger getIndex = (self.numberOfPages + self.currentPage + 2 + i) % self.numberOfPages;
        if (self.arrImages[getIndex] == self.imgPlaceholder) {
            [[SDWebImageManager sharedManager] downloadImageWithURL:self.arrUrls[getIndex] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                if (image) {
                    @try {
                        [self.arrImages replaceObjectAtIndex:getIndex withObject:image];
                    }
                    @catch (NSException *exception) { }
                    @finally { }
                }
            }];
        }
    }
}

- (void)timerTicking {
    CGPoint tempOffSet = self.scrollView.contentOffset;
    tempOffSet.x = (_selfWidth + SPA_INTERITEM) * 2;
    [self.scrollView setContentOffset:tempOffSet animated:YES];
}

- (void)rollViewPause {
    [self.timer setFireDate:[NSDate distantFuture]];
}

-(void)rollViewPlay {
    if (self.arrUrls.count > 0) {
        [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:_animateInterval]];
    }
}

- (void)tapAction {
    if (self.blockTapAction && self.arrImages[_currentPage] != self.imgPlaceholder) {
        self.blockTapAction (_currentPage);
    }
}

- (void)jx_Free {
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









