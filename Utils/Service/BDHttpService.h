//
//  BDHttpService.h
//  FHC
//
//  Created by 枫叶砂 on 16/9/21.
//  Copyright © 2016年 bluedeer-ban. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "BDBaseResutInfo.h"
#import "BDHttpServiceHead.h"
#import "Reachability.h"

//通用错误返回
typedef void (^BDErrorBlock)(NSURLSessionDataTask *operation,NSError *error);
//AFHTTPSessionManager 错误返回
typedef void (^BDSMErrorBlock)(NSURLSessionDataTask *task,NSError *error);
//是否成功返回
typedef void (^BDIsSuccessResult)(BOOL isSuccess);
//基本返回信息
typedef void (^BDBaseResult)(BDBaseResutInfo *resultInfo);

@interface BDHttpService : NSObject

//单例
+(BDHttpService *)shareInstance;

//是否联网
+(BOOL)isReachNetWork;
//是否是wifi
+(BOOL)isReachIsWifi;
//APP版本
- (void)loadVersion:(id)sender
  completionHandler:(void (^)(BDBaseResutInfo *info))completionBlock
       errorHandler:(BDErrorBlock)errorBlock;
//获取收藏列表
- (void)loadAppData:(id)sender
               idNo:(NSString *)idNo
               type:(NSString *)type
        finishBlock:(void(^)(id responseObject, NSError *error))finishBlock;
//新增或者更新数据接口
- (void)saveAppData:(id)sender
               uuid:(NSString *)uuid
               idNo:(NSString *)idNo
               type:(NSString *)type
            content:(NSString *)content
        finishBlock:(void(^)(id responseObject, NSError *error))finishBlock;
- (void)uploadAppDownloadVersionWithHtmlVersion:(NSString *)htmlVersion withFinishBlock:(void(^)(id responseObject, NSError *error))finishBlock;

//获取爱招募代理人信息
- (void)loadAiZhaoMuData:(id)sender
       completionHandler:(void (^)(BDBaseResutInfo *info))completionBlock
            errorHandler:(BDErrorBlock)errorBlock;

@end

