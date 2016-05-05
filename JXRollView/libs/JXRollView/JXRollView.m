//
//  JXRollView.m
//  JXRollView
//
//  Created by CoderSun on 9/25/15.
//  Copyright © 2015 AugSun. All rights reserved.
//

#import "JXRollView.h"
#import "UIImageView+WebCache.h"

NSString *const JXRollViewPlay      = @"jxRollViewPlay";
NSString *const JXRollViewPause     = @"jxRollViewPause";

#define INTERVAL_ANIM_DEF           3.0f        // 默认滚动动画间隔
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

// ====================================================================================================
#pragma mark -
@interface JXPageControl : UIView

@property (nonatomic, assign) NSUInteger            currentPage;                //
@property (nonatomic, assign) NSUInteger            numberOfPages;              //
@property (nonatomic, strong) UIImage               *imgIndicatorNormal;        //
@property (nonatomic, strong) UIImage               *imgIndicatorHighlight;     //
@property (nonatomic, strong) NSMutableArray <UIImageView *> *arrImgViews;      //

@end

@implementation JXPageControl

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        _arrImgViews = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setNumberOfPages:(NSUInteger)numberOfPages {
    if (self.numberOfPages < numberOfPages) {
        for (NSInteger i = self.numberOfPages; i < numberOfPages; i ++) {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                                 (self.frame.size.height - INDICATOR_SIDES) / 2,
                                                                                 INDICATOR_SIDES,
                                                                                 INDICATOR_SIDES)];
            [self addSubview:imgView];
            [self.arrImgViews addObject:imgView];
        }
    }
    else {
        for (NSInteger i = 0; i < self.numberOfPages - numberOfPages; i ++) {
            [[self.arrImgViews lastObject] removeFromSuperview];
            [self.arrImgViews removeLastObject];
        }
    }
    _numberOfPages = numberOfPages;
    
    CGFloat wIndicator = self.numberOfPages * (INDICATOR_SPA_INTERITEM + INDICATOR_SIDES) - INDICATOR_SPA_INTERITEM;
    CGFloat xLocFirstImgView = (self.frame.size.width - wIndicator) / 2;
    for (NSInteger i = 0; i < self.numberOfPages; i ++) {
        UIImageView *imgViewTemp = self.arrImgViews[i];
        CGRect rectTemp = imgViewTemp.frame;
        rectTemp.origin.x = xLocFirstImgView + i * (INDICATOR_SPA_INTERITEM + INDICATOR_SIDES);
        imgViewTemp.frame = rectTemp;
        imgViewTemp.image = i == self.currentPage ? self.imgIndicatorHighlight : self.imgIndicatorNormal;
    }
}

- (void)setCurrentPage:(NSUInteger)currentPage {
    if (self.numberOfPages > 0) {
        if (_currentPage < self.arrImgViews.count) {
            self.arrImgViews[_currentPage].image = self.imgIndicatorNormal;
        }
        self.arrImgViews[currentPage].image = self.imgIndicatorHighlight;
        _currentPage = currentPage;
    }
}

@end

// ====================================================================================================
#pragma mark -
@interface JXRollView () <UIScrollViewDelegate>

@property (nonatomic, strong)   NSArray <NSURL *>       *arrUrls;               //
@property (nonatomic, assign)   CGFloat                 selfWidth;              //
@property (nonatomic, assign)   CGFloat                 selfHeight;             //
@property (nonatomic, strong)   UIScrollView            *scrollView;            //
@property (nonatomic, strong)   JXPageControl           *pageControlImage;      //
@property (nonatomic, strong)   UIPageControl           *pageControlColor;      //
@property (nonatomic, assign)   JXRollViewPageType      rollViewPageType;       //

@property (nonatomic, assign)   NSInteger               currentPage;            //
@property (nonatomic, assign)   NSInteger               numberOfPages;          //
@property (nonatomic, strong)   NSMutableArray <UIImage *>      *arrImages;     //
@property (nonatomic, strong)   NSMutableArray <UIImageView *>  *arrImgViews;   //
@property (nonatomic, strong)   UIImage                 *imgPlaceholder;        //
@property (nonatomic, assign)   NSTimeInterval          animateInterval;        //
@property (nonatomic, strong)   NSTimer                 *timer;                 //

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

