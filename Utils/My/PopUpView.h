//
//  PopUpView.h
//  望湘园 Beta
//
//  Created by duan on 13-2-3.
//  Copyright (c) 2013年 com.wrsoft.MapCallouts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

typedef enum{
    PopupViewAnimationSlideFade = 1,
    PopupViewAnimationFadeSlideBottomBottom,
    PopupViewAnimationFadeSlideRight
}PopupViewAnimation;

@interface UIViewController (PopUpView)
@property(nonatomic,assign)NSInteger temp;
-(void)clearBtnClick;
- (void)presentPopupViewController:(UIViewController*)popupViewController
                     animationType:(PopupViewAnimation)animationType;

- (void)dismissPopupViewController:(PopupViewAnimation)animationType;

- (void)presentPopupView:(UIView*)popupView
           animationType:(PopupViewAnimation)animationType;
- (void)presentPopup02View:(UIView*)popupView
             animationType:(PopupViewAnimation)animationType;
@end
