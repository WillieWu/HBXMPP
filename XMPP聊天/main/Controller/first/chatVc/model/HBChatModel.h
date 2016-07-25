//
//  HBChatModel.h
//  XMPP_Chat
//
//  Created by 伍宏彬 on 16/4/6.
//  Copyright © 2016年 Wow_我了个去. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatMessage.h"

@interface HBChatModel : NSObject

@property (nonatomic, strong) ChatMessage *message;
/**
 *  内容
 */
@property (nonatomic, copy) NSAttributedString *chatContent;
#pragma mark - 文字Frame
/**
 *  文字
 */
@property (nonatomic, assign) CGSize textSize;
#pragma mark - 图片Frame
/**
 *  图片
 */
@property (nonatomic, assign) CGSize imageSize;
#pragma mark - 声音Frame
/**
 *  语音
 */
@property (nonatomic, assign) CGSize voiceSize;
/**
 *  语音时间
 */
@property (nonatomic, copy) NSString * voiceTime;
/**
 *  语音地址
 */
@property (nonatomic, strong) NSURL * voiceURL;
/**
 *  背景气泡大小
 */
@property (nonatomic, assign) CGSize chatBgSize;
/**
 *  cell高度
 */
@property (nonatomic, assign) CGFloat cellHeight;
@end
