//
//  UIImage+ZXJCompressionImage.h
//  AIARecruitment2.0
//
//  Created by 枫叶砂 on 2018/12/11.
//  Copyright © 2018 bluedeer. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (ZXJCompressionImage)
+ (NSData *)compressImage:(UIImage *)image;
+ (NSData *)compressImage:(UIImage *)image withMask:(NSString *)maskName;
+ (NSData *)compressImage:(UIImage *)image withCustomImage:(NSString *)imageName;
@end

NS_ASSUME_NONNULL_END
