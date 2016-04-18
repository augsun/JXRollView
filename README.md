
<p align="center" >
  <img src="https://github.com/augsun/JXRollView/blob/master/JXRollView/Assets.xcassets/AppIcon.appiconset/JXRollView_180.png" alt="JXRollView" title="JXRollView">
</p>

<p align="center" >
The easiest way to create an infinite loop scroll view.
</p>

[![Twitter](https://img.shields.io/badge/twitter-@jianxingangel-blue.svg?style=flat-square)](http://twitter.com/jianxingangel)

<p align="right" >
NO BEST ONLY CLOSER.
</p>


## Installation 
#####Installation with CocoaPods is coming soon...Without it is also very simple as follows.
1. Download the [latest version](https://github.com/augsun/JXRollView/archive/master.zip).

2. Open your project in Xcode, then drag and drop `JXRollView.h` and `JXRollView.m` onto your project (use the "Product Navigator view"). Make sure to select Copy items when asked if you extracted the code archive outside of your project.
3. Include JXRollView wherever you need it with `#import "JXRollView.h"`.


## How To Get Started
######以创建 pageControl 为自定义图片 的 JXRollView 为例
####1. (create) 创建 JXRollView

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
    
####2. (start rolling) 开始滚动
    [_jxRollView jx_refreshRollViewByUrls:arrUrls];
    
####3. (release) 在父对象销毁之前释放 JXRollView
	- (void)dealloc {
        [_jxRollView jx_free];
    }
    
####4. (OPTIONAL) 如果不想在 JXRollView 所在页面出现闪滚(从子页面返回 或 从后台切换到前台), 即 JXRollView 所在页每次出现都重新滚动(非从第一张), 则在:
######1. 在 JXRollView 所在页面的 viewDidAppear 和 viewWillDisappear 发送相应通知;
	- (void)viewDidAppear:(BOOL)animated {
        [super viewDidAppear:animated];
        [[NSNotificationCenter defaultCenter] postNotificationName:JXROLLVIEW_PLAY object:nil];
    }

    - (void)viewWillDisappear:(BOOL)animated {
        [super viewWillDisappear:animated];
        [[NSNotificationCenter defaultCenter] postNotificationName:JXROLLVIEW_PAUSE object:nil];
    }
######2. 在 AppDelegate applicationDidEnterBackground 和 applicationWillEnterForeground 发送相应通知;
	- (void)applicationDidEnterBackground:(UIApplication *)application {
        [[NSNotificationCenter defaultCenter] postNotificationName:JXROLLVIEW_PAUSE object:nil];
    }
    
    - (void)applicationWillEnterForeground:(UIApplication *)application {
        [[NSNotificationCenter defaultCenter] postNotificationName:JXROLLVIEW_PLAY object:nil];
    }

     
## License
JXRollView is distributed under the terms and conditions of the [MIT LICENSE](http://rem.mit-license.org/).See LICENSE for details.

## Who Use It 
[SHIBA](https://itunes.apple.com/cn/app/shi-ba-mian-fei-shi-yong-shi/id1073524695)


