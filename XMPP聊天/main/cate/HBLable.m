//
//  HBLable.m
//  XMPP_Chat
//
//  Created by 伍宏彬 on 16/4/6.
//  Copyright © 2016年 Wow_我了个去. All rights reserved.
//

#import "HBLable.h"
#import "HBChatModel.h"

@interface HBLable()
{
    CGRect _contextFrame;
}
@end

@implementation HBLable
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self set];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self set];
    }
    return self;
}
- (void)set
{
    self.numberOfLines = 1;
}
- (void)setText:(NSString *)text
{
    [super setText:text];
    
    CGRect contextFrame = [text boundingRectWithSize:CGSizeMake(MAXFLOAT,self.HB_H)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName : self.font}
                                             context:nil];
    _contextFrame = contextFrame;

}
- (CGFloat)getHeight
{
    return _contextFrame.size.height;
}
- (CGFloat)getWidth
{
    return MIN(_contextFrame.size.width, HBChatBgMaxWidth);
}
@end
