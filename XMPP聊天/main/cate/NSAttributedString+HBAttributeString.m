//
//  NSAttributedString+HBAttributeString.m
//  XMPP_Chat
//
//  Created by 伍宏彬 on 16/6/7.
//  Copyright © 2016年 Wow_我了个去. All rights reserved.
//

#import "NSAttributedString+HBAttributeString.h"
#import "HBTextAttachment.h"

@implementation NSAttributedString (HBAttributeString)
- (NSString *)HB_ChatAttributeStringToString
{
    __block NSMutableString *chatStr = [NSMutableString string];
    [self enumerateAttributesInRange:NSMakeRange(0, self.length)
                                                     options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                                  usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
                                                      
              HBTextAttachment *hbAttachment = [attrs objectForKey:@"NSAttachment"];
              if (hbAttachment) {
                  
                  [chatStr appendString:[NSString stringWithFormat:@"[/%@]",hbAttachment.emjoysName]];
                  
              }else{
                  NSAttributedString *aStr = [self attributedSubstringFromRange:range];
                  
                  
                  [chatStr appendString:aStr.string];
              }
    }];
    return (NSString *)chatStr;
}
@end
