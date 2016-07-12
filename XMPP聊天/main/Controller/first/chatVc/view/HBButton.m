//
//  HBButton.m
//  XMPP_Chat
//
//  Created by 伍宏彬 on 15/12/16.
//  Copyright © 2015年 Wow_我了个去. All rights reserved.
//

#import "HBButton.h"

@interface HBButton()
@property (nonatomic, copy) actionBlock action;
@end

@implementation HBButton
+ (instancetype)buttonFrame:(CGRect)frame
{
    HBButton *button = [[HBButton alloc] initWithFrame:frame];
    return button;
}
- (void)setNormalImage:(UIImage *)normalImage selectImage:(UIImage *)selectImage
{
    [self setImage:normalImage forState:UIControlStateNormal];
    [self setImage:selectImage forState:UIControlStateSelected];
}
- (void)setNormalBackGroundImage:(UIImage *)normalImage selectBackGroundImage:(UIImage *)selectImage
{
    [self setBackgroundImage:normalImage forState:UIControlStateNormal];
    [self setBackgroundImage:selectImage forState:UIControlStateHighlighted];
}
//- (void)setHighlighted:(BOOL)highlighted{}
- (void)addAction:(actionBlock)action
{
    self.action = action;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self addTarget:self action:@selector(chick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}
- (void)chick:(HBButton *)btn
{
  
    if (self.action) {
        self.action(btn);
    }
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
}
@end
