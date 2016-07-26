//
//  HBRecordHUD.m
//  XMPP_Chat
//
//  Created by 伍宏彬 on 16/6/23.
//  Copyright © 2016年 Wow_我了个去. All rights reserved.
//

#import "HBRecordHUD.h"
#import <AVFoundation/AVFoundation.h>
#import "HBHelp.h"


@interface HBRecordHUD()<AVAudioPlayerDelegate>
{
    AVAudioRecorder *_recorder;//录音
    AVAudioPlayer *_soundPlayer;//播放
    NSArray *_recordingNames;
    NSTimeInterval timerValue;
    NSString *_lastPath;
}
@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic, strong) NSTimer *tm;
@property (nonatomic, strong) NSMutableDictionary *setting;
@property (nonatomic, strong) UIImageView *statuImageView;
@property (nonatomic, assign) recordStatus status;
@property (nonatomic, copy) playCompletionBlcok completion;
@property (nonatomic, copy) recordTimeBlcok recordTime;
@end


@implementation HBRecordHUD

#define timeInterval 1.0
static HBRecordHUD *recordHUD = nil;
+ (instancetype)shareRecordHUD{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        recordHUD = [[self alloc] init];
    });
    return recordHUD;
}
+ (id)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        recordHUD = [super allocWithZone:zone];
    });
    return recordHUD;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        
        AVAudioSession* audioSession = [AVAudioSession sharedInstance];
        NSError * audioSessionError;
        [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&audioSessionError];
        [audioSession setActive:YES error:&audioSessionError];
        
    }
    return self;
}

