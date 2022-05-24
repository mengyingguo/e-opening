//
//  ProgressView.h
//  DownLoadTest
//
//  Created by 枫叶砂 on 2018/3/29.
//  Copyright © 2018年 Quarkdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressView : UIView

@property (nonatomic , assign) CGFloat progress;
@property (nonatomic , strong) UILabel *progressLabel;
@property (nonatomic , strong) UILabel *measureNetLabel;

- (void)dismissAnimated:(BOOL)animated completion:(void (^)(void))completion;

+ (ProgressView*)sharedView;
@end
