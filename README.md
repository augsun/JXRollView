
<p align="center" >
  <img src="https://github.com/augsun/JXRollView/blob/master/JXRollView/Assets.xcassets/AppIcon.appiconset/JXRollView_180.png" alt="JXRollView" title="JXRollView">
</p>
[![Twitter](https://img.shields.io/badge/twitter-@jianxingangel-blue.svg?style=flat)](http://twitter.com/jianxingangel)

<p align="center" >
The easiest way to create an infinite loop scroll view.
</p>

    //step 1 创建 JXRollView
    _jxRollView = [[JXRollView alloc] initWithFrame:CGRectMake(0, 110, WIDTH_SCREEN, WIDTH_SCREEN/2)];
    
    //step 2 图片 URL 数据
    _jxRollView.arrImgStrUrls = arrImagesStrUrl;
    
    //step 3 事件回调
    _jxRollView.blockTapAction = ^(NSInteger index) {
        NSLog(@"Tap The Index %ld!",index);
    };
    //step 4 在 dealloc 方法中调用释放
==
[![Twitter](https://img.shields.io/badge/twitter-@jianxingangel-blue.svg?style=flat)](http://twitter.com/jianxingangel)
