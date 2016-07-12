//
//  HBChatModel.h
//  XMPP_Chat
//
//  Created by 伍宏彬 on 16/4/6.
//  Copyright © 2016年 Wow_我了个去. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPMessageArchiving_Message_CoreDataObject.h"

@interface HBChatModel : NSObject

@property (nonatomic, strong) XMPPMessageArchiving_Message_CoreDataObject *message;
/**
 *  内容
 */
@property (nonatomic, copy) NSAttributedString *chatContent;
#pragma mark - 文字Frame
/**
 *  文字大小
 */
@property (nonatomic, assign) CGSize textSize;
#pragma mark - 图片Frame
/**
 *  图片大小
 */
@property (nonatomic, assign) CGSize imageSize;
/**
 *  背景气泡大小
 */
@property (nonatomic, assign) CGSize chatBgSize;
/**
 *  cell高度
 */
@property (nonatomic, assign) CGFloat cellHeight;
@end
