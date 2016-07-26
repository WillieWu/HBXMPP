//
//  XMPP_Const.h
//  XMPP_Chat
//
//  Created by 伍宏彬 on 15/12/8.
//  Copyright © 2015年 伍宏彬. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN const NSUInteger HBXMPPHostPort;
UIKIT_EXTERN NSString *const HBXMPPHostName;
UIKIT_EXTERN NSString *const HBXMPPOnline;
UIKIT_EXTERN NSString *const HBXMPPOffline;

UIKIT_EXTERN const  NSInteger HBUserIconImageWH;
UIKIT_EXTERN const  NSInteger HBUserIconNameH;
UIKIT_EXTERN const  NSInteger HBUserIconImageToTop;
UIKIT_EXTERN const  NSInteger HBChatBgToUserIconImage;
UIKIT_EXTERN const  NSInteger HBChatBgToUserIconName;
UIKIT_EXTERN const  NSInteger HBMid;
UIKIT_EXTERN const  CGFloat padding;//气泡的小尖尖
UIKIT_EXTERN  NSString *const HBTypeText;
UIKIT_EXTERN  NSString *const HBTypeVoice;
UIKIT_EXTERN  NSString *const HBTypeImage;
UIKIT_EXTERN  NSString *const HBTypeMap;
UIKIT_EXTERN  NSString *const HBImageString;
UIKIT_EXTERN const CGFloat chatViewH;


#define HBChatBgMaxWidth [UIScreen mainScreen].bounds.size.width - HBUserIconImageWH - HBMid - 5 - HBMid - HBMid