#pragma mark - 录音相关
- (void)starRecord{
    
    _lastPath = [RootDocumentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf",[HBHelp currentdate]]];
    NSURL *currentURL = [NSURL fileURLWithPath:_lastPath];
    NSError *error;
    _recorder = [[AVAudioRecorder alloc] initWithURL:currentURL settings:self.setting error:&error];
    
    if (error) {
        whbLog(@"录音错误 - %@",error);
    }

    _recorder.meteringEnabled = YES;
    
    if ([_recorder prepareToRecord]) {
        [_recorder record];
    }
    
    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    [[NSRunLoop mainRunLoop] addTimer:self.tm forMode:NSRunLoopCommonModes];
    
    
    
}
- (void)stopRecord{
    
    
    if (self.link) {
        [self.link removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [self.link invalidate];
        self.link = nil;
    }
    
    if (self.tm) {
        whbLog(@"计时器：%@",@(timerValue));
        [self.tm invalidate];
        self.tm = nil;
    }
    
    if (_recorder.recording)
        [_recorder stop];
    
    [self hideCorver];

}
#pragma mark - 播放相关
- (void)playLocalMusicFileURL:(NSURL *)localURL beginPlay:(beginPlayBlcok)beginPlay completion:(playCompletionBlcok)completion{
    
    [self stopPlay];
    
    if (!localURL || [[NSFileManager defaultManager] fileExistsAtPath:[localURL absoluteString]]) {
        whbLog(@"路径错误 - 路径为空或者文件不存在！");
        return;
    }

    _soundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:localURL error:nil];
    _soundPlayer.delegate = self;
    if ([_soundPlayer prepareToPlay]) {
        
        [_soundPlayer play];
        
        if (beginPlay) {
            beginPlay();
        }
        
        self.completion = completion;
        whbLog(@"开始播放");
    }
}
- (void)stopPlay{
    
    if ([_soundPlayer isPlaying]) {
        [_soundPlayer stop];
    }
}

#pragma mark - 展示当前状态
- (void)showRecordingImageNames:(NSArray *)recordingNames{
    _recordingNames = recordingNames;
    
    self.status = recordStatusNormal;
    
    self.statuImageView.image = [UIImage imageNamed:[recordingNames firstObject]];
    
    if (!self.statuImageView.superview)
        [[UIApplication sharedApplication].keyWindow addSubview:self.statuImageView];
    
}
- (void)showFailRecordImageName:(NSString *)failName{
    
    self.status = recordStatusFaile;
    
    self.statuImageView.image = [UIImage imageNamed:failName];
    
    if (!self.statuImageView.superview)
    [[UIApplication sharedApplication].keyWindow addSubview:self.statuImageView];
    
}
- (void)showShortTimeImageName:(NSString *)shortName{
    
    self.statuImageView.image = [UIImage imageNamed:shortName];
    
    if (!self.statuImageView.superview)
        [[UIApplication sharedApplication].keyWindow addSubview:self.statuImageView];
}
- (void)hideCorver
{
    
    [UIView animateWithDuration:1. animations:^{
        self.statuImageView.alpha = 0;
    } completion:^(BOOL finished) {
        
        if (self.statuImageView.superview)
            [self.statuImageView removeFromSuperview];
        //重置初始状态
        self.statuImageView.alpha = 1;
        self.statuImageView.image = [UIImage imageNamed:[_recordingNames firstObject]];
        
    }];
    
}
- (void)recordTime:(recordTimeBlcok)time;
{
    self.recordTime = time;
}
- (NSString *)lastVoicePath
{
    return _lastPath;
}
- (NSTimeInterval)lastVoiceLengthTime
{
    return timerValue;
}
- (void)update{

    [_recorder updateMeters];
    
    float   level;                // The linear 0.0 .. 1.0 value we need.
    
    float   minDecibels = -80.0f; // Or use -60dB, which I measured in a silent room.
    
    float   decibels = [_recorder averagePowerForChannel:0];
    
    if (decibels < minDecibels){
        
        level = 0.0f;
        
    }else if (decibels >= 0.0f){
        
        level = 1.0f;
        
    }else{
        
        float   root            = 2.0f;
        
        float   minAmp          = powf(10.0f, 0.05f * minDecibels);
        
        float   inverseAmpRange = 1.0f / (1.0f - minAmp);
        
        float   amp             = powf(10.0f, 0.05f * decibels);
        
        float   adjAmp          = (amp - minAmp) * inverseAmpRange;
        
        level = powf(adjAmp, 1.0f / root);
        
    }   
    float voiceVaule = roundf(level * 120);
    
//    whbLog(@"平均值 %f", roundf(level * 120));
    
    if (self.status == recordStatusFaile) {
        return;
    }
    
    if (voiceVaule > 0.0 && voiceVaule <= 8.0) {
        
//        whbLog(@"平静");
        self.statuImageView.image = [UIImage imageNamed:@"1"];
        
    }else if (voiceVaule > 8.0 && voiceVaule <= 15.0){
        
//        whbLog(@"点点声音");
        self.statuImageView.image = [UIImage imageNamed:@"2"];
        
    }else if (voiceVaule > 15.0 && voiceVaule <= 25.0){
        
//        whbLog(@"大点点声音");
        self.statuImageView.image = [UIImage imageNamed:@"3"];
        
    }else if (voiceVaule > 25.0){
        
//        whbLog(@"暴风雨");
        self.statuImageView.image = [UIImage imageNamed:@"4"];
        
    }

    
}
- (void)timestar:(NSTimer *)tm
{
    
    timerValue += timeInterval;
    
    if (self.recordTime) {
        self.recordTime(timerValue);
    }
}
#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    whbLog(@"播放完成");
    if (self.completion) {
        self.completion(flag);
    }
}
#pragma mark - get
- (CADisplayLink *)link{
    if (!_link) {
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    }
    return _link;
}
- (NSTimer *)tm{
    if (!_tm) {
        _tm = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(timestar:) userInfo:nil repeats:YES];
        timerValue = 1.0;
    }
    return _tm;
}
- (NSMutableDictionary *)setting{
    if (!_setting) {
        _setting = [NSMutableDictionary dictionary];
        // 设置录音属性
        // 音频格式
        _setting[AVFormatIDKey] = @(kAudioFormatAppleIMA4);
        // 音频采样率
        _setting[AVSampleRateKey] = @(44100.0);
        // 音频通道数
        _setting[AVNumberOfChannelsKey] = @(1);
        // 线性音频的位深度
        _setting[AVLinearPCMBitDepthKey] = @(16);
    }
    return _setting;
}
- (UIImageView *)statuImageView{
    if (!_statuImageView) {
        CGSize SrcBoundsSize = [UIScreen mainScreen].bounds.size;
        CGFloat statuWH = SrcBoundsSize.width * 0.6;
        _statuImageView = [[UIImageView alloc] init];
        _statuImageView.HB_Size = CGSizeMake(statuWH, statuWH);
        _statuImageView.HB_center = CGPointMake(SrcBoundsSize.width * 0.5, SrcBoundsSize.height * 0.5);
    }
    return _statuImageView;
}
@end
