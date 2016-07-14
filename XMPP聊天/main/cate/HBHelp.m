//
//  HBHelp.m
//  XMPP_Chat
//
//  Created by 伍宏彬 on 15/12/14.
//  Copyright © 2015年 Wow_我了个去. All rights reserved.
//

#import "HBHelp.h"
#import <CoreText/CoreText.h>
#import <AVFoundation/AVFoundation.h>

@implementation HBHelp

    
+ (CGSize)HB_boundsSize:(CGSize)size textFont:(UIFont *)textFont contentText:(NSString *)contentText;{
    CGRect textRect = [contentText boundingRectWithSize:size
                                                options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName : textFont}
                                                context:NULL];
    CGSize getSize = textRect.size;
    return CGSizeMake(getSize.width, getSize.height + 8);
}
+ (CGSize)HB_attributeBoundsSize:(CGSize)size attributeContentText:(NSMutableAttributedString *)attributeContentText{

    CGRect textRect = [attributeContentText boundingRectWithSize:size
                                                         options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                                         context:NULL];
    CGSize getSize = textRect.size;
    return CGSizeMake(getSize.width, getSize.height);
}
+ (CGSize)HB_sizeForAttributeString:(NSAttributedString *)attributeString size:(CGSize)size{

    NSMutableAttributedString *MattributeString = [attributeString mutableCopy];
    [MattributeString setAttributes:[self attributesWithConfig] range:NSMakeRange(0, attributeString.length)];
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)[MattributeString copy]);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0,0), nil, size, nil);
    return coreTextSize;
}
+ (NSDictionary *)attributesWithConfig{
    CGFloat fontSize = 17;
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
    CGFloat lineSpacing = 10;
    NSInteger lineBreakMode = kCTLineBreakByWordWrapping;
    const CFIndex kNumberOfSettings = 4;
    CTParagraphStyleSetting theSettings[kNumberOfSettings] = {
        { kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &lineSpacing },
        { kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineSpacing },
        { kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &lineSpacing },
        { kCTParagraphStyleSpecifierLineBreakMode, sizeof(NSInteger), &lineBreakMode}
    };
    
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);
    
    UIColor * textColor = [UIColor whiteColor];
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    dict[(id)kCTForegroundColorAttributeName] = (id)textColor.CGColor;
    dict[(id)kCTFontAttributeName] = [UIFont systemFontOfSize:17];
    dict[(id)kCTParagraphStyleAttributeName] = (__bridge id)theParagraphRef;
    
    CFRelease(theParagraphRef);
    CFRelease(fontRef);
    return dict;
}
+ (NSString *)currentdate
{
    NSDate *  senddate=[NSDate date];
    
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"YYYYMMddHHmmss"];
    
    NSString *  locationString =[dateformatter stringFromDate:senddate];
    
    return locationString;
}
+ (BOOL)cameraEnable{
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied){
        return NO;
    }
    return YES;
}
+ (void)MicrophoneEnable:(MicrophoneBlock)mBlcok{
    
    if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
        [[AVAudioSession sharedInstance] performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
            
                if (mBlcok) {
                    mBlcok(granted);
                }
                
            });
            
        }];
    }
}
@end
