//
//  JXRollView.m
//  JXRollView
//
//  Created by CoderSun on 9/25/15.
//  Copyright © 2015 AugSun. All rights reserved.
//

#import "JXRollView.h"
#import "UIImageView+WebCache.h"

const CGFloat JXAutoRollTimeIntervalDefault         = 3.f;  // 默认滚动间隔
const CGFloat JXTimerCycle                          = .2f;  // 定时器周期
const CGFloat JXInteritemSpacingDefault             = 8.f;  // 滚动图片的间距
const CGFloat JXIndicatorToBottomSpacingDefault     = 8.f;  // pageControl 到底部的距离
const CGFloat JXSystemIndicatorSide                 = 7.f;  // 系统 indicator 边长

//以下常量只对针对 indicatorImage
const CGFloat JXIndicatorSideMin                    = 4.f;  // indicatorImage 的最小尺寸
const CGFloat JXIndicatorSideMax                    = 18.f; // indicatorImage 的最大尺寸
const CGFloat JXIndicatorInteritemSpacing           = 8.f;  // 两个 indicator 之间的距离

typedef NS_ENUM(NSUInteger, JXRollViewIndicatorStyle) {
    JXRollViewIndicatorStyleColor = 1,
    JXRollViewIndicatorStyleImage,
};

typedef NS_ENUM(NSInteger, JXRollDirection) {
    JXRollDirectionToLeft = 1,
    JXRollDirectionTORight,
};

//#define JX_DEALLOC_TEST   - (void)dealloc { NSLog(@"dealloc -> %@",NSStringFromClass([self class])); }
#define JX_DEALLOC_TEST

// ====================================================================================================
#pragma mark -
@interface JXPageControl : UIView

@property (nonatomic, assign)   NSUInteger              currentPage;                //
@property (nonatomic, assign)   NSUInteger              numberOfPages;              //
@property (nonatomic, strong)   UIImage                 *pageIndicatorImage;        //
@property (nonatomic, strong)   UIImage                 *currentPageIndicatorImage; //
@property (nonatomic, assign)   BOOL                    hidesForSinglePage;
@property (nonatomic, strong)   NSMutableArray <UIImageView *> *arrImgViews;      //

- (JXPageControl *)initWithPageIndicatorImage:(UIImage *)pageIndicatorImage
                    currentPageIndicatorImage:(UIImage *)currentPageIndicatorImage;

@end

@implementation JXPageControl

- (JXPageControl *)initWithPageIndicatorImage:(UIImage *)pageIndicatorImage currentPageIndicatorImage:(UIImage *)currentPageIndicatorImage {
    if (self = [super init]) {
        self.userInteractionEnabled = NO;
        _arrImgViews = [[NSMutableArray alloc] init];
        _pageIndicatorImage = pageIndicatorImage;
        _currentPageIndicatorImage = currentPageIndicatorImage;
    }
    return self;
}

