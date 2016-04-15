//
//  JXRollView.m
//  JXRollView
//
//  Created by CoderSun on 9/25/15.
//  Copyright © 2015 AugSun. All rights reserved.
//

#import "JXRollView.h"
#import "UIImageView+WebCache.h"

typedef NS_ENUM(NSInteger, JXRollMethod) {
    JXRollMethodPrevious = 1,
    JXRollMethodNext,
};

const NSInteger     baseImgViewTag  = 666;  //
const CGFloat       intervalAnim    = 3.f;  //the interval of per image rolling.
const NSInteger     spaGap          = 8;    //gap between two images.(set zero if you unlike)

@interface JXRollView ()

<
UIScrollViewDelegate
>

@property (nonatomic, assign) CGFloat           widthSelf;          //width of JXRollView
@property (nonatomic, assign) CGFloat           heightSelf;         //height of JXRollView
@property (nonatomic, strong) UIScrollView      *scrollView;
@property (nonatomic, strong) UIPageControl     *pagCtl;
@property (nonatomic, assign) NSInteger         pageTotal;
@property (nonatomic, assign) NSInteger         pageCurrent;
@property (nonatomic, strong) NSMutableArray    *arrImages;
@property (nonatomic, strong) UIImage           *imgPlaceholder;

@property (nonatomic, strong) NSTimer           *timer;

@end

@implementation JXRollView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createComponentByWidth:frame.size.width height:frame.size.height];
    }
    return self;
}

// if associate from xib to JXRollView class reimplementation - (nullable instancetype)initWithCoder:(NSCoder *)aDecoder; method
- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
#warning The frame in the method is unlayout, to say exactly, JXRollView in xib is (320, 240), run in the (375w or 414w) device, the frame is (320, 240), so, use [UIScreen mainScreen] if you want have a screen's width JXRollView, if no, recommend you init JXRollView by - (instancetype)initWithFrame:(CGRect)frame to create a JXRollView by custom frame in you project.
        [self createComponentByWidth:self.frame.size.width height:self.frame.size.height];
    }
    return self;
}

- (void)createComponentByWidth:(CGFloat)width height:(CGFloat)height {
    _widthSelf = width;
    _heightSelf = height;
    
    _arrImages = [[NSMutableArray alloc] init];
    
    _imgPlaceholder = [[UIImage alloc] init];
    
    self.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0f];
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _widthSelf+spaGap, _heightSelf)];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    _pagCtl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, _heightSelf - 20, _widthSelf, 20)];
    _pagCtl.userInteractionEnabled = NO;
    _pagCtl.currentPageIndicatorTintColor = [UIColor orangeColor];
    _pagCtl.pageIndicatorTintColor = [UIColor grayColor];
    
    [self addSubview:_scrollView];
    [self addSubview:_pagCtl];
    
    //the 3 reused UIImageView
    for (NSInteger i = 0; i < 3; i ++) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(i*(_widthSelf+spaGap), 0, _widthSelf, _heightSelf)];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.clipsToBounds = YES;
        imgView.tag = baseImgViewTag + i;
        imgView.image = _imgPlaceholder;
        
        [_scrollView addSubview:imgView];
    }
    _scrollView.contentSize = CGSizeMake(3 * (_widthSelf + spaGap), _heightSelf);
    _scrollView.contentOffset = CGPointMake(_widthSelf + spaGap, 0);
    _scrollView.scrollsToTop = NO;
    
    //timer to control loop
    _timer = [NSTimer scheduledTimerWithTimeInterval:intervalAnim
                                              target:self
                                            selector:@selector(timerFired)
                                            userInfo:nil
                                             repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    [_timer setFireDate:[NSDate distantFuture]];
    
    //event response chain
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)]];
    
    //the view of JXRoll should play in force, be covered when push/present or app enter background should be pause.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jxRollViewPause) name:JXROLLVIEW_PAUSE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jxRollViewPlay) name:JXROLLVIEW_PLAY object:nil];
}

