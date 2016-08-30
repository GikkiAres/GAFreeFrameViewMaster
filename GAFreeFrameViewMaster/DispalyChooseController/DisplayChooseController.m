//
//  DisplayChooseController.m
//  GARectChooseViewMaster
//
//  Created by GikkiAres on 8/24/16.
//  Copyright © 2016 GikkiAres. All rights reserved.
//

#import "DisplayChooseController.h"

@interface DisplayChooseController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrv;

@end

@implementation DisplayChooseController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
  self.edgesForExtendedLayout = UIRectEdgeNone;
  self.automaticallyAdjustsScrollViewInsets = NO;
  UIImageView *iv = [[UIImageView alloc]initWithImage:_image];
  _scrv.contentSize = iv.frame.size;
  [_scrv addSubview:iv];
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
