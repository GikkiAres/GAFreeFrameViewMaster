//
//  GAAspectFitImageView.m
//  GARectChooseViewMaster
//
//  Created by GikkiAres on 8/24/16.
//  Copyright © 2016 GikkiAres. All rights reserved.
//

#import "GAAspectFitImageView.h"

@implementation GAAspectFitImageView

- (instancetype)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder:coder];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (void)commonInit {
  self.backgroundColor = [UIColor blackColor];
    _iv = [UIImageView new];
    [self addSubview:_iv];
}

-(void)setImage:(UIImage *)image {
  if (!image) {
    return;
  }
  _image = image;

}


- (void)layoutSubviews {
 
  CGRect rect = [self imageAspectFitDisplayFrame];
  _iv.frame = rect;
  _iv.contentMode = UIViewContentModeScaleToFill;
  _iv.image =_image;
  if (_delegate&&[_delegate respondsToSelector:@selector(GAAspectFitImageViewEndLayout:)]) {
    [_delegate GAAspectFitImageViewEndLayout:self];
  }
}

- (CGRect)imageAspectFitDisplayFrame {
  UIImage *image = self.image;
  CGFloat imageWidthOrigin = image.size.width;
  CGFloat imageHeightOrigin = image.size.height;
  CGFloat kWidth = self.frame.size.width/imageWidthOrigin;
  CGFloat kHeight = self.frame.size.height/imageHeightOrigin;
  CGFloat kWidthHeight = imageWidthOrigin/imageHeightOrigin;
  CGFloat imageWidth = 0;
  CGFloat imageHeight = 0;
  //用小的比例为实际图像缩放比
  if (kWidth>kHeight) {
    imageHeight = self.frame.size.height;
    imageWidth = kWidthHeight*imageHeight;
    _scaleFactor = kHeight;
  }
  else {
    _scaleFactor = kWidth;
    imageWidth = self.frame.size.width;
    imageHeight = imageWidth/kWidthHeight;
  }
  return CGRectMake((self.frame.size.width-imageWidth)/2, (self.frame.size.height-imageHeight)/2, imageWidth, imageHeight);
}

@end
