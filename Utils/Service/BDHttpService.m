//
//  BDHttpService.m
//  FHC
//
//  Created by 枫叶砂 on 16/9/21.
//  Copyright © 2016年 bluedeer-ban. All rights reserved.
//

#import "BDHttpService.h"
#import "ProgressView.h"
#import "FTDKeyChain.h"
#import "BDNetServerDownLoadTool.h"
#import <sys/utsname.h>

static BDHttpService *_instance = nil;

@interface BDHttpService ()

@property (nonatomic, strong) AFNetworkReachabilityManager *statusManger;

@end

@implementation BDHttpService

//单例
+(BDHttpService *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        [_instance networkStatus];
    });
    return _instance;
}
#pragma mark - 请求的公共方法
- (void)requestWithPostURL:(NSString *)url parameters:(NSDictionary *)parameter completionHandler:(void (^)(BDBaseResutInfo *info))completionBlock errorHandler:(BDErrorBlock)errorBlock{
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:url]];
    AFHTTPRequestSerializer *requestSerializer =  [AFJSONRequestSerializer serializer];
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    if (token != nil) {
        NSString * authorization = [NSString stringWithFormat:@"Bearer %@",token];
        NSDictionary *headerFieldValueDictionary = @{@"Authorization":authorization};
        if (headerFieldValueDictionary != nil) {
            for (NSString *httpHeaderField in headerFieldValueDictionary.allKeys) {
                NSString *value = headerFieldValueDictionary[httpHeaderField];
                [requestSerializer setValue:value forHTTPHeaderField:httpHeaderField];
            }
        }
    }
    
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager POST:url parameters:parameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        BDBaseResutInfo *info = [[BDBaseResutInfo alloc] initWithJsonDic:responseObject];
        if (info.code == 401) {//token失效
            [[NSNotificationCenter defaultCenter] postNotificationName:kHomeOpenImapNotification object:nil];
            return;
        }
        completionBlock(info);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorBlock(task,error);
    }];
}

