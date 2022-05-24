//
//  PopToastView.m
//  ZXHT
//
//  Created by Future on 14-7-24.
//  Copyright (c) 2014年 xiamenzhuoxuncompany. All rights reserved.
//

#import "FCPopToast.h"
#define SELFHEIGHT 30
#define SELFPADDING 20
#define SELFHEIHTPADDING 7.5

@interface FCPopToast ()<CAAnimationDelegate>
{
    UIImageView *_imagev;
    UILabel *_label;
}
@end

@implementation FCPopToast

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-100, [UIScreen mainScreen].bounds.size.height, 200, SELFHEIGHT)];
        [self.layer setCornerRadius:3.0f];
        [self.layer setMasksToBounds:YES];
        
         self.backgroundColor=[UIColor blackColor];
        _imagev=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg_prompt_box"]];
    
        _label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, SELFHEIGHT)];
    }
    return self;
}
static FCPopToast * instance;
+ (FCPopToast *)sharedInstance{
    static dispatch_once_t  onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FCPopToast alloc] init];
    });
    instance.offsetX = 0;
    instance.offsetY = 0;
    instance.kType = popViewLocationType_Center;
    return instance;
}
+ (id) allocWithZone:(NSZone *)zone //单例重写allocWithZone方法，alloc不产生新的势力
{
    @synchronized (self) {
        if (instance == nil) {
            instance = [super allocWithZone:zone];
            return instance;
        }
    }
    return nil;
}
- (void)popShowWithError:(NSError *)error AndTime:(float)time AndPopViewLocationType:(PopViewLocationType)type{
    NSString *strError = [NSString stringWithFormat:@"%@",error];
    NSString *strShow = @"";
    
    NSArray *arr = [strError componentsSeparatedByString:@"Code=-"];\
    if (arr.count > 1) {
        NSString *str = [arr[1] substringWithRange:NSMakeRange(0, 6)];
        NSMutableString *numberString = [[NSMutableString alloc] init];
        NSString *tempStr;
        NSScanner *scanner = [NSScanner scannerWithString:str];
        NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        while (![scanner isAtEnd]) {
            [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
            [scanner scanCharactersFromSet:numbers intoString:&tempStr];
            [numberString appendString:tempStr];
            tempStr = @"";
        }
        int number = [numberString intValue];
        strShow = [NSString stringWithFormat:@"%d", number];
    }
    NSArray *arr2 = [strError componentsSeparatedByString:@"\""];
    if (arr2.count > 1) {
        strShow = [NSString stringWithFormat:@"%@%@", strShow, arr2[1]];
    }
    NSString *errorString = [NSString stringWithFormat:@"请求服务器失败，请检查网络配置！%@",strShow];
    [self popShowWithTitle:errorString AndTime:time AndPopViewLocationType:type];
}
-(void)popShowWithTitle:(NSString *)title AndTime:(float )time AndPopViewLocationType:(PopViewLocationType)type
{
    if([BDTools isBlankString:title]){
        return;
    }
    _kType = type;
    _label.text=title;
    [_label setFont:[UIFont systemFontOfSize:15]];
    [_label setTextColor:[UIColor whiteColor]];
    [_label setTextAlignment:NSTextAlignmentCenter];
    _label.lineBreakMode = NSLineBreakByWordWrapping;// UILineBreakModeWordWrap;
    _label.numberOfLines = 0;
  
//    CGSize contentLabelSize = [_label.text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(180, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    CGSize contentLabelSize = [_label.text boundingRectWithSize:CGSizeMake(220, MAXFLOAT)  options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_label.font} context:nil].size;
    //长度最大值、高度最大值
    int width=contentLabelSize.width+SELFHEIHTPADDING + 15;
    int height=contentLabelSize.height+SELFHEIHTPADDING;
    if(height<SELFHEIGHT)
    {
        height=SELFHEIGHT;
    }
    
    [_imagev setFrame:CGRectMake(0, 0, width, height)];
    [_label setFrame:CGRectMake(0, 0, width, height)];
    [self addSubview:_imagev];
    [self addSubview:_label];

    if (self.offsetX || self.offsetY) {
        [self setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-width/2, [UIScreen mainScreen].bounds.size.height-49-50, width, height)];
        self.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2+self.offsetX, [UIScreen mainScreen].bounds.size.height/2+self.offsetY);
    }
    else{
        switch (_kType) {
            case popViewLocationType_Top:
                [self setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-width/2, 99 , width, height)];
                break;
            case popViewLocationType_Center:
            {
             [self setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-width/2, [UIScreen mainScreen].bounds.size.height-49-50, width, height)];
                self.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
            }
                break;
            case popViewLocationType_Bottom:
                [self setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-width/2, [UIScreen mainScreen].bounds.size.height-49-50, width, height)];
                break;
            default:
                break;
        }
    }
    
    CABasicAnimation * animation1=[CABasicAnimation  animationWithKeyPath:@"opacity"];//模糊动画
	[animation1 setFromValue:[NSNumber numberWithFloat:0.5]];//设置开始值为 1.0
    [animation1 setToValue:[NSNumber numberWithInt:1]];
    [animation1 setDuration:1];
    //	animation setRepeatCount:3.0];//设置重复时间3秒
    //    [animation2 setDelegate:self];
    [animation1 setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    //	[animation setAutoreverses:YES];//设置恢复//默认的是NO，即透明完毕后立马恢复，YES是延迟恢复
//   [self.layer  addAnimation:animation1 forKey:@"img-opacity"];
 
    CABasicAnimation * animation2=[CABasicAnimation  animationWithKeyPath:@"opacity"];//模糊动画
	[animation2 setFromValue:[NSNumber numberWithFloat:1]];//设置开始值为 1.0
    [animation2 setToValue:[NSNumber numberWithInt:0.5]];
    [animation2 setDuration:time];
    [animation2 setCumulative:YES];
    //	animation setRepeatCount:3.0];//设置重复时间3秒
    [animation2 setDelegate:self];
    [animation2 setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [animation2 setBeginTime:1];
    //	[animation setAutoreverses:YES];//设置恢复//默认的是NO，即透明完毕后立马恢复，YES是延迟恢复
//    [self.layer  addAnimation:animation2 forKey:@"img-opacity"];
//    UIActivityIndicatorView *testActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//    testActivityIndicator.center = CGPointMake(100.0f, 50.0f);//只能设置中心，不能设置大小
//    [self addSubview:testActivityIndicator];
////    testActivityIndicator.color = [UIColor redColor]; // 改变圈圈的颜色为红色； iOS5引入
//    [testActivityIndicator startAnimating]; // 开始旋转
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
	animationGroup.duration = 1+time;
    animationGroup.delegate=self;
//	animationGroup.autoreverses = YES;
//	animationGroup.repeatCount = HUGE_VALF;
	[animationGroup setAnimations:[NSArray arrayWithObjects:animation1,animation2, nil]];
    [self.layer addAnimation:animationGroup forKey:@"animationGroup"];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag;
{
   // NSLog(@" 动画结束 ");
//    [self removeFromSuperview];
    self .alpha=0;
}

//-(void)doOpacity//图片模糊变化
//{
//	NSLog(@"%s",__FUNCTION__);
//	CABasicAnimation * animation=[CABasicAnimation  animationWithKeyPath:@"opacity"];//模糊动画
//	[animation setFromValue:[NSNumber numberWithFloat:1.0]];//设置开始值为 1.0
//    [animation setToValue:[NSNumber numberWithInt:0.0]];
//    [animation setDuration:3.0];
//	[animation setRepeatCount:3.0];//设置重复时间3秒
//    [animation setDelegate:self];
//	[animation setAutoreverses:YES];//设置恢复//默认的是NO，即透明完毕后立马恢复，YES是延迟恢复
//    [bigImage.layer  addAnimation:animation forKey:@"img-opacity"];
//}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