- (void)createComponentWithFrame:(CGRect)frame
            indicatorColorNormal:(UIColor *)indicatorColorNormal
         indicatorColorHighlight:(UIColor *)indicatorColorHighlight
            indicatorImageNormal:(UIImage *)indicatorImageNormal
         indicatorImageHighlight:(UIImage *)indicatorImageHighlight
                 animateInterval:(NSTimeInterval)animateInterval
                       tapAction:(JXBlockTapAction)tapAction {
    //
    [self setClipsToBounds:YES];
    [self setBlockTapAction:tapAction];
    [self setSelfWidth:frame.size.width];
    [self setSelfHeight:frame.size.height];
    [self setBackgroundColor:[UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1.0f]];
    [self setAnimateInterval:animateInterval < 1 || animateInterval > 8 ? INTERVAL_ANIM_DEF : animateInterval];
    [self setRollViewPageType:indicatorImageNormal && indicatorImageHighlight ? JXRollViewPageTypeImage : JXRollViewPageTypeColor];
    [self setArrImages:[[NSMutableArray alloc] init]];
    [self setArrImgViews:[[NSMutableArray alloc] init]];
    [self setImgPlaceholder:[[UIImage alloc] init]];
    
    //
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _selfWidth + SPA_INTERITEM, _selfHeight)];
    [self addSubview:_scrollView];
    [_scrollView setContentSize:CGSizeMake(3 * (_selfWidth + SPA_INTERITEM), _selfHeight)];
    [_scrollView setContentOffset:CGPointMake(_selfWidth + SPA_INTERITEM, 0)];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setPagingEnabled:YES];
    [_scrollView setScrollsToTop:NO];
    [_scrollView setDelegate:self];
    
    //
    if (_rollViewPageType == JXRollViewPageTypeImage) {
        _pageControlImage = [[JXPageControl alloc] initWithFrame:CGRectMake(0,
                                                                            _selfHeight - JXPAGECTL_H - JXPAGECTL_TO_BOTTOM,
                                                                            _selfWidth,
                                                                            JXPAGECTL_H)];
        [self addSubview:_pageControlImage];
        [_pageControlImage setImgIndicatorNormal:indicatorImageNormal];
        [_pageControlImage setImgIndicatorHighlight:indicatorImageHighlight];
    }
    else {
        _pageControlColor = [[UIPageControl alloc] initWithFrame:CGRectMake(0,
                                                                            _selfHeight - JXPAGECTL_H - JXPAGECTL_TO_BOTTOM + 5,
                                                                            _selfWidth,
                                                                            JXPAGECTL_H)];
        [self addSubview:self.pageControlColor];
        if (indicatorColorNormal) {
            [_pageControlColor setPageIndicatorTintColor:indicatorColorNormal];
        }
        if (indicatorColorHighlight) {
            [_pageControlColor setCurrentPageIndicatorTintColor:indicatorColorHighlight];
        }
        [_pageControlColor setUserInteractionEnabled:NO];
    }
    
    //
    for (NSInteger i = 0; i < 3; i ++) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(i * (_selfWidth + SPA_INTERITEM), 0, _selfWidth, _selfHeight)];
        [_scrollView addSubview:imgView];
        [imgView setBackgroundColor:[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0f]];
        [imgView setContentMode:UIViewContentModeScaleAspectFill];
        [imgView setClipsToBounds:YES];
        [imgView setImage:self.imgPlaceholder];
        [self.arrImgViews addObject:imgView];
    }
    
    //
    _timer = [[NSTimer alloc] initWithFireDate:[NSDate distantFuture]
                                      interval:_animateInterval
                                        target:self
                                      selector:@selector(timerTicking)
                                      userInfo:nil
                                       repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
    //
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self addGestureRecognizer:tap];
    
    //
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(rollViewPause)
                                                 name:JXRollViewPause
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(rollViewPlay)
                                                 name:JXRollViewPlay
                                               object:nil];
    
    
}

