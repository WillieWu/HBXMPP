//
//  HBButton.h
//  XMPP_Chat
//
//  Created by 伍宏彬 on 15/12/16.
//  Copyright © 2015年 Wow_我了个去. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HBButton;

typedef void(^actionBlock)(HBButton *chickBtn);
typedef NS_ENUM(NSInteger,ActionStatus) {

    ActionStatusNormal,
    ActionStatusSelect,
    ActionStatusOther
};

@interface HBButton : UIButton
+ (instancetype)buttonFrame:(CGRect)frame;
- (void)setNormalImage:(UIImage *)normalImage selectImage:(UIImage *)selectImage;
- (void)setNormalBackGroundImage:(UIImage *)normalImage selectBackGroundImage:(UIImage *)selectImage;
- (void)addAction:(actionBlock)action;
@property (nonatomic, assign) ActionStatus stauts;
@end
