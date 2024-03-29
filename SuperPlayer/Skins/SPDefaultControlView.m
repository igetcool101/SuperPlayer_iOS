#import "SuperPlayerControlView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "MoreContentView.h"
#import "DataReport.h"
#import "SuperPlayerFastView.h"
#import "PlayerSlider.h"
#import "UIView+MMLayout.h"
#import "SuperPlayerView+Private.h"
#import "StrUtils.h"
#import "SPDefaultControlView.h"
#import "UIView+Fade.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"

#define MODEL_TAG_BEGIN 20
#define BOTTOM_IMAGE_VIEW_HEIGHT 50

@interface SPDefaultControlView () <UIGestureRecognizerDelegate, PlayerSliderDelegate>

@property (nonatomic, assign) BOOL showRate;    //!< 是否显示播放倍速，根据playModel的数据确定值
@property (nonatomic, strong) UIImageView *arrowImg;     //!< 选中图片
@end

@implementation SPDefaultControlView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        
        [self addSubview:self.topImageView];
        [self addSubview:self.bottomImageView];
        [self.bottomImageView addSubview:self.startBtn];
        [self.bottomImageView addSubview:self.currentTimeLabel];
        [self.bottomImageView addSubview:self.videoSlider];
        [self.bottomImageView addSubview:self.resolutionBtn];
        [self.bottomImageView addSubview:self.fullScreenBtn];
        [self.bottomImageView addSubview:self.totalTimeLabel];
        [self.bottomImageView addSubview:self.rateBtn];//播放速度按钮
        
        [self.topImageView addSubview:self.captureBtn];
        [self.topImageView addSubview:self.danmakuBtn];
        [self.topImageView addSubview:self.moreBtn];
        [self addSubview:self.lockBtn];
        [self.topImageView addSubview:self.backBtn];
        
        [self addSubview:self.playeBtn];
        
        [self.topImageView addSubview:self.titleLabel];
        
        
        [self addSubview:self.backLiveBtn];
        
        // 添加子控件的约束
        [self makeSubViewsConstraints];
        
        self.captureBtn.hidden = YES;
        self.danmakuBtn.hidden = YES;
        self.moreBtn.hidden     = YES;
        self.resolutionBtn.hidden   = YES;
        self.moreContentView.hidden = YES;
        self.rateBtn.hidden = YES;
        // 初始化时重置controlView
        [self playerResetControlView];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)makeSubViewsConstraints {
    
    [self.topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.top.equalTo(self.mas_top).offset(0);
        make.height.mas_equalTo(50);
    }];
    
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.topImageView.mas_leading).offset(5);
        make.top.equalTo(self.topImageView.mas_top).offset(3);
        make.width.height.mas_equalTo(40);
    }];
    
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(49);
        make.trailing.equalTo(self.topImageView.mas_trailing).offset(-10);
        make.centerY.equalTo(self.backBtn.mas_centerY);
    }];
    
    [self.captureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(49);
        make.trailing.equalTo(self.moreBtn.mas_leading).offset(-10);
        make.centerY.equalTo(self.backBtn.mas_centerY);
    }];
    
    [self.danmakuBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(49);
        make.trailing.equalTo(self.captureBtn.mas_leading).offset(-10);
        make.centerY.equalTo(self.backBtn.mas_centerY);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.backBtn.mas_trailing).offset(5);
        make.centerY.equalTo(self.backBtn.mas_centerY);
        make.trailing.equalTo(self.captureBtn.mas_leading).offset(-10);
    }];
    
    [self.bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(0);
        make.height.mas_equalTo(BOTTOM_IMAGE_VIEW_HEIGHT);
    }];
    
    [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.bottomImageView.mas_leading).offset(5);
        make.top.equalTo(self.bottomImageView.mas_top).offset(10);
        make.width.height.mas_equalTo(30);
    }];
    
    [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.startBtn.mas_trailing);
        make.centerY.equalTo(self.startBtn.mas_centerY);
        make.width.mas_equalTo(60);
    }];
    
    [self.fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(30);
        make.trailing.equalTo(self.bottomImageView.mas_trailing).offset(-8);
        make.centerY.equalTo(self.startBtn.mas_centerY);
    }];
    
    [self.resolutionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.width.mas_greaterThanOrEqualTo(45);
        make.trailing.equalTo(self.bottomImageView.mas_trailing).offset(-8);
        make.centerY.equalTo(self.startBtn.mas_centerY);
    }];
    
    [self.rateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.width.mas_greaterThanOrEqualTo(45);
        make.trailing.equalTo(self.resolutionBtn.mas_leading).offset(-8);
        make.centerY.equalTo(self.startBtn.mas_centerY);
    }];
    
    [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.fullScreenBtn.mas_leading);
        make.centerY.equalTo(self.startBtn.mas_centerY);
        make.width.mas_equalTo(60);
    }];
    
    [self.videoSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.currentTimeLabel.mas_trailing);
        make.trailing.equalTo(self.totalTimeLabel.mas_leading);
        make.centerY.equalTo(self.currentTimeLabel.mas_centerY).offset(-1);
    }];
    
    [self.lockBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading).offset(15);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(36);
    }];
    
    
    [self.playeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(50);
        make.center.equalTo(self);
    }];
    
    
    [self.backLiveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.startBtn.mas_top).mas_offset(-15);
        make.width.mas_equalTo(70);
        make.centerX.equalTo(self);
    }];
}




