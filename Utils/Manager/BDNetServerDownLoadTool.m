//
//  BDNetServerDownLoadTool.m
//  QuarkData
//
//  Created by Apple on 2017/7/20.
//  Copyright © 2017年 Thunder Software Technology. All rights reserved.
//

#import "BDNetServerDownLoadTool.h"
#import <AFNetworking/AFNetworking.h>
#import "SSZipArchive.h"
#import "SRDownloadManager.h"
@interface BDNetServerDownLoadTool ()
@property (nonatomic,strong) NSString  *fileHistoryPath;
@property (nonatomic,strong) NSString  *breakPointHistoryPath;

@end

@implementation BDNetServerDownLoadTool
static BDNetServerDownLoadTool *tool = nil;
+ (instancetype)sharedTool{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool =  [[self alloc] init];
    });
    return tool;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        //获取Document路径
        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *path=[paths objectAtIndex:0];
        
        //创建文件版本list
        self.fileHistoryPath=[path stringByAppendingPathComponent:@"fileDownLoadHistory.plist"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.fileHistoryPath]) {
            _downLoadHistoryDictionary =[NSMutableDictionary dictionaryWithContentsOfFile:self.fileHistoryPath];
        }else{
            _downLoadHistoryDictionary =[NSMutableDictionary dictionary];
            [_downLoadHistoryDictionary writeToFile:self.fileHistoryPath atomically:YES];
        }
        //创建断点下载list
        _breakPointHistoryPath=[path stringByAppendingPathComponent:@"breakpointHistoryDictionary.plist"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.breakPointHistoryPath]) {
            _breakpointHistoryDictionary =[NSMutableDictionary dictionaryWithContentsOfFile:self.breakPointHistoryPath];
        }else{
            _breakpointHistoryDictionary =[NSMutableDictionary dictionary];
            [_breakpointHistoryDictionary writeToFile:self.breakPointHistoryPath atomically:YES];
        }
    
    }
    return self;
}
- (void)saveBreakpointHistoryWithKey:(NSString *)key DownloadTaskResumeData:(NSData *)data{
    if (!data) {
        NSString *emptyData = [NSString stringWithFormat:@""];
        NSMutableDictionary *dicData = (NSMutableDictionary *)self.breakpointHistoryDictionary[@"dicData"];
        [dicData setObject:emptyData forKey:key];
        [self.breakpointHistoryDictionary setObject:dicData forKey:@"dicData"];
        
    }else{
        NSMutableDictionary *dicData = (NSMutableDictionary *)self.breakpointHistoryDictionary[@"dicData"];
        [dicData setObject:data forKey:key];
        [self.breakpointHistoryDictionary setObject:dicData forKey:@"dicData"];
    }
    
  [self.breakpointHistoryDictionary writeToFile:self.breakPointHistoryPath atomically:NO];
}
- (void)saveDownLoadHistoryDirectory{
    [self.downLoadHistoryDictionary writeToFile:self.fileHistoryPath atomically:YES];
}

