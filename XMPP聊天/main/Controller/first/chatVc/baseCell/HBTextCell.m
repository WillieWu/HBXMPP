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
        [self.contentView addSubview:self.chatMessage];
        
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];

    self.chatMessage.HB_Size = self.chatModel.textSize;
    self.chatMessage.HB_center = self.chatBg.HB_center;
#warning 功能完善后，优化异步绘制。textKit -> CoreText
}
- (void)pressLong{
    [super pressLong];
    
    if ([self.delegate respondsToSelector:@selector(baseTableViewCell:longPressType:)]) {
        [self.delegate baseTableViewCell:self longPressType:longPressText];
    }
   
  
}
- (void)setChatModel:(HBChatModel *)chatModel
{
    [super setChatModel:chatModel];
    
    self.chatMessage.attributedText = chatModel.chatContent;
}
- (BOOL)canBecomeFirstResponder{
    return YES;
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    
    return YES;
}
#pragma mark - getter
- (UILabel *)chatMessage
{
    if (!_chatMessage) {
        _chatMessage = [[UILabel alloc] init];
        _chatMessage.textColor = [UIColor blackColor];
        _chatMessage.numberOfLines = 0;
        _chatMessage.font = chatTextFont;
    }
    return _chatMessage;
}
@end