- (void)setNumberOfPages:(NSUInteger)numberOfPages {
    if (self.numberOfPages < numberOfPages) {
        for (NSInteger i = self.numberOfPages; i < numberOfPages; i ++) {
            UIImageView *imgView = [[UIImageView alloc] init];
            [self addSubview:imgView];
            imgView.contentMode = UIViewContentModeScaleAspectFit;
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
    
    CGFloat wIndicator = self.numberOfPages * (JXIndicatorInteritemSpacing + self.frame.size.height) - JXIndicatorInteritemSpacing;
    CGFloat xLocFirstImgView = (self.frame.size.width - wIndicator) / 2;
    for (NSInteger i = 0; i < self.numberOfPages; i ++) {
        self.arrImgViews[i].frame = CGRectMake(xLocFirstImgView + i * (JXIndicatorInteritemSpacing + self.frame.size.height),
                                               0,
                                               self.frame.size.height,
                                               self.frame.size.height);
        self.arrImgViews[i].image = i == self.currentPage ? self.currentPageIndicatorImage : self.pageIndicatorImage;
    }
    self.hidden = (self.hidesForSinglePage && self.numberOfPages == 1) || self.numberOfPages == 0;
    
}

- (void)setCurrentPage:(NSUInteger)currentPage {
    if (self.numberOfPages > 0) {
        if (_currentPage < self.arrImgViews.count) {
            self.arrImgViews[_currentPage].image = self.pageIndicatorImage;
        }
        self.arrImgViews[currentPage].image = self.currentPageIndicatorImage;
        _currentPage = currentPage;
    }
}

JX_DEALLOC_TEST

@end

// ====================================================================================================
#pragma mark -

@interface JXRollView () <UIScrollViewDelegate>

@property (nonatomic, assign)   JXRollViewIndicatorStyle    rollViewIndicatorStyle;     //
@property (nonatomic, assign)   CGFloat                     rWidth;                     //
@property (nonatomic, assign)   CGFloat                     rHeight;                    //
@property (nonatomic, strong)   UIScrollView                *scrollView;                //
@property (nonatomic, strong)   NSMutableArray <UIImageView *>  *arr3ImgViews;           //
@property (nonatomic, strong)   NSMutableArray <NSNumber *>     *arr3Index;                   //
@property (nonatomic, strong)   NSMutableArray <NSNumber *>     *arr3IsDownloading;      //
@property (nonatomic, strong)   NSMutableArray <UIImage *>  *arrImages;                 //
@property (nonatomic, strong)   UIPageControl               *pageControlColor;          //
@property (nonatomic, strong)   JXPageControl               *pageControlImage;          //

@property (nonatomic, assign)   NSInteger                   currentPage;                //
@property (nonatomic, assign)   NSInteger                   numberOfPages;              //

@property (nonatomic, strong)   NSTimer                     *timer;                     //
@property (nonatomic, assign)   CGFloat                     timerCounter;               //

@end

@implementation JXRollView

// ====================================================================================================
#pragma mark - setter
// 占拉图片
- (void)setPlaceholderImage:(UIImage *)placeholderImage {
    _placeholderImage = placeholderImage;
}

// 图片模式
- (void)setImageContentMode:(UIViewContentMode)imageContentMode {
    _imageContentMode = imageContentMode;
    for (UIImageView *imgViewEnum in self.arr3ImgViews) {
        imgViewEnum.contentMode = self.imageContentMode;
    }
}

// 是否自动滚动 默认 YES
- (void)setAutoRoll:(BOOL)autoRoll {
    _autoRoll = autoRoll;
    if (!self.autoRoll) {
        [self.timer invalidate];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

// 自动滚动间隔
- (void)setAutoRollTimeInterval:(CGFloat)autoRollTimeInterval {
    if (autoRollTimeInterval >= 1.f && autoRollTimeInterval <= 5.f) {
        _autoRollTimeInterval = autoRollTimeInterval;
    }
}

// 图片之间的间距
- (void)setInteritemSpacing:(CGFloat)interitemSpacing {
    _interitemSpacing = interitemSpacing;
    [self.scrollView setContentSize:CGSizeMake(3 * (self.rWidth+ self.interitemSpacing), self.rHeight)];
    [self.scrollView setContentOffset:CGPointMake(self.rWidth + self.interitemSpacing, 0)];
    [self.scrollView setFrame:CGRectMake(0, 0, self.rWidth + self.interitemSpacing, self.rHeight)];
    for (NSInteger i = 0; i < self.arr3ImgViews.count; i ++) {
        CGRect rectImgView = CGRectMake(i * (self.rWidth + self.interitemSpacing), 0, self.rWidth, self.rHeight);
        self.arr3ImgViews[i].frame = rectImgView;
    }
}

// 页面指示器距底部的距离 默认 8pt
- (void)setIndicatorToBottomSpacing:(CGFloat)indicatorToBottomSpacing {
    _indicatorToBottomSpacing = indicatorToBottomSpacing;
    
    if (self.rollViewIndicatorStyle == JXRollViewIndicatorStyleColor) {
        CGRect rectPageControlColor = CGRectMake(0,
                                                 self.rHeight - self.indicatorToBottomSpacing - JXSystemIndicatorSide,
                                                 self.rWidth,
                                                 JXSystemIndicatorSide);
        self.pageControlColor.frame = rectPageControlColor;
    }
    else {
        CGSize indicatorSize = self.pageControlImage.pageIndicatorImage.size;
        CGFloat indicatorSide = indicatorSize.width > indicatorSize.height ? indicatorSize.width : indicatorSize.height;
        indicatorSide = indicatorSide < JXIndicatorSideMin ? JXIndicatorSideMin : (indicatorSide > JXIndicatorSideMax ? JXIndicatorSideMax : indicatorSide);
        
        CGRect rectPageControlImage = CGRectMake(0,
                                                 self.rHeight - self.indicatorToBottomSpacing - indicatorSide,
                                                 self.rWidth,
                                                 indicatorSide);
        self.pageControlImage.frame = rectPageControlImage;
    }
}

- (void)setHideIndicatorForSinglePage:(BOOL)hideIndicatorForSinglePage {
    _hideIndicatorForSinglePage = hideIndicatorForSinglePage;
    if (self.rollViewIndicatorStyle == JXRollViewIndicatorStyleColor) {
        self.pageControlColor.hidesForSinglePage = self.hideIndicatorForSinglePage;
    }
    else {
        self.pageControlImage.hidesForSinglePage = self.hideIndicatorForSinglePage;
    }
}

// ====================================================================================================
#pragma mark - init
- (JXRollView *)initWithFrame:(CGRect)frame pageIndicatorColor:(UIColor *)pageIndicatorColor currentPageIndicatorColor:(UIColor *)currentPageIndicatorColor {
    if (self = [super initWithFrame:frame]) {
        [self createComponentByFrame:frame pageIndicatorColor:pageIndicatorColor currentPageIndicatorColor:currentPageIndicatorColor pageIndicatorImage:nil currentPageIndicatorImage:nil];
    }
    return self;
}

- (JXRollView *)initWithFrame:(CGRect)frame pageIndicatorImage:(UIImage *)pageIndicatorImage currentPageIndicatorImage:(UIImage *)currentPageIndicatorImage {
    if (self = [super initWithFrame:frame]) {
        [self createComponentByFrame:frame pageIndicatorColor:nil currentPageIndicatorColor:nil pageIndicatorImage:pageIndicatorImage currentPageIndicatorImage:currentPageIndicatorImage];
    }
    return self;
}

- (void)createComponentByFrame:(CGRect)frame pageIndicatorColor:(UIColor *)pageIndicatorColor currentPageIndicatorColor:(UIColor *)currentPageIndicatorColor pageIndicatorImage:(UIImage *)pageIndicatorImage currentPageIndicatorImage:(UIImage *)currentPageIndicatorImage {
    self.clipsToBounds = YES;
    self.rWidth = CGRectGetWidth(frame);
    self.rHeight = CGRectGetHeight(frame);
    self.arr3ImgViews = [[NSMutableArray alloc] init];
    self.arr3Index = [[NSMutableArray alloc] init];
    self.arr3IsDownloading = [[NSMutableArray alloc] init];
    self.arrImages = [[NSMutableArray alloc] init];
    self.placeholderImage = [[UIImage alloc] init];
    self.autoRollTimeInterval = JXAutoRollTimeIntervalDefault;
    self.autoRoll = YES;
    if (pageIndicatorImage &&
        currentPageIndicatorImage &&
        pageIndicatorImage.size.width > 0 &&
        pageIndicatorImage.size.height > 0 &&
        currentPageIndicatorImage.size.width > 0 &&
        currentPageIndicatorImage.size.height > 0) {
        self.rollViewIndicatorStyle = JXRollViewIndicatorStyleImage;
    }
    else {
        self.rollViewIndicatorStyle = JXRollViewIndicatorStyleColor;
    }
    self.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1.0f];
    
    //
    self.scrollView = [[UIScrollView alloc] init];
    [self addSubview:self.scrollView];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView setPagingEnabled:YES];
    [self.scrollView setScrollsToTop:NO];
    [self.scrollView setDelegate:self];
    
    //
    for (NSInteger i = 0; i < 3; i ++) {
        UIImageView *imgView = [[UIImageView alloc] init];
        [self.scrollView addSubview:imgView];
        imgView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0f];
        imgView.clipsToBounds = YES;
        [self.arr3ImgViews addObject:imgView];
        [self.arr3Index addObject:@(-1)];
    }
    
    //
    if (self.rollViewIndicatorStyle == JXRollViewIndicatorStyleColor) {
        self.pageControlColor = [[UIPageControl alloc] init];
        [self addSubview:self.pageControlColor];
        self.pageControlColor.currentPageIndicatorTintColor = currentPageIndicatorColor;
        self.pageControlColor.pageIndicatorTintColor = pageIndicatorColor;
        self.pageControlColor.userInteractionEnabled = NO;
    }
    else {
        self.pageControlImage = [[JXPageControl alloc] initWithPageIndicatorImage:pageIndicatorImage
                                                        currentPageIndicatorImage:currentPageIndicatorImage];
        [self addSubview:self.pageControlImage];
    }
    self.indicatorToBottomSpacing = JXIndicatorToBottomSpacingDefault;
    self.imageContentMode = UIViewContentModeScaleAspectFill;
    
    //
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self addGestureRecognizer:tap];
    
    //
    self.timer = [[NSTimer alloc] initWithFireDate:[NSDate distantFuture]
                                          interval:JXTimerCycle
                                            target:self
                                          selector:@selector(timerTicking)
                                          userInfo:nil
                                           repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(rollViewPause)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(rollViewPlay)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    //
    self.interitemSpacing = JXInteritemSpacingDefault;
    
}

- (void)setCurrentPage:(NSInteger)currentPage {
    _currentPage = currentPage;
    if (self.rollViewIndicatorStyle == JXRollViewIndicatorStyleColor) {
        self.pageControlColor.currentPage = self.currentPage;
    }
    else {
        self.pageControlImage.currentPage = self.currentPage;
    }
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    _numberOfPages = numberOfPages;
    if (self.rollViewIndicatorStyle == JXRollViewIndicatorStyleColor) {
        self.pageControlColor.numberOfPages = self.numberOfPages;
    }
    else {
        self.pageControlImage.numberOfPages = self.numberOfPages;
    }
    
    if (self.numberOfPages == 1 && self.hideIndicatorForSinglePage) {
        self.scrollView.scrollEnabled = NO;
    }
}

- (void)reloadData {
    [self rollViewPause];
    [self.scrollView setContentOffset:CGPointMake(self.rWidth + self.interitemSpacing, 0) animated:NO];
    
    self.numberOfPages = [self.delegate numberOfItemsInRollView:self];
    self.currentPage = 0;
    if (self.numberOfPages > 0) {
        [self.arrImages removeAllObjects];
        [self.arr3IsDownloading removeAllObjects];
        for (NSInteger i = 0; i < self.numberOfPages; i ++) {
            if (!self.placeholderImage) {
                self.placeholderImage = [[UIImage alloc] init];
            }
            [self.arrImages addObject:self.placeholderImage];
            [self.arr3IsDownloading addObject:@(NO)];
        }
        
        [self refreshImages];
        if (self.autoRoll && !(self.numberOfPages == 1 && self.hideIndicatorForSinglePage)) {
            [self rollViewPlay];
        }
    }
    else {
        for (UIImageView *imgView in self.arr3ImgViews) {
            imgView.image = nil;
        }
    }
}

- (void)refreshImages {
    for (NSInteger i = 0; i < 3; i ++) {
        NSInteger getIndex = (self.numberOfPages + self.currentPage - 1 + i) % self.numberOfPages;
        NSURL *urlGetIndex = [self.delegate rollView:self urlForItemAtIndex:getIndex];
        
        [self.arr3Index replaceObjectAtIndex:i withObject:@(getIndex)];
        
        if (getIndex >=self.arrImages.count || getIndex < 0) {
            continue;
        }
        self.arr3ImgViews[i].image = self.arrImages[getIndex];
        if (self.arrImages[getIndex] != self.placeholderImage) {
            continue;
        }
        
        if ([self.arr3IsDownloading[getIndex] boolValue]) {
            continue;
        }
        [self.arr3IsDownloading replaceObjectAtIndex:getIndex withObject:@(YES)];
        
        [[SDWebImageManager sharedManager] downloadImageWithURL:urlGetIndex options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            @try {
                [self.arr3IsDownloading replaceObjectAtIndex:getIndex withObject:@(NO)];
            }
            @catch (NSException *exception) { }
            @finally { }
            if (finished && image) {
                @try {
                    [self.arrImages replaceObjectAtIndex:getIndex withObject:image];
                    
                    for (NSInteger j = 0; j < 3; j ++) {
                        if ([self.arr3Index[j] integerValue] == getIndex) {
                            self.arr3ImgViews[j].image = self.arrImages[getIndex];
                        }
                    }
                }
                @catch (NSException *exception) { }
                @finally { }
            }
        }];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.numberOfPages > 0 && self.autoRoll) {
        [self rollViewPause];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.numberOfPages > 0 && self.autoRoll && !(self.numberOfPages == 1 && self.hideIndicatorForSinglePage)) {
        [self rollViewPlay];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.numberOfPages > 0) {
        CGFloat xOffSet = scrollView.contentOffset.x;
        if (xOffSet < (self.rWidth + self.interitemSpacing) * 0.5f) {
            scrollView.contentOffset = CGPointMake(xOffSet + self.rWidth + self.interitemSpacing, 0);
            [self changePageByDirection:JXRollDirectionTORight];
        }
        if (xOffSet > (self.rWidth + self.interitemSpacing) * 1.5f) {
            scrollView.contentOffset = CGPointMake(xOffSet - self.rWidth - self.interitemSpacing, 0);
            [self changePageByDirection:JXRollDirectionToLeft];
        }
    }
}

