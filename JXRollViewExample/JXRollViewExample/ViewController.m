//
//  ViewController.m
//  JXRollViewExample
//
//  Created by shiba_iosJX on 6/12/16.
//  Copyright © 2016 CoderSun. All rights reserved.
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
    CGFloat spa_Edge = 8.f;
    
// ==========================================================================================
    // Create a JXRollView with image indicator.
    self.rollView = [[JXRollView alloc] initWithFrame:CGRectMake(0, yLocation, wScreen, wScreen / imgRate)
                                   pageIndicatorImage:[UIImage imageNamed:@"indicatorImageNormal"]
                            currentPageIndicatorImage:[UIImage imageNamed:@"indicatorImageHighlight"]];
    [self.view addSubview:self.rollView];
    self.rollView.delegate = self;
    [self.rollView reloadData];
    
    // Create a JXRollView with custom color indicator.
    CGRect rectAnotherKind = CGRectMake(2 * spa_Edge,
                                        yLocation + self.rollView.frame.size.height + spa_Edge,
                                        wScreen - 4 * spa_Edge,
                                        (wScreen - 2 * spa_Edge) / imgRate );
    self.rollViewAnotherKind = [[JXRollView alloc] initWithFrame:rectAnotherKind
                                              pageIndicatorColor:[UIColor lightGrayColor]
                                       currentPageIndicatorColor:[UIColor redColor]];
    [self.view addSubview:self.rollViewAnotherKind];
    self.rollViewAnotherKind.delegate = self;
    self.rollViewAnotherKind.autoRoll = NO;
    [self.rollViewAnotherKind reloadData];
    
    // Create a JXRollView with color(system default) indicator.
    CGRect rectRollViewLast = CGRectMake(2 * spa_Edge,
                                         self.rollViewAnotherKind.frame.origin.y + self.rollViewAnotherKind.frame.size.height + spa_Edge,
                                         wScreen - 4 * spa_Edge,
                                         (wScreen - 2 * spa_Edge) / imgRate);
    self.rollViewLast = [[JXRollView alloc] initWithFrame:rectRollViewLast
                                              pageIndicatorColor:nil
                                       currentPageIndicatorColor:nil];
    [self.view addSubview:self.rollViewLast];
    self.rollViewLast.delegate = self;
    self.rollViewLast.indicatorToBottomSpacing = 20;
    [self.rollViewLast reloadData];
    
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
    [self.rollViewAnotherKind free];
    [self.rollViewLast free];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end