#pragma mark - Action

/**
 *  点击切换分别率按钮
 */
- (void)changeResolution:(UIButton *)sender {
    self.resoultionCurrentBtn.selected = NO;
    self.resoultionCurrentBtn = sender;
    self.resoultionCurrentBtn.selected = YES;
    
    [self.arrowImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.resolutionView).offset(-60);
        make.width.height.mas_equalTo(16);
        make.centerY.mas_equalTo(self.resoultionCurrentBtn);
    }];
    NSString *str1 = [sender.titleLabel.text substringToIndex:2];
    // topImageView上的按钮的文字
    [self.resolutionBtn setTitle:str1 forState:UIControlStateNormal];
    [self.delegate controlViewSwitch:self withDefinition:str1];
}

- (void)changePlayRate:(UIButton *)sender {
    self.rateCurrentBtn.selected = NO;
    self.rateCurrentBtn = sender;
    self.rateCurrentBtn.selected = YES;
    [self.arrowImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.rateView).offset(-35);
        make.width.height.mas_equalTo(16);
        make.centerY.mas_equalTo(self.rateCurrentBtn);
    }];
    self.rateView.hidden        = YES;
    // topImageView上的按钮的文字
//    NSString *rateString = sender.titleLabel.text;
//    if ([rateString isEqualToString:@"1.0x"]) {
//        rateString = @"倍速";
//    }
//    [self.rateBtn setTitle:rateString forState:UIControlStateNormal];
    if ([self.delegate respondsToSelector:@selector(controlViewSwitch:withRate:)]) {
        [self.delegate controlViewSwitch:self withRate:sender.titleLabel.text];
    }
}

- (void)backBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(controlViewBack:)]) {
        [self.delegate controlViewBack:self];
    }
}

- (void)exitFullScreen:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(controlViewChangeScreen:withFullScreen:)]) {
        [self.delegate controlViewChangeScreen:self withFullScreen:NO];
    }
}

- (void)lockScrrenBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.isLockScreen = sender.selected;
    self.topImageView.hidden    = self.isLockScreen;
    self.bottomImageView.hidden = self.isLockScreen;
    if (self.isLive) {
        self.backLiveBtn.hidden = self.isLockScreen;
    }
    [self.delegate controlViewLockScreen:self withLock:self.isLockScreen];
    [self fadeOut:3];
}

- (void)playBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.delegate controlViewPlay:self];
    } else {
        [self.delegate controlViewPause:self];
    }
    [self cancelFadeOut];
}

- (void)fullScreenBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.fullScreen = !self.fullScreen;
    [self.delegate controlViewChangeScreen:self withFullScreen:YES];
    [self fadeOut:3];
}


- (void)captureBtnClick:(UIButton *)sender {
    [self.delegate controlViewSnapshot:self];
    [self fadeOut:3];
}

- (void)danmakuBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self fadeOut:3];
}

- (void)moreBtnClick:(UIButton *)sender {
    self.topImageView.hidden = YES;
    self.bottomImageView.hidden = YES;
    self.lockBtn.hidden = YES;
    
    self.moreContentView.playerConfig = self.playerConfig;
    [self.moreContentView update];
    self.moreContentView.hidden = NO;
    
    [self cancelFadeOut];
    self.isShowSecondView = YES;
}

