//
//  HBChatView.m
//  XMPP_Chat
//
//  Created by 伍宏彬 on 15/12/14.
//  Copyright © 2015年 Wow_我了个去. All rights reserved.
//

#import "HBChatView.h"
#import "HBHelp.h"
#import "HBButton.h"
#import "HBTextView.h"
#import "HBEmjoyView.h"
#import "HBTextAttachment.h"
#import "NSAttributedString+HBAttributeString.h"
#import "UIImage+HBImage.h"
#import "HBRecordHUD.h"
#import "NSString+HBString.h"
#import "NSFileManager+HBFileManagerHelp.h"

@interface HBChatView()<UITextViewDelegate,HBEmjoyViewDelegate>
{
    CGRect _originFrame;
    CGRect _newFrame;
    CGFloat _originaButtomViewH;//初始bar的高度
    CGFloat _originaTextViewH;//初始TextView的高度
    CGFloat _lastY;
    CGFloat _lastH;
    //保留上一次高度
    CGRect _lastTextViewFrame;
    CGRect _lastButtomFrame;
}
@property (nonatomic, strong) HBTextView *textView;
@property (nonatomic, weak) HBButton *selectBtn;
@property (nonatomic, strong) HBButton *pressVoiceBtn;
@property (nonatomic, strong) HBEmjoyView *putView;
@property (nonatomic, strong) HBButton *voiceBtn;
@property (nonatomic, strong) HBButton *emjoyBtn;
@property (nonatomic, strong) HBButton *addBtn;
@end

//static CGFloat textViewX = 15;
static CGFloat textViewY = 5;

