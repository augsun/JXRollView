
<p align="center" >
  <img src="https://github.com/augsun/JXRollView/blob/master/JXRollView/Assets.xcassets/AppIcon.appiconset/JXRollView_180.png" alt="JXRollView" title="JXRollView">
</p>
<p align="center" >
The easiest way to create an infinite loop scroll view.
</p>
[![Twitter](https://img.shields.io/badge/twitter-@jianxingangel-blue.svg?style=flat-square)](http://twitter.com/jianxingangel)
## How To Get Started
    //step 1 Create JXRollView
    _jxRollView = [[JXRollView alloc] initWithFrame:CGRectMake(0, 110, WIDTH_SCREEN, WIDTH_SCREEN/2)];
    
    //step 2 Set array contained urls.
    _jxRollView.arrImgStrUrls = arrImagesStrUrl;
    
    //step 3 Event callbacks.
    __weak __typeof(self) weakSelf = self;
    _jxRollView.blockTapAction = ^(NSInteger index) {
        NSLog(@"Tap The Index %ld!",index);
        //If you reference self in this block, use strongSelf to avoid cycle reference wisely.
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.view.isHidden) {
            
        }
    };
    
    //step 4 Release _jxRollView in dealloc method;
    /*
     -(void)dealloc {
        [self.jxRollView jx_Free];
     }
     */

## Who Use It
[ShiBa](https://itunes.apple.com/cn/app/shi-ba-mian-fei-shi-yong-shi/id1073524695)