- (UIView *)resolutionView {
    if (!_resolutionView) {
        // 添加分辨率按钮和分辨率下拉列表
        
        _resolutionView = [[UIView alloc] initWithFrame:CGRectZero];
        _resolutionView.hidden = YES;
        [self addSubview:_resolutionView];
        [_resolutionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(330);
            make.height.mas_equalTo(self.mas_height);
            make.trailing.equalTo(self.mas_trailing).offset(0);
            make.top.equalTo(self.mas_top).offset(0);
        }];
        
        _resolutionView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    }
    return _resolutionView;
}

- (UIView *)rateView {
    if (!_rateView) {
        _rateView = [[UIView alloc] initWithFrame:CGRectZero];
        _rateView.hidden = YES;
        [self addSubview:_rateView];
        [_rateView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(330);
            make.height.mas_equalTo(self.mas_height);
            make.trailing.equalTo(self.mas_trailing).offset(0);
            make.top.equalTo(self.mas_top).offset(0);
        }];
        
        _rateView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        
    }
    return _rateView;
}
//修改分辨率
- (void)resolutionBtnClick:(UIButton *)sender {
    self.topImageView.hidden = YES;
    self.bottomImageView.hidden = YES;
    self.lockBtn.hidden = YES;
    
    // 显示隐藏分辨率View
    self.resolutionView.hidden = NO;
    [DataReport report:@"change_resolution" param:nil];
    [self.resolutionView addSubview:self.arrowImg];
    [self.arrowImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.resolutionView).offset(-60);
        make.width.height.mas_equalTo(16);
        make.centerY.mas_equalTo(self.resoultionCurrentBtn);
    }];
    [self cancelFadeOut];
    self.isShowSecondView = YES;
}

//修改视频播放倍速
- (void)rateBtnClick:(UIButton *)sender {
    self.topImageView.hidden = YES;
    self.bottomImageView.hidden = YES;
    self.lockBtn.hidden = YES;
    
    // 显示倍数View
    self.rateView.hidden = NO;
    [DataReport report:@"change_rate" param:nil];
    [self.rateView addSubview:self.arrowImg];
    [self.arrowImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.rateView).offset(-35);
        make.width.height.mas_equalTo(16);
        make.centerY.mas_equalTo(self.rateCurrentBtn);
    }];
    [self cancelFadeOut];
    self.isShowSecondView = YES;
}

- (void)progressSliderTouchBegan:(UISlider *)sender {
    self.isDragging = YES;
    [self cancelFadeOut];
}

- (void)progressSliderValueChanged:(UISlider *)sender {
    [self.delegate controlViewPreview:self where:sender.value];
}

- (void)progressSliderTouchEnded:(UISlider *)sender {
    [self.delegate controlViewSeek:self where:sender.value];
    self.isDragging = NO;
    [self fadeOut:5];
}

- (void)backLiveClick:(UIButton *)sender {
    [self.delegate controlViewReload:self];
}

- (void)pointJumpClick:(UIButton *)sender {
    self.pointJumpBtn.hidden = YES;
    PlayerPoint *point = [self.videoSlider.pointArray objectAtIndex:self.pointJumpBtn.tag];
    [self.delegate controlViewSeek:self where:point.where];
    [self fadeOut:0.1];
}

/**
 *  屏幕方向发生变化会调用这里
 */
