//
//  GAImageCutViewController.m
//  GAFreeFrameViewMaster
//
//  Created by GikkiAres on 8/29/16.
//  Copyright © 2016 GikkiAres. All rights reserved.
//

#import "GAImageCutViewController.h"
#import "GAAspectFitImageView.h"
#import "DisplayChooseController.h"
#import "GAFreeFrameView.h"


@interface GAImageCutViewController ()<
GAAspectFitImageViewDelegate,
GAFreeFrameViewDelegate
>
@property (weak, nonatomic) IBOutlet UILabel *lbDisplayFrame;
@property (weak, nonatomic) IBOutlet UILabel *lbRealFrame;
@property (weak, nonatomic) IBOutlet GAAspectFitImageView *iv;
@property (nonatomic,strong) GAFreeFrameView *freeView;

//4个遮罩View
@property(nonatomic,strong)UIView *maskViewTop;
@property(nonatomic,strong)UIView *maskViewLeft;
@property(nonatomic,strong)UIView *maskViewRight;
@property(nonatomic,strong)UIView *maskViewDown;

@end

@implementation GAImageCutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  _iv.image = [UIImage imageNamed:@"longHeight.jpg"];
  _iv.delegate = self;
  _maskViewTop = [UIView new];
  _maskViewDown = [UIView new];
  _maskViewLeft = [UIView new];
  _maskViewRight = [UIView new];
  UIColor *maskColor = [UIColor colorWithWhite:0.1 alpha:0.7];
  _maskViewTop.backgroundColor = maskColor;
  _maskViewLeft.backgroundColor = maskColor;
  _maskViewRight.backgroundColor = maskColor;
  _maskViewDown.backgroundColor = maskColor;
  [_iv.iv addSubview:_maskViewTop];
  [_iv.iv addSubview:_maskViewDown];
  [_iv.iv addSubview:_maskViewLeft];
  [_iv.iv addSubview:_maskViewRight];
  
  GAFreeFrameView *freeView = [GAFreeFrameView new];
  _freeView = freeView;
  freeView.delegate = self;
  [_iv.iv addSubview:freeView];
  
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)ok:(id)sender {
  DisplayChooseController *vc = [DisplayChooseController new];
  
  UIImage *originImage = _iv.image;
  
  //获取实际图片对应的区域.  显示/scaleFactor
  CGFloat scaleFactor = _iv.scaleFactor;
  CGRect realRect = CGRectMake(_freeView.frame.origin.x/scaleFactor, _freeView.frame.origin.y/scaleFactor, _freeView.frame.size.width/scaleFactor, _freeView.frame.size.height/scaleFactor);
  _lbRealFrame.text = [self stringFromRect:realRect];
  //获取图片的实际数据.
  CGImageRef cgRef = originImage.CGImage;

  CGImageRef imageRef = CGImageCreateWithImageInRect(cgRef,realRect);
  UIImage *subImage = [UIImage imageWithCGImage:imageRef];
  CGImageRelease(imageRef);
  
  
  vc.image = subImage;
  
  [self.navigationController pushViewController:vc animated:YES];
}

- (void)GAAspectFitImageViewEndLayout:(GAAspectFitImageView *)view {
  [_freeView matchParentSize];
    _lbDisplayFrame.text = [ self stringFromRect:_freeView.frame];
  
 
  //获取实际图片对应的区域.  显示/scaleFactor
  CGFloat scaleFactor = _iv.scaleFactor;
  CGRect realRect = CGRectMake(_freeView.frame.origin.x/scaleFactor, _freeView.frame.origin.y/scaleFactor, _freeView.frame.size.width/scaleFactor, _freeView.frame.size.height/scaleFactor);
  _lbRealFrame.text = [self stringFromRect:realRect];
  
  
  
  
  [self adjustMaskView];
}

- (void)GAFreeFrameViewIsChangingFrame:(GAFreeFrameView *)view{
    _lbDisplayFrame.text = [ self stringFromRect:_freeView.frame];
  CGFloat scaleFactor = _iv.scaleFactor;
  CGRect realRect = CGRectMake(view.frame.origin.x/scaleFactor, view.frame.origin.y/scaleFactor, view.frame.size.width/scaleFactor, view.frame.size.height/scaleFactor);
  _lbRealFrame.text = [self stringFromRect:realRect];
  [self adjustMaskView];
}


- (NSString *)stringFromRect:(CGRect)rc {
  NSString *str = [NSString stringWithFormat:@"(%.2f,%.2f),(%.2f,%.2f)",rc.origin.x,rc.origin.y,rc.size.width,rc.size.height];
  return str;
}


- (void)adjustMaskView {
  _maskViewTop.frame = CGRectMake(0, 0, _iv.iv.frame.size.width, _freeView.frame.origin.y);
  _maskViewDown.frame = CGRectMake(0, _freeView.fMaxY, _iv.iv.frame.size.width, _iv.iv.frame.size.height- _freeView.fMaxY);
  _maskViewLeft.frame = CGRectMake(0, _freeView.fMinY, _freeView.fMinX,_freeView.fMaxY-_freeView.fMinY);
  _maskViewRight.frame = CGRectMake(_freeView.fMaxX,_freeView.fMinY,_iv.iv.frame.size.width-_freeView.fMaxX,_freeView.fMaxY-_freeView.fMinY);
}

- (IBAction)clickFree:(id)sender {
  _freeView.mode = GAFreeFrameViewModeFreedom;
    [self adjustMaskView];
}

- (IBAction)click11:(id)sender {
  _freeView.mode = GAFreeFrameViewMode1To1;
    [self adjustMaskView];
}

- (IBAction)click43:(id)sender {
  _freeView.mode = GAFreeFrameViewMode4To3;
    [self adjustMaskView];
}

- (IBAction)click34:(id)sender {
  _freeView.mode = GAFreeFrameViewMode3To4;
    [self adjustMaskView];
}

- (IBAction)click169:(id)sender {
  _freeView.mode = GAFreeFrameViewMode16To9;
    [self adjustMaskView];
}

- (IBAction)click916:(id)sender {
  _freeView.mode = GAFreeFrameViewMode9To16;
    [self adjustMaskView];
}

@end
