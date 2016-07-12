//
//  HBXMPPCoreDataManager.m
//  XMPP_Chat
//
//  Created by 伍宏彬 on 15/12/15.
//  Copyright © 2015年 Wow_我了个去. All rights reserved.
//

#import "HBXMPPCoreDataManager.h"
#import "XMPPMessageArchivingCoreDataStorage.h"
#import "XMPPMessageArchiving_Message_CoreDataObject.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPUserCoreDataStorageObject.h"


@implementation HBXMPPCoreDataManager

+ (void)HB_XMPPSaveChatMessage:(XMPPMessage *)xmppMessage isOutGoing:(BOOL)isOutGoing;
{
    NSManagedObjectContext *context = [XMPPMessageArchivingCoreDataStorage sharedInstance].mainThreadManagedObjectContext;
    XMPPMessageArchiving_Message_CoreDataObject *messageCoreData = [NSEntityDescription insertNewObjectForEntityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:context];
    messageCoreData.streamBareJidStr = [NSString stringWithFormat:@"%@@%@",[HBXMPP shareXMPP].xmppStream.myJID.user,[HBXMPP shareXMPP].xmppStream.myJID.domain];
    if (isOutGoing) {//发送
        messageCoreData.bareJidStr = [NSString stringWithFormat:@"%@@%@",xmppMessage.to.user,xmppMessage.to.domain];
    }else{//接受
        messageCoreData.bareJidStr = [NSString stringWithFormat:@"%@@%@",xmppMessage.from.user,xmppMessage.from.domain];
    }
    messageCoreData.outgoing = [NSNumber numberWithBool:isOutGoing];
    messageCoreData.body = xmppMessage.body;

    if ([xmppMessage.body hasPrefix:HBImageString]) {
        messageCoreData.messageStr = HBTypeImage;
    }else{
        messageCoreData.messageStr = xmppMessage.type;
    }
    
    messageCoreData.timestamp = [NSDate date];
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"聊天信息保存失败");
    }
    
}
+ (void)HB_XMPPSaveRosterWithFrineds:(XMPPUserCoreDataStorageObject *)user
{
    NSManagedObjectContext *context = [XMPPRosterCoreDataStorage sharedInstance].mainThreadManagedObjectContext;
    XMPPUserCoreDataStorageObject *messageCoreData = [NSEntityDescription insertNewObjectForEntityForName:@"XMPPUserCoreDataStorageObject" inManagedObjectContext:context];
    
}
+ (BOOL)HB_XMPPFetchUser:(XMPPUserCoreDataStorageObject *)user
{
    return YES;
}
@end
