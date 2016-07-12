//
//  HBChatTableView.m
//  XMPP_Chat
//
//  Created by 伍宏彬 on 16/7/6.
//  Copyright © 2016年 Wow_我了个去. All rights reserved.
//

#import "HBChatTableView.h"

@implementation HBChatTableView

- (void)setContentSize:(CGSize)contentSize
{
    if (!CGSizeEqualToSize(self.contentSize, CGSizeZero))
    {
        if (contentSize.height > self.contentSize.height)
        {
            CGPoint offset = self.contentOffset;
            offset.y += (contentSize.height - self.contentSize.height);
            self.contentOffset = offset;
        }
    }
    [super setContentSize:contentSize];
}

@end
