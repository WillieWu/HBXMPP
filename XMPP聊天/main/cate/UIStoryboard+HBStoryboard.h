//
//  UIStoryboard+HBStoryboard.h
//  XMPP_Chat
//
//  Created by 伍宏彬 on 15/12/10.
//  Copyright © 2015年 Wow_我了个去. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIStoryboard (HBStoryboard)
+ (UIViewController *)HB_StoryboardWithVcID:(NSString *)VcID;
@end
