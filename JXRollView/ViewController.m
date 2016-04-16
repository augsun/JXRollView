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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
#define STR_CAT(str1, str2)     [NSString stringWithFormat:@"%@%@", str1, str2]
    NSString *strUrlBase = @"http://juhuituan.boguyuan.com/juhuituan/file_upload/myt/";
    NSArray <NSURL *> *arrUrls = @[
                                   [NSURL URLWithString:STR_CAT(strUrlBase, @"201507/20150725/20150725034403725.jpg")],
                                   [NSURL URLWithString:STR_CAT(strUrlBase, @"201507/20150725/20150725025802743.png")],
                                   [NSURL URLWithString:STR_CAT(strUrlBase, @"201507/20150725/20150725025502036.png")],
                                   [NSURL URLWithString:STR_CAT(strUrlBase, @"201507/20150725/20150725025102481.png")],
                                   [NSURL URLWithString:STR_CAT(strUrlBase, @"201505/20150527/20150527001812082.png")],
                                   ];
#undef STR_CAT
    CGFloat yLocation = 100;
    CGFloat imgRate = 2.f;
    CGFloat wScreen = [UIScreen mainScreen].bounds.size.width;
    
#pragma mark 以创建 pageControl 为自定义图片 的 JXRollView 为例
    // step 1 创建 JXRollView
    __weak __typeof(self) weakSelf = self;
    _jxRollView = [[JXRollView alloc] initWithFrame:CGRectMake(0, yLocation, wScreen, wScreen / imgRate)
                               indicatorImageNormal:[UIImage imageNamed:@"indicatorImageNormal"]
                            indicatorImageHighlight:[UIImage imageNamed:@"indicatorImageHighlight"]
                                    animateInterval:2.f
                                          tapAction:^(NSInteger tapIndex) {
                                              NSLog(@"Tap The Index %ld!",tapIndex);
                                              __strong __typeof(weakSelf) strongSelf = weakSelf;
                                              // 该 block 里应该使用 strongSelf
                                              if (strongSelf.view.isHidden) {
                                              
                                              }
                                          }];
    [self.view addSubview:_jxRollView];
    
    // step 2 开始滚动
    [_jxRollView jx_RefreshRollViewByUrls:arrUrls];
    
    // step 3 在父对象销毁之前释放 JXRollView
    /*(详见 示例代码)*/
    
    // step 3 (optional)
    /*
     *  如果不想在 JXRollView 所在页面出现闪滚(从子页面返回 或 从后台切换到前台), 即 JXRollView 所在页每次出现都重新滚动(非从第一张), 则在
     1. 在 JXRollView 所在页面的 viewDidAppear 和 viewWillDisappear 发送相应通知;(详见 demo)
     2. 在 AppDelegate applicationDidEnterBackground 和 applicationWillEnterForeground 发送相应通知;(详见 demo)
     */
    
#pragma mark 创建 pageControl 为自定义颜色 的 JXRollView
    CGFloat spa_Edge = 30;
    CGRect rectJXRollViewTypeColor = CGRectMake(spa_Edge,
                                                yLocation + _jxRollView.frame.size.height + spa_Edge,
                                                200,
                                                120);
    _jxRollViewAnotherKind = [[JXRollView alloc] initWithFrame:rectJXRollViewTypeColor
                                          indicatorColorNormal:[UIColor grayColor]
                                       indicatorColorHighlight:[UIColor orangeColor]
                                               animateInterval:1.f
                                                     tapAction:^(NSInteger tapIndex) {
                                                     
                                                     }];
    [self.view addSubview:_jxRollViewAnotherKind];
    [_jxRollViewAnotherKind jx_RefreshRollViewByUrls:arrUrls];
    
    
    
    
    

}

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

-(void)dealloc {
    [self.jxRollView jx_Free];
    [self.jxRollViewAnotherKind jx_Free];
}









- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
