//
//  HBImageCell.m
//  XMPP_Chat
//
//  Created by 伍宏彬 on 15/12/18.
//  Copyright © 2015年 Wow_我了个去. All rights reserved.
//

#import "HBImageCell.h"
#import "UIImageView+HBImageView.h"


@interface HBImageCell()
@property (nonatomic, strong) UIImageView *imageContent;
@end

@implementation HBImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.chatBg addSubview:self.imageContent];
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageContent.HB_Size = self.chatModel.imageSize;
    
}
- (void)setChatModel:(HBChatModel *)chatModel
{
    [super setChatModel:chatModel];
    
    NSRange range = [chatModel.message.body rangeOfString:HBImageString];
    
    if (range.location == NSNotFound) return;
    
    NSString *picURL = [chatModel.message.body substringFromIndex:range.location + range.length];
    
    [self.imageContent HB_setImageURL:[NSURL URLWithString:picURL]];

    
}
#pragma mark - lazy
- (UIImageView *)imageContent
{
    if (!_imageContent) {
        _imageContent = [[UIImageView alloc] init];
        _imageContent.HB_X = padding;
        _imageContent.HB_Y = padding;
    }
    return _imageContent;
}
@end
