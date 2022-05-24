//
//  PopUpView.m
//  望湘园 Beta
//
//  Created by duan on 13-2-3.
//  Copyright (c) 2013年 com.wrsoft.MapCallouts. All rights reserved.
//

#define Duration 0.5

#import "PopUpView.h"

#define kOverlayViewTag 23941
#define kPopupViewTag 23942
#define kBackBtnTag 23943
#define kOverlayViewTag02 23944
#define kPopupViewTag02 23945
@interface Extance :NSObject
@end
@implementation Extance
@end

@interface UIViewController (PopUpViewPrivate)
@property(nonatomic,assign)NSInteger temp;
- (void)presentPopupView:(UIView*)popupView animationType:(PopupViewAnimation)animationType;

@end
@implementation UIViewController (PopUpView)

- (void)presentPopupViewController:(UIViewController*)popupViewController animationType:(PopupViewAnimation)animationType
{
    [self presentPopupView:popupViewController.view animationType:animationType];
}

- (void)dismissPopupViewController:(PopupViewAnimation)animationType
{
    [self showOutView:animationType];
}

-(void)clearBtnClick{
    //UIView *sourceView = [self view];
    //UIButton *btn = [sourceView viewWithTag:kBackBtnTag];
    //[btn addTarget:self action:@selector(dismissPopupViewController:) forControlEvents:UIControlEventTouchUpInside];
    //btn.userInteractionEnabled = NO;
    //btn.enabled = NO;
}

- (void)presentPopupView:(UIView*)popupView animationType:(PopupViewAnimation)animationType
{
    UIView *sourceView = [self view];
    popupView.tag = kPopupViewTag;
    
    UIView *overlayView = [[UIView alloc] initWithFrame:sourceView.bounds];
    overlayView.tag = kOverlayViewTag;
    overlayView.backgroundColor = [UIColor clearColor];
    overlayView.alpha = 0.0;
    
    UIButton *backImagebtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backImagebtn setTag:kBackBtnTag];
    //[backImagebtn setBackgroundColor:[UIColor colorWithRed:255 green:255 blue:255 alpha:0.1]];
    
    backImagebtn.frame = CGRectMake(0, 0, sourceView.frame.size.width , sourceView.frame.size.height );
    
    if (animationType == PopupViewAnimationSlideFade)
    {
        [backImagebtn addTarget:self action:@selector(dismissPopupViewControllerWithanimationTypeSlideFade) forControlEvents:UIControlEventTouchUpInside];
    }else if(animationType == PopupViewAnimationFadeSlideRight){
        [backImagebtn addTarget:self action:@selector(dismissPopupViewControllerWithanimationTypeSlideRight) forControlEvents:UIControlEventTouchUpInside];
    }
    else{
        [backImagebtn addTarget:self action:@selector(dismissPopupViewControllerWithanimationTypeSlideBottomBottom) forControlEvents:UIControlEventTouchUpInside];
    }
    [overlayView addSubview:backImagebtn];
    //[overlayView.layer addSublayer:boxLayer];
    [self.view addSubview:overlayView];
    
    [self showInView:popupView shaowView:overlayView animationType:animationType];
}

- (void)presentPopup02View:(UIView*)popupView animationType:(PopupViewAnimation)animationType
{
    UIView *sourceView = [self view];
    popupView.tag = kPopupViewTag02;
    
    UIView *overlayView = [[UIView alloc] initWithFrame:sourceView.bounds];
    overlayView.tag = kOverlayViewTag02;
    overlayView.backgroundColor = [UIColor clearColor];
    overlayView.alpha = 0.0;
    
    CALayer *boxLayer = [[CALayer alloc]init];
    [boxLayer setFrame:CGRectMake(0, 0, sourceView.frame.size.width, sourceView.frame.size.height)];
    UIColor *blackdish = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    CGColorRef cgBalckdish = [blackdish CGColor];
    [boxLayer setBackgroundColor:cgBalckdish];
    
    
    
    UIButton *backImagebtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backImagebtn setTag:kBackBtnTag];
    [backImagebtn setBackgroundColor:[UIColor colorWithRed:255 green:255 blue:255 alpha:0.1]];
    
    backImagebtn.frame = CGRectMake(0, 0, sourceView.frame.size.width , sourceView.frame.size.height );
    
    if (animationType == PopupViewAnimationSlideFade)
    {
        [backImagebtn addTarget:self action:@selector(dismissPopupViewControllerWithanimationTypeSlideFade02) forControlEvents:UIControlEventTouchUpInside];
    }else if(animationType == PopupViewAnimationFadeSlideRight){
        [backImagebtn addTarget:self action:@selector(dismissPopupViewControllerWithanimationTypeSlideRight02) forControlEvents:UIControlEventTouchUpInside];
    }
    else{
        [backImagebtn addTarget:self action:@selector(dismissPopupViewControllerWithanimationTypeSlideBottomBottom02) forControlEvents:UIControlEventTouchUpInside];
    }
    [overlayView addSubview:backImagebtn];
    //[overlayView.layer addSublayer:boxLayer];
    [self.view addSubview:overlayView];
    
    [self showInView:popupView shaowView:overlayView animationType:animationType];
}

- (void)dismissPopupViewControllerWithanimationTypeSlideBottomBottom
{
    [self showOutView:PopupViewAnimationFadeSlideBottomBottom];
    ////NSLog(@"%@",extance);
}
- (void)dismissPopupViewControllerWithanimationTypeSlideFade
{
    [self showOutView:PopupViewAnimationSlideFade];
}
-(void)dismissPopupViewControllerWithanimationTypeSlideRight{
    [self showOutView:PopupViewAnimationFadeSlideRight];
}

