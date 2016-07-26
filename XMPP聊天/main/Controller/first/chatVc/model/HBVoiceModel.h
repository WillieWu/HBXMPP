//
//  HBVoiceModel.h
//  XMPP_Chat
//
//  Created by 伍宏彬 on 16/7/26.
//  Copyright © 2016年 Wow_我了个去. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBVoiceModel : NSObject
/**
 *  录音路径
 */
@property (nonatomic, copy) NSString * path;
/**
 *  录音秒数
 */
@property (nonatomic, assign) NSTimeInterval lengthTime;
@end
