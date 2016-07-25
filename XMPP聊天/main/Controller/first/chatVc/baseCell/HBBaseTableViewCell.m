//
//  HBBaseTableViewCell.m
//  XMPP_Chat
//
//  Created by 伍宏彬 on 15/12/18.
//  Copyright © 2015年 Wow_我了个去. All rights reserved.
//

#import "HBBaseTableViewCell.h"
#import "UIImage+HBImage.h"
#import "HBTextCell.h"
#import "HBImageCell.h"
#import "HBVoiceCell.h"
#import "HBMapCell.h"

@interface HBBaseTableViewCell()

@property (nonatomic, strong) HBLable * userIconName;
@property (nonatomic, strong) UIImageView *userIconImage;
@property (nonatomic, strong) UIImage *getLeftImage;
@property (nonatomic, strong) UIImage *getRightImage;

@end

@implementation HBBaseTableViewCell

static NSString *_otherImageName   = @"anon_group_loading";
static NSString *_mineImageName    = @"anon_group_loading_fail";

+ (instancetype)baseCell:(UITableView *)tableView cellType:(NSString *)type
{
    static NSString *chatID = nil;
    Class cellClass = nil;
    
    if ([type isEqualToString:HBTypeText]) {
        chatID = @"chatID";
        cellClass = [HBTextCell class];
    }else if ([type isEqualToString:HBTypeVoice]){
        chatID = @"voiceID";
        cellClass = [HBVoiceCell class];
    }else if ([type isEqualToString:HBTypeImage]){
        chatID = @"imageID";
        cellClass = [HBImageCell class];
    }else if ([type isEqualToString:HBTypeMap]){
        chatID = @"mapID";
        cellClass = [HBMapCell class];
    }else{
        
    }
    HBBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:chatID];
    if (!cell) {
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:chatID];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.userIconImage];
        [self.contentView addSubview:self.userIconName];
        [self.contentView addSubview:self.chatBg];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.chatBg.HB_Size = self.chatModel.chatBgSize;
    self.userIconName.HB_W = self.userIconName.getWidth;
    
    if ([self.chatModel.message.outgoing boolValue]) {
        
        self.userIconImage.HB_X = [UIScreen mainScreen].bounds.size.width - HBMid - HBUserIconImageWH;
        self.userIconImage.image = [UIImage imageNamed:_mineImageName];
        self.userIconName.HB_X = self.userIconImage.HB_X - self.userIconName.getWidth - HBUserIconImageToTop;
        
        self.chatBg.HB_X = CGRectGetMaxX(self.userIconName.frame) - self.chatBg.HB_W;
        self.chatBg.image = self.getLeftImage;
        
    }else{
        
        self.userIconImage.HB_X =  HBMid;
        self.userIconImage.image = [UIImage imageNamed:_otherImageName];
        self.userIconName.HB_X = CGRectGetMaxX(self.userIconImage.frame) + HBUserIconImageToTop;
        
        self.chatBg.HB_X = self.userIconName.HB_X;
        self.chatBg.image = self.getRightImage;
    }
}

- (void)setChatModel:(HBChatModel *)chatModel
{
    _chatModel = chatModel;
    
    NSString *from = nil;
    if ([chatModel.message.outgoing boolValue]) {//自己发的
        
        from = [NSString stringWithFormat:@"来自：%@",chatModel.message.streamBareJidStr];
    }else{
        
        from = [NSString stringWithFormat:@"来自：%@",chatModel.message.bareJidStr];
    }
    self.userIconName.text = from;
}
#pragma mark - getter
- (UIImageView *)userIconImage
{
    if (!_userIconImage) {
        _userIconImage = [[UIImageView alloc] init];
        _userIconName.userInteractionEnabled = YES;
        _userIconImage.HB_W = _userIconImage.HB_H = HBUserIconImageWH;
        _userIconImage.HB_Y = HBUserIconImageToTop;
    }
    return _userIconImage;
}
- (HBLable *)userIconName
{
    if (!_userIconName) {
        _userIconName = [[HBLable alloc] initWithFrame:CGRectMake(0, self.userIconImage.HB_Y, HBChatBgMaxWidth, 30)];
//        _userIconName.HB_H = 30;
//        _userIconName.HB_W = HBChatBgMaxWidth;
//        _userIconName.HB_Y = self.userIconImage.HB_Y;
        _userIconName.backgroundColor = [UIColor redColor];
        _userIconName.textColor = [UIColor blueColor];
    }
    return _userIconName;
}
- (UIImageView *)chatBg
{
    if (!_chatBg) {
        _chatBg = [[UIImageView alloc] init];
        _chatBg.userInteractionEnabled = YES;
        _chatBg.HB_W = HBChatBgMaxWidth;
        _chatBg.HB_H = 80;
        _chatBg.HB_Y = CGRectGetMaxY(self.userIconName.frame) + HBChatBgToUserIconImage;
//        _chatBg.contentMode = UIViewContentModeScaleToFill;
//        _chatBg.backgroundColor = [UIColor colorWithRed:0.6816 green:0.9571 blue:0.5959 alpha:1.0];
    }
    return _chatBg;
}
- (UIImage *)getLeftImage
{
    
    if (!_getLeftImage) {
        _getLeftImage = [UIImage releizeImage:@"mqz_photoTag_labelLeftDown"];
    }
    return _getLeftImage;
}
- (UIImage *)getRightImage
{
    
    if (!_getRightImage) {
        _getRightImage = [UIImage releizeImage:@"mqz_photoTag_labelRightDown"];
    }
    return _getRightImage;
}
@end
