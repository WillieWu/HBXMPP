//
//  HBXMPP.h
//  XMPP_Chat
//
//  Created by 伍宏彬 on 15/12/8.
//  Copyright © 2015年 伍宏彬. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPRosterCoreDataStorage.h"

#define HBXMPPMananger [HBXMPP shareXMPP]

typedef NS_ENUM(NSInteger, resultOption) {
    
    resultOptionLoginSuccess,
    resultOptionLoginFail,
    resultOptionRegisterSuccess,
    resultOptionRegisterFail,
    resultOptionTimeOut,
    resultOptionDisConnect

};

typedef NS_ENUM(NSInteger,ConnectActionOption) {
    
    ConnectActionOptionLogin,//登录
    ConnectActionOptionRegister//注册
    
};

typedef void(^connectServerBlock)(XMPPStream *sender,resultOption result);
@interface HBXMPP : NSObject
/**
 *  初始化(默认颜色输出开启)
 *
 *  DDLogVerbose(@"Verbose");                               //蓝色
 *  DDLogDebug(@"Debug");                                   //黑色
 *  DDLogWarn(@"Warn");                                     //黄色
 *  DDLogError(@"Error");                                   //红色
 *  DDLogInfo(@"Warming up printer (post-customization)");  //绿色
 *
 *  @param isPut 是否
 */
+ (instancetype)shareXMPP;

@property (nonatomic, strong) XMPPStream *xmppStream;
@property (nonatomic, strong) XMPPRoster *xmppRoster;
/**
 *  连接服务器
 *
 *  @param userName    账户
 *  @param password    密码
 *  @param option      登录 or 注册
 *  @param ServerStatu 结果
 */
- (void)connectServer:(NSString *)userName
             password:(NSString *)password
  connectActionOption:(ConnectActionOption)option
          ServerStatu:(connectServerBlock)ServerStatu;
- (void)disConnectServer;
@end
