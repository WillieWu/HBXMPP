//
//  NSFileManager+HBFileManagerHelp.m
//  XMPP_Chat
//
//  Created by 伍宏彬 on 16/7/1.
//  Copyright © 2016年 Wow_我了个去. All rights reserved.
//

#import "NSFileManager+HBFileManagerHelp.h"

@implementation NSFileManager (HBFileManagerHelp)
+ (BOOL)fileExist:(NSString *)path
{
    if(path == nil)
    {
        return NO;
    }
    
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}
+ (BOOL)deleteFile:(NSString*)path
{
    NSError *error = nil;
    BOOL bRet = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    return bRet;
}
@end
