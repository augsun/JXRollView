//
//  ViewController.m
//  JXRollViewExample
//
//  Created by shiba_iosJX on 6/12/16.
//  Copyright © 2016 CoderSun. All rights reserved.
//

#import "ViewController.h"
#import "JXRollView.h"
#import "UIImageView+WebCache.h"

@interface ViewController () <JXRollViewDelegate>

@property (nonatomic, strong)           JXRollView          *rollViewImage;
@property (nonatomic, strong)           JXRollView          *rollViewColor;
@property (weak, nonatomic) IBOutlet    JXRollView          *rollViewFromXib;
@property (nonatomic, strong)           NSArray <NSURL *>   *arrUrls;

@end

@implementation ViewController

- (NSArray<NSURL *> *)arrUrls {
    if (!_arrUrls) {
        NSString *strWScreen = [NSString stringWithFormat:@".%ld", (long)[UIScreen mainScreen].bounds.size.width];
        NSString *strUrlBase = @"https://raw.githubusercontent.com/augsun/Resources/master/JXRollView/";
#define STR_CAT2(str1, str2)    [NSString stringWithFormat:@"%@%@", str1, str2]
#define URL_FROM_NAME(name)     [NSURL URLWithString:STR_CAT2(strUrlBase, STR_CAT2(name, STR_CAT2(strWScreen, @".jpg")))]
        _arrUrls = @[
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
    }
    return _arrUrls;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    const CGFloat yLocation = 20.f;
    const CGFloat imgRate = 16 / 9.f;
    const CGFloat wScreen = [UIScreen mainScreen].bounds.size.width;
    const CGFloat spa_Edge = 8.f;
    
    // Create a JXRollView with image indicator.
    // 创建指示器为自定义图片的 JXRollView.
    self.rollViewImage = [[JXRollView alloc] initWithFrame:CGRectMake(0, 20, wScreen, wScreen / imgRate)];
    [self.view addSubview:self.rollViewImage];
    self.rollViewImage.pageIndicatorImage = [UIImage imageNamed:@"indicatorImageNormal"];
    self.rollViewImage.currentPageIndicatorImage = [UIImage imageNamed:@"indicatorImageHighlight"];
    self.rollViewImage.autoRollingTimeInterval = M_LN10;
    self.rollViewImage.delegate = self;
    [self.rollViewImage reloadData];
    
    // Create a JXRollView with custom color indicator.
    // 创建指示器为自定义颜色的 JXRollView.
    CGFloat x = 2 * spa_Edge;
    CGFloat y = yLocation + self.rollViewImage.frame.size.height + spa_Edge;
    CGFloat w = wScreen - 4 * spa_Edge;
    CGFloat h = (wScreen - 2 * spa_Edge) / imgRate;
    self.rollViewColor = [[JXRollView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    [self.view addSubview:self.rollViewColor];
    self.rollViewColor.pageIndicatorColor = [UIColor lightGrayColor];
    self.rollViewColor.currentPageIndicatorColor = [UIColor redColor];
    self.rollViewColor.delegate = self;
    self.rollViewColor.autoRolling = NO;
    [self.rollViewColor reloadData];
    
    // Create a JXRollView from Xib.
    // 从 Xib 创建 JXRollView.
    self.rollViewFromXib.delegate = self;
    self.rollViewFromXib.indicatorToBottomSpacing = 20;
    self.rollViewFromXib.interitemSpacing = 4.f;
    self.rollViewFromXib.autoRollingTimeInterval = M_SQRT2;
    [self.rollViewFromXib reloadData];
    
}

#pragma mark <JXRollViewDelegate>
- (NSInteger)numberOfItemsInRollView:(JXRollView *)rollView {
    return self.arrUrls.count;
}

- (void)rollView:(JXRollView *)rollView setImageForImageView:(UIImageView *const)imageView atIndex:(NSInteger)index {
    // Recommend use [[SDWebImageManager sharedManager] downloadImageWithURL:options:progress:completed:] method to set image.
    // 推荐使用 [[SDWebImageManager sharedManager] downloadImageWithURL:options:progress:completed:] 方法设置图片.
    [[SDWebImageManager sharedManager] downloadImageWithURL:self.arrUrls[index] options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        imageView.image = image;
    }];
}

- (void)rollView:(JXRollView *)rollView didTapItemAtIndex:(NSInteger)index {
    NSLog(@"Tap the index %ld", index);
}

@end









