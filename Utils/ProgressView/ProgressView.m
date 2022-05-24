//
//  ProgressView.m
//  DownLoadTest
//
//  Created by 枫叶砂 on 2018/3/29.
//  Copyright © 2018年 Quarkdata. All rights reserved.
//

#import "ProgressView.h"

@interface ProgressView()
@property (nonatomic , strong) CAGradientLayer *ProgressLayer;
//@property (nonatomic , strong) UILabel *progressLabel;
@property (nonatomic , strong) UIView *contentView;
@end

@implementation ProgressView

+ (ProgressView*)sharedView {
    static dispatch_once_t once;
    static ProgressView *sharedView;
#if !defined(SV_APP_EXTENSIONS)
    dispatch_once(&once, ^{
        sharedView = [[self alloc] initWithFrame:[[[UIApplication sharedApplication] delegate] window].bounds];
    });
#else
    dispatch_once(&once, ^{
        sharedView = [[self alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    });
#endif
    return sharedView;
}
- (void)show{
    [ProgressView sharedView].alpha = 1.0f;
    _contentView.alpha = 1.0f;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:[ProgressView sharedView]];
}
- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = ({
            UIView *view = [[UIView alloc]init];
            [[ProgressView sharedView] addSubview:view];
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
            }];
            view.backgroundColor = [UIColor whiteColor];
            
            UIImageView *imageView = [[UIImageView alloc]init];
            [view addSubview:imageView];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.bottom.equalTo(view);
            }];
            imageView.image = [UIImage imageNamed:@"progressBack"];
            
            UIImageView *lineImageView = [[UIImageView alloc]init];
            [view addSubview:lineImageView];
            [lineImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(view);
                make.top.equalTo(view.mas_top).offset(420);
                make.size.mas_equalTo(CGSizeMake(400, 8));
            }];
            lineImageView.image = [UIImage imageNamed:@"progressLine"];
            
            _ProgressLayer = [CAGradientLayer layer];
            _ProgressLayer.frame = CGRectMake(0, 0, 0, 8);
//            _ProgressLayer.colors = @[(__bridge id)RGB(0, 157, 245).CGColor,(__bridge id)RGB(0, 201, 203).CGColor,(__bridge id)RGB(0, 157, 245).CGColor,(__bridge id)RGB(0, 201, 203).CGColor,(__bridge id)RGB(0, 157, 245).CGColor,(__bridge id)RGB(0, 201, 203).CGColor];
            _ProgressLayer.colors = @[(__bridge id)RGB(0, 157, 245).CGColor,(__bridge id)RGB(0, 201, 203).CGColor];
            _ProgressLayer.startPoint = CGPointMake(0, 0);
            _ProgressLayer.endPoint = CGPointMake(1, 0);
            _ProgressLayer.locations = @[@0,@0.5];
//            _ProgressLayer.locations = @[@(-1),@(-0.5),@(0),@(0.5),@(0.75),@(1)];
            _ProgressLayer.cornerRadius = 4.0f;
            [lineImageView.layer addSublayer:_ProgressLayer];
            