- (void)setOrientationLandscapeConstraint {
    self.fullScreen             = YES;
    self.lockBtn.hidden         = NO;
    self.fullScreenBtn.selected = self.isLockScreen;
    self.fullScreenBtn.hidden   = YES;
    self.resolutionBtn.hidden   = self.resolutionArray.count == 0;
    if (self.showRate) {
        self.rateBtn.hidden = NO;
    }
    self.moreBtn.hidden         = NO;
    self.captureBtn.hidden      = NO;
    self.danmakuBtn.hidden      = NO;
    
    [self.backBtn setImage:SuperPlayerImage(@"back_full") forState:UIControlStateNormal];
    //横屏更改布局
    [self.resolutionBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.width.mas_greaterThanOrEqualTo(45);
        make.trailing.equalTo(self.bottomImageView.mas_trailing).offset(-8);
        make.centerY.equalTo(self.startBtn.mas_centerY);
    }];
    
    [self.rateBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.width.mas_greaterThanOrEqualTo(45);
        if (self.resolutionArray.count > 0) {
            make.trailing.equalTo(self.resolutionBtn.mas_leading).offset(-8);
        } else {
            make.trailing.equalTo(self.bottomImageView.mas_trailing).offset(-8);
        }
        
        make.centerY.equalTo(self.startBtn.mas_centerY);
    }];
    
    [self.totalTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.resolutionArray.count > 0 && self.showRate) {
            //两个都有
            make.trailing.equalTo(self.rateBtn.mas_leading);
        } else if (self.resolutionArray.count > 0) {
            make.trailing.equalTo(self.resolutionBtn.mas_leading);
        } else if(self.showRate) {
            make.trailing.equalTo(self.rateBtn.mas_leading);
        } else {
            make.trailing.equalTo(self.bottomImageView.mas_trailing);
        }
        
        make.centerY.equalTo(self.startBtn.mas_centerY);
        make.width.mas_equalTo(self.isLive?10:60);
    }];
    
    [self.bottomImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        CGFloat b = self.superview.mm_safeAreaBottomGap;
        make.height.mas_equalTo(BOTTOM_IMAGE_VIEW_HEIGHT+b);
    }];
    
    self.videoSlider.hiddenPoints = NO;
}
/**
 *  设置竖屏的约束
 */
- (void)setOrientationPortraitConstraint {
    self.fullScreen             = NO;
    self.lockBtn.hidden         = YES;
    self.fullScreenBtn.selected = NO;
    self.fullScreenBtn.hidden   = NO;
    self.resolutionBtn.hidden   = YES;
    self.rateBtn.hidden         = YES;
    self.moreBtn.hidden         = YES;
    self.captureBtn.hidden      = YES;
    self.danmakuBtn.hidden      = YES;
    self.moreContentView.hidden = YES;
    self.resolutionView.hidden  = YES;
    self.rateView.hidden        = YES;
    [self.totalTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.fullScreenBtn.mas_leading);
        make.centerY.equalTo(self.startBtn.mas_centerY);
        make.width.mas_equalTo(self.isLive?10:60);
    }];
    
    [self.bottomImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(BOTTOM_IMAGE_VIEW_HEIGHT);
    }];
    
    self.videoSlider.hiddenPoints = YES;
    self.pointJumpBtn.hidden = YES;
}

#pragma mark - Private Method
#pragma mark - setter
- (void)setIsLockScreen:(BOOL)isLockScreen {
    self.lockBtn.selected = isLockScreen;
    _isLockScreen = isLockScreen;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:15.0];
    }
    return _titleLabel;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:SuperPlayerImage(@"back_full") forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UIImageView *)topImageView {
    if (!_topImageView) {
        _topImageView                        = [[UIImageView alloc] init];
        _topImageView.userInteractionEnabled = YES;
        _topImageView.image                  = SuperPlayerImage(@"top_shadow");
    }
    return _topImageView;
}

- (UIImageView *)bottomImageView {
    if (!_bottomImageView) {
        _bottomImageView                        = [[UIImageView alloc] init];
        _bottomImageView.userInteractionEnabled = YES;
        _bottomImageView.image                  = SuperPlayerImage(@"bottom_shadow");
    }
    return _bottomImageView;
}

