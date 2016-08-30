//
//  GAFreeFrameView.m
//  GAFreeFrameViewMaster
//
//  Created by GikkiAres on 8/26/16.
//  Copyright © 2016 GikkiAres. All rights reserved.
//

// 关于各个view的名字:
// FreeFrameView,self就是这个可以自由大小的view.
// SourceView,是选择源的视图,直接父视图得了.


//displayview的最小size是sizeControlView.如果给出的尺寸小于这个,就origin是这个,但是size是最小值.
//init方法,让主要是做那种只需要操作一次的操作,比如一些对象的赋初值.
//但是,这个控件需要提供一个更新尺寸的方法.


//控制块首先更改FrameNew属性.
//然后得到合法的FrameNew,放在frameNew的setter中.
//然后self.farme = frameNew,并更新所有.不要调用set方法,set方法表示外部直接调用设置.


//使用方法
//作为子视图放在待选择的view中,随时返回选中的区域.


//有待改进

//1 实现按比例缩放,切换模式之后的frame,是根据父视图的大小来配置的.
//2 实现吸附效果

#import "GAFreeFrameView.h"
#import "DisplayView.h"


//ControlView的短边固定值
static const CGFloat sizeControlView = 30;
////CornerLength,四个角的长度
//static const CGFloat cornerLength = 10;

//FreeFrameView指的是整个体系, self只是一个容器,真正显示的是displayView;
//static const CGFloat widthMin = sizeControlView;
//static const CGFloat heightMin = sizeControlView;

//保持矩形的尺寸,将中心移动到指定点
CGRect GARectMoveCenterToPoint(CGRect rect, CGPoint pt) {
  rect.origin.x = pt.x-rect.size.width/2;
  rect.origin.y = pt.y-rect.size.height/2;
  return rect;
}

//返回矩形的中点
CGPoint GACenterOfRect(CGRect rect) {
  return CGPointMake(rect.origin.x+rect.size.width/2,rect.origin.y+rect.size.height/2);
}

//根据矩形四个位置来创建rect
CGRect GARectMake(CGFloat left,CGFloat up,CGFloat right,CGFloat bottom) {
  return CGRectMake(left, up, right-left, bottom-up);
}


@interface GAFreeFrameView()

@property (nonatomic,assign) BOOL isLeftAttatched;
@property (nonatomic,assign) BOOL isTopAttatched;
@property (nonatomic,assign) BOOL isRightAttatched;
@property (nonatomic,assign) BOOL isBottomAttatched;

//显示出来的view,displayView会绘制一些图案
@property(nonatomic,strong)DisplayView *displayView;
@property(nonatomic,strong)UIView *sourceView;

////选择区域的矩形frame,这个是核心数据
@property (nonatomic,assign) CGRect frameNew;



//九个控制view
///八个方向的控制view
@property(nonatomic,strong)NSArray *arrControlView;
@property(nonatomic,strong)UIView *viewLeftUp;  //0
@property(nonatomic,strong)UIView *viewUp;      //1
@property(nonatomic,strong)UIView *viewRightUp; //2
@property(nonatomic,strong)UIView *viewRight;   //3
@property(nonatomic,strong)UIView *viewRightDown;//4
@property(nonatomic,strong)UIView *viewDown;    //5
@property(nonatomic,strong)UIView *viewLeftDown;  //6
@property(nonatomic,strong)UIView *viewLeft;    //7
//中间的view,用来响应拖动.
@property(nonatomic,strong)UIView *viewCenter;//8





//八个控制View的中心点
@property(nonatomic,strong)NSArray *arrControlPoint;
@property(nonatomic,assign)CGPoint ptLeftUp;
@property(nonatomic,assign)CGPoint ptUp;
@property(nonatomic,assign)CGPoint ptRightUp;
@property(nonatomic,assign)CGPoint ptRight;
@property(nonatomic,assign)CGPoint ptRightDown;
@property(nonatomic,assign)CGPoint ptDown;
@property(nonatomic,assign)CGPoint ptLeftDown;
@property(nonatomic,assign)CGPoint ptLeft;
@property(nonatomic,assign)CGPoint ptCenter;




@end


@implementation GAFreeFrameView

#pragma mark 1 - SystemCycle
#pragma mark 1.1 Init方法
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (void)setFrame:(CGRect)frame {
  [super setFrame:frame];
  [self updateAllControlViewGeometry];
}


