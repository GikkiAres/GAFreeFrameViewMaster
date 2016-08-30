//
//  DisplayView.m
//  GAFreeFrameViewMaster
//
//  Created by GikkiAres on 8/29/16.
//  Copyright © 2016 GikkiAres. All rights reserved.
//

#import "DisplayView.h"

//定位线段的长度
#define kCornerLength 10

@implementation DisplayView

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.contentMode = UIViewContentModeRedraw;
  }
  return self;
}


- (void)drawRect:(CGRect)rect {
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  //1 画出选择边框框
  static const float borderWidth = 2;
  CGContextSetLineWidth(context , borderWidth);
  CGRect borderRect = CGRectInset(self.bounds, borderWidth/2, borderWidth/2);
  CGContextAddRect(context, borderRect);

  CGContextSetStrokeColorWithColor(context, [[UIColor colorWithWhite:0.9 alpha:0.9] CGColor]);
  CGContextStrokePath(context);
  //2 画出九宫格
  CGPoint arrPt1[2] = {CGPointMake(self.bounds.origin.x, self.bounds.origin.y+self.bounds.size.height/3),CGPointMake(self.bounds.origin.x+self.bounds.size.width,self.bounds.origin.y+self.bounds.size.height/3)};
  CGPoint arrPt2[2] = {CGPointMake(self.bounds.origin.x, self.bounds.origin.y+self.bounds.size.height/3*2),CGPointMake(self.bounds.origin.x+self.bounds.size.width,self.bounds.origin.y+self.bounds.size.height/3*2)};
  CGPoint arrPt3[2] = {CGPointMake(self.bounds.origin.x+self.bounds.size.width/3, self.bounds.origin.y),CGPointMake(self.bounds.origin.x+self.bounds.size.width/3,self.bounds.origin.y+self.bounds.size.height)};
  CGPoint arrPt4[2] = {CGPointMake(self.bounds.origin.x+self.bounds.size.width/3*2, self.bounds.origin.y),CGPointMake(self.bounds.origin.x+self.bounds.size.width/3*2,self.bounds.origin.y+self.bounds.size.height)};
  CGContextAddLines(context, arrPt1, 2);
  CGContextAddLines(context, arrPt2, 2);
  CGContextAddLines(context, arrPt3, 2);
  CGContextAddLines(context, arrPt4, 2);
  CGContextSetLineWidth(context , 1);
  CGContextSetStrokeColorWithColor(context, [[UIColor colorWithWhite:0.9 alpha:0.9] CGColor]);
  CGContextStrokePath(context);
  //  3 画出四边的角
  static const float cornerSpace = 4;
  CGContextSetLineWidth(context , 2);
  //#1 左上方
  CGPoint corner1[3] = {CGPointMake(self.bounds.origin.x+cornerSpace, self.bounds.origin.y+kCornerLength+cornerSpace), CGPointMake(self.bounds.origin.x+cornerSpace, self.bounds.origin.y+cornerSpace),CGPointMake(self.bounds.origin.x+kCornerLength+cornerSpace,self.bounds.origin.y+cornerSpace)};
  //# 2右上角
  CGPoint corner2[3] = {CGPointMake(self.bounds.origin.x+self.bounds.size.width-cornerSpace, self.bounds.origin.y+kCornerLength+cornerSpace), CGPointMake(self.bounds.origin.x+self.bounds.size.width-cornerSpace, self.bounds.origin.y+cornerSpace),CGPointMake(self.bounds.origin.x+self.bounds.size.width-kCornerLength-cornerSpace,self.bounds.origin.y+cornerSpace)};
  //# 3右下角
  CGPoint corner3[3] = {CGPointMake(self.bounds.origin.x+self.bounds.size.width-cornerSpace, self.bounds.origin.y+self.bounds.size.height-kCornerLength-cornerSpace), CGPointMake(self.bounds.origin.x+self.bounds.size.width-cornerSpace, self.bounds.origin.y+self.bounds.size.height-cornerSpace),CGPointMake(self.bounds.origin.x+self.bounds.size.width-kCornerLength-cornerSpace,self.bounds.origin.y+self.bounds.size.height-cornerSpace)};
  //# 4左下角
  CGPoint corner4[3] = {CGPointMake(self.bounds.origin.x+kCornerLength+cornerSpace, self.bounds.origin.y+self.bounds.size.height-cornerSpace), CGPointMake(self.bounds.origin.x+cornerSpace, self.bounds.origin.y+self.bounds.size.height-cornerSpace),CGPointMake(self.bounds.origin.x+cornerSpace,self.bounds.origin.y+self.bounds.size.height-kCornerLength-cornerSpace)};
  CGContextAddLines(context, corner1, 3);
  CGContextAddLines(context, corner2, 3);
  CGContextAddLines(context, corner3, 3);
  CGContextAddLines(context, corner4, 3);

  CGContextSetStrokeColorWithColor(context, [[UIColor colorWithWhite:0.9 alpha:1] CGColor]);
  CGContextStrokePath(context);

}


@end