- (void)getAppAndH5Version:(id)sender
                 dProgress:(DowningProgress)dProgress
             dSuccessBlock:(DonwLoadSuccessBlock)dSuccessBlock
                dfailBlock:(DownLoadfailBlock)dfailBlock
 completionLocalUrlHandler:(void (^)(NSString *localUrl))completionBlock{
    if (self.downLoadIng) {
        NSLog(@"资源正在下载");
        return;
    }
    self.downLoadIng = YES;
    
    [[BDHttpService shareInstance] loadVersion:nil completionHandler:^(BDBaseResutInfo *info) {
        
        if (info.code == 200) {
            //获取所有下载的list
            NSArray *zipArray = [self getDownloadList:info];
            //获取所有下载版本的list
            NSArray *versionArr = [self getVersionList:info];
            //获取所有解压密码list
            NSArray *unzipArr = [self getUnzipPwdList:info];
            //获取所有删除file
            //NSArray *deleteFileArr = (NSArray *)info.resultDictionary[@"deleteFile"];

            //如果没有下载则返回最后一次的页面
            if(!self.fistLoadIng){
                self.fistLoadIng = YES;
                if(zipArray.count == 0){
                    NSString *path = [self getIndexFileLocal];
                    NSFileManager *manager = [NSFileManager  defaultManager];
                    if ([manager fileExistsAtPath:path]) {
                        if (completionBlock) {
                            self.downLoadIng = NO;
                            completionBlock(path);
                        }
                    }else{
                        kPOP(@"文件不存在");
                        dfailBlock(nil,-999);
                    }
                    return ;
                }
            }else{
                self.downLoadIng = NO;
            }
            
//            //如果版本更新超过1个大更新，则删除该模块所有
//            if(([curVersion floatValue]-1)>[get_sp(type) floatValue]){
//                if([self removeFile:[self unzipFileLocalWithType:[NSString stringWithFormat:@"%@/",type]]]){
//                    set_sp(type,curVersion);
//                }
//            }
            
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            
            __block BOOL isCancel = NO;
            dispatch_apply(zipArray.count, queue, ^(size_t i) {
                if(!isCancel){
                    dispatch_async(queue, ^{
                        // 等待信号量
                        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                        // 解压的文件位置
                        NSString *unZipFileLocal = [self unzipFileLocalWithVersion:versionArr[i]];
                        // 下载url地址
                        self.currentDownLoadUrl = zipArray[i];
                        NSLog(@"%@",self.currentDownLoadUrl);
                        [[BDHttpService shareInstance] uploadAppDownloadVersionWithHtmlVersion:versionArr[i] withFinishBlock:^(id responseObject, NSError *error) {
                            if ([[responseObject objectForKey:@"success"] boolValue]) {
                                NSLog(@"记录成功%@",versionArr[i]);
//                                NSString *str = [NSString stringWithFormat:@"记录成功%@",versionArr[i]];
//                                kPOP(str);
                            }
                        }];
                        //默认先保存一个下载list
                        [self breakpointHistoryDictionarySave:info downUrl:zipArray[i] curVersion:versionArr[i] password:unzipArr[i]];
                        [[SRDownloadManager sharedManager]
                         downloadFileOfURL:[NSURL URLWithString:zipArray[i]]
                         state:^(SRDownloadState state) {}
                         progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress) {
                             dProgress(receivedSize,expectedSize,progress);
                         }
                         completion:^(BOOL success, NSString *filePath, NSError *error) {
                             if (success) {
                                 NSLog(@"FilePath: %@", filePath);
                                 NSString *currenVersion = [[BDTools getCurH5Version] floatValue]>0?[BDTools getCurH5Version]:@"0.00";
                                 [self fixIndexFileNameWithVersion:currenVersion toVersion:versionArr[i]];
                                 //是否解压文件成功
                                 if ([self unzipFile:filePath withDstPath:unZipFileLocal password:unzipArr[i]]) {
                                     NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                                     [userDefaults setObject:versionArr[i] forKey:@"localCachingH5Version"];
                                     [userDefaults synchronize];
                                     //保存下载的plist
                                     [self downloadSuccessToSave:info curVersion:versionArr[i]];
                                     [self setBreakpointHistoryDictionaryToNil];
                                     //是否是最后一个
                                     if(i==(zipArray.count-1)){
                                         dSuccessBlock([NSURL URLWithString:[self getIndexFileLocal]]);
                                         isCancel = YES;
                                         self.downLoadIng = NO;
                                     }
                                 }else{
                                     kPOP(@"解压失败！");

                                     [self fixIndexFileNameWithVersion:versionArr[i] toVersion:currenVersion];
                                     isCancel = YES;
                                     self.downLoadIng = NO;
                                 }
                             } else {
                                 NSLog(@"Error: %@", error);
                                 isCancel = YES;
                                 self.downLoadIng = NO;
                                 [self stopAllDownLoadTasks];
                                 dfailBlock(error,-1000);
                             }
                             dispatch_semaphore_signal(semaphore);
                         }];
                        
                    });
                }
            });
            
        }
        else
        {
            kPOP(info.msg);
            self.downLoadIng = NO;
        }
    } errorHandler:^(NSURLSessionDataTask *operation, NSError *error) {
        if (dfailBlock) {
            dfailBlock(error,error.code);
            self.downLoadIng = NO;
        }
    }];
}

