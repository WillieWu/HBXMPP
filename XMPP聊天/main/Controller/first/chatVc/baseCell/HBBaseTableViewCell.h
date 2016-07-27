//
//  HBBaseTableViewCell.h
//  XMPP_Chat
//
//  Created by 伍宏彬 on 15/12/18.
//  Copyright © 2015年 Wow_我了个去. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPMessageArchiving_Message_CoreDataObject.h"
#import "HBLable.h"
#import "HBChatModel.h"
@class HBBaseTableViewCell;

typedef NS_ENUM(NSInteger, longPress) {
    longPressText,
    longPressImage,
    longPressVoice,
    longPressMap

};

@protocol HBBaseTableViewCellDelegate <NSObject>

- (void)baseTableViewCell:(HBBaseTableViewCell *)cell longPressType:(longPress)press;

@end

@interface HBBaseTableViewCell : UITableViewCell

+ (instancetype)baseCell:(UITableView *)tableView cellType:(NSString *)type;
@property (nonatomic, weak) id<HBBaseTableViewCellDelegate>  delegate;
@property (nonatomic, strong) UIImageView *chatBg;
@property (nonatomic, strong) HBChatModel *chatModel;
- (void)pressLong;
@end
