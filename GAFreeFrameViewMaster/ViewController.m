//
//  ViewController.m
//  GAFreeFrameViewMaster
//
//  Created by GikkiAres on 8/26/16.
//  Copyright © 2016 GikkiAres. All rights reserved.
//

#import "ViewController.h"
#import "GAFreeFrameView.h"
#import "GAImageCutViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet GAFreeFrameView *freeView;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  
  // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}
- (IBAction)go:(id)sender {
  GAImageCutViewController *vc = [GAImageCutViewController new];
  [self.navigationController pushViewController:vc animated:YES];
}

@end
