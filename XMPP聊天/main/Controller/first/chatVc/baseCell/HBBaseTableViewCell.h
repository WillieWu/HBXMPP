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

@interface HBBaseTableViewCell : UITableViewCell

+ (instancetype)baseCell:(UITableView *)tableView cellType:(NSString *)type;
//@property (nonatomic, assign) BOOL isMineSend;
@property (nonatomic, strong) UIImageView *chatBg;
@property (nonatomic, strong) HBChatModel *chatModel;

@end
