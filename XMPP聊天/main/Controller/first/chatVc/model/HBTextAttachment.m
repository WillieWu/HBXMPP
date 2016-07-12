//
//  HBTextAttachment.m
//  XMPP_Chat
//
//  Created by 伍宏彬 on 16/6/7.
//  Copyright © 2016年 Wow_我了个去. All rights reserved.
//

#import "HBTextAttachment.h"

@implementation HBTextAttachment
- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex
{
    return CGRectMake(0, -3, 22, 22);
}
@end
