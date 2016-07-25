//
//  ChatMessage+CoreDataProperties.h
//  XMPP_Chat
//
//  Created by 伍宏彬 on 16/7/25.
//  Copyright © 2016年 Wow_我了个去. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ChatMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatMessage (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *chatType;
@property (nullable, nonatomic, retain) NSString *chatBody;
@property (nullable, nonatomic, retain) NSNumber *outgoing;
@property (nullable, nonatomic, retain) NSString *bareJidStr;
@property (nullable, nonatomic, retain) NSDate *timestamp;
@property (nullable, nonatomic, retain) NSString *voiceTime;
@property (nullable, nonatomic, retain) NSString *streamBareJidStr;

@end

NS_ASSUME_NONNULL_END
