//
//  GAAspectFitImageView.h
//  GARectChooseViewMaster
//
//  Created by GikkiAres on 8/24/16.
//  Copyright © 2016 GikkiAres. All rights reserved.
//

#import <UIKit/UIKit.h>



@class GAAspectFitImageView;
@protocol GAAspectFitImageViewDelegate <NSObject>

- (void)GAAspectFitImageViewEndLayout:(GAAspectFitImageView *)view;

@end

@interface GAAspectFitImageView : UIView

@property (nonatomic,strong)UIImageView *iv;
@property (nonatomic,strong)UIImage *image;
@property(nonatomic,weak)id<GAAspectFitImageViewDelegate> delegate;

//显示/实际
@property (nonatomic,assign)CGFloat scaleFactor;

@end
