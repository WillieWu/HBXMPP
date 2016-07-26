//
//  HBXMPPCoreDataManager.h
//  XMPP_Chat
//
//  Created by 伍宏彬 on 15/12/15.
//  Copyright © 2015年 Wow_我了个去. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBXMPPCoreDataManager : NSObject
+ (instancetype)manager;
@property (nonatomic, strong) NSManagedObjectContext *mainContext;
@property (nonatomic, strong) NSManagedObjectContext *privateContext;
/**
 *  存储聊天信息
 *
 *  @param xmppMessage 聊天内容对象
 *  @param isOutGoing  是不是自己发送的
 */
- (void)HB_XMPPSaveChatMessage:(XMPPMessage *)xmppMessage isOutGoing:(BOOL)isOutGoing;

- (void)HB_XMPPUpdateVoiceDate:(NSDate *)date time:(NSString *)time;

- (void)HB_XMPPDeleteWithDate:(NSDate *)date;

- (BOOL)HB_XMPPContainsWithVoiceName:(NSString *)name;
@end
