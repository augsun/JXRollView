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

@interface ViewController ()

@property (nonatomic, strong) JXRollView *jxRollView;
@property (nonatomic, strong) JXRollView *jxRollViewAnotherKind;

@property (nonatomic, strong) JXRollView *jxRollViewLast;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor colorWithRed:239/255.f green:239/255.f blue:244/255.f alpha:1.f];
    
#define STR_CAT(str1, str2)     [NSString stringWithFormat:@"%@%@", str1, str2]
    NSString *strUrlBase = @"http://img.51shiba.com/";
    NSArray <NSURL *> *arrUrls = @[
                                   [NSURL URLWithString:STR_CAT(strUrlBase, @"M00/02/FE/Cvmki1b80S-AcaM0AAEnegwfb4Y261.jpg")],
                                   [NSURL URLWithString:STR_CAT(strUrlBase, @"M00/03/46/Cvmki1cLVTWASqItAACZKcsjVhY117.jpg")],
                                   [NSURL URLWithString:STR_CAT(strUrlBase, @"M00/02/FF/Cvmki1b80W2ARBqqAAFQE2bkZ-Q237.jpg")],
                                   [NSURL URLWithString:STR_CAT(strUrlBase, @"M00/02/FF/Cvmki1b80WyASlfhAAES1pEwsjI653.jpg")],
                                   [NSURL URLWithString:STR_CAT(strUrlBase, @"M00/03/39/Cvmki1cHUXeAPQn6AACgVAcdtk0325.jpg")],
                                   [NSURL URLWithString:STR_CAT(strUrlBase, @"M00/03/39/Cvmki1cHLd-AEMkUAADiBAlh4VU041.jpg")],
                                   [NSURL URLWithString:STR_CAT(strUrlBase, @"M00/03/38/Cvmki1cHJiCASqhdAACZreZxFCw557.jpg")],
                                   ];

#undef STR_CAT
    CGFloat yLocation = 60;
    CGFloat imgRate = 2.f;
    CGFloat wScreen = [UIScreen mainScreen].bounds.size.width;
    
#pragma mark 以创建 pageControl 为自定义图片 的 JXRollView 为例
    // STEP 1 创建 JXRollView
    __weak __typeof(self) weakSelf = self;
    _jxRollView = [[JXRollView alloc] initWithFrame:CGRectMake(0, yLocation, wScreen, wScreen / imgRate)
                               indicatorImageNormal:[UIImage imageNamed:@"indicatorImageNormal"]
                            indicatorImageHighlight:[UIImage imageNamed:@"indicatorImageHighlight"]
                                    animateInterval:M_PI
                                          tapAction:^(NSInteger tapIndex) {
                                              __strong __typeof(weakSelf) strongSelf = weakSelf;
                                              [strongSelf rollViewTapIndex:tapIndex];
                                          }];
    [self.view addSubview:_jxRollView];
    
    // STEP 2 开始滚动
    [_jxRollView jx_refreshRollViewByUrls:arrUrls];
    
    // STEP 3 在父对象销毁之前释放 JXRollView
    /*
     * (详见 demo)
     */
    
    // STEP 4 (optional)
    /*
     * 如果不想在 JXRollView 所在页面出现闪滚(从子页面返回 或 从后台切换到前台), 即 JXRollView 所在页每次出现都重新滚动(非从第一张), 则在
     * (详见 demo)1. 在 JXRollView 所在页面的 viewDidAppear 和 viewWillDisappear 发送相应通知;
     * (详见 demo)2. 在 AppDelegate applicationDidEnterBackground 和 applicationWillEnterForeground 发送相应通知;
     */
    
    
#pragma mark 创建 pageControl 为自定义颜色 的 JXRollView
    CGFloat spa_Edge = 30;
    CGRect rectRollViewAnotherKind = CGRectMake(spa_Edge,
                                                yLocation + _jxRollView.frame.size.height + spa_Edge,
                                                wScreen - 2 * spa_Edge,
                                                120);
    _jxRollViewAnotherKind = [[JXRollView alloc] initWithFrame:rectRollViewAnotherKind
                                          indicatorColorNormal:nil
                                       indicatorColorHighlight:nil
                                               animateInterval:M_E
                                                     tapAction:^(NSInteger tapIndex) {
                                                     
                                                     }];
    [self.view addSubview:_jxRollViewAnotherKind];
    [_jxRollViewAnotherKind jx_refreshRollViewByUrls:[arrUrls subarrayWithRange:NSMakeRange(1, 5)]];
    
    //
    CGRect rectRollViewLast = CGRectMake(spa_Edge,
                                         _jxRollViewAnotherKind.frame.origin.y + _jxRollViewAnotherKind.frame.size.height + spa_Edge,
                                         wScreen - 2 * spa_Edge,
                                         120);

    _jxRollViewLast = [[JXRollView alloc] initWithFrame:rectRollViewLast
                                   indicatorColorNormal:[UIColor lightGrayColor]
                                indicatorColorHighlight:[UIColor greenColor]
                                        animateInterval:M_SQRT2
                                              tapAction:^(NSInteger tapIndex) {
                                              
                                              }];
    [self.view addSubview:_jxRollViewLast];
    [_jxRollViewLast jx_refreshRollViewByUrls:[arrUrls subarrayWithRange:NSMakeRange(2, 2)]];
    
    

}

//在 JXRollView 所在页面的 viewDidAppear 和 viewWillDisappear 发送相应通知;
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
#warning JXRollView: best to do so.
    [[NSNotificationCenter defaultCenter] postNotificationName:JXROLLVIEW_PLAY object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
#warning JXRollView: best to do so.
    [[NSNotificationCenter defaultCenter] postNotificationName:JXROLLVIEW_PAUSE object:nil];
}

- (void)rollViewTapIndex:(NSInteger)tapIndex {
    
}





- (void)dealloc {
    [_jxRollView jx_free];
    [_jxRollViewAnotherKind jx_free];
    [_jxRollViewLast jx_free];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
