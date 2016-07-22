//
//  HBChatModel.m
//  XMPP_Chat
//
//  Created by 伍宏彬 on 16/4/6.
//  Copyright © 2016年 Wow_我了个去. All rights reserved.
//

#import "HBChatModel.h"
#import "NSString+HBString.h"
#import "HBHelp.h"

@implementation HBChatModel

- (void)setMessage:(XMPPMessageArchiving_Message_CoreDataObject *)message
{
    _message = message;
    
    CGSize getChatBgSize;

    if ([message.messageStr isEqualToString:HBTypeText]){//聊天文字内容

        //聊天，表情字符串
        self.chatContent = [message.body HB_StringToChatAttributeString];
        
        CGSize size = [HBHelp HB_attributeBoundsSize:CGSizeMake(HBChatBgMaxWidth,MAXFLOAT) attributeContentText:[self.chatContent mutableCopy]];
//        //1.文字内容大小
        self.textSize = size;
        
        getChatBgSize = CGSizeMake(size.width + 2 * padding, size.height);
    
    }else if ([message.messageStr isEqualToString:HBTypeImage]){//图片
            
        self.imageSize = CGSizeMake(120, 60);
        
        getChatBgSize = CGSizeMake(self.imageSize.width + 2 * padding, self.imageSize.height + 2 * padding);
        
    }else if ([message.messageStr isEqualToString:HBTypeVoice]){//语音
        
    }else if ([message.messageStr isEqualToString:HBTypeMap]){//地图
        
    }
    
    //2.聊天背景大小
    self.chatBgSize = getChatBgSize;
    //3.行高
    self.cellHeight = self.chatBgSize.height + HBUserIconImageToTop + HBUserIconImageWH + HBChatBgToUserIconImage + HBUserIconImageToTop;;
    
    
}

@end