- (void)dismissPopupViewControllerWithanimationTypeSlideBottomBottom02
{
    [self showOutView02:PopupViewAnimationFadeSlideBottomBottom];
    ////NSLog(@"%@",extance);
}
- (void)dismissPopupViewControllerWithanimationTypeSlideFade02
{
    [self showOutView02:PopupViewAnimationSlideFade];
}
-(void)dismissPopupViewControllerWithanimationTypeSlideRight02{
    [self showOutView02:PopupViewAnimationFadeSlideRight];
}

-(UIView*)topView {
    UIViewController *recentView = self;
    
    while (recentView.parentViewController != nil) {
        recentView = recentView.parentViewController;
    }
    return recentView.view;
}


- (void)showInView:(UIView *)popupView shaowView:(UIView *)overlayView animationType:(PopupViewAnimation)animationType
{
 
    //overlayView.alpha = 0.3;
    CGSize overlayViewSize = overlayView.bounds.size;
    CGSize popupSize = popupView.bounds.size;
    CGRect popupStartRect;
    CGRect popupEndRect;
    
    if (animationType == PopupViewAnimationSlideFade)
    {
        popupStartRect = CGRectMake((overlayViewSize.width - popupSize.width) / 2,
                                    (overlayViewSize.height - popupSize.height) / 2,
                                    popupSize.width,
                                    popupSize.height);
        
        popupEndRect = CGRectMake((overlayViewSize.width - popupSize.width) / 2,
                                  (overlayViewSize.height - popupSize.height) / 2,
                                  popupSize.width,
                                  popupSize.height);
        
    }else if(animationType == PopupViewAnimationFadeSlideRight){
        popupStartRect = CGRectMake(overlayViewSize.width,
                                    (overlayViewSize.height - popupSize.height) / 2,
                                    popupSize.width,
                                    popupSize.height);
        
        popupEndRect = CGRectMake(overlayViewSize.width-popupSize.width,
                                  (overlayViewSize.height - popupSize.height) / 2,
                                  popupSize.width,
                                  popupSize.height);
    }else
    {
        popupStartRect = CGRectMake(0,
                                    overlayViewSize.height,
                                    popupSize.width,
                                    popupSize.height);
        
        popupEndRect = CGRectMake(0,
                                  (overlayViewSize.height - popupSize.height),
                                  popupSize.width,
                                  popupSize.height);
        
    }
    
    popupView.frame = popupStartRect;
    [self.view addSubview:popupView];
        
    [UIView animateWithDuration:Duration animations:^{
        popupView.frame = popupEndRect;    
        popupView.alpha = 1.0;
        overlayView.alpha = 0.7;
            
    } completion:^(BOOL finished) {
    }];
    
}

- (void)showOutView:(PopupViewAnimation)animationType
{
    UIView *sourceView = [self view];
    UIView *popupView = [sourceView viewWithTag:kPopupViewTag];
    UIView *overlayView = [sourceView viewWithTag:kOverlayViewTag];
    
    CGSize overlayViewSize = overlayView.bounds.size;
    CGSize popupSize = popupView.bounds.size;
    CGRect popupEndRect;
    
    if (animationType == PopupViewAnimationSlideFade)
    {
        popupEndRect = CGRectMake((overlayViewSize.width - popupSize.width) / 2,
                                                   (overlayViewSize.height - popupSize.height) / 2,
                                                   popupSize.width,
                                                   popupSize.height);
    }else if(animationType == PopupViewAnimationFadeSlideRight){
        popupEndRect = CGRectMake(overlayViewSize.width,
                                  (overlayViewSize.height - popupSize.height) / 2,
                                  popupSize.width,
                                  popupSize.height);
    }
    else{
        popupEndRect = CGRectMake(0,
                                  overlayViewSize.height,
                                  popupSize.width,
                                  popupSize.height);
    }
    
    [UIView animateWithDuration:Duration animations:^{
        overlayView.alpha = 0.0;
        if (animationType == PopupViewAnimationSlideFade)
        {
            popupView.alpha = 0.0;
        }else
        {
            popupView.frame = popupEndRect;
        }
    } completion:^(BOOL finished) {
        [overlayView removeFromSuperview];
        [popupView removeFromSuperview];
    }];
}

- (void)showOutView02:(PopupViewAnimation)animationType
{
    UIView *sourceView = [self view];
    UIView *popupView = [sourceView viewWithTag:kPopupViewTag02];
    UIView *overlayView = [sourceView viewWithTag:kOverlayViewTag02];
    
    CGSize overlayViewSize = overlayView.bounds.size;
    CGSize popupSize = popupView.bounds.size;
    CGRect popupEndRect;
    
    if (animationType == PopupViewAnimationSlideFade)
    {
        popupEndRect = CGRectMake((overlayViewSize.width - popupSize.width) / 2,
                                  (overlayViewSize.height - popupSize.height) / 2,
                                  popupSize.width,
                                  popupSize.height);
    }else if(animationType == PopupViewAnimationFadeSlideRight){
        popupEndRect = CGRectMake(overlayViewSize.width,
                                  (overlayViewSize.height - popupSize.height) / 2,
                                  popupSize.width,
                                  popupSize.height);
    }
    else{
        popupEndRect = CGRectMake(0,
                                  overlayViewSize.height,
                                  popupSize.width,
                                  popupSize.height);
    }
    
    [UIView animateWithDuration:Duration animations:^{
        overlayView.alpha = 0.0;
        if (animationType == PopupViewAnimationSlideFade)
        {
            popupView.alpha = 0.0;
        }else
        {
            popupView.frame = popupEndRect;
        }
    } completion:^(BOOL finished) {
        [overlayView removeFromSuperview];
        [popupView removeFromSuperview];
    }];
}

@end
