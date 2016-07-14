//
//  HBHelp.h
//  XMPP_Chat
//
//  Created by 伍宏彬 on 15/12/14.
//  Copyright © 2015年 Wow_我了个去. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^MicrophoneBlock)(BOOL microphoneEnable);

@interface HBHelp : NSObject

+ (CGSize)HB_boundsSize:(CGSize)size textFont:(UIFont *)textFont contentText:(NSString *)contentText;
+ (CGSize)HB_attributeBoundsSize:(CGSize)size attributeContentText:(NSMutableAttributedString *)attributeContentText;
+ (CGSize)HB_sizeForAttributeString:(NSAttributedString *)attributeString size:(CGSize)size;
+ (NSString *)currentdate;
/**
 *  相机是否可用
 */
+ (BOOL)cameraEnable;
+ (BOOL)albumEnable;
/**
 *  麦克风是否可用
 */
+ (void)MicrophoneEnable:(MicrophoneBlock)mBlcok;
@end
