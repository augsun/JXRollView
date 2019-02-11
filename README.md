## !!! `JXRollView` 已经不单独更新了~ 且将要废弃, 请使用其更好用的升级版 `JXCarouselView`.
## !!! `JXCarouselView` 不作为独立库, 作为 `JXEfficient` 的子功能, 使用时请接入 `JXEfficient` [点击传送](https://github.com/augsun/JXEfficient) !!!

<p align="center" >
  <img src="https://raw.githubusercontent.com/augsun/JXRollView/master/JXRollViewExample/JXRollViewExample/Assets.xcassets/AppIcon.appiconset/JXRollView_180.png?raw=true" alt="JXRollView" title="JXRollView">
</p>

<p align="center" >
The easiest way to create an infinite loop scroll view.
</p>

<p align="center" >
  <img src="https://raw.githubusercontent.com/augsun/Resources/master/JXRollView/jxRollView.gif" alt="JXRollView" title="jxRollView">
</p>

[![Twitter](https://img.shields.io/badge/twitter-@jianxingangel-blue.svg?style=flat-square)](http://twitter.com/jianxingangel)

<p align="right" >
NO BEST ONLY CLOSER.
</p>

## Installation with CocoaPods 

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like JXRollView in your projects.You can install it with the following command:

    pod 'JXRollView'

## Installation through manually

1. Download the [latest version](https://github.com/augsun/JXRollView/archive/master.zip).

2. Open your project in Xcode, then drag and drop `JXRollView.h` and `JXRollView.m` onto your project (use the "Product Navigator view"). Make sure to select Copy items when asked if you extracted the code archive outside of your project.
3. Include JXRollView wherever you need it with `#import "JXRollView.h"`.


## How To Get Started
####1. Create JXRollView.
```objc
- (instancetype)initWithFrame:(CGRect)frame;
```
#####or outlet from (IB)Xib.
```objc
@property (weak, nonatomic) IBOutlet JXRollView *rollView;
```

####2. Implement the method of JXRollViewDelegate.
```objc
@protocol JXRollViewDelegate <NSObject>

@required
- (NSInteger)numberOfItemsInRollView:(nonnull JXRollView *)rollView;
- (void)rollView:(nonnull JXRollView *)rollView setImageForImageView:(nonnull UIImageView *)imageView atIndex:(NSInteger)index;

@optional
- (void)rollView:(nonnull JXRollView *)rollView didTapItemAtIndex:(NSInteger)index;

@end
```

####3. It reload data.
```objc
- (void)reloadData;
```

## License
JXRollView is distributed under the terms and conditions of the [MIT LICENSE](http://rem.mit-license.org/).



