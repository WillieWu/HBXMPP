//
//  HBChatView.h
//  XMPP_Chat
//
//  Created by 伍宏彬 on 15/12/14.
//  Copyright © 2015年 Wow_我了个去. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HBChatView;

@protocol HBChatViewDelegate <NSObject>

- (void)chatView:(HBChatView *)chatView chickSend:(NSString *)content;
- (void)chatViewDidChangeFrame:(HBChatView *)chatView;
@end

@interface HBChatView : UIView
@property (nonatomic, weak) id<HBChatViewDelegate>  delegate;
@end
