//
//  PopToastView.h
//  ZXHT
//
//  Created by Future on 14-7-24.
//  Copyright (c) 2014年 xiamenzhuoxuncompany. All rights reserved.
//

#import <UIKit/UIKit.h>

/*使用方法：
_prefix.pch中 import
 
 PopToastView *pop=[PopToastView sharedInstance];
 [pop popShowWithTitle:@"这是一个很长很长的提示框" AndTime:3];
 */

typedef NS_ENUM(NSUInteger,PopViewLocationType) {
    popViewLocationType_Top = 0,
    popViewLocationType_Center = 1,
    popViewLocationType_Bottom = 2
};

@interface FCPopToast : UIView

@property (assign, nonatomic) CGFloat offsetX;
@property (assign, nonatomic) CGFloat offsetY;
@property (assign, nonatomic) PopViewLocationType kType;
+ (FCPopToast *)sharedInstance;
+ (id) allocWithZone:(NSZone *)zone ;
-(void)popShowWithTitle:(NSString *)title AndTime:(float )time AndPopViewLocationType:(PopViewLocationType)type;
-(void)popShowWithError:(NSError *)error AndTime:(float )time AndPopViewLocationType:(PopViewLocationType)type;
@end

