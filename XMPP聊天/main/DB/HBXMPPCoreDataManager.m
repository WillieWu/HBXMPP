//
//  HBXMPPCoreDataManager.m
//  XMPP_Chat
//
//  Created by 伍宏彬 on 15/12/15.
//  Copyright © 2015年 Wow_我了个去. All rights reserved.
//

#import "HBXMPPCoreDataManager.h"
#import "ChatFriends.h"
#import "ChatMessage.h"

#pragma mark - 其他
#import "XMPPMessageArchivingCoreDataStorage.h"
#import "XMPPMessageArchiving_Message_CoreDataObject.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPUserCoreDataStorageObject.h"

@interface HBXMPPCoreDataManager()
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation HBXMPPCoreDataManager

static HBXMPPCoreDataManager *_manager;

+ (instancetype)manager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
    });
    return _manager;
}
+ (id)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [super allocWithZone:zone];
    });
    return _manager;
}

- (void)HB_XMPPSaveChatMessage:(XMPPMessage *)xmppMessage isOutGoing:(BOOL)isOutGoing;
{
    
    ChatMessage *messageCoreData = [NSEntityDescription insertNewObjectForEntityForName:@"ChatMessage" inManagedObjectContext:self.mainContext];
  
    messageCoreData.streamBareJidStr = [NSString stringWithFormat:@"%@@%@",[HBXMPP shareXMPP].xmppStream.myJID.user,[HBXMPP shareXMPP].xmppStream.myJID.domain];
    if (isOutGoing) {//发送
        messageCoreData.bareJidStr = [NSString stringWithFormat:@"%@@%@",xmppMessage.to.user,xmppMessage.to.domain];
    }else{//接受
        messageCoreData.bareJidStr = [NSString stringWithFormat:@"%@@%@",xmppMessage.from.user,xmppMessage.from.domain];
    }
    messageCoreData.outgoing = [NSNumber numberWithBool:isOutGoing];
    messageCoreData.chatBody = xmppMessage.body;

    if ([xmppMessage.body hasPrefix:HBImageString]) {
        messageCoreData.chatType = HBTypeImage;
    }else{
        messageCoreData.chatType = xmppMessage.type;
    }
    messageCoreData.voiceTime = xmppMessage.subject;
    messageCoreData.timestamp = [NSDate date];
    NSError *error = nil;
    if (![self.mainContext save:&error]) {
        NSLog(@"聊天信息保存失败");
    }
    
}
- (void)HB_XMPPUpdateVoiceDate:(NSDate *)date time:(NSString *)time;{

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ChatMessage"];
    NSPredicate *predecate = [NSPredicate predicateWithFormat:@"timestamp == %@",date];
    request.predicate = predecate;
    NSArray *array = [self.mainContext executeFetchRequest:request error:nil];
    ChatMessage *msg = [array firstObject];
    if (!msg) {
        whbLog(@"没有此条数据");
        return;
    }
    msg.voiceTime = time;
    NSError *error;
    if (![self.mainContext save:&error]) {
        whbLog(@"保存失败:%@",error.description);
    }
}
- (void)HB_XMPPDeleteWithDate:(NSDate *)date{

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ChatMessage"];
    NSPredicate *predecate = [NSPredicate predicateWithFormat:@"timestamp == %@",date];
    request.predicate = predecate;
    NSArray *array = [self.mainContext executeFetchRequest:request error:nil];
    ChatMessage *msg = [array firstObject];
    if (!msg) {
        whbLog(@"没有此条数据");
        return;
    }
    [self.mainContext deleteObject:msg];
}
- (BOOL)HB_XMPPContainsWithVoiceName:(NSString *)name;
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ChatMessage"];
    NSPredicate *predecate = [NSPredicate predicateWithFormat:@"chatBody == %@",name];
    request.predicate = predecate;
    NSArray *array = [self.mainContext executeFetchRequest:request error:nil];
    ChatMessage *msg = [array firstObject];
    if (!msg) {
        return NO;
    }
    return YES;
}
- (NSURL *)applicationDocumentsDirectory {
   
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"XMPP_ChatDB" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"XMPP_ChatDB.sqlite"];
    NSError *error = nil;
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = @"There was an error creating or loading the application's saved data.";
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
       
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}
- (NSManagedObjectContext *)mainContext {
    
    if (_mainContext != nil) {
        return _mainContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_mainContext setPersistentStoreCoordinator:coordinator];
    return _mainContext;
}
- (NSManagedObjectContext *)privateContext {
   
    if (_privateContext != nil) {
        return _privateContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_privateContext setPersistentStoreCoordinator:coordinator];
    return _privateContext;
}
@end