- (void)setCurrentPage:(NSInteger)currentPage {
    _currentPage = currentPage;
    if (self.rollViewPageType == JXRollViewPageTypeImage) {
        self.pageControlImage.currentPage = self.currentPage;
    }
    else {
        self.pageControlColor.currentPage = self.currentPage;
    }
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    _numberOfPages = numberOfPages;
    if (self.rollViewPageType == JXRollViewPageTypeImage) {
        self.pageControlImage.numberOfPages = self.numberOfPages;
    }
    else {
        self.pageControlColor.numberOfPages = self.numberOfPages;
    }
}

- (void)jx_refreshRollViewByUrls:(NSArray <NSURL *> *)urls {
    [self rollViewPause];
    
    self.arrUrls = urls;
    self.numberOfPages = self.arrUrls.count;
    self.currentPage = 0;
    
    if (self.numberOfPages > 0) {
        [self.arrImages removeAllObjects];
        for (NSInteger i = 0; i < self.numberOfPages; i ++) {
            [self.arrImages addObject:self.imgPlaceholder];
        }
        
        [self downloadImages];
        [self refreshImages];
        [self rollViewPlay];
    }
    else {
        for (UIImageView *imgView in self.arrImgViews) {
            imgView.image = nil;
        }
    }
}

- (void)downloadImages {
    for (NSInteger i = 0; i < self.numberOfPages; i ++) {
        NSInteger getIndex = (self.numberOfPages + self.currentPage - 1 + i) % self.numberOfPages;
        SDWebImageOptions webImageOptions = i < 3 ? SDWebImageHighPriority : SDWebImageLowPriority;
        [[SDWebImageManager sharedManager] downloadImageWithURL:self.arrUrls[getIndex] options:webImageOptions | SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (finished && image) {
                @try {
                    [self.arrImages replaceObjectAtIndex:getIndex withObject:image];
                    if (getIndex >= self.currentPage - 1 && getIndex <= self.currentPage + 1) {
                        [self refreshImages];
                    }
                }
                @catch (NSException *exception) { }
                @finally { }
            }
        }];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.numberOfPages > 0) {
        [self rollViewPause];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.numberOfPages > 0) {
        [self rollViewPlay];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.numberOfPages > 0) {
        CGFloat xOffSet = scrollView.contentOffset.x;
        if (xOffSet < (self.selfWidth + SPA_INTERITEM) * 0.5f) {
            scrollView.contentOffset = CGPointMake(xOffSet + self.selfWidth + SPA_INTERITEM, 0);
            [self changePageByDirection:JXRollDirectionTORight];
        }
        if (xOffSet > (self.selfWidth + SPA_INTERITEM) * 1.5f) {
            scrollView.contentOffset = CGPointMake(xOffSet - self.selfWidth - SPA_INTERITEM, 0);
            [self changePageByDirection:JXRollDirectionToLeft];
        }
    }
}

- (void)changePageByDirection:(JXRollDirection)rollDirection {
    self.currentPage = (self.numberOfPages + self.currentPage + (rollDirection == JXRollDirectionToLeft ? 1 : -1)) % self.numberOfPages;
    [self refreshImages];
}

- (void)refreshImages {
    for (NSInteger i = 0; i < 3; i ++) {
        NSInteger getIndex = (self.numberOfPages + self.currentPage - 1 + i) % self.numberOfPages;
        if (getIndex < self.arrImages.count) {
            self.arrImgViews[i].image = self.arrImages[getIndex];
        }
    }
}

- (void)timerTicking {
    CGPoint tempOffSet = self.scrollView.contentOffset;
    tempOffSet.x = (self.selfWidth + SPA_INTERITEM) * 2;
    [self.scrollView setContentOffset:tempOffSet animated:YES];
}

- (void)rollViewPause {
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)rollViewPlay {
    if (self.numberOfPages > 0) {
        [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.animateInterval]];
    }
}

- (void)tapAction {
    if (self.blockTapAction) {
        [self rollViewPlay];
        self.blockTapAction (self.currentPage);
    }
}

- (void)jx_free {
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