- (void)requestWithGetURL:(NSString *)URL parameters:(NSDictionary *)parameter completionHandler:(void (^)(BDBaseResutInfo *info))completionBlock errorHandler:(BDErrorBlock)errorBlock{
    {
        // 在请求之前你可以统一配置你请求的相关参数 ,设置请求头, 请求参数的格式, 返回数据的格式....这样你就不需要每次请求都要设置一遍相关参数
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithBaseURL:[NSURL URLWithString:URL]];
        //    NSString *cerPath = [[NSBundle mainBundle] pathForResource:CERNAME ofType:@"cer"];
        //    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
        //    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        //    securityPolicy.allowInvalidCertificates=YES;
        //    securityPolicy.validatesDomainName = NO;
        //    securityPolicy.pinnedCertificates = [[NSSet alloc] initWithObjects:cerData,nil];
        //    manager.securityPolicy= securityPolicy;
        AFHTTPRequestSerializer *requestSerializer =  [AFJSONRequestSerializer serializer];
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
        if (token != nil) {
            NSString * authorization = [NSString stringWithFormat:@"Bearer %@",token];
            NSDictionary *headerFieldValueDictionary = @{@"Authorization":authorization};
            if (headerFieldValueDictionary != nil) {
                for (NSString *httpHeaderField in headerFieldValueDictionary.allKeys) {
                    NSString *value = headerFieldValueDictionary[httpHeaderField];
                    [requestSerializer setValue:value forHTTPHeaderField:httpHeaderField];
                }
            }
        }

        manager.requestSerializer = requestSerializer;
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer.timeoutInterval = 30;
        
        [manager GET:URL parameters:parameter progress:^(NSProgress * _Nonnull downloadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *responseObjecte = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            BDBaseResutInfo *info = [[BDBaseResutInfo alloc] initWithJsonDic:responseObjecte];
            
            if (info.code == 401) {//token失效
                [[NSNotificationCenter defaultCenter] postNotificationName:kHomeOpenImapNotification object:nil];
                return;
            }
            
            completionBlock(info);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            errorBlock(task,error);
        }];
        
    }
    
}
#pragma mark - 版本更新接口
- (void)loadVersion:(id)sender completionHandler:(void (^)(BDBaseResutInfo *info))completionBlock errorHandler:(BDErrorBlock)errorBlock
{
    
    NSString *url = [NSString stringWithFormat:@"%@nbs-eopening/APP/version",ROOT_URL];
    NSLog(@"%@",url);
    [self requestWithGetURL:url parameters:nil completionHandler:^(BDBaseResutInfo *info) {
        
        completionBlock(info);
    } errorHandler:^(NSURLSessionDataTask *operation, NSError *error) {
        errorBlock(operation,error);
        
    }];
}
- (void)uploadAppDownloadVersionWithHtmlVersion:(NSString *)htmlVersion withFinishBlock:(void(^)(id responseObject, NSError *error))finishBlock{
    NSMutableDictionary *parametersDic = [NSMutableDictionary dictionary];
    //    deviceNumber     String     设备号
    NSString *identifierStr = nil;
    if ([BDTools isBlankString:[FTDKeyChain load:KEYCHAIN_UUID]]) {
        identifierStr = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [FTDKeyChain save:KEYCHAIN_UUID data:identifierStr];
    }
    identifierStr = [FTDKeyChain load:KEYCHAIN_UUID];
    if (![BDTools isBlankString:identifierStr]) {
        [parametersDic setObject:identifierStr forKey:@"deviceNumber"];
    }
    //    downloadTime     String     下载时间
    NSString *downloadTime = [self getCurrentTimes];
    if (![BDTools isBlankString:downloadTime]) {
        [parametersDic setObject:downloadTime forKey:@"downloadTime"];
    }
    //    appVersion     String     app版本号
    NSString *appVersion = [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if (![BDTools isBlankString:appVersion]) {
        [parametersDic setObject:appVersion forKey:@"appVersion"];
    }
    //    htmlVersion     String     html版本号
    if (![BDTools isBlankString:htmlVersion]) {
        [parametersDic setObject:htmlVersion forKey:@"htmlVersion"];
    }
    //    iosVersion     String     ios版本号
    NSString* iosVersion = [[UIDevice currentDevice] systemVersion];
    if (![BDTools isBlankString:iosVersion]) {
        [parametersDic setObject:iosVersion forKey:@"iosVersion"];
    }
    //    ipadModel     String     IPAD型号
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *model = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    //    NSString *ipadModel = [self currentModel:model];
    if (![BDTools isBlankString:model]) {
        [parametersDic setObject:model forKey:@"ipadModel"];
    }
    else{
        [parametersDic setObject:@"iPad7,6" forKey:@"ipadModel"];
    }
    //    idNo     String     营销员唯一标识
    NSString *idNo = [FTDKeyChain load:KEYCHAIN_LOGININFO_AGENTCODE];
    if (![BDTools isBlankString:idNo]) {
        [parametersDic setObject:idNo forKey:@"idNo"];
    }
    else{
        [parametersDic setObject:@"e-opening" forKey:@"idNo"];
    }
    //    agencyInformation     String     代理人机构信息
    NSString *agencyInformation = [FTDKeyChain load:KEYCHAIN_LOGININFO_ORGANIZATION];
    if (![BDTools isBlankString:agencyInformation]) {
        [parametersDic setObject:agencyInformation forKey:@"agencyInformation"];
    }
    else{
        [parametersDic setObject:@"e-opening" forKey:@"agencyInformation"];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@api/version/add-version-log",SERVICE_URL];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:url]];
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:CERNAME ofType:@"cer"];
    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    securityPolicy.allowInvalidCertificates=YES;
    securityPolicy.validatesDomainName = NO;
    securityPolicy.pinnedCertificates = [[NSSet alloc] initWithObjects:cerData,nil];
    manager.securityPolicy= securityPolicy;
    
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 30;
    [manager GET:url parameters:parametersDic progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        finishBlock([BDTools jsonToData:responseObject],nil);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        finishBlock(nil,error);
    }];
}
- (NSString *)currentModel:(NSString *)phoneModel {
    
    if ([phoneModel isEqualToString:@"iPhone3,1"] ||
        [phoneModel isEqualToString:@"iPhone3,2"])   return @"iPhone 4";
    if ([phoneModel isEqualToString:@"iPhone4,1"])   return @"iPhone 4S";
    if ([phoneModel isEqualToString:@"iPhone5,1"] ||
        [phoneModel isEqualToString:@"iPhone5,2"])   return @"iPhone 5";
    if ([phoneModel isEqualToString:@"iPhone5,3"] ||
        [phoneModel isEqualToString:@"iPhone5,4"])   return @"iPhone 5C";
    if ([phoneModel isEqualToString:@"iPhone6,1"] ||
        [phoneModel isEqualToString:@"iPhone6,2"])   return @"iPhone 5S";
    if ([phoneModel isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    if ([phoneModel isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    if ([phoneModel isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    if ([phoneModel isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    if ([phoneModel isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    if ([phoneModel isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    if ([phoneModel isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    if ([phoneModel isEqualToString:@"iPhone10,1"] ||
        [phoneModel isEqualToString:@"iPhone10,4"]) return @"iPhone 8";
    if ([phoneModel isEqualToString:@"iPhone10,2"] ||
        [phoneModel isEqualToString:@"iPhone10,5"]) return @"iPhone 8 Plus";
    if ([phoneModel isEqualToString:@"iPhone10,3"] ||
        [phoneModel isEqualToString:@"iPhone10,6"]) return @"iPhone X";
    
    if ([phoneModel isEqualToString:@"iPad1,1"]) return @"iPad 1st";
    if ([phoneModel isEqualToString:@"iPad1,2"]) return @"iPad 3G";
    if ([phoneModel isEqualToString:@"iPad2,1"] ||
        [phoneModel isEqualToString:@"iPad2,2"] ||
        [phoneModel isEqualToString:@"iPad2,3"] ||
        [phoneModel isEqualToString:@"iPad2,4"]) return @"iPad 2";
    if ([phoneModel isEqualToString:@"iPad3,1"] ||
        [phoneModel isEqualToString:@"iPad3,2"] ||
        [phoneModel isEqualToString:@"iPad3,3"]) return @"iPad 3";
    if ([phoneModel isEqualToString:@"iPad3,4"] ||
        [phoneModel isEqualToString:@"iPad3,5"] ||
        [phoneModel isEqualToString:@"iPad3,6"]) return @"iPad 4";
    if ([phoneModel isEqualToString:@"iPad4,1"] ||
        [phoneModel isEqualToString:@"iPad4,2"] ||
        [phoneModel isEqualToString:@"iPad4,3"]) return @"iPad Air";
    if ([phoneModel isEqualToString:@"iPad5,3"] ||
        [phoneModel isEqualToString:@"iPad5,4"]) return @"iPad Air 2";
    if ([phoneModel isEqualToString:@"iPad6,3"] ||
        [phoneModel isEqualToString:@"iPad6,4"]) return @"iPad Pro 9.7-inch";
    if ([phoneModel isEqualToString:@"iPad6,7"] ||
        [phoneModel isEqualToString:@"iPad6,8"]) return @"iPad Pro 12.9-inch";
    if ([phoneModel isEqualToString:@"iPad6,11"] ||
        [phoneModel isEqualToString:@"iPad6,12"]) return @"iPad 5";
    if ([phoneModel isEqualToString:@"iPad7,1"] ||
        [phoneModel isEqualToString:@"iPad7,2"]) return @"iPad Pro 12.9-inch 2";
    if ([phoneModel isEqualToString:@"iPad7,3"] ||
        [phoneModel isEqualToString:@"iPad7,4"]) return @"iPad Pro 10.5-inch";
    if ([phoneModel isEqualToString:@"iPad7,5"] ||
        [phoneModel isEqualToString:@"iPad7,6"]) return @"iPad 2018";
    if ([phoneModel isEqualToString:@"iPad8,1"] ||
        [phoneModel isEqualToString:@"iPad8,2"] ||
        [phoneModel isEqualToString:@"iPad8,3"] ||
        [phoneModel isEqualToString:@"iPad8,4"]) return @"iPad Pro 11-inch";
    if ([phoneModel isEqualToString:@"iPad8,5"] ||
        [phoneModel isEqualToString:@"iPad8,6"] ||
        [phoneModel isEqualToString:@"iPad8,7"] ||
        [phoneModel isEqualToString:@"iPad8,8"]) return @"iPad Pro 12.9-inch 3rd";
    
    if ([phoneModel isEqualToString:@"iPad2,5"] ||
        [phoneModel isEqualToString:@"iPad2,6"] ||
        [phoneModel isEqualToString:@"iPad2,7"]) return @"iPad mini";
    if ([phoneModel isEqualToString:@"iPad4,4"] ||
        [phoneModel isEqualToString:@"iPad4,5"] ||
        [phoneModel isEqualToString:@"iPad4,6"]) return @"iPad mini 2";
    if ([phoneModel isEqualToString:@"iPad4,7"] ||
        [phoneModel isEqualToString:@"iPad4,8"] ||
        [phoneModel isEqualToString:@"iPad4,9"]) return @"iPad mini 3";
    if ([phoneModel isEqualToString:@"iPad5,1"] ||
        [phoneModel isEqualToString:@"iPad5,2"]) return @"iPad mini 4";
    
    if ([phoneModel isEqualToString:@"iPod1,1"]) return @"iTouch";
    if ([phoneModel isEqualToString:@"iPod2,1"]) return @"iTouch2";
    if ([phoneModel isEqualToString:@"iPod3,1"]) return @"iTouch3";
    if ([phoneModel isEqualToString:@"iPod4,1"]) return @"iTouch4";
    if ([phoneModel isEqualToString:@"iPod5,1"]) return @"iTouch5";
    if ([phoneModel isEqualToString:@"iPod7,1"]) return @"iTouch6";
    
    if ([phoneModel isEqualToString:@"i386"] || [phoneModel isEqualToString:@"x86_64"]) return @"iPhone Simulator";
    
    return @"iPad";
}
//获取当前的时间
- (NSString*)getCurrentTimes{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    
    return currentTimeString;
}
//获取收藏列表
- (void)loadAppData:(id)sender
               idNo:(NSString *)idNo
               type:(NSString *)type
        finishBlock:(void(^)(id responseObject, NSError *error))finishBlock{
    NSString *url = [NSString stringWithFormat:@"%@%@",SERVICE_URL,@"api/app/load-app-data"];
    NSLog(@"%@",url);
    if([BDTools isBlankString:idNo]){
        idNo = @"";
    }
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:url]];
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:CERNAME ofType:@"cer"];
    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    securityPolicy.allowInvalidCertificates=YES;
    securityPolicy.validatesDomainName = NO;
    securityPolicy.pinnedCertificates = [[NSSet alloc] initWithObjects:cerData,nil];
    manager.securityPolicy= securityPolicy;
    NSDictionary *parameters = @{@"idNo":idNo,@"type":type};
    
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 30;
    [manager GET:url parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        //NSLog(@"JSON: %@", [self dataToJson:responseObject]);
        finishBlock([BDTools jsonToData:responseObject],nil);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        //NSLog(@"Error: %@", error);
        finishBlock(nil,error);
    }];
}


//保存
- (void)saveAppData:(id)sender
               uuid:(NSString *)uuid
               idNo:(NSString *)idNo
               type:(NSString *)type
            content:(NSString *)content
        finishBlock:(void(^)(id responseObject, NSError *error))finishBlock{
    NSString *url = [NSString stringWithFormat:@"%@%@",SERVICE_URL,@"api/app/save-app-data"];
    NSLog(@"%@",url);
    if([BDTools isBlankString:idNo]){
        idNo = @"";
    }
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:url]];
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:CERNAME ofType:@"cer"];
    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    manager.securityPolicy= [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:[[NSSet alloc] initWithObjects:cerData,nil]];
    manager.securityPolicy.allowInvalidCertificates=YES;
    manager.securityPolicy.validatesDomainName = NO;
    NSDictionary *parameters = @{@"id":uuid,@"idNo":idNo,@"type":type,@"content":content};
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 30;
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        //NSLog(@"JSON: %@", [self dataToJson:responseObject]);
        //finishBlock([self dataToJson:responseObject],nil);
        finishBlock([BDTools jsonToData:responseObject],nil);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        //NSLog(@"Error: %@", error);
        finishBlock(nil,error);
    }];
}
-(NSDictionary *)dataToJson:(id)responseObject{
    NSMutableString *responseString;
    if ([responseObject isKindOfClass:[NSData class]]) {
        responseString = [[NSMutableString alloc] initWithData:(NSData *)responseObject  encoding:NSUTF8StringEncoding];
    }
    else if ([responseObject isKindOfClass:[NSString class]])
    {
        responseString = responseObject;
    }
    
    if (responseString == nil) {
        return nil;
    }
    NSData *jsonData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

#pragma mark- 网络相关
-(void)networkStatus {
    _statusManger = [AFNetworkReachabilityManager sharedManager];
    [_statusManger setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
            {
                NSLog(@"未识别的网络");
                if([BDNetServerDownLoadTool sharedTool].downLoadIng){
                    kPOP(@"网络请求失败！")
                    [BDNetServerDownLoadTool sharedTool].downLoadIng = NO;
                    [[ProgressView sharedView] dismissAnimated:YES completion:nil];
                }
            }
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
            {
                NSLog(@"不可达的网络(未连接)");
                if([BDNetServerDownLoadTool sharedTool].downLoadIng){
                    kPOP(@"网络请求失败！")
                    [BDNetServerDownLoadTool sharedTool].downLoadIng = NO;
                    [[ProgressView sharedView] dismissAnimated:YES completion:nil];
                }
            }
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
            {
                NSLog(@"2G,3G,4G...的网络");
                if(![BDNetServerDownLoadTool sharedTool].downLoadIng){
                    if ([BDNetServerDownLoadTool sharedTool].currentDownLoadUrl) {
//                        [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkChangedNotification object:@""];
                    }
                }
                
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                NSLog(@"WIFI的网络");
                if(![BDNetServerDownLoadTool sharedTool].downLoadIng){
                    if ([BDNetServerDownLoadTool sharedTool].currentDownLoadUrl) {
//                        [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkChangedNotification object:@""];
                    }
                }
            }
                break;
                
            default:
                break;
        }
    }];
    [_statusManger startMonitoring];
}

+(BOOL)isReachNetWork {
    BOOL isExistenceNetwork;
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch([reachability currentReachabilityStatus]){
        case NotReachable: isExistenceNetwork = FALSE;
            break;
        case ReachableViaWWAN: isExistenceNetwork = TRUE;
            break;
        case ReachableViaWiFi: isExistenceNetwork = TRUE;
            break;
    }
    return isExistenceNetwork;
}

+(BOOL)isReachIsWifi {
    BOOL isExistenceNetwork;
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch([reachability currentReachabilityStatus]){
        case NotReachable: isExistenceNetwork = FALSE;
            break;
        case ReachableViaWWAN: isExistenceNetwork = FALSE;
            break;
        case ReachableViaWiFi: isExistenceNetwork = TRUE;
            break;
    }
    return isExistenceNetwork;
}

//获取爱招募代理人信息
- (void)loadAiZhaoMuData:(id)sender completionHandler:(void (^)(BDBaseResutInfo *))completionBlock errorHandler:(BDErrorBlock)errorBlock{
    NSString *url = [NSString stringWithFormat:@"%@%@",ROOT_URL,@"nbs-eopening/agent/personCard"];
    NSLog(@"%@",url);
    [self requestWithGetURL:url parameters:nil completionHandler:^(BDBaseResutInfo *info) {
        completionBlock(info);
    } errorHandler:^(NSURLSessionDataTask *operation, NSError *error) {
        errorBlock(operation,error);
    }];
}

@end

