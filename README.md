
<p align="center" >
  <img src="https://github.com/augsun/JXRollView/blob/master/JXRollView/Assets.xcassets/AppIcon.appiconset/JXRollView_180.png" alt="JXRollView" title="JXRollView">
</p>
<p align="center" >
The easiest way to create an infinite loop scroll view.
</p>
[![Twitter](https://img.shields.io/badge/twitter-@jianxingangel-blue.svg?style=flat-square)](http://twitter.com/jianxingangel)
## How To Get Started
######以创建 pageControl 为自定义图片 的 JXRollView 为例
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
    
## License

JXRollView is distributed under the terms and conditions of the [MIT license](http://rem.mit-license.org/).
## Who Use It 
[ShiBa](https://itunes.apple.com/cn/app/shi-ba-mian-fei-shi-yong-shi/id1073524695)


