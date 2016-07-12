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
   
    NSMutableArray *marray = [NSMutableArray array];
    NSMutableString *mStr = [[NSMutableString alloc] initWithString:self];

    NSArray *array = [regularExpression matchesInString:self options:NSMatchingReportCompletion range:NSMakeRange(0, self.length)];
    
    for (NSInteger z = 0; z < array.count; z++) {
        
        NSTextCheckingResult *result = array[z];
        
        NSString *emjoyStr = [self substringWithRange:result.range];//[/001]
        
        NSRange range = [emjoyStr rangeOfString:@"[/"];
        NSUInteger loc = range.location + range.length;
        NSUInteger len = [emjoyStr rangeOfString:@"]"].location;
        
        NSString *emjoyName = [emjoyStr substringWithRange:NSMakeRange(loc, len - loc)];//001
        
        NSRange fixRange = NSMakeRange(result.range.location - z * (result.range.length - 1), result.range.length);
        
        HBTextAttachment *textAtt = [HBTextAttachment new];
        textAtt.emjoysName = emjoyName;
        textAtt.range = NSMakeRange(fixRange.location, 1);
        UIImage *image = [UIImage imageNamed:textAtt.emjoysName];
        if (image == nil) {
            continue;
        }
        textAtt.image = image;
        
        [marray addObject:textAtt];
        
        [mStr replaceCharactersInRange:fixRange withString:@" "];
        //        whbLog(@"%@ - %@ - %@",NSStringFromRange(result.range),NSStringFromRange(fixRange),self);
        
    }
   
    NSMutableAttributedString *AttributeString = [[NSMutableAttributedString alloc] initWithString:mStr];
    
    [AttributeString setAttributes:@{
                                     NSFontAttributeName : chatTextFont,
                                     
                                     }
                             range:NSMakeRange(0, AttributeString.length)];
    for (NSInteger i = 0; i < marray.count; i++) {
        HBTextAttachment *textAttachment = marray[i];
        NSAttributedString *imageAttribute = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [AttributeString replaceCharactersInRange:textAttachment.range withAttributedString:imageAttribute];
    }
    
    return AttributeString;
    
}

@end
