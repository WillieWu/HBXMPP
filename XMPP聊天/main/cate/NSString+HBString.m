//
//  NSString+HBString.m
//  XMPP_Chat
//
//  Created by 伍宏彬 on 16/6/7.
//  Copyright © 2016年 Wow_我了个去. All rights reserved.
//

#import "NSString+HBString.h"
#import "HBTextAttachment.h"
#import "HBHelp.h"


@implementation NSString (HBString)
- (NSAttributedString *)HB_StringToChatAttributeString
{
    static dispatch_once_t onceToken;
    static NSRegularExpression *regularExpression;
    dispatch_once(&onceToken, ^{
        regularExpression = [NSRegularExpression regularExpressionWithPattern:@"\\[[a-zA-Z0-9\\u4e00-\\u9fa5/]+\\]"
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:nil];
    });
   
    NSMutableAttributedString *AttributeString = [[NSMutableAttributedString alloc] initWithString:self];
    
    [AttributeString setAttributes:@{NSFontAttributeName : chatTextFont}
                             range:NSMakeRange(0, AttributeString.length)];

    NSArray *array = [regularExpression matchesInString:self options:NSMatchingReportCompletion range:NSMakeRange(0, self.length)];
    
    
    [array enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult *result, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *emjoyStr = [self substringWithRange:result.range];//[/001]
        
        NSRange range = [emjoyStr rangeOfString:@"[/"];
        NSUInteger loc = range.location + range.length;
        NSUInteger len = [emjoyStr rangeOfString:@"]"].location;
        
        NSString *emjoyName = [emjoyStr substringWithRange:NSMakeRange(loc, len - loc)];//001
        
        HBTextAttachment *textAtt = [HBTextAttachment new];
        textAtt.emjoysName = emjoyName;
        UIImage *image = [UIImage imageNamed:textAtt.emjoysName];
        textAtt.image = image;
        
        NSAttributedString *imageAttribute = [NSAttributedString attributedStringWithAttachment:textAtt];
        [AttributeString replaceCharactersInRange:result.range withAttributedString:imageAttribute];
        
    }];
    return AttributeString;
    
}

@end