- (void)didMoveToSuperview {
  //调整self大小如果没有设置,就设置为父视图的大小,然后更新所有
  if(self.frame.size.width == 0) {
    self.frame = self.superview.frame;
  }
  self.superview.userInteractionEnabled = YES;
  
  //先加self,再加displayView,再加控制View
  [self.superview addSubview:_displayView];
  
  [self.superview addSubview:_viewLeftUp];
  [self.superview addSubview:_viewUp];
  [self.superview addSubview:_viewRightUp];
  [self.superview addSubview:_viewRight];
  [self.superview addSubview:_viewRightDown];
  [self.superview addSubview:_viewDown];
  [self.superview addSubview:_viewLeftDown];
  [self.superview addSubview:_viewLeft];
  [self.superview addSubview:_viewCenter];
  [self updateAllControlViewGeometry];
}

-(void)setMode:(GAFreeFrameViewMode)mode {
  _mode = mode;
  switch (mode) {
    case GAFreeFrameViewModeFreedom:
      _kRatio=-1;
      break;
      case GAFreeFrameViewMode1To1:
      _kRatio = 1;
            break;
    case GAFreeFrameViewMode4To3:
      _kRatio=4/3.0;
            break;
    case GAFreeFrameViewMode3To4:
      _kRatio = 3/4.0;
            break;
    case GAFreeFrameViewMode16To9:
      _kRatio = 16/9.0;
            break;
    case GAFreeFrameViewMode9To16:
      _kRatio = 9/16.0;
            break;
    default:
      break;
  }
  [self matchParentSize];
  
  
}


#pragma mark 2 - BasicFunc

//根据自己的模式和父视图,调整自己的frame,应该在两个地方调用
//1 父视图大小确定后,首次手动设置
//2 模式切换后,自动调用
- (void)matchParentSize {
  //父视图的maskview不能动画,除非maskview写在自己这边.可以,等下改.
  [self matchParentSizeAnimated:NO];
}
- (void)matchParentSizeAnimated:(BOOL) animated {
  CGRect frame = CGRectZero;
  if (_kRatio==-1) {
    frame = CGRectInset(self.superview.bounds, 10, 10);
  }
  else {
    //让一条边沾满,一条边有余量.算出比例下最短边.先检查父视图的宽度是不是最短
    //    ws'/hs = kRatio, ws= kRatio*hs;
    CGFloat widthSuper = self.superview.frame.size.width;
    CGFloat heightSuper = self.superview.frame.size.height;
    CGFloat widthCompare = _kRatio*heightSuper;
    
    if (widthSuper>widthCompare) {
      //宽度是长边,应该沾满高度.
      CGFloat heightSelf = heightSuper;
      CGFloat widthSelf = heightSelf*_kRatio;

      frame = CGRectInset(self.superview.bounds, (widthSuper-widthSelf)/2,(heightSuper-heightSelf)/2);
    }
    else {
      //宽度是短边,沾满宽度
      CGFloat widthSelf = widthSuper;
      CGFloat heightSelf = widthSelf/_kRatio;
      frame = CGRectInset(self.superview.bounds,  (widthSuper-widthSelf)/2,(heightSuper-heightSelf)/2);
    }
    
  }
  
  
  
  if(animated) {
    [UIView animateWithDuration:2 animations:^{
      self.frame = frame;
    }];
  }
  else {
    self.frame = frame;
  }
}



