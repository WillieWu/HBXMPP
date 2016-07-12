//
//  HBTextView.m
//  XMPP_Chat
//
//  Created by 伍宏彬 on 15/12/17.
//  Copyright © 2015年 Wow_我了个去. All rights reserved.
//

#import "HBTextView.h"

@implementation HBTextView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.returnKeyType = UIReturnKeySend;
        self.font = [UIFont systemFontOfSize:16];
        


    }
    return self;
}

@end