//获取对应版本号
-(NSArray *)getVersionList:(BDBaseResutInfo *)info{
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    [resultArr addObject:info.data[@"curH5Version"][@"version"]];

    //如果第一次下载则下载全量包
//      if([BDTools getCurH5Version].length == 0){
//        [resultArr addObject:info.data[@"curH5Version"][@"version"]];
//        NSLog(@"第一次，下载版本号为：%@",resultArr);
//        return resultArr;
//    }
    //本地的版本
//    CGFloat currentVersion = [[BDTools getCurH5Version] floatValue];
    //下载的版本
//    CGFloat downVersion = [info.data[@"curH5Version"][@"version"] floatValue];
    //版本列表
//    NSArray *versions = (NSArray *)info.data[@"h5VersionHistory"];
    
    //如果本地的版本<下载的版本
//    if(currentVersion<downVersion){
//        for (int i=versions.count-1; i>=0; i--)  {
//            //列表中版本>当前版本
//            if([versions[i][@"version"] floatValue]>currentVersion){
//                //如果列表中版本超前当前版本
//                if(([versions[versions.count-1][@"verison"] floatValue]-currentVersion)>=0.1){
//                    resultArr = [[NSMutableArray alloc] init];
//                    [resultArr addObject:info.data[@"curH5Version"][@"version"]];
//                    break;
//                }else{
//                    NSArray *str01Array = [[self.downLoadHistoryDictionary objectForKey:@"curVersion"] componentsSeparatedByString:@"."];
//                    NSArray *str02Array = [versions[i][@"version"] componentsSeparatedByString:@"."];
//                    int firststr01 = [[str01Array firstObject] intValue];
//                    int firststr02 = [[str02Array firstObject] intValue];
//                    int str01 = [[str01Array lastObject] intValue]/10;
//                    int str02 = [[str02Array lastObject] intValue]/10;
//                    if(str01 != str02 || firststr01 != firststr02){
//                        resultArr = [[NSMutableArray alloc] init];
//                        [resultArr addObject:info.data[@"curH5Version"][@"version"]];
//                        break;
//                    }else{
//                        [resultArr addObject:versions[i][@"version"]];
//                    }
//                }
//            }
//        }
//    }
    
    NSLog(@"下载版本号：%@",resultArr);

    return resultArr;
}
//返回下载列表
-(NSArray *)getDownloadList:(BDBaseResutInfo *)info{
    
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    [resultArr addObject:info.data[@"curH5Version"][@"downloadUrl"]];

    //如果第一次下载则下载全量包
//    if([BDTools getCurH5Version].length == 0){
//        [resultArr addObject:info.data[@"h5FullPackage"][@"downloadUrl"]];
//        NSLog(@"第一次，下载地址为：%@",resultArr);
//        return resultArr;
//    }
    //本地的版本
//    CGFloat currentVersion = [[BDTools getCurH5Version] floatValue];
    //下载的版本
//    CGFloat downVersion = [info.data[@"curH5Version"][@"version"] floatValue];
    //版本列表
//    NSArray *versions = (NSArray *)info.data[@"h5VersionHistory"];
    
//    //如果本地的版本<下载的版本
//    if(currentVersion<downVersion){
//        for (int i=versions.count-1; i>=0; i--) {
//            //列表中版本>当前版本
//            if([versions[i][@"version"] floatValue]>currentVersion){
//                //如果列表中版本超前当前版本
//                if(([versions[versions.count-1][@"version"] floatValue]-currentVersion)>=0.1){
//                    resultArr = [[NSMutableArray alloc] init];
//                    [resultArr addObject:info.data[@"h5FullPackage"][@"downloadUrl"]];
//                    break;
//                }else{
//                    NSArray *str01Array = [[self.downLoadHistoryDictionary objectForKey:@"curVersion"] componentsSeparatedByString:@"."];
//                    NSArray *str02Array = [versions[i][@"version"] componentsSeparatedByString:@"."];
//                    int firststr01 = [[str01Array firstObject] intValue];
//                    int firststr02 = [[str02Array firstObject] intValue];
//                    int str01 = [[str01Array lastObject] intValue]/10;
//                    int str02 = [[str02Array lastObject] intValue]/10;
//                    if(str01 != str02 || firststr01 != firststr02){
//                        resultArr = [[NSMutableArray alloc] init];
//                        [resultArr addObject:info.data[@"h5FullPackage"][@"downloadUrl"]];
//                        break;
//                    }else{
//                        [resultArr addObject:versions[i][@"downloadUrl"]];
//                    }
//                }
//            }
//        }
//    }
    
    NSLog(@"下载地址为：%@",resultArr);
    
    return resultArr;
    
}
//返回解压密码列表
-(NSArray *)getUnzipPwdList:(BDBaseResutInfo *)info{
    
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    [resultArr addObject:info.data[@"curH5Version"][@"unzipPwd"]];

    //如果第一次下载则下载全量包
//    if([BDTools getCurH5Version].length == 0){
//        [resultArr addObject:info.data[@"h5FullPackage"][@"unzipPwd"]];
//
//        NSLog(@"第一次，下载密码为：%@",resultArr);
//        return resultArr;
//    }
    //本地的版本
//    CGFloat currentVersion = [[BDTools getCurH5Version] floatValue];
//    //下载的版本
//    CGFloat downVersion = [info.data[@"curH5Version"][@"version"] floatValue];
    //版本列表
//    NSArray *versions = (NSArray *)info.data[@"h5VersionHistory"];
    
    //如果本地的版本<下载的版本
//    if(currentVersion<downVersion){
//        for (int i=versions.count-1; i>=0; i--)  {
//            //列表中版本>当前版本
//            if([versions[i][@"version"] floatValue]>currentVersion){
//                //如果列表中版本超前当前版本
//                if(([versions[versions.count-1][@"version"] floatValue]-currentVersion)>=0.1){
//                    resultArr = [[NSMutableArray alloc] init];
//                    [resultArr addObject:info.data[@"h5FullPackage"][@"unzipPwd"]];
//                    break;
//                }else{
//                    NSArray *str01Array = [[self.downLoadHistoryDictionary objectForKey:@"curVersion"] componentsSeparatedByString:@"."];
//                    NSArray *str02Array = [versions[i][@"version"] componentsSeparatedByString:@"."];
//                    int firststr01 = [[str01Array firstObject] intValue];
//                    int firststr02 = [[str02Array firstObject] intValue];
//                    int str01 = [[str01Array lastObject] intValue]/10;
//                    int str02 = [[str02Array lastObject] intValue]/10;
//                    if(str01 != str02 || firststr01 != firststr02){
//                        resultArr = [[NSMutableArray alloc] init];
//                        [resultArr addObject:info.data[@"h5FullPackage"][@"unzipPwd"]];
//                        break;
//                    }else{
//                        [resultArr addObject:versions[i][@"unzipPwd"]];
//                    }
//                }
//            }
//        }
//    }
    
    NSLog(@"下载密码为：%@",resultArr);
    
    return resultArr;
    
}
//下载成功后保存
-(BOOL)downloadSuccessToSave:(BDBaseResutInfo *)info curVersion:(NSString *)curVersion{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:info.data];
    [dic setObject:curVersion forKey:@"curVersion"];
    self.downLoadHistoryDictionary = dic;
    return [self.downLoadHistoryDictionary writeToFile:self.fileHistoryPath atomically:YES];
}
-(BOOL)downLoadHistoryDictionaryToSave:(NSDictionary *)resultDictionary curVersion:(NSString *)curVersion{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:resultDictionary];
    [dic setObject:curVersion forKey:@"curVersion"];
    self.downLoadHistoryDictionary = dic;
    return [self.downLoadHistoryDictionary writeToFile:self.fileHistoryPath atomically:YES];
}
-(BOOL)breakpointHistoryDictionarySave:(BDBaseResutInfo *)info downUrl:(NSString *)downUrl curVersion:(NSString *)curVersion password:(NSString *)password{
    NSMutableDictionary *dicData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"",downUrl, nil];
    NSMutableDictionary *dicList = [[NSMutableDictionary alloc] initWithDictionary:info.data];
    [dicList setObject:curVersion forKey:@"curVersion"];
    [dicList setObject:password forKey:@"password"];
    [self.breakpointHistoryDictionary setObject:dicData forKey:@"dicData"];
    [self.breakpointHistoryDictionary setObject:dicList forKey:@"dicList"];
    return [self.breakpointHistoryDictionary writeToFile:self.breakPointHistoryPath atomically:YES];
}
-(BOOL)setBreakpointHistoryDictionaryToNil{
    self.breakpointHistoryDictionary =  [[NSMutableDictionary alloc] init];
    return [self.breakpointHistoryDictionary writeToFile:self.breakPointHistoryPath atomically:YES];
}
//解压文件
-(BOOL)unzipFile:(NSString*)filePath withDstPath:(NSString*)dstPath password:(NSString *)password{

    BOOL success = [SSZipArchive unzipFileAtPath:filePath
                                   toDestination:dstPath
                              preserveAttributes:YES
                                       overwrite:YES
                                  nestedZipLevel:0
                                        password:password
                                           error:nil
                                        delegate:nil
                                 progressHandler:nil
                               completionHandler:nil];
   
    if (success) {
        NSLog(@"Success unzip");
        [self removeFile:filePath];
    } else {
        NSLog(@"No success unzip");
        kPOP(@"解压失败！");
        [self removeFile:filePath];
        return NO;
    }
    return success;
}
//删除文件
-(BOOL)removeFile:(NSString*)filePath{
    BOOL ret =  NO;
    if ([filePath isKindOfClass:[NSString class]] && [filePath length] > 0) {
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:filePath]) {
            ret = [fm removeItemAtPath:filePath error:nil];
        }
    }
    return ret;
}
//获取http最后的/内容
-(NSString *)getHttpFinalContent:(NSString *)str{
    NSArray *arr = [str componentsSeparatedByString:@"/"];
    return arr[arr.count-1];
}
//下载目标文件
-(NSString *)downloadFileLocal:(NSString *)str{
    NSString *localPath = [BDTools downZipURL];
    // 要检查的文件目录
    NSString *filePath = [localPath  stringByAppendingPathComponent:[self getHttpFinalContent:str]];
    //NSURL *fileUrl = [NSURL fileURLWithPath:filePath isDirectory:NO];
    return filePath;
}
//解压目标文件保存的位置
-(NSString *)unzipFileLocalWithVersion:(NSString *)version{
    NSString *localPath = [BDTools downZipURL];
    // 要检查的文件目录
    NSString *filePath = [localPath  stringByAppendingPathComponent:[NSString stringWithFormat:@"e_opening"]];
    return filePath;
}
//获取index位置
- (NSString *)getIndexFileLocal{
    NSString *localPath = [self unzipFileLocalWithVersion:[BDTools getCurH5Version]];
    NSFileManager* fm=[NSFileManager defaultManager];
    NSString *indexFileLocal = @"";
    if([fm fileExistsAtPath:[NSString stringWithFormat:@"%@/dist/index.html",localPath]]){
        indexFileLocal = [NSString stringWithFormat:@"%@/dist/index.html",localPath];
    }

    return indexFileLocal;
}
//修改版本文件地址
-(BOOL)fixIndexFileNameWithVersion:(NSString *)version toVersion:(NSString *)toVersion{
    NSString *localPath = [self unzipFileLocalWithVersion:version];
    NSString *localPath2 = [self unzipFileLocalWithVersion:toVersion];
    NSFileManager *fm=[NSFileManager defaultManager];
    if([fm fileExistsAtPath:localPath]){
        if([fm moveItemAtPath:localPath toPath:localPath2 error:nil]){
            return YES;
        }else{
            NSLog(@"文件名修改失败");
            return NO;
        }
    }else{
        NSLog(@"文件不存在");
        return NO;
    }
    
    return YES;
    //[manager moveItemAtPath:filePath toPath:filePath2 error:nil]
}
//根据文件名来获取文件路径
- (NSString *)dataFilePath:(NSString *)sender {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                        NSUserDomainMask,
                                                        YES);
    NSString *documentDirectory = [path objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:sender];
}
- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
/** 停止所有的下载任务 */
- (void)stopAllDownLoadTasks{
    //cancelAllDownloads
    [[SRDownloadManager sharedManager] suspendAllDownloads];
    //[[SRDownloadManager sharedManager] cancelAllDownloads];
}

@end
