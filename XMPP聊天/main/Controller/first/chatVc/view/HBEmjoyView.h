//
//  HBEmjoyView.h
//  XMPP_Chat
//
//  Created by 伍宏彬 on 15/12/17.
//  Copyright © 2015年 Wow_我了个去. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HBEmjoyView;

typedef NS_ENUM(NSInteger,actionType) {
    actionTypeAdd,
    actionTypeSend,

};

@protocol HBEmjoyViewDelegate <NSObject>
- (void)emjoyView:(HBEmjoyView *)emjoyView didChoose:(NSString *)choose;
- (void)emjoyViewDidTouchActionType:(actionType)type;
@end

@interface HBEmjoyView : UIView
@property (nonatomic, weak) id<HBEmjoyViewDelegate>  delegate;
@end