@implementation HBChatView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefult];
    }
    return self;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setDefult];
    }
    return self;
}
- (void)setDefult
{
    self.backgroundColor = [UIColor colorWithRed:0.8122 green:0.8122 blue:0.8122 alpha:1.0];
    _originaButtomViewH = self.frame.size.height;
    _originFrame = self.frame;
    _originaTextViewH = self.textView.HB_H;
    
    //1.语音
    [self addSubview:self.voiceBtn];
    
    //2.textView
    [self addSubview:self.textView];
    [self addSubview:self.pressVoiceBtn];//语音录制按钮
    
    //3.表情
    [self addSubview:self.emjoyBtn];
    
    //4.加号
    [self addSubview:self.addBtn];
    
    //5.监听
    [self keyboardNotifacation];

}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _lastY = self.HB_Y;
    _lastH = self.HB_H;
    self.voiceBtn.HB_Y = self.HB_H - self.voiceBtn.HB_H;
    self.emjoyBtn.HB_Y = self.voiceBtn.HB_Y;
    self.addBtn.HB_Y = self.voiceBtn.HB_Y;

}
#pragma mark - Custom
- (void)keyboardNotifacation{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //5.监听文本变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextChange:) name:UITextViewTextDidChangeNotification object:self.textView];
    
    [self.textView addObserver:self forKeyPath:@"attributedText" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    [self.textView addObserver:self forKeyPath:@"inputView" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    //6.监听自身frame
    [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    
}
- (void)caclulaterTextViewHeight{
    
    NSString *context = [self.textView.attributedText HB_ChatAttributeStringToString];
    
    if (![context hasSuffix:@"\n"] && context.length > 0) {

        CGFloat getSysHeight = [self.textView sizeThatFits:CGSizeMake(self.textView.HB_W, MAXFLOAT)].height;
        CGFloat getHeight = [HBHelp HB_attributeBoundsSize:CGSizeMake(self.textView.HB_W, MAXFLOAT)
                  attributeContentText:[[context HB_StringToChatAttributeString] mutableCopy]].height;
//        whbLog(@"++++++++++++++++ 开始 ++++++++++++++++++");
//    
//        whbLog(@"myHeight :%@ - sysHeight :%@",@(getHeight),@(getSysHeight));
        if (getHeight <= _originaTextViewH) {
            
            self.textView.HB_H = _originaTextViewH;
            
        }else{
            //1.限制最大高度
            if (getHeight >= _originaButtomViewH * 2) {
                getHeight = _originaButtomViewH * 2;
            }
            self.textView.HB_H = getHeight;
        }
//        whbLog(@"caclulaterTextViewHeight :%@",NSStringFromCGRect(self.frame));
        
        self.HB_H = self.textView.HB_H + self.textView.HB_Y * 2;
        self.HB_Y -= self.HB_H - _lastH;
        //2.始终更新最后的状态
        [self layoutIfNeeded];
        
//        whbLog(@"layoutIfNeeded : %@",NSStringFromCGRect(self.frame));
        _lastButtomFrame = self.frame;
        _lastTextViewFrame = self.textView.frame;
        
    }
    
}
- (void)sendMessage{
    NSString *getChatStr = [self.textView.attributedText HB_ChatAttributeStringToString];
    
    if ([self.delegate respondsToSelector:@selector(chatView:chickSend:)]) {
        [self.delegate chatView:self chickSend:getChatStr];
    }
    
    self.textView.text = @"";
    self.frame = [self originSelfFrame];
    self.textView.frame = [self originTextViewFrame];
}
#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView{
    [textView becomeFirstResponder];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text{
    if ([text isEqualToString:@"\n"] && textView.text.length > 0) {
        
        [self sendMessage];
        return NO;
    }
    return YES;
}
#pragma mark - HBEmjoyViewDelegate
- (void)emjoyView:(HBEmjoyView *)emjoyView didChoose:(NSString *)choose{
    if ([choose isEqualToString:@"cancel"]) {
        
        [self.textView deleteBackward];
        
    }else{
        
        //表情
        HBTextAttachment *textAttachment = [[HBTextAttachment alloc] init];
        textAttachment.emjoysName = choose;
        textAttachment.image = [UIImage imageNamed:choose];
        NSAttributedString *imageStr = [NSMutableAttributedString attributedStringWithAttachment:textAttachment];
        //文字
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
        
        NSUInteger insetIndex = self.textView.selectedRange.location;
        //拼接
        [attributeStr insertAttributedString:imageStr atIndex:insetIndex];
        
        [attributeStr addAttribute:NSFontAttributeName value:self.textView.font range:NSMakeRange(0, attributeStr.length)];
    
        self.textView.attributedText = attributeStr;

        self.textView.selectedRange = NSMakeRange(insetIndex + 1, 0);
    
    }
    
}
- (void)emjoyViewDidTouchActionType:(actionType)type{
    switch (type) {
        case actionTypeAdd: {
            whbLog(@"添加按钮响应事件");
            break;
        }
        case actionTypeSend: {
            
            [self sendMessage];
            
            break;
        }
    }
}
#pragma mark - 语音录制
- (void)dragOutsidePress:(HBButton *)btn{
    whbLog(@"松开即可取消发送");
    [[HBRecordHUD shareRecordHUD] showFailRecordImageName:@"chat_cancle"];

}
- (void)dragInsidePress:(HBButton *)btn{
    whbLog(@"录音中");
    [[HBRecordHUD shareRecordHUD] showRecordingImageNames:@[@"1",@"2",@"3",@"4"]];
}
- (void)enterPress:(HBButton *)btn{
    whbLog(@"开始录音");
    [[HBRecordHUD shareRecordHUD] starRecord];
    [[HBRecordHUD shareRecordHUD] showRecordingImageNames:@[@"1",@"2",@"3",@"4"]];
}
- (void)canclePress:(HBButton *)btn{
    whbLog(@"取消录音");
    if ([[HBRecordHUD shareRecordHUD] isTooShortTime]) {
        whbLog(@"时间太短，哥们");
        //展示时间太短提示
        [[HBRecordHUD shareRecordHUD] showShortTimeImageName:@"little_time"];
        
        //删除取消录音
        if ([NSFileManager fileExist:[[HBRecordHUD shareRecordHUD] lastVoicePath]])
            [NSFileManager deleteFile:[[HBRecordHUD shareRecordHUD] lastVoicePath]];
        
    }
    
    [[HBRecordHUD shareRecordHUD] stopRecord];
    
}
- (void)TouchUpOutsidePress:(HBButton *)btn{
    whbLog(@"已取消发送");
    //停止录音
    [[HBRecordHUD shareRecordHUD] stopRecord];
    //删除录音
    if ([NSFileManager fileExist:[[HBRecordHUD shareRecordHUD] lastVoicePath]])
        [NSFileManager deleteFile:[[HBRecordHUD shareRecordHUD] lastVoicePath]];
}
#pragma mark - keyBoardNotifacation
- (void)keyBoardWillShow:(NSNotification *)info{
    NSDictionary *dic = info.userInfo;
    NSTimeInterval showTime = [[dic objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"] floatValue];
    CGRect rect = [[dic objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    
    if (self.HB_Y == [UIScreen mainScreen].bounds.size.height - rect.size.height - self.HB_H) {
        return;
    }
    [UIView animateWithDuration:showTime animations:^{
        self.HB_Y = [UIScreen mainScreen].bounds.size.height - rect.size.height - self.HB_H;
    }];
    
}
- (void)keyBoardWillHide:(NSNotification *)info{
    
    NSDictionary *dic = info.userInfo;
    NSTimeInterval showTime = [[dic objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"] floatValue];

    if (self.HB_Y == [UIScreen mainScreen].bounds.size.height - self.HB_H) {
        return;
    }
    [UIView animateWithDuration:showTime animations:^{
        self.HB_Y = [UIScreen mainScreen].bounds.size.height - self.HB_H;
    }];
    
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"frame"]) {
        
        if ([self.delegate respondsToSelector:@selector(chatViewDidChangeFrame:)]) {
            [self.delegate chatViewDidChangeFrame:self];
        }
        _newFrame = [[change objectForKey:@"new"] CGRectValue];
        
    }else if ([keyPath isEqualToString:@"attributedText"]){
        
        [self caclulaterTextViewHeight];
        
    }else if ([keyPath isEqualToString:@"inputView"]) {
    
        HBEmjoyView *emjoyView = [change objectForKey:@"new"];

        [UIView animateWithDuration:0.25 animations:^{
                
            CGFloat moveHeight = ((NSNull *)emjoyView == [NSNull null]) ? 258 : emjoyView.HB_H;
            
            self.HB_Y = [UIScreen mainScreen].bounds.size.height - moveHeight - self.HB_H;
        }];
        
    }else{
        
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        
    }
}
- (void)textViewTextChange:(NSNotification *)info{
    [self caclulaterTextViewHeight];
}
#pragma mark - getter
- (HBTextView *)textView{
    if (!_textView) {
        _textView = [[HBTextView alloc] initWithFrame:[self originTextViewFrame]];
        _textView.delegate = self;

    }
    return _textView;
}
- (HBButton *)pressVoiceBtn{
    if (!_pressVoiceBtn) {
        _pressVoiceBtn = [HBButton buttonFrame:self.textView.frame];
        [_pressVoiceBtn setNormalBackGroundImage:[UIImage releizeImage:@"ai_record_send_button"]
                           selectBackGroundImage:[UIImage releizeImage:@"aio_record_send_button_press"]];
        [_pressVoiceBtn setTitle:@"按住 说话" forState:UIControlStateNormal];
        [_pressVoiceBtn addTarget:self action:@selector(enterPress:) forControlEvents:UIControlEventTouchDown];
        [_pressVoiceBtn addTarget:self action:@selector(canclePress:) forControlEvents:UIControlEventTouchUpInside];
        [_pressVoiceBtn addTarget:self action:@selector(dragInsidePress:) forControlEvents:UIControlEventTouchDragInside];
        [_pressVoiceBtn addTarget:self action:@selector(dragOutsidePress:) forControlEvents:UIControlEventTouchDragOutside];
        [_pressVoiceBtn addTarget:self action:@selector(TouchUpOutsidePress:) forControlEvents:UIControlEventTouchUpOutside];
        _pressVoiceBtn.backgroundColor = [UIColor whiteColor];
        _pressVoiceBtn.hidden = YES;
    }
    return _pressVoiceBtn;
}
- (HBEmjoyView *)putView{
    if (!_putView) {
        _putView = [[[NSBundle mainBundle] loadNibNamed:@"HBEmjoyView" owner:nil options:nil] firstObject];
        _putView.delegate = self;
    }
    return _putView;
}
- (HBButton *)voiceBtn{
    if (!_voiceBtn) {
        _voiceBtn = [HBButton buttonFrame:CGRectMake(0, 0, self.HB_H, self.HB_H)];
        [_voiceBtn setNormalImage:[UIImage imageNamed:@"anon_chat_bottom_voice_nor"]
                     selectImage:[UIImage imageNamed:@"anon_group_chat_bottom_keyboard_nor"]];
        __weak typeof(self) weakSelf = self;
        __block HBButton *emjoyButton = self.emjoyBtn;
        [_voiceBtn addAction:^(HBButton *chickBtn) {
            
            switch (chickBtn.stauts) {
                case ActionStatusNormal:
                {
                    //变键盘图标，textView变语音说话
                    chickBtn.stauts = ActionStatusOther;
                    //跟表情互斥,只要语音就重置表情
                    emjoyButton.selected = NO;
                    emjoyButton.stauts = ActionStatusNormal;
                    
                    weakSelf.selectBtn.selected = NO;
                    chickBtn.selected = YES;
                    weakSelf.selectBtn = chickBtn;
                    weakSelf.pressVoiceBtn.hidden = NO;
                    if (weakSelf.textView.isFirstResponder) {
                        [weakSelf.textView resignFirstResponder];//willhidden
                    }
                    if (weakSelf.textView.inputView) {
                        weakSelf.textView.inputView = nil;//keyObsever
                    }
                    
                    [UIView animateWithDuration:0.25 animations:^{
                        
                        weakSelf.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - chatViewH, [UIScreen mainScreen].bounds.size.width, chatViewH);
                        weakSelf.textView.frame = [weakSelf originTextViewFrame];
                        
                    }];
                }
                    break;
                case ActionStatusSelect:
                {
                    chickBtn.stauts = ActionStatusOther;
                    
                    chickBtn.selected = YES;
                    weakSelf.selectBtn = chickBtn;
                    [weakSelf.textView resignFirstResponder];
                    weakSelf.pressVoiceBtn.hidden = NO;
                    
                    [UIView animateWithDuration:0.25 animations:^{
                        
                        weakSelf.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - chatViewH, [UIScreen mainScreen].bounds.size.width, chatViewH);
                        weakSelf.textView.frame = [weakSelf originTextViewFrame];
                        
                    }];
                    
                }
                    break;
                case ActionStatusOther:
                {
                    
                    //变语音图标，textView变输入文字
                    chickBtn.stauts = ActionStatusSelect;
                    
                    chickBtn.selected = NO;
                    weakSelf.selectBtn = nil;
                    
                    if (self.textView.attributedText.length > 0) {
                        //                        whbLog(@"ActionStatusOther : %@",NSStringFromCGRect(_lastButtomFrame));
                        [UIView animateWithDuration:0.25 animations:^{
                            
                            weakSelf.textView.frame = _lastTextViewFrame;
                            weakSelf.frame = _lastButtomFrame;
                        }];
                        
                    }
                    
                    [weakSelf.textView becomeFirstResponder];
                    weakSelf.pressVoiceBtn.hidden = YES;

                    
                }
                    break;
                    
                default:
                    break;
            }
            
        }];

    }
    return _voiceBtn;
}
- (HBButton *)emjoyBtn
{
    if (!_emjoyBtn) {
        _emjoyBtn = [HBButton buttonFrame:CGRectMake(CGRectGetMaxX(self.textView.frame) + 5, 0, self.HB_H, self.HB_H)];
//        _emjoyBtn.backgroundColor = [UIColor purpleColor];
        [_emjoyBtn setNormalImage:[UIImage imageNamed:@"chat_bottom_emotion_nor"]
                     selectImage:[UIImage imageNamed:@"anon_group_chat_bottom_keyboard_nor"]];
        __weak typeof(self) weakSelf = self;
        __block HBButton *voiceButton = self.voiceBtn;
        [_emjoyBtn addAction:^(HBButton *chickBtn) {
            
            switch (chickBtn.stauts) {
                case ActionStatusNormal:{
                    chickBtn.stauts = ActionStatusOther;
                    
                    //跟语音互斥,只要是表情就重置语音
                    voiceButton.stauts = ActionStatusNormal;
                    voiceButton.selected = NO;
                    
                    
                    weakSelf.selectBtn.selected = NO;
                    chickBtn.selected = YES;
                    weakSelf.selectBtn = chickBtn;
                    
                    if (!weakSelf.pressVoiceBtn.hidden) {
                        weakSelf.pressVoiceBtn.hidden = YES;
                        [UIView animateWithDuration:0.25 animations:^{
                            
                            weakSelf.textView.frame = _lastTextViewFrame;
                            weakSelf.frame = _lastButtomFrame;
                        }];
                    }
                    
                    weakSelf.textView.inputView = weakSelf.putView;
                    [weakSelf.textView reloadInputViews];
                    
                    [weakSelf.textView becomeFirstResponder];
                
                }
                    break;
                case ActionStatusOther:{
                    chickBtn.stauts = ActionStatusNormal;
                    
                    chickBtn.selected = NO;
                    weakSelf.selectBtn = nil;
                    weakSelf.textView.inputView = nil;
                    [weakSelf.textView reloadInputViews];
                    [weakSelf.textView becomeFirstResponder];
                }
                    break;
                case ActionStatusSelect:{
                    
                }
                    break;
                    
                default:
                    break;
            }
            
        }];
    }
    return _emjoyBtn;
}
- (HBButton *)addBtn{
    if (!_addBtn) {
        _addBtn = [HBButton buttonFrame:CGRectMake(CGRectGetMaxX(self.emjoyBtn.frame) + 5, 0, self.HB_H, self.HB_H)];
        [_addBtn setNormalImage:[UIImage imageNamed:@"chat_bottom_up_nor"] selectImage:nil];
        __weak typeof(self) weakSelf = self;
        [_addBtn addAction:^(HBButton *chickBtn) {
            
            whbLog(@"你点了添加按钮!!!");
//            weakSelf.selectBtn.selected = NO;
//            chickBtn.selected = YES;
//            weakSelf.selectBtn = chickBtn;
            
        }];
    }
    return _addBtn;
}
- (CGRect)originTextViewFrame
{
    return CGRectMake(self.HB_H + 5, textViewY, self.HB_W - ((self.HB_H + 5) * 3), self.HB_H - textViewY * 2);
}
- (CGRect)originSelfFrame
{
    CGRect fixFrame = _originFrame;
    fixFrame.origin.y = _lastY + self.HB_H - _originaButtomViewH;
    return fixFrame;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self.textView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [self.textView removeObserver:self forKeyPath:@"attributedText"];
    [self.textView removeObserver:self forKeyPath:@"inputView"];
    [self removeObserver:self forKeyPath:@"frame"];
    
}
@end