- (void)commonInit {
  _canOverStepContainer = NO;
  _attachSuperviewDistance = 10;
  _kRatio = -1;
  _mode = GAFreeFrameViewModeFreedom;
  
  _displayView = [DisplayView new];
  _displayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
  _displayView.backgroundColor = [UIColor clearColor];
  
  
  
  _viewLeftUp = [[UIView alloc]init];
  _viewUp = [[UIView alloc]init];
  _viewRightUp = [[UIView alloc]init];
  _viewRight = [[UIView alloc]init];
  _viewRightDown = [[UIView alloc]init];
  _viewDown = [[UIView alloc]init];
  _viewLeftDown =[[UIView alloc]init];
  _viewLeft = [[UIView alloc]init];
  _viewCenter = [[UIView alloc]init];
  
  UIColor *color = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.25];
  color = [UIColor clearColor];
  _viewLeftUp.backgroundColor = color;
  _viewUp.backgroundColor = color;
  _viewRightUp.backgroundColor = color;
  _viewRight.backgroundColor = color;
  _viewRightDown.backgroundColor = color;
  _viewDown.backgroundColor = color;
  _viewLeftDown.backgroundColor = color;
  _viewLeft.backgroundColor = color;
  _viewCenter.backgroundColor = [UIColor colorWithRed:0.9516 green:0.0 blue:0.0047 alpha:0.25];
  _viewCenter.backgroundColor = [UIColor clearColor];
  
  //手势
  UIPanGestureRecognizer *panMove = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panMove:)];
  [_viewCenter addGestureRecognizer:panMove];
  
  UIPanGestureRecognizer *panLeftUp = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panLeftUp:)];
  [_viewLeftUp addGestureRecognizer:panLeftUp];
  
  UIPanGestureRecognizer *panUp = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panUp:)];
  [_viewUp addGestureRecognizer:panUp];
  
  UIPanGestureRecognizer *panRightUp = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panRightUp:)];
  [_viewRightUp addGestureRecognizer:panRightUp];
  
  UIPanGestureRecognizer *panRight = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panRight:)];
  [_viewRight addGestureRecognizer:panRight];
  
  UIPanGestureRecognizer *panRightDown = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panRightDown:)];
  [_viewRightDown addGestureRecognizer:panRightDown];
  
  UIPanGestureRecognizer *panDown = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDown:)];
  [_viewDown addGestureRecognizer:panDown];
  
  UIPanGestureRecognizer *panLeftDown = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panLeftDown:)];
  [_viewLeftDown addGestureRecognizer:panLeftDown];
  
  UIPanGestureRecognizer *panLeft = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panLeft:)];
  [_viewLeft addGestureRecognizer:panLeft];
  
  
}

//self.center是在父坐标系下的center
//现在要得到FreeFrameView container的中心点.
- (CGPoint)centerInSelf {
  return CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}




//根据当前chooseRect的值来更新当前所有视图的尺寸
- (void)updateAllControlViewGeometry {
  //1 控制点更新
  _fMaxX = CGRectGetMaxX(self.frame);
  _fMaxY = CGRectGetMaxY(self.frame);
  _fMinX = CGRectGetMinX(self.frame);
  _fMinY = CGRectGetMinY(self.frame);
  _fMidY = CGRectGetMidY(self.frame);
  _fMidX = CGRectGetMidX(self.frame);
  //2 中心点更新
  _ptLeftUp = CGPointMake(_fMinX, _fMinY);
  _ptUp = CGPointMake(_fMidX, _fMinY);
  _ptRightUp = CGPointMake(_fMaxX, _fMinY);
  _ptRight = CGPointMake(_fMaxX, _fMidY);
  _ptRightDown = CGPointMake(_fMaxX, _fMaxY);
  _ptDown = CGPointMake(_fMidX, _fMaxY);
  _ptLeftDown = CGPointMake(_fMinX, _fMaxY);
  _ptLeft = CGPointMake(_fMinX, _fMidY);
  _ptCenter = self.center;
  
  //3 控制view的size
  CGFloat width = _fMaxX-_fMinX-sizeControlView;
  CGFloat height = _fMaxY-_fMinY-sizeControlView;
  CGRect frameLeftUp = CGRectMake(0, 0, sizeControlView, sizeControlView);
  CGRect frameUp = CGRectMake(0, 0, width, sizeControlView);
  CGRect frameRightUp = CGRectMake(0, 0, sizeControlView, sizeControlView);
  CGRect frameRight = CGRectMake(0, 0, sizeControlView, height);
  CGRect frameRightDown = CGRectMake(0, 0, sizeControlView, sizeControlView);
  CGRect frameDown = CGRectMake(0, 0, width, sizeControlView);
  CGRect frameLeftDown = CGRectMake(0, 0, sizeControlView, sizeControlView);
  CGRect frameLeft = CGRectMake(0, 0, sizeControlView, height);
  CGRect frameCenter = CGRectMake(0, 0, width, height);
  
  _viewLeftUp.frame = frameLeftUp;
  _viewUp.frame = frameUp;
  _viewRightUp.frame = frameRightUp;
  _viewRight.frame = frameRight;
  _viewRightDown.frame = frameRightDown;
  _viewDown.frame = frameDown;
  _viewLeftDown.frame = frameLeftDown;
  _viewLeft.frame = frameLeft;
  _viewCenter.frame = frameCenter;
  
  _viewLeftUp.center = _ptLeftUp;
  _viewUp.center = _ptUp;
  _viewRightUp.center = _ptRightUp;
  _viewRight.center = _ptRight;
  _viewRightDown.center = _ptRightDown;
  _viewDown.center = _ptDown;
  _viewLeftDown.center = _ptLeftDown;
  _viewLeft.center = _ptLeft;
  _viewCenter.center = _ptCenter;
  
  //  _maskViewTop.frame = CGRectMake(sizeControlView/2, sizeControlView/2, _sourceView.frame.size.width, _fMinY-sizeControlView/2);
  //  _maskViewDown.frame = CGRectMake(sizeControlView/2, _fMaxY, _sourceView.frame.size.width, _sourceView.frame.size.height-_fMaxY+sizeControlView/2);
  //  _maskViewLeft.frame = CGRectMake(sizeControlView/2, _fMinY, _fMinX-sizeControlView/2, _fMaxY-_fMinY);
  //  _maskViewRight.frame = CGRectMake(_fMaxX,_fMinY,_sourceView.frame.size.width-_fMaxX+sizeControlView/2,_fMaxY-_fMinY);
  
  _displayView.frame = self.frame;
  
  [self setNeedsDisplay];
}


