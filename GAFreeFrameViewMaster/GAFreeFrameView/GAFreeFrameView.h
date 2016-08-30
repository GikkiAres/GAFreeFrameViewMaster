//
//  GAFreeFrameView.h
//  GAFreeFrameViewMaster
//
//  Created by GikkiAres on 8/26/16.
//  Copyright © 2016 GikkiAres. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, GAFreeFrameViewMode) {
  GAFreeFrameViewModeFreedom,
  GAFreeFrameViewMode1To1,
  GAFreeFrameViewMode4To3,
  GAFreeFrameViewMode3To4,
  GAFreeFrameViewMode16To9,
  GAFreeFrameViewMode9To16,
};


@class GAFreeFrameView;
@protocol GAFreeFrameViewDelegate <NSObject>
@optional
- (void)GAFreeFrameViewBeginChangingFrame:(GAFreeFrameView *)view;
- (void)GAFreeFrameViewIsChangingFrame:(GAFreeFrameView *)view;
- (void)GAFreeFrameViewEndChangingFrame:(GAFreeFrameView *)view;

@end


@interface GAFreeFrameView : UIView

@property (nonatomic,weak) id <GAFreeFrameViewDelegate> delegate;

//self.frame辅助计算的几个点
@property(nonatomic,assign)CGFloat fMaxY;
@property(nonatomic,assign)CGFloat fMinY;
@property(nonatomic,assign)CGFloat fMaxX;
@property(nonatomic,assign)CGFloat fMinX;
@property(nonatomic,assign)CGFloat fMidX;
@property(nonatomic,assign)CGFloat fMidY;



//displayView,能否超出container,默认NO,超出没有意义.
@property (nonatomic,assign) BOOL canOverStepContainer;
//吸附距离,距离父视图边框的吸附距离,默认10;
@property (nonatomic,assign) CGFloat attachSuperviewDistance;

@property (nonatomic,assign)GAFreeFrameViewMode mode;
//宽高比
@property (nonatomic,assign)CGFloat kRatio;

//根据自己的模式和父视图,调整自己的frame,应该在两个地方调用
//1 父视图大小确定后,首次手动设置
//2 模式切换后,自动调用
- (void)matchParentSize;
//- (void)matchParentSizeAnimated:(BOOL)animated;


@end
