//
//  UIView+HBView.m
//  XMPP_Chat
//
//  Created by 伍宏彬 on 15/12/14.
//  Copyright © 2015年 Wow_我了个去. All rights reserved.
//

#import "UIView+HBView.h"

@implementation UIView (HBView)
- (void)setHB_X:(CGFloat)HB_X
{
    CGRect frame = self.frame;
    frame.origin.x = HB_X;
    self.frame = frame;
}
- (CGFloat)HB_X
{
    return self.frame.origin.x;
}
- (void)setHB_Y:(CGFloat)HB_Y
{
    CGRect frame = self.frame;
    frame.origin.y = HB_Y;
    self.frame = frame;
}
- (CGFloat)HB_Y
{
    return self.frame.origin.y;
}
- (void)setHB_W:(CGFloat)HB_W
{
    CGRect frame = self.frame;
    frame.size.width = HB_W;
    self.frame = frame;
}
- (CGFloat)HB_W
{
    return self.frame.size.width;
}
- (void)setHB_H:(CGFloat)HB_H
{
    CGRect frame = self.frame;
    frame.size.height = HB_H;
    self.frame = frame;
}
- (CGFloat)HB_H
{
    return self.frame.size.height;
}
- (void)setHB_Size:(CGSize)HB_Size
{
    CGRect frame = self.frame;
    frame.size = HB_Size;
    self.frame = frame;
}
- (CGSize)HB_Size
{
    return self.frame.size;
}
- (void)setHB_centerX:(CGFloat)HB_centerX
{
    CGPoint center = self.center;
    center.x = HB_centerX;
    self.center = center;
}
- (CGFloat)HB_centerX
{
    return self.center.x;
}
- (void)setHB_centerY:(CGFloat)HB_centerY
{
    CGPoint point = self.center;
    point.y = HB_centerY;
    self.center = point;
}
- (CGFloat)HB_centerY
{
    return self.center.y;
}
- (void)setHB_center:(CGPoint)HB_center
{
    CGPoint point = self.center;
    point = HB_center;
    self.center = point;
}
- (CGPoint)HB_center
{
    return self.center;
}
@end