//返回
- (CGRect)chooseRectInSourceView {
  return [_sourceView convertRect:self.frame fromView:self];
}


//由于移动和调整大小的限定方式不一样.
- (void)validateNewMoveRect {
  CGFloat newMaxX = CGRectGetMaxX(_frameNew);
  CGFloat newMaxY = CGRectGetMaxY(_frameNew);
  CGFloat newMinX = CGRectGetMinX(_frameNew);
  CGFloat newMinY = CGRectGetMinY(_frameNew);
  
  //位置调整,width,height不变.限定原点位置.
  if (!_canOverStepContainer) {
    //如果越界,那么进行限定.
    if (newMinX<0) {
      _frameNew.origin.x = 0;
    }
    if(newMinY<0) {
      _frameNew.origin.y = 0;
    }
    if(newMaxX>self.superview.frame.size.width) {
      _frameNew.origin.x = self.superview.bounds.size.width-_frameNew.size.width;
    }
    if(newMaxY>self.superview.frame.size.height) {
      _frameNew.origin.y = self.superview.bounds.size.height-_frameNew.size.height;
    }
  }
  //  //吸附靠近效果
  //  if (newMinX<10) {
  //    _frameNew.origin.x = 0;
  //  }
  //  if(newMinY<10) {
  //    _frameNew.origin.y = 0;
  //  }
  //  if(newMaxX>self.superview.frame.size.width-10) {
  //    _frameNew.origin.x = self.bounds.size.width-_frameNew.size.width;
  //  }
  //  if(newMaxY>self.superview.frame.size.height-10) {
  //    _frameNew.origin.y = self.bounds.size.height-_frameNew.size.height;
  //  }
  //  //吸附脱离效果
  
}

//大小调整,只调整某些点的位置,其余点的位置为初始值.
- (void)validateNewSizeRect {
  if (!_canOverStepContainer) {
    CGFloat newMaxX = CGRectGetMaxX(_frameNew);
    CGFloat newMaxY = CGRectGetMaxY(_frameNew);
    CGFloat newMinX = CGRectGetMinX(_frameNew);
    CGFloat newMinY = CGRectGetMinY(_frameNew);
    CGFloat originMaxX = CGRectGetMaxX(self.frame);
    CGFloat originMaxY = CGRectGetMaxY(self.frame);
    CGFloat originMinX = CGRectGetMinX(self.frame);
    CGFloat originMinY = CGRectGetMinY(self.frame);
    //如果越界,那么进行限定.
    if (newMinX<0) {
      _frameNew = GARectMake(0, originMinY, originMaxX, originMaxY);
    }
    if(newMinY<0) {
      _frameNew = GARectMake(originMinX,0, originMaxX, originMaxY);
    }
    if(newMaxX>self.superview.bounds.size.width) {
      _frameNew = GARectMake(originMinX,originMinY,  self.superview.bounds.size.width, originMaxY);
      
    }
    if(newMaxY>self.superview.bounds.size.height) {
      _frameNew = GARectMake(originMinX,originMinY,  originMaxX,  self.superview.bounds.size.height);
    }
  }
}


