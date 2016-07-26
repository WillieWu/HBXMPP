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

- (void)setMessage:(ChatMessage *)message
{
    _message = message;
    
    CGSize getChatBgSize;

    if ([message.chatType isEqualToString:HBTypeText]){//聊天文字内容

        //聊天，表情字符串
        self.chatContent = [message.chatBody HB_StringToChatAttributeString];
        
        CGSize size = [HBHelp HB_attributeBoundsSize:CGSizeMake(HBChatBgMaxWidth,MAXFLOAT) attributeContentText:[self.chatContent mutableCopy]];
//        //1.文字内容大小
        self.textSize = size;
        
        getChatBgSize = CGSizeMake(size.width + 2 * padding, size.height + 2 * padding);
    
    }else if ([message.chatType isEqualToString:HBTypeImage]){//图片
            
        self.imageSize = CGSizeMake(120, 60);
        
        getChatBgSize = CGSizeMake(self.imageSize.width + 2 * padding, self.imageSize.height + 2 * padding);
        
    }else if ([message.chatType isEqualToString:HBTypeVoice]){//语音
        
        self.voiceSize = CGSizeMake(85, 44);
        NSString *path = [RootDocumentPath stringByAppendingPathComponent:message.chatBody];
        self.voiceURL = [NSURL fileURLWithPath:path];
        self.voiceTime = message.voiceTime;
        
        getChatBgSize = self.voiceSize;
        
    }else if ([message.chatType isEqualToString:HBTypeMap]){//地图
        
    }
    
    //2.聊天背景大小
    self.chatBgSize = getChatBgSize;
    //3.行高
    self.cellHeight = self.chatBgSize.height + HBUserIconImageToTop + HBUserIconNameH + HBChatBgToUserIconName;
    
    
}

@end
