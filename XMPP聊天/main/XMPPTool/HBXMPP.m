//
//  HBXMPP.m
//  XMPP_Chat
//
//  Created by 伍宏彬 on 15/12/8.
//  Copyright © 2015年 伍宏彬. All rights reserved.
//

#import "HBXMPP.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "HBXMPPCoreDataManager.h"

@interface HBXMPP()<XMPPStreamDelegate>
{
    NSString *_userName;
    NSString *_passwod;
}
@property (nonatomic, strong) XMPPReconnect *reconnect;
@property (nonatomic, copy) connectServerBlock severStatu;
@property (nonatomic, assign) ConnectActionOption option;
@end

@implementation HBXMPP

static HBXMPP *instens = nil;

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_OFF;
#endif

+ (instancetype)shareXMPP
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instens = [[self alloc] init];
    });
    return instens;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instens = [super allocWithZone:zone];
    });
    return instens;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self setDDLog];
        
    }
    return self;
}
- (void)setDDLog
{
    setenv("XcodeColors", "YES", 0);
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor colorWithRed:0.0 green:0.6607 blue:0.0 alpha:1.0] backgroundColor:nil forFlag:LOG_FLAG_INFO];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor blueColor] backgroundColor:nil forFlag:LOG_FLAG_VERBOSE];
    
}

#pragma mark - XMPP
- (void)connectServer:(NSString *)userName password:(NSString *)password connectActionOption:(ConnectActionOption)option ServerStatu:(connectServerBlock)ServerStatu
{
    _userName = userName;
    _passwod = password;
    self.severStatu = ServerStatu;
    self.option = option;
    [self connectServiesUser:_userName];
}
- (void)disConnectServer
{
    [self removeAllRrfrences];
}
- (void)connectServiesUser:(NSString *)userName
{
    //1.设置xmppStream
    self.xmppStream.myJID = [XMPPJID jidWithUser:userName domain:HBXMPPHostName resource:nil];
    
    //2.设置断线自动重连
    self.reconnect = [[XMPPReconnect alloc] init];
    [self.reconnect activate:self.xmppStream];
    
    //3.设置代理
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    //4.发起请求
    NSError *error = nil;
    if (![self.xmppStream connectWithTimeout:15. error:&error]) {
        DDLogError(@"connectServies - %@",error);
    }

}
- (void)goOnline
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:HBXMPPOnline];
    [self.xmppStream sendElement:presence];
}
- (void)goOffline
{
    
    XMPPPresence *presence = [XMPPPresence presenceWithType:HBXMPPOffline];
    [self.xmppStream sendElement:presence];
    
    [self.xmppStream disconnect];
}
#pragma mark - XMPPDelegate
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{

    DDLogError(@"身份验证失败（账户或者密码错误） - %@",error);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.severStatu) {
            self.severStatu(sender,resultOptionLoginFail);
        }
    });
}
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{

    [self goOnline];
    DDLogInfo(@"身份验证成功（上线） - %@",sender);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.severStatu) {
            self.severStatu(sender,resultOptionLoginSuccess);
        }
    });
}
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSError *error = nil;
    switch (self.option) {
        case ConnectActionOptionLogin:
        {
            if (![self.xmppStream authenticateWithPassword:_passwod error:&error]) {
                DDLogError(@"验证登录密码错误 - %@",error);
            }
        }
            break;
        case ConnectActionOptionRegister:
        {
            if (![self.xmppStream registerWithPassword:_passwod error:&error]) {
                DDLogError(@"注册密码错误 - %@",error);
            }
        }
            break;
            
        default:
            break;
    }
    

}
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{

    DDLogVerbose(@"下线 - %@",_userName);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.severStatu) {
            self.severStatu(sender,resultOptionDisConnect);
        }
    });
}
- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender
{

     DDLogError(@"链接超时 - %@",sender);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.severStatu) {
            self.severStatu(sender,resultOptionTimeOut);
        }
    });
}
- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    DDLogInfo(@"注册成功 - %@",sender);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.severStatu) {
            self.severStatu(sender,resultOptionRegisterSuccess);
        }
    });
}
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
    DDLogError(@"注册失败 - %@",error);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.severStatu) {
            self.severStatu(sender,resultOptionRegisterFail);
        }
    });
}
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    DDLogInfo(@"%@ - 收到 - %@，消息是：%@ - %@ - %@",sender.myJID.user,message.from.user,message.body, message.type, message.subject);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[HBXMPPCoreDataManager manager] HB_XMPPSaveChatMessage:message isOutGoing:NO];
    });
}
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    
    DDLogVerbose(@"%@ - 发送 - %@，消息是：%@ - %@ - %@",sender.myJID.user,message.to.user,message.body, message.type, message.subject);
    dispatch_async(dispatch_get_main_queue(), ^{
        [[HBXMPPCoreDataManager manager] HB_XMPPSaveChatMessage:message isOutGoing:YES];
    });
}
#pragma mark - 移除所有引用
- (void)removeAllRrfrences
{
    if (![self.xmppStream isConnected]) return;
    
    [self goOffline];
    
    [self.xmppStream removeDelegate:self];
    self.xmppStream = nil;
    
    [self.reconnect deactivate];
    self.reconnect = nil;
}
#pragma mark- getter
- (XMPPStream *)xmppStream
{
    if (!_xmppStream) {
        _xmppStream = [[XMPPStream alloc] init];
        _xmppStream.hostName = HBXMPPHostName;
        _xmppStream.hostPort = HBXMPPHostPort;
        
    }
    return _xmppStream;
}
- (XMPPRoster *)xmppRoster
{
    if (!_xmppRoster) {

        _xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:[XMPPRosterCoreDataStorage sharedInstance]];
        _xmppRoster.autoFetchRoster = YES;
        if (![_xmppRoster activate:self.xmppStream]) {
            DDLogCError(@"花名册激活失败");
        }
        
        
    }
    return _xmppRoster;
}
@end
