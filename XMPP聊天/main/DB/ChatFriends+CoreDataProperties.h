//
//  ChatFriends+CoreDataProperties.h
//  XMPP_Chat
//
//  Created by 伍宏彬 on 16/7/25.
//  Copyright © 2016年 Wow_我了个去. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ChatFriends.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatFriends (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *bareJidStr;

@end

NS_ASSUME_NONNULL_END