- (UIButton *)lockBtn {
    if (!_lockBtn) {
        _lockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _lockBtn.exclusiveTouch = YES;
        [_lockBtn setImage:SuperPlayerImage(@"unlock-nor") forState:UIControlStateNormal];
        [_lockBtn setImage:SuperPlayerImage(@"lock-nor") forState:UIControlStateSelected];
        [_lockBtn addTarget:self action:@selector(lockScrrenBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _lockBtn;
}

- (UIButton *)startBtn {
    if (!_startBtn) {
        _startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_startBtn setImage:SuperPlayerImage(@"play") forState:UIControlStateNormal];
        [_startBtn setImage:SuperPlayerImage(@"pause") forState:UIControlStateSelected];
        [_startBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startBtn;
}

- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        _currentTimeLabel               = [[UILabel alloc] init];
        _currentTimeLabel.textColor     = [UIColor whiteColor];
        _currentTimeLabel.font          = [UIFont systemFontOfSize:12.0f];
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _currentTimeLabel;
}

- (PlayerSlider *)videoSlider {
    if (!_videoSlider) {
        _videoSlider                       = [[PlayerSlider alloc] init];
        [_videoSlider setThumbImage:SuperPlayerImage(@"slider_thumb") forState:UIControlStateNormal];
        _videoSlider.minimumTrackTintColor = TintColor;
        // slider开始滑动事件
        [_videoSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
        // slider滑动中事件
        [_videoSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        // slider结束滑动事件
        [_videoSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        _videoSlider.delegate = self;
    }
    return _videoSlider;
}

- (UILabel *)totalTimeLabel {
    if (!_totalTimeLabel) {
        _totalTimeLabel               = [[UILabel alloc] init];
        _totalTimeLabel.textColor     = [UIColor whiteColor];
        _totalTimeLabel.font          = [UIFont systemFontOfSize:12.0f];
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _totalTimeLabel;
}

- (UIButton *)fullScreenBtn {
    if (!_fullScreenBtn) {
        _fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenBtn setImage:SuperPlayerImage(@"fullscreen") forState:UIControlStateNormal];
        [_fullScreenBtn addTarget:self action:@selector(fullScreenBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullScreenBtn;
}

- (UIButton *)captureBtn {
    if (!_captureBtn) {
        _captureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_captureBtn setImage:SuperPlayerImage(@"capture") forState:UIControlStateNormal];
        [_captureBtn setImage:SuperPlayerImage(@"capture_pressed") forState:UIControlStateSelected];
        [_captureBtn addTarget:self action:@selector(captureBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _captureBtn;
}

- (UIButton *)danmakuBtn {
    if (!_danmakuBtn) {
        _danmakuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_danmakuBtn setImage:SuperPlayerImage(@"danmu") forState:UIControlStateNormal];
        [_danmakuBtn setImage:SuperPlayerImage(@"danmu_pressed") forState:UIControlStateSelected];
        [_danmakuBtn addTarget:self action:@selector(danmakuBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _danmakuBtn;
}

- (UIButton *)moreBtn {
    if (!_moreBtn) {
        _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreBtn setImage:SuperPlayerImage(@"more") forState:UIControlStateNormal];
        [_moreBtn setImage:SuperPlayerImage(@"more_pressed") forState:UIControlStateSelected];
        [_moreBtn addTarget:self action:@selector(moreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreBtn;
}

- (UIButton *)resolutionBtn {
    if (!_resolutionBtn) {
        _resolutionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _resolutionBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        _resolutionBtn.backgroundColor = [UIColor clearColor];
        [_resolutionBtn addTarget:self action:@selector(resolutionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resolutionBtn;
}

- (UIButton *)rateBtn {
    if (!_rateBtn) {
        _rateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rateBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        _rateBtn.backgroundColor = [UIColor clearColor];
        [_rateBtn addTarget:self action:@selector(rateBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_rateBtn setTitle:@"倍速" forState:UIControlStateNormal];
    }
    return _rateBtn;
}

- (UIImageView *)arrowImg {
    if (!_arrowImg) {
        _arrowImg = [[UIImageView alloc] init];
        _arrowImg.image = SuperPlayerImage(@"selected");
    }
    return _arrowImg;
}

- (UIButton *)backLiveBtn {
    if (!_backLiveBtn) {
        _backLiveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backLiveBtn setTitle:@"返回直播" forState:UIControlStateNormal];
        _backLiveBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        UIImage *image = SuperPlayerImage(@"qg_online_bg");
        
        UIImage *resizableImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(33 * 0.5, 33 * 0.5, 33 * 0.5, 33 * 0.5)];
        [_backLiveBtn setBackgroundImage:resizableImage forState:UIControlStateNormal];
        
        [_backLiveBtn addTarget:self action:@selector(backLiveClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backLiveBtn;
}

- (UIButton *)pointJumpBtn {
    if (!_pointJumpBtn) {
        _pointJumpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = SuperPlayerImage(@"copywright_bg");
        UIImage *resizableImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20) resizingMode:UIImageResizingModeStretch];
        [_pointJumpBtn setBackgroundImage:resizableImage forState:UIControlStateNormal];
        _pointJumpBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_pointJumpBtn addTarget:self action:@selector(pointJumpClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_pointJumpBtn];
    }
    return _pointJumpBtn;
}

- (MoreContentView *)moreContentView {
    if (!_moreContentView) {
        _moreContentView = [[MoreContentView alloc] initWithFrame:CGRectZero];
        _moreContentView.controlView = self;
        _moreContentView.hidden = YES;
        [self addSubview:_moreContentView];
        [_moreContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(330);
            make.height.mas_equalTo(self.mas_height);
            make.trailing.equalTo(self.mas_trailing).offset(0);
            make.top.equalTo(self.mas_top).offset(0);
        }];
        _moreContentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    }
    return _moreContentView;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    
    if ([touch.view isKindOfClass:[UISlider class]]) { // 如果在滑块上点击就不响应pan手势
        return NO;
    }
    return YES;
}

#pragma mark - Public method

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    if (hidden) {
        self.resolutionView.hidden = YES;
        self.rateView.hidden        = YES;
        self.moreContentView.hidden = YES;
        if (!self.isLockScreen) {
            self.topImageView.hidden = NO;
            self.bottomImageView.hidden = NO;
        }
    }
    
    self.lockBtn.hidden = !self.fullScreen;
    self.isShowSecondView = NO;
    self.pointJumpBtn.hidden = YES;
}

/** 重置ControlView */
- (void)playerResetControlView {
    self.videoSlider.value           = 0;
    self.videoSlider.progressView.progress = 0;
    self.currentTimeLabel.text       = @"00:00";
    self.totalTimeLabel.text         = @"00:00";
    self.playeBtn.hidden             = YES;
    self.resolutionView.hidden       = YES;
    self.rateView.hidden             = YES;
    self.backgroundColor             = [UIColor clearColor];
    self.moreBtn.enabled         = YES;
    self.lockBtn.hidden              = !self.fullScreen;
    
    self.danmakuBtn.enabled = YES;
    self.captureBtn.enabled = YES;
    self.moreBtn.enabled = YES;
    self.backLiveBtn.hidden              = YES;
}

- (void)setPointArray:(NSArray *)pointArray
{
    [super setPointArray:pointArray];
    
    for (PlayerPoint *holder in self.videoSlider.pointArray) {
        [holder.holder removeFromSuperview];
    }
    [self.videoSlider.pointArray removeAllObjects];
    
    for (SuperPlayerVideoPoint *p in pointArray) {
        PlayerPoint *point = [self.videoSlider addPoint:p.where];
        point.content = p.text;
        point.timeOffset = p.time;
    }
}



- (void)onPlayerPointSelected:(PlayerPoint *)point {
    NSString *text = [NSString stringWithFormat:@"  %@ %@  ", [StrUtils timeFormat:point.timeOffset],
                      point.content];
    
    [self.pointJumpBtn setTitle:text forState:UIControlStateNormal];
    [self.pointJumpBtn sizeToFit];
    CGFloat x = self.videoSlider.mm_x + self.videoSlider.mm_w * point.where - self.pointJumpBtn.mm_h/2;
    if (x < 0)
        x = 0;
    if (x + self.pointJumpBtn.mm_h/2 > ScreenWidth)
        x = ScreenWidth - self.pointJumpBtn.mm_h/2;
    self.pointJumpBtn.tag = [self.videoSlider.pointArray indexOfObject:point];
    self.pointJumpBtn.mm_left(x).mm_bottom(60);
    self.pointJumpBtn.hidden = NO;
    
    [DataReport report:@"player_point" param:nil];
}

- (void)setProgressTime:(NSInteger)currentTime
              totalTime:(NSInteger)totalTime
          progressValue:(CGFloat)progress
          playableValue:(CGFloat)playable {
    if (!self.isDragging) {
        // 更新slider
        self.videoSlider.value           = progress;
    }
    // 更新当前播放时间
    self.currentTimeLabel.text = [StrUtils timeFormat:currentTime];
    // 更新总时间
    self.totalTimeLabel.text = [StrUtils timeFormat:totalTime];
    [self.videoSlider.progressView setProgress:playable animated:NO];
}

- (void)playerBegin:(SuperPlayerModel *)model
             isLive:(BOOL)isLive
     isTimeShifting:(BOOL)isTimeShifting
         isAutoPlay:(BOOL)isAutoPlay
{
    self.showRate = (model.playRate != nil && model.playRateArray.count > 0);
    [self setPlayState:isAutoPlay];
    self.backLiveBtn.hidden = !isTimeShifting;
    self.moreContentView.isLive = isLive;
    //配置显示视频播放倍速
    [self configPlayRateView:model];
    //配置播放分辨率
    [self configResolutionView:model];
    
    if (self.isLive != isLive) {
        self.isLive = isLive;
        [self setNeedsLayout];
    }
    // 时移的时候不能切清晰度
    self.resolutionBtn.userInteractionEnabled = !isTimeShifting;
}

//配置播放倍速视图
- (void)configPlayRateView:(SuperPlayerModel *)model {
    for (UIView *subView in self.rateView.subviews) {
        [subView removeFromSuperview];
    }
    
    _rateArray = model.playRateArray;
    
    UILabel *lable = [UILabel new];
    lable.text = @"倍速";
    lable.textAlignment = NSTextAlignmentCenter;
    lable.textColor = [UIColor whiteColor];
    if (@available(iOS 8.2, *)) {
        lable.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    }
    [self.rateView addSubview:lable];
    [lable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.resolutionView.mas_width);
        make.height.mas_equalTo(30);
        make.left.equalTo(self.resolutionView.mas_left);
        make.top.equalTo(self.resolutionView.mas_top).mas_offset(20);
    }];
    
    // 分辨率View上边的Btn
    for (NSInteger i = 0 ; i < _rateArray.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:_rateArray[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:250/255.0 green:100/255.0 blue:0/255.0 alpha:1.0] forState:UIControlStateSelected];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.rateView addSubview:btn];
        if (@available(iOS 8.2, *)) {
            btn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        }
        [btn addTarget:self action:@selector(changePlayRate:) forControlEvents:UIControlEventTouchUpInside];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.rateView.mas_width);
            make.height.mas_equalTo(45);
            make.left.equalTo(self.rateView.mas_left);
            make.centerY.equalTo(self.rateView.mas_centerY).offset((self.rateArray.count/2.0-i-0.5)*45);
        }];
        btn.tag = MODEL_TAG_BEGIN+i;
        
        if ([self.rateArray[i] isEqualToString:model.playRate]) {
            
            btn.selected = YES;
            self.rateCurrentBtn = btn;
        }
    }
}

- (void)configResolutionView:(SuperPlayerModel *)model {
    for (UIView *subview in self.resolutionView.subviews)
        [subview removeFromSuperview];

    _resolutionArray = model.playDefinitions;
    [self.resolutionBtn setTitle:model.playingDefinition forState:UIControlStateNormal];
    
    UILabel *lable = [UILabel new];
    lable.text = @"清晰度";
    lable.textAlignment = NSTextAlignmentCenter;
    lable.textColor = [UIColor whiteColor];
    if (@available(iOS 8.2, *)) {
        lable.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    }
    [self.resolutionView addSubview:lable];
    [lable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.resolutionView.mas_width);
        make.height.mas_equalTo(30);
        make.left.equalTo(self.resolutionView.mas_left);
        make.top.equalTo(self.resolutionView.mas_top).mas_offset(20);
    }];
    
    // 分辨率View上边的Btn
    for (NSInteger i = 0 ; i < _resolutionArray.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:_resolutionArray[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:250/255.0 green:100/255.0 blue:0/255.0 alpha:1.0] forState:UIControlStateSelected];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.resolutionView addSubview:btn];
        [btn addTarget:self action:@selector(changeResolution:) forControlEvents:UIControlEventTouchUpInside];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.resolutionView.mas_width);
            make.height.mas_equalTo(45);
            make.left.equalTo(self.resolutionView.mas_left);
            make.centerY.equalTo(self.resolutionView.mas_centerY).offset((self.resolutionArray.count/2.0-i-0.5)*45);
        }];
        btn.tag = MODEL_TAG_BEGIN+i;
        if (@available(iOS 8.2, *)) {
            btn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        }
        if ([_resolutionArray[i] containsString:model.playingDefinition]) {
            btn.selected = YES;
            self.resoultionCurrentBtn = btn;
        }
    }
}


/** 播放按钮状态 */
- (void)setPlayState:(BOOL)state {
    self.startBtn.selected = state;
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    self.titleLabel.text = title;
}

#pragma clang diagnostic pop

@end