- (void)changePageByDirection:(JXRollDirection)rollDirection {
    self.currentPage = (self.numberOfPages + self.currentPage + (rollDirection == JXRollDirectionToLeft ? 1 : -1)) % self.numberOfPages;
    [self refreshImages];
}

- (void)timerTicking {
    if (self.window) {
        if (self.timerCounter > self.autoRollTimeInterval) {
            self.timerCounter = .0f;
            CGPoint tempOffSet = self.scrollView.contentOffset;
            tempOffSet.x = (self.rWidth + self.interitemSpacing) * 2;
            [self.scrollView setContentOffset:tempOffSet animated:YES];
        }
        else {
            self.timerCounter += JXTimerCycle;
        }
    }
}

- (void)rollViewPause {
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)rollViewPlay {
    if (self.numberOfPages > 0) {
        [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.autoRollTimeInterval]];
    }
}

- (void)tapAction {
    if ([self.delegate respondsToSelector:@selector(rollView:didSelectItemAtIndex:)]) {
        [self.delegate rollView:self didSelectItemAtIndex:self.currentPage];
    }
}

- (void)free {
    self.scrollView.delegate = nil;
    self.delegate = nil;
    [self.timer invalidate];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    NSLog(@"dealloc -> %@",NSStringFromClass([self class]));
}

@end