//            CABasicAnimation * animation = [CABasicAnimation animation];
//            animation.keyPath = @"locations";
//            animation.duration = 2;
////            animation.fromValue = @[@-1,@-0.5,@0,@0.5,@1];
////            animation.toValue = @[@0,@0.5,@1,@1.5,@2];
//            animation.fromValue = @[@0,@0.5,@1];
//            animation.toValue = @[@1,@1.5,@2];
//            animation.repeatCount = CGFLOAT_MAX;
//            [_ProgressLayer addAnimation:animation forKey:nil];
            
            view;
        });
    }
    return _contentView;
}
- (UILabel *)progressLabel
{
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc]init];
        [self.contentView addSubview:_progressLabel];
        [_progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).offset(440);
            make.centerX.equalTo(self.contentView);
            make.height.mas_equalTo(20);
        }];
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.textColor = RGB(0, 143, 200);
    }
    return _progressLabel;
}
- (UILabel *)measureNetLabel
{
    if (!_measureNetLabel) {
        _measureNetLabel = [[UILabel alloc]init];
        [_measureNetLabel setFont:[UIFont systemFontOfSize:13]];
        [_measureNetLabel setTextAlignment:NSTextAlignmentRight];
        [self.contentView addSubview:_measureNetLabel];
        [_measureNetLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).offset(440);
            make.centerX.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(400, 20));
        }];
        _measureNetLabel.textColor = RGB(0, 143, 200);
    }
    return _measureNetLabel;
}
- (void)dismissAnimated:(BOOL)animated completion:(void (^)(void))completion
{
    [UIView animateWithDuration:0.05 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self->_contentView.alpha = 0.8f;
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:animated? 0.25:0 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
                self->_contentView.alpha = 0.0f;
                [ProgressView sharedView].alpha = 0;
            } completion:^(BOOL finished) {
                [[ProgressView sharedView] removeFromSuperview];
                self->_ProgressLayer.frame = CGRectMake(0, 0, 0, 8);
                if (completion) completion();
            }];
        }
    }];
}
- (void)setProgress:(CGFloat)progress
{
    [self show];
    _progress = progress;
    _ProgressLayer.frame = CGRectMake(0, 0, 400*progress, 8);
    NSString *progressValue = [NSString stringWithFormat:@"%.0f%%",progress*100];
    self.progressLabel.text = progressValue;
}
- (instancetype)init
{
    if (self = [super init]) {
        [self addContentView];
    }
    return self;
}

- (void)addContentView
{
    UIImageView *imageView = [[UIImageView alloc]init];
    [self addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self);
    }];
    imageView.image = [UIImage imageNamed:@"progressBack"];
    
    UIImageView *lineImageView = [[UIImageView alloc]init];
    [self addSubview:lineImageView];
    [lineImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.mas_top).offset(420);
        make.size.mas_equalTo(CGSizeMake(400, 8));
    }];
    lineImageView.image = [UIImage imageNamed:@"progressLine"];
    
    _ProgressLayer = [CAGradientLayer layer];
    _ProgressLayer.frame = CGRectMake(0, 0, 0, 8);
    _ProgressLayer.colors = @[(__bridge id)RGB(0, 157, 245).CGColor,(__bridge id)RGB(0, 201, 203).CGColor];
    _ProgressLayer.startPoint = CGPointMake(0, 0);
    _ProgressLayer.endPoint = CGPointMake(1, 0);
    _ProgressLayer.locations = @[@0,@0.5];
    _ProgressLayer.cornerRadius = 4.0f;
    [lineImageView.layer addSublayer:_ProgressLayer];
    
//    CABasicAnimation * animation = [CABasicAnimation animation];
//    animation.keyPath = @"locations";
//    animation.duration = 2;
//    animation.fromValue = @[@-1,@-0.5,@0,@0.5,@1];
//    animation.toValue = @[@0,@0.5,@1,@1.5,@2];
//    animation.repeatCount = CGFLOAT_MAX;
//    [layer addAnimation:animation forKey:nil];
    
    _progressLabel = [[UILabel alloc]init];
    [self addSubview:_progressLabel];
    [_progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineImageView.mas_bottom).offset(12);
        make.centerX.equalTo(lineImageView);
        make.height.mas_equalTo(20);
    }];
    _progressLabel.textAlignment = NSTextAlignmentCenter;
    _progressLabel.textColor = RGB(0, 143, 200);
}

//- (void)setProgress:(CGFloat)progress
//{
//    _progress = progress;
//    _ProgressLayer.frame = CGRectMake(0, 0, 400*progress, 8);
//    NSString *progressValue = [NSString stringWithFormat:@"%0.0f%%",progress*100];
//    _progressLabel.text = progressValue;
//}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
