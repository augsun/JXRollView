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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    NSArray *arrImagesStrUrl = @[
                                 @"http://juhuituan.boguyuan.com/juhuituan/file_upload/myt/201507/20150725/20150725034403725.jpg",
                                 @"http://juhuituan.boguyuan.com/juhuituan/file_upload/myt/201507/20150725/20150725025802743.png",
                                 @"http://juhuituan.boguyuan.com/juhuituan/file_upload/myt/201507/20150725/20150725025502036.png",
                                 @"http://juhuituan.boguyuan.com/juhuituan/file_upload/myt/201507/20150725/20150725025102481.png",
                                 @"http://juhuituan.boguyuan.com/juhuituan/file_upload/myt/201505/20150527/20150527001812082.png"
                                 ];
    //step 1 创建 JXRollView
    _jxRollView = [[JXRollView alloc] initWithFrame:CGRectMake(0, 110, WIDTH_SCREEN, WIDTH_SCREEN/2)];
    
    //step 2 图片 URL 数据
    _jxRollView.arrImgStrUrls = arrImagesStrUrl;
    
    //step 3 事件回调
    _jxRollView.blockTapAction = ^(NSInteger index) {
        NSLog(@"Tap The Index %ld!",index);
    };
    //step 4 在 dealloc 方法中调用释放
    
    /*
     *  如果不想在 JXRollView 所在页面出现闪滚(从子页面返回 或 从后台切换到前台), 即 JXRollView 所在页每次出现都重新滚动(非从第一张), 则在
     1. JXRollView 所在页面的 viewDidAppear 和 viewWillDisappear 发送相应通知;(详见 demo)
     2. 在 AppDelegate applicationDidEnterBackground 和 applicationWillEnterForeground 发送相应通知;(详见 demo)
     */
    [self.view addSubview:_jxRollView];

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
}









- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