#pragma mark setter
- (void)setArrImgStrUrls:(NSArray<NSURL *> *)arrImgStrUrls {
    _arrImgStrUrls = arrImgStrUrls;
    _pageTotal = arrImgStrUrls.count;
    if (_pageTotal > 0) {
        _pagCtl.numberOfPages = _pageTotal;
        for (NSInteger i = 0; i < _arrImgStrUrls.count; i ++) {
            UIImageView *imgView = [[UIImageView alloc] init];
            [_arrImages addObject:_imgPlaceholder];
            [imgView sd_setImageWithURL:_arrImgStrUrls[i] placeholderImage:_imgPlaceholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image) [_arrImages setObject:image atIndexedSubscript:i];
            }];
        }
        [self setImgs];
        [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:intervalAnim]];
    }
}

#pragma mark UIScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_timer setFireDate:[NSDate distantFuture]];
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:intervalAnim]];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat xOffSet = scrollView.contentOffset.x;
    if (xOffSet < _widthSelf / 2 + spaGap / 2) {
        scrollView.contentOffset = CGPointMake(_widthSelf+xOffSet+spaGap, 0);
        [self changePageByMethod:JXRollMethodPrevious];
    }
    if (xOffSet > _widthSelf * 1.5f + spaGap * 1.5) {
        scrollView.contentOffset = CGPointMake(xOffSet - _widthSelf - spaGap, 0);
        [self changePageByMethod:JXRollMethodNext];
    }
}

#pragma mark reused when half passed and refresh image.
-(void) changePageByMethod:(JXRollMethod)changePageMethod {
    switch (changePageMethod) {
        case JXRollMethodPrevious: {
            _pageCurrent --;
            if (_pageCurrent < 0)
                _pageCurrent = _pageTotal - 1;
        } break;
            
        case JXRollMethodNext: {
            _pageCurrent ++;
            if (_pageCurrent > _pageTotal-1)
                _pageCurrent = 0;
        } break;
            
        default: break;
    }
    _pagCtl.currentPage = _pageCurrent;
    [self setImgs];
}

-(void)setImgs {
    for (NSInteger i = 0; i < 3; i ++) {
        NSInteger getIndex = _pageCurrent-1+i;
        if (getIndex < 0)
            getIndex = _pageTotal - 1;
        if (getIndex > _pageTotal - 1)
            getIndex = 0;
        UIImageView *imgView = (UIImageView *)[_scrollView viewWithTag:i+baseImgViewTag];
        imgView.image = _imgPlaceholder;
        if (_arrImages.count > getIndex) {
            if (_arrImages[getIndex] == _imgPlaceholder) {
                [imgView sd_setImageWithURL:_arrImgStrUrls[getIndex] placeholderImage:_imgPlaceholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (image) {
                        [_arrImages setObject:image atIndexedSubscript:getIndex];
                    }
                }];
            }
            else imgView.image = _arrImages[getIndex];
        }
    }
}

#pragma mark timerFired
-(void)timerFired {
    CGPoint tempOffSet = _scrollView.contentOffset;
    tempOffSet.x = (_widthSelf + spaGap) * 2;
    [_scrollView setContentOffset:tempOffSet animated:YES];
}

#pragma mark noti from outside to decide play/pause
-(void)jxRollViewPause {
    [_timer setFireDate:[NSDate distantFuture]];
}
-(void)jxRollViewPlay {
    [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:intervalAnim]];
}

#pragma mark TapActionIndex CallBack
-(void)tapAction {
    if (_blockTapAction)
        if (_arrImages[_pageCurrent] != _imgPlaceholder)
            _blockTapAction (_pageCurrent);
}

#pragma mark invalidate timer and release JXRollView
-(void)jx_Free {
    _scrollView.delegate = nil;
    [_timer invalidate];
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