- (CGPoint)deltaWithRatioOfOriginDelta:(CGPoint)ptDelta sameSign:(BOOL)sign {
  //1 找出现在比例下变化量最大的方向的变化量
  CGFloat deltaXCompare = ABS(ptDelta.y*_kRatio);
  int signX = ptDelta.x>=0?1:-1;
  int signY = ptDelta.y>=0?1:-1;
  
  if (ABS(ptDelta.x)>deltaXCompare) {
    //x方向是变化大的
    if (sign) {
         return CGPointMake(ABS(ptDelta.x)*signX, ABS(ptDelta.x)/_kRatio*signX);
    }
    else {
         return CGPointMake(ABS(ptDelta.x)*signX, ABS(ptDelta.x)/_kRatio*signX*(-1));
    }
 
  }
  else {
    //y方向是变化大的
    if (sign) {
          return  CGPointMake(ABS(ptDelta.y)*_kRatio*signY, ABS(ptDelta.y)*signY);
    }
    else {
      return CGPointMake(ABS(ptDelta.y)*signY*_kRatio*(-1), ABS(ptDelta.y)*signY);
    }

  }
}

#pragma mark 3 - Delegate

#pragma mark 4 - Event
#pragma mark 1 frame控制事件
#pragma mark #1 Move
- (void)panMove:(UIPanGestureRecognizer *)sender {
  // 1 调用代理
  switch (sender.state) {
    case UIGestureRecognizerStateBegan:{
      if (_delegate&&[_delegate respondsToSelector:@selector(GAFreeFrameViewBeginChangingFrame:)]) {
        [_delegate GAFreeFrameViewBeginChangingFrame:self];
      }
      break;
    }
    case UIGestureRecognizerStateChanged :{
      if (_delegate&&[_delegate respondsToSelector:@selector(GAFreeFrameViewIsChangingFrame:)]) {
     [_delegate GAFreeFrameViewIsChangingFrame:self];
      }
      break;
    }
    case UIGestureRecognizerStateEnded: {
      if (_delegate&&[_delegate respondsToSelector:@selector(GAFreeFrameViewEndChangingFrame:)]) {
     [_delegate GAFreeFrameViewEndChangingFrame:self];
      }
      break;
    }
    default: break;
  }
  // 2 更新_frameNew;
  //  CGPoint center = GACenterOfRect(self.frame);
  CGPoint center = self.center;
  CGPoint ptDelta = [sender translationInView:self];
  CGPoint centerNew = CGPointMake(center.x+ptDelta.x, center.y+ptDelta.y);
  _frameNew = GARectMoveCenterToPoint(self.frame, centerNew);
  
  //3 限定NewRect的位置
  //根据当前的新尺寸,返回合法新尺寸,主要是针对超越容器的情况的处理.
  [self validateNewMoveRect];
  
  //4 更新self.frame
  self.frame = _frameNew;
  [sender setTranslation:CGPointZero inView:self];
  
}

- (void)panLeftUp:(UIPanGestureRecognizer *)sender {
  // 1 调用代理
  switch (sender.state) {
    case UIGestureRecognizerStateBegan:{
      if (_delegate&&[_delegate respondsToSelector:@selector(GAFreeFrameViewBeginChangingFrame:)]) {
        [_delegate GAFreeFrameViewBeginChangingFrame:self];
      }
      break;
    }
    case UIGestureRecognizerStateChanged :{
      if (_delegate&&[_delegate respondsToSelector:@selector(GAFreeFrameViewIsChangingFrame:)]) {
        [_delegate GAFreeFrameViewIsChangingFrame:self];
      }
      break;
    }
    case UIGestureRecognizerStateEnded: {
      if (_delegate&&[_delegate respondsToSelector:@selector(GAFreeFrameViewEndChangingFrame:)]) {
        [_delegate GAFreeFrameViewEndChangingFrame:self];
      }
      break;
    }
    default: break;
  }
  
  
  CGPoint ptDelta = [sender translationInView:self];
  _frameNew = self.frame;
  
  if(_kRatio==-1) {
    _frameNew.origin.x += ptDelta.x;
    _frameNew.origin.y += ptDelta.y;
    _frameNew.size.width -= ptDelta.x;
    _frameNew.size.height -= ptDelta.y;
  }
  else {
    CGPoint delta = [self deltaWithRatioOfOriginDelta:ptDelta sameSign:YES];
    _frameNew.origin.x += delta.x;
    _frameNew.origin.y += delta.y;
    _frameNew.size.width -= delta.x;
    _frameNew.size.height -= delta.y;
    
  }

  
  [self validateNewSizeRect];
  self.frame = _frameNew;
  [self updateAllControlViewGeometry];
  
  [sender setTranslation:CGPointZero inView:self];
}

