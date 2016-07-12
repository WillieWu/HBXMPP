//
//  UIImageView+HBImageView.m
//  XMPP_Chat
//
//  Created by 伍宏彬 on 16/4/7.
//  Copyright © 2016年 Wow_我了个去. All rights reserved.
//

#import "UIImageView+HBImageView.h"
@import SDWebImage;
#import <SDWebImage/UIImageView+WebCache.h>

@implementation UIImageView (HBImageView)
- (void)HB_setImageURL:(NSURL *)URL
{
    [self sd_setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"loading_Fang"]];
}
@end
