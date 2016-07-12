//
//  UIImage+HBImage.m
//  XMPP_Chat
//
//  Created by 伍宏彬 on 15/12/18.
//  Copyright © 2015年 Wow_我了个去. All rights reserved.
//

#import "UIImage+HBImage.h"

@implementation UIImage (HBImage)
+ (UIImage *)releizeImage:(NSString *)imageName
{

    UIImage *image = [UIImage imageNamed:imageName];
    CGFloat left = image.size.width * 0.5;
    CGFloat top = image.size.height * 0.5;
    return [image stretchableImageWithLeftCapWidth:left topCapHeight:top];
    
}
@end