- (void)panUp:(UIPanGestureRecognizer *)sender {
  // 1 调用代理
  switch (sender.state) {
    case UIGestureRecognizerStateBegan:{
      if (_delegate&&[_delegate respondsToSelector:@selector(GAFreeFrameViewBeginChangingFrame:)]) {
        [_delegate GAFreeFrameViewBeginChangingFrame:self];
      }
      break;
    }
    case UIGestureRecognizerStateChanged :{
      if (_delegate&&[_delegate respondsToSelector:@selector(GAFreeFrameViewIsChangingFrame:)]) {
        [_delegate GAFreeFrameViewIsChangingFrame:self];
      }
      break;
    }
    case UIGestureRecognizerStateEnded: {
      if (_delegate&&[_delegate respondsToSelector:@selector(GAFreeFrameViewEndChangingFrame:)]) {
        [_delegate GAFreeFrameViewEndChangingFrame:self];
      }
      break;
    }
    default: break;
  }
  
  CGPoint ptDelta = [sender translationInView:self];
  _frameNew = self.frame;
  
  
  
  if(_kRatio==-1) {
    _frameNew.origin.x += ptDelta.x;
    _frameNew.origin.y += ptDelta.y;
    _frameNew.size.width -= ptDelta.x;
    _frameNew.size.height -= ptDelta.y;
  }
  else {
    //不考虑x方向,置零
    ptDelta.x = 0;
    CGPoint delta = [self deltaWithRatioOfOriginDelta:ptDelta sameSign:YES];
    _frameNew.origin.x += delta.x/2;
    _frameNew.origin.y += delta.y;
    _frameNew.size.width -= delta.x;
    _frameNew.size.height -= delta.y;
    
  }


  
  [self validateNewSizeRect];
  self.frame = _frameNew;
  
  
  [sender setTranslation:CGPointZero inView:self];
}

- (void)panRightUp:(UIPanGestureRecognizer *)sender {
  // 1 调用代理
  switch (sender.state) {
    case UIGestureRecognizerStateBegan:{
      if (_delegate&&[_delegate respondsToSelector:@selector(GAFreeFrameViewBeginChangingFrame:)]) {
        [_delegate GAFreeFrameViewBeginChangingFrame:self];
      }
      break;
    }
    case UIGestureRecognizerStateChanged :{
      if (_delegate&&[_delegate respondsToSelector:@selector(GAFreeFrameViewIsChangingFrame:)]) {
        [_delegate GAFreeFrameViewIsChangingFrame:self];
      }
      break;
    }
    case UIGestureRecognizerStateEnded: {
      if (_delegate&&[_delegate respondsToSelector:@selector(GAFreeFrameViewEndChangingFrame:)]) {
        [_delegate GAFreeFrameViewEndChangingFrame:self];
      }
      break;
    }
    default: break;
  }
  CGPoint ptDelta = [sender translationInView:self];
  _frameNew = self.frame;
  
  
  if(_kRatio==-1) {
    //    _frameNew.origin.x += ptDelta.x;
    _frameNew.origin.y += ptDelta.y;
    _frameNew.size.width += ptDelta.x;
    _frameNew.size.height -= ptDelta.y;
  }
  else {
//    //不考虑x方向,置零
//    ptDelta.x = 0;
    CGPoint delta = [self deltaWithRatioOfOriginDelta:ptDelta sameSign:NO];
//        _frameNew.origin.x += ptDelta.x;
    _frameNew.origin.y += delta.y;
    _frameNew.size.width += delta.x;
    _frameNew.size.height -= delta.y;
    
  }

  
  [self validateNewSizeRect]; self.frame = _frameNew;
  
  [sender setTranslation:CGPointZero inView:self];
}

