//
//  UIStoryboard+HBStoryboard.m
//  XMPP_Chat
//
//  Created by 伍宏彬 on 15/12/10.
//  Copyright © 2015年 Wow_我了个去. All rights reserved.
//

#import "UIStoryboard+HBStoryboard.h"

@implementation UIStoryboard (HBStoryboard)
+ (UIViewController *)HB_StoryboardWithVcID:(NSString *)VcID
{
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [board instantiateViewControllerWithIdentifier:VcID];
}
@end
