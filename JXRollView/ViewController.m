//
//  ViewController.m
//  JXRollView
//
//  Created by shiba_iosJX on 3/31/16.
//  Copyright © 2016 shiba_iosJX. All rights reserved.
//

#import "ViewController.h"

#import "JXRollView.h"

#define WIDTH_SCREEN [UIScreen mainScreen].bounds.size.width

@interface ViewController () <JXRollViewDelegate>

@property (nonatomic, strong) JXRollView *rollView;
@property (nonatomic, strong) JXRollView *rollViewAnotherKind;
@property (nonatomic, strong) JXRollView *rollViewLast;

@property (nonatomic, strong)   NSArray <NSURL *> *arrUrls;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
//    self.view.backgroundColor = [UIColor colorWithRed:239/255.f green:239/255.f blue:244/255.f alpha:1.f];
    self.view.backgroundColor = [UIColor grayColor];
    
    
    NSString *strWScreen = [NSString stringWithFormat:@".%ld", (long)[UIScreen mainScreen].bounds.size.width];
    NSString *strUrlBase = @"https://raw.githubusercontent.com/augsun/Resources/master/JXRollView/";
#define STR_CAT2(str1, str2)    [NSString stringWithFormat:@"%@%@", str1, str2]
#define URL_FROM_NAME(name)     [NSURL URLWithString:STR_CAT2(strUrlBase, STR_CAT2(name, STR_CAT2(strWScreen, @".jpg")))]
    self.arrUrls = @[
                     URL_FROM_NAME(@"101749"),
                     URL_FROM_NAME(@"107500"),
                     URL_FROM_NAME(@"108389"),
                     URL_FROM_NAME(@"111258"),
                     URL_FROM_NAME(@"112793"),
                     URL_FROM_NAME(@"355362"),
                     URL_FROM_NAME(@"931282"),
                     URL_FROM_NAME(@"969118"),
                     URL_FROM_NAME(@"970400"),
                     URL_FROM_NAME(@"986765"),
                     ];
#undef STR_CAT
#undef URL_FROM_NAME
    CGFloat yLocation = 20.f;
    CGFloat imgRate = 16 / 9.f;
    CGFloat wScreen = [UIScreen mainScreen].bounds.size.width;
    
// ==========================================================================================
#pragma mark 以创建 pageControl 为自定义图片 的 JXRollView 为例
    // STEP 1 创建 JXRollView
    self.rollView = [[JXRollView alloc] initWithFrame:CGRectMake(0, yLocation, wScreen, wScreen / imgRate)
                                   pageIndicatorColor:[UIColor grayColor]
                            currentPageIndicatorColor:[UIColor orangeColor]];
    [self.view addSubview:self.rollView];
    self.rollView.delegate = self;
    
    
//    self.rollView.placeholderImage = [[UIImage alloc] init];
//    self.rollView.imageContentMode = UIViewContentModeScaleToFill;
//    self.rollView.interitemSpacing = 20.f;
//    self.rollView.autoRoll = NO;
//    self.rollView.autoRollTimeInterval = 2.f;
//    self.rollView.indicatorToBottomSpace = 20.f;
//    self.rollView.hidesForSinglePage = YES;
    
    
    // STEP 2 开始滚动
    [self.rollView reloadData];
    
//#pragma mark 创建 pageControl 为自定义颜色 的 JXRollView
//    CGFloat spa_Edge = 8;
//    CGRect rectRollViewAnotherKind = CGRectMake(2 * spa_Edge,
//                                                yLocation + _jxRollView.frame.size.height + spa_Edge,
//                                                wScreen - 4 * spa_Edge,
//                                                (wScreen - 2 * spa_Edge) / imgRate );
//    _jxRollViewAnotherKind = [[JXRollView alloc] initWithFrame:rectRollViewAnotherKind
//                                          indicatorColorNormal:nil
//                                       indicatorColorHighlight:nil
//                                               animateInterval:M_E
//                                                     tapAction:^(NSInteger tapIndex) {
//                                                     
//                                                     }];
//    [self.view addSubview:_jxRollViewAnotherKind];
//    [_jxRollViewAnotherKind jx_refreshRollViewByUrls:[arrUrls subarrayWithRange:NSMakeRange(1, 5)]];
//    
//    //
//    CGRect rectRollViewLast = CGRectMake(2 * spa_Edge,
//                                         _jxRollViewAnotherKind.frame.origin.y + _jxRollViewAnotherKind.frame.size.height + spa_Edge,
//                                         wScreen - 4 * spa_Edge,
//                                         (wScreen - 2 * spa_Edge) / imgRate);
//
//    _jxRollViewLast = [[JXRollView alloc] initWithFrame:rectRollViewLast
//                                   indicatorColorNormal:[UIColor lightGrayColor]
//                                indicatorColorHighlight:[UIColor greenColor]
//                                        animateInterval:M_SQRT2
//                                              tapAction:^(NSInteger tapIndex) {
//                                              
//                                              }];
//    [self.view addSubview:_jxRollViewLast];
//    [_jxRollViewLast jx_refreshRollViewByUrls:[arrUrls subarrayWithRange:NSMakeRange(2, 2)]];
    
    

}

- (NSInteger)numberOfItemsInRollView:(JXRollView *)rollView {
    return self.arrUrls.count;
}

- (NSURL *)rollView:(JXRollView *)rollView urlForItemAtIndex:(NSInteger)index {
    return self.arrUrls[index];
}

- (void)rollView:(JXRollView *)rollView didSelectItemAtIndex:(NSInteger)index {
    NSLog(@"%s", __func__);
}







- (void)dealloc {
    [self.rollView free];
//    [_jxRollViewAnotherKind jx_free];
//    [_jxRollViewLast jx_free];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end