- (void)panRight:(UIPanGestureRecognizer *)sender {
  // 1 调用代理
  switch (sender.state) {
    case UIGestureRecognizerStateBegan:{
      if (_delegate&&[_delegate respondsToSelector:@selector(GAFreeFrameViewBeginChangingFrame:)]) {
        [_delegate GAFreeFrameViewBeginChangingFrame:self];
      }
      break;
    }
    case UIGestureRecognizerStateChanged :{
      if (_delegate&&[_delegate respondsToSelector:@selector(GAFreeFrameViewIsChangingFrame:)]) {
        [_delegate GAFreeFrameViewIsChangingFrame:self];
      }
      break;
    }
    case UIGestureRecognizerStateEnded: {
      if (_delegate&&[_delegate respondsToSelector:@selector(GAFreeFrameViewEndChangingFrame:)]) {
        [_delegate GAFreeFrameViewEndChangingFrame:self];
      }
      break;
    }
    default: break;
  }
  CGPoint ptDelta = [sender translationInView:self];
  _frameNew = self.frame;
  
  
  //尺寸变化,挺复杂的啊
  if(_kRatio==-1) {
    //  _frameNew.origin.x += ptDelta.x;
    //  _frameNew.origin.y += ptDelta.y;
    _frameNew.size.width += ptDelta.x;
    //  _frameNew.size.height -= ptDelta.y;
  }
  else {
    //    //不考虑y方向,置零
        ptDelta.y = 0;
    CGPoint delta = [self deltaWithRatioOfOriginDelta:ptDelta sameSign:NO];
//      _frameNew.origin.x += delta.x;
      _frameNew.origin.y += delta.y/2;
    _frameNew.size.width += delta.x;
      _frameNew.size.height -= delta.y;
    
  }
  
  

  
  [self validateNewSizeRect]; self.frame = _frameNew;
  
  [sender setTranslation:CGPointZero inView:self];
}

- (void)panRightDown:(UIPanGestureRecognizer *)sender {
  // 1 调用代理
  switch (sender.state) {
    case UIGestureRecognizerStateBegan:{
      if (_delegate&&[_delegate respondsToSelector:@selector(GAFreeFrameViewBeginChangingFrame:)]) {
        [_delegate GAFreeFrameViewBeginChangingFrame:self];
      }
      break;
    }
    case UIGestureRecognizerStateChanged :{
      if (_delegate&&[_delegate respondsToSelector:@selector(GAFreeFrameViewIsChangingFrame:)]) {
        [_delegate GAFreeFrameViewIsChangingFrame:self];
      }
      break;
    }
    case UIGestureRecognizerStateEnded: {
      if (_delegate&&[_delegate respondsToSelector:@selector(GAFreeFrameViewEndChangingFrame:)]) {
        [_delegate GAFreeFrameViewEndChangingFrame:self];
      }
      break;
    }
    default: break;
  }
  CGPoint ptDelta = [sender translationInView:self];
  _frameNew = self.frame;
  
  
  
  if(_kRatio==-1) {
    //  _frameNew.origin.x += ptDelta.x;
    //  _frameNew.origin.y += ptDelta.y;
    _frameNew.size.width += ptDelta.x;
    _frameNew.size.height += ptDelta.y;
  }
  else {
    //    //不考虑y方向,置零
//    ptDelta.y = 0;
    CGPoint delta = [self deltaWithRatioOfOriginDelta:ptDelta sameSign:YES];
    //  _frameNew.origin.x += ptDelta.x;
    //  _frameNew.origin.y += ptDelta.y;
    _frameNew.size.width += delta.x;
    _frameNew.size.height += delta.y;
    
  }

  
  [self validateNewSizeRect]; self.frame = _frameNew;
  
  [sender setTranslation:CGPointZero inView:self];
}

- (void)panDown:(UIPanGestureRecognizer *)sender {
  // 1 调用代理
  switch (sender.state) {
    case UIGestureRecognizerStateBegan:{
      if (_delegate&&[_delegate respondsToSelector:@selector(GAFreeFrameViewBeginChangingFrame:)]) {
        [_delegate GAFreeFrameViewBeginChangingFrame:self];
      }
      break;
    }
    case UIGestureRecognizerStateChanged :{
      if (_delegate&&[_delegate respondsToSelector:@selector(GAFreeFrameViewIsChangingFrame:)]) {
        [_delegate GAFreeFrameViewIsChangingFrame:self];
      }
      break;
    }
    case UIGestureRecognizerStateEnded: {
      if (_delegate&&[_delegate respondsToSelector:@selector(GAFreeFrameViewEndChangingFrame:)]) {
        [_delegate GAFreeFrameViewEndChangingFrame:self];
      }
      break;
    }
    default: break;
  }
  CGPoint ptDelta = [sender translationInView:self];
  _frameNew = self.frame;
  
  
  
  if(_kRatio==-1) {
    //  _frameNew.origin.x += ptDelta.x;
    //  _frameNew.origin.y += ptDelta.y;
    //    _frameNew.size.width -= ptDelta.x;
    _frameNew.size.height += ptDelta.y;
  }
  else {
    //    //不考虑x方向,置零
        ptDelta.x = 0;
    CGPoint delta = [self deltaWithRatioOfOriginDelta:ptDelta sameSign:NO];
      _frameNew.origin.x += delta.x/2;
    //  _frameNew.origin.y += ptDelta.y;
        _frameNew.size.width -= delta.x;
    _frameNew.size.height += delta.y;
    
  }

  
  [self validateNewSizeRect]; self.frame = _frameNew;
  
  [sender setTranslation:CGPointZero inView:self];
}

