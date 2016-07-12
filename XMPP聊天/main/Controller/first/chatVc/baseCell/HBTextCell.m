//
//  HBTextCell.m
//  XMPP_Chat
//
//  Created by 伍宏彬 on 15/12/18.
//  Copyright © 2015年 Wow_我了个去. All rights reserved.
//

#import "HBTextCell.h"

@implementation HBTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.chatBg addSubview:self.chatMessage];
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];

    self.chatMessage.HB_Size = self.chatModel.textSize;
#warning 功能完善后，优化异步绘制。textKit -> CoreText
}

- (void)setChatModel:(HBChatModel *)chatModel
{
    [super setChatModel:chatModel];
    
    self.chatMessage.attributedText = chatModel.chatContent;
}
#pragma mark - getter
- (UILabel *)chatMessage
{
    if (!_chatMessage) {
        _chatMessage = [[UILabel alloc] initWithFrame:CGRectMake(padding, 0, 0, 40)];
        _chatMessage.textColor = [UIColor whiteColor];
        _chatMessage.numberOfLines = 0;
        _chatMessage.font = chatTextFont;
    }
    return _chatMessage;
}
@end
