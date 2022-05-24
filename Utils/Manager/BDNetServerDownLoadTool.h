//
//  BDNetServerDownLoadTool.h
//  QuarkData
//
//  Created by Apple on 2017/7/20.
//  Copyright © 2017年 Thunder Software Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFURLSessionManager.h>

typedef void (^DonwLoadSuccessBlock)(NSURL * fileUrlPath);
typedef void (^DownLoadfailBlock)(NSError * error ,NSInteger statusCode);
typedef void (^DowningProgress)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress);

@interface BDNetServerDownLoadTool : NSObject

/* AFURLSessionManager */
@property (nonatomic,strong) AFURLSessionManager *manager;
/**  下载进程状态 */
@property (nonatomic,assign) BOOL downLoadIng;
/**  只加载一次，防止重复返回首页 */
@property (nonatomic,assign) BOOL fistLoadIng;
/**  下载历史记录 */
@property (nonatomic,strong) NSMutableDictionary *downLoadHistoryDictionary;
/**  断点历史记录 */
@property (nonatomic,strong) NSMutableDictionary *breakpointHistoryDictionary;
/**  当前下载地址 */
@property (nonatomic,strong) NSString *currentDownLoadUrl;

/**
 获取到网络请求单例对象
 @return 网络请求对象
 */
+ (instancetype)sharedTool;

/**
 获取app和h5版本
 @param sender 类型
 @param dProgress 进度
 @param dSuccessBlock 成功回调
 @param dfailBlock 失败回调
 @param completionBlock 完成回调
 */
- (void)getAppAndH5Version:(id)sender
                 dProgress:(DowningProgress)dProgress
             dSuccessBlock:(DonwLoadSuccessBlock)dSuccessBlock
                dfailBlock:(DownLoadfailBlock)dfailBlock
 completionLocalUrlHandler:(void (^)(NSString *localUrl))completionBlock;
/** 停止所有的下载任务 */
- (void)stopAllDownLoadTasks;
/** 获取对应版本号 */
-(NSArray *)getVersionList:(BDBaseResutInfo *)info;
/** 解压文件 */
-(BOOL)unzipFile:(NSString*)filePath withDstPath:(NSString*)dstPath password:(NSString *)password;
/** 解压目标文件保存的位置 */
-(NSString *)unzipFileLocalWithVersion:(NSString *)version;
/** 下载目标文件 */
-(NSString *)downloadFileLocal:(NSString *)str;
/** 获取index位置 */
- (NSString *)getIndexFileLocal;
/** 保存下载数据 */
-(BOOL)downLoadHistoryDictionaryToSave:(NSDictionary *)resultDictionary curVersion:(NSString *)curVersion;
/** 保存断点数据 */
-(BOOL)breakpointHistoryDictionarySave:(BDBaseResutInfo *)info downUrl:(NSString *)downUrl curVersion:(NSString *)curVersion password:(NSString *)password;
/** 删除文件 */
-(BOOL)removeFile:(NSString*)filePath;
/** 断点数据至空 */
-(BOOL)setBreakpointHistoryDictionaryToNil;
/** 修改版本文件地址 */
-(BOOL)fixIndexFileNameWithVersion:(NSString *)version toVersion:(NSString *)toVersion;
@end

