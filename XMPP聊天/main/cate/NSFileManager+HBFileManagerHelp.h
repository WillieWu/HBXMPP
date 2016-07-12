//
//  NSFileManager+HBFileManagerHelp.h
//  XMPP_Chat
//
//  Created by 伍宏彬 on 16/7/1.
//  Copyright © 2016年 Wow_我了个去. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (HBFileManagerHelp)
/**
 *  检测指定全路径的文件是否存在
 */
+ (BOOL)fileExist:(NSString *)path;
/**
 *  删除指定文件
 */
+ (BOOL)deleteFile:(NSString*)path;
@end