- (void)panLeftDown:(UIPanGestureRecognizer *)sender {
  // 1 调用代理
  switch (sender.state) {
    case UIGestureRecognizerStateBegan:{
      if (_delegate&&[_delegate respondsToSelector:@selector(GAFreeFrameViewBeginChangingFrame:)]) {
        [_delegate GAFreeFrameViewBeginChangingFrame:self];
      }
      break;
    }
    case UIGestureRecognizerStateChanged :{
      if (_delegate&&[_delegate respondsToSelector:@selector(GAFreeFrameViewIsChangingFrame:)]) {
        [_delegate GAFreeFrameViewIsChangingFrame:self];
      }
      break;
    }
    case UIGestureRecognizerStateEnded: {
      if (_delegate&&[_delegate respondsToSelector:@selector(GAFreeFrameViewEndChangingFrame:)]) {
        [_delegate GAFreeFrameViewEndChangingFrame:self];
      }
      break;
    }
    default: break;
  }
  CGPoint ptDelta = [sender translationInView:self];
  _frameNew = self.frame;
  
  
  if(_kRatio==-1) {
    _frameNew.origin.x += ptDelta.x;
    //  _frameNew.origin.y += ptDelta.y;
    _frameNew.size.width -= ptDelta.x;
    _frameNew.size.height += ptDelta.y;
  }
  else {
    //    //不考虑x方向,置零
//    ptDelta.x = 0;
    CGPoint delta = [self deltaWithRatioOfOriginDelta:ptDelta sameSign:NO];
    _frameNew.origin.x += delta.x;
    //  _frameNew.origin.y += ptDelta.y;
    _frameNew.size.width -= delta.x;
    _frameNew.size.height += delta.y;
    
  }

  
  [self validateNewSizeRect]; self.frame = _frameNew;
  
  [sender setTranslation:CGPointZero inView:self];
}

- (void)panLeft:(UIPanGestureRecognizer *)sender {
  // 1 调用代理
  switch (sender.state) {
    case UIGestureRecognizerStateBegan:{
      if (_delegate&&[_delegate respondsToSelector:@selector(GAFreeFrameViewBeginChangingFrame:)]) {
        [_delegate GAFreeFrameViewBeginChangingFrame:self];
      }
      break;
    }
    case UIGestureRecognizerStateChanged :{
      if (_delegate&&[_delegate respondsToSelector:@selector(GAFreeFrameViewIsChangingFrame:)]) {
        [_delegate GAFreeFrameViewIsChangingFrame:self];
      }
      break;
    }
    case UIGestureRecognizerStateEnded: {
      if (_delegate&&[_delegate respondsToSelector:@selector(GAFreeFrameViewEndChangingFrame:)]) {
        [_delegate GAFreeFrameViewEndChangingFrame:self];
      }
      break;
    }
    default: break;
  }
  CGPoint ptDelta = [sender translationInView:self];
  _frameNew = self.frame;
  
  
  if(_kRatio==-1) {
    _frameNew.origin.x += ptDelta.x;
    //  _frameNew.origin.y += ptDelta.y;
    _frameNew.size.width -= ptDelta.x;
    //  _frameNew.size.height -= ptDelta.y;
  }
  else {
    //    //不考虑x方向,置零
    //    ptDelta.x = 0;
    CGPoint delta = [self deltaWithRatioOfOriginDelta:ptDelta sameSign:YES];
    _frameNew.origin.x += delta.x;
      _frameNew.origin.y += delta.y/2;
    _frameNew.size.width -= delta.x;
      _frameNew.size.height -= delta.y;
    
  }

  
  [self validateNewSizeRect]; self.frame = _frameNew;
  
  [sender setTranslation:CGPointZero inView:self];
}



//比例变化逻辑:根据位移算出宽高变化.
//1 上下左右的,只考虑一个方向的位移,根据这个位移计算出宽高变化值.
//2 两个方向可移动,选取x,y方向上变化最大的作为变化值来考虑.



@end
