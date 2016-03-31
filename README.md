
<p align="center" >
  <img src="http://static.oschina.net/uploads/space/2016/0331/113119_iQiL_2434368.png" alt="JXRollView" title="JXRollView">
</p>

<p align="center" >
The easiest way to create an infinite loop scroll view.
</p>
=
    //step 1 创建 JXRollView
    _jxRollView = [[JXRollView alloc] initWithFrame:CGRectMake(0, 110, WIDTH_SCREEN, WIDTH_SCREEN/2)];
    
    //step 2 图片 URL 数据
    _jxRollView.arrImgStrUrls = arrImagesStrUrl;
    
    //step 3 事件回调
    _jxRollView.blockTapAction = ^(NSInteger index) {
        NSLog(@"Tap The Index %ld!",index);
    };
    //step 4 在 dealloc 方法中调用释放
