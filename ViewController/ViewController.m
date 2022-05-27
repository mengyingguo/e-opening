//
//  ViewController.m
//  DownLoadTest
//
//  Created by 枫叶砂 on 2018/3/29.
//  Copyright © 2018年 Quarkdata. All rights reserved.
//
// 保存后台返回的东西以及本地存储的地址
// 进度条
// js交互然后再下载保存、进度条
// 每次刷新home的时候：是否需要立即更新并刷新页面 后台更新不需要刷新页面，这样不影响用户的操作、


//#define IMAP_URL_LOGIN @"IMAP2Demo://LoginViewController?scheme=eOpening&schemeName=eOpening"
#define IMAP_URL_LOGIN @"IMAP2Demo://LoginViewController?scheme=eOpening&schemeName=eOpening"
#define IMAP_URL_DOWNLOAD_ADDRESS @"https://appstore.metlife.com.cn/imapstore"
#define IMAP_URL_FPLAN @"IMAP2Demo://?targetPage=finance"
#define IMAP_URL_MAIN @"IMAP2Demo://?targetPage=main"
#define EOPENING_URL_DOWNLOAD_ADDRESS @"itms-services:///?action=download-manifest&url=https://appstore.metlife.com.cn/appstore/eopening.plist"
#define POP_ALERT_DELAY_TIME 0.3
#define ALERT_UPDATE_TAG 1000
#define ALERT_IMPALOGIN_TAG 1001
#define ALERT_IMPADOWN_TAG 1002
#define ALERT_OLDDOWN_TAG 1003

#define WEBURL @"https://www.jianshu.com"

#import "ViewController.h"
#import "ProgressView.h"
#import "CollectionView.h"
#import "PopUpView.h"
#import "LKDBHelper.h"
#import "CollectionModel.h"
#import "UIImage+ZXJCompressionImage.h"
#import "SRDownloadManager.h"
#import <WebKit/WebKit.h>

@interface ViewController ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler,UIAlertViewDelegate,CollectionViewDelegate>
{
    NSString *saveImage;
    NSString  *downLoadUrl;
    NSURL *fileUrl;
    NSURLSessionDownloadTask *task;
    BOOL isRefresh;
    UIAlertController *loginAlertVC;
    UIAlertController *imapAlertVC;
    UIAlertController *updateAlertVC;
    UIAlertController *oldUpdateAlertVC;
    UIAlertController *appAlertVC;
    UIAlertController *h5AlertVC;
    NSString *offectY;
    NSString *mainTitle;
    NSString *subTitle;
    UIImageView *startPageImgv;
    NSInteger downErrorCount;
    UILabel *versionLab;
    
}
@property (nonatomic , strong) WKWebView *webView;

@property (nonatomic, strong)LKDBHelper *dbHelper;
@property (nonatomic, strong)NSString *filePath;
@end

@implementation ViewController

- (void)dealloc{
    //释放通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    [self refreshAndDownload];
    if (self.webView.title == nil) {
        [self.webView reload];
    }
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"loadAiZhaoMuUserdata"];
    
  
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"loadAiZhaoMuUserdata"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
//    NSString * token = @"eyJhbGciOiJIUzUxMiJ9.eyJhdXRoX3R5cGUiOiJhZ3QiLCJhZ2VudF9uYW1lIjoi5YiY5pmT6bilIiwidXNlcl9rZXkiOiJmYzJhYTZlNy0yMTRlLTQzZjctYjM4Ny1lYmMyMTRiMWEwOGEiLCJhZ2VudF9jb2RlIjoiODYwMTAwMDM3NSJ9.IsbVhwHbYb_LCr1EJKdLvnTWydltrlkCiFyqO3-AKOJvILLuHVJQLrzsP7xiWmK22t9clwD4AxQHXLpWNPP5XQ";
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults setObject:token forKey:@"access_token"];
//    [userDefaults synchronize];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startDownload) name:kNetworkChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAndDownload) name:kDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openIMAP) name:kHomeOpenImapNotification object:nil];
    
    [self goToHomeIndex];
    //    [self loadAppData];
}
-(void)initUI{
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];
    versionLab = [[UILabel alloc] init];
    [self.webView addSubview:versionLab];
    versionLab.textColor = [UIColor lightGrayColor];
    [versionLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.equalTo(_webView);
    }];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [versionLab setText:[NSString stringWithFormat:@"当前版本号为:%@",app_Version]];
    
    
    //    NSString *path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"dist"];
    //    NSURL *fileURL = [NSURL fileURLWithPath:path];
    //    if (@available(iOS 9.0, *)) {
    //        [_webView loadFileURL:fileURL allowingReadAccessToURL:fileURL.URLByDeletingLastPathComponent];
    //    } else {
    //        // Fallback on earlier versions
    //    }
    //    [_webView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//前往home网页
-(void)goToHomeIndex{
    if(startPageImgv){
        startPageImgv.alpha = 0;
    }
    //加载一个遮罩界面
    [self addStartupPageView];
        NSString *newPath = [[BDNetServerDownLoadTool sharedTool] getIndexFileLocal];
//    NSString *newPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"dist"];
    if(newPath.length>1){
        
        NSURL *fileURL = [NSURL fileURLWithPath:newPath];
        if (@available(iOS 9.0, *)) {
            [_webView loadFileURL:fileURL allowingReadAccessToURL:fileURL.URLByDeletingLastPathComponent];
        } else {
            // Fallback on earlier versions
        }
        [self closeStartupPageView];
        
        
    }else{
        kPOP(@"未下载网页模块");
        
    }
}

#pragma Action
//是否登录
-(BOOL)loginAction{
    if([self isLogin]){
        if([self isConversationOut]){
            return NO;
        }
    }else{
        return NO;
    }
    return YES;
}
//判断是否存在imap
-(BOOL)isHaveImap{
    NSURL *turnUrl = [NSURL URLWithString:IMAP_URL_LOGIN];
    if (![[UIApplication sharedApplication] canOpenURL:turnUrl]) {
        return NO;
    }
    return YES;
}

//判断是否存在旧版本
-(BOOL)isHaveOldVersion{
    //下载超过12个小时 直接放弃
    if(!get_sp(@"historyTime")){
        set_sp(@"historyTime", [BDTools getTimeStamp]);
    }
    NSMutableDictionary *breakpointHistoryDictionary = (NSMutableDictionary *)[[BDNetServerDownLoadTool sharedTool] breakpointHistoryDictionary];
    NSMutableDictionary *dictData = breakpointHistoryDictionary[@"dicData"];
    NSString *key = [dictData allKeys][0];
    if([[SRDownloadManager sharedManager] fileHasDownloadedProgressOfURL:[NSURL URLWithString:key]]>0){
        if(([get_sp(@"historyTime") integerValue]+12*3600)<=[[BDTools getTimeStamp] integerValue] && [[key lastPathComponent] isEqualToString:@"fullPackage.zip"]){
            set_sp(@"historyTime", [BDTools getTimeStamp]);
            [[SRDownloadManager sharedManager] deleteFileOfURL:[NSURL URLWithString:key]];
            [[BDNetServerDownLoadTool sharedTool] setBreakpointHistoryDictionaryToNil];
            return NO;
        }
        return YES;
    }
    return NO;
}

//去登录
-(void)goToLogin{
    [self cancelAllAlert];
    if ([BDHttpService isReachNetWork]) {
        //登录失效 校验凭证时候失效
        //没有接口直接跳转
        //任务放到哪个队列中执行
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        double delay = POP_ALERT_DELAY_TIME; // 延迟多少秒
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), queue, ^{
            if (@available(iOS 8.0, *)) {
                loginAlertVC = [UIAlertController alertControllerWithTitle:@"警告" message:@"使用权限已过期，是否需要重新登录？" preferredStyle:UIAlertControllerStyleAlert];
                //[self.loginAlertVC.view setTag:1001];
                UIAlertAction *go = [UIAlertAction actionWithTitle: @"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* action) {
                    if (startPageImgv.alpha) {
                        [self closeStartupPageView];
                    }
                    NSURL *turnUrl = [NSURL URLWithString:IMAP_URL_LOGIN];
                    if ([[UIApplication sharedApplication] canOpenURL:turnUrl]) {
                        if (@available(iOS 10.0,*)) {
                            [[UIApplication sharedApplication] openURL:turnUrl options:@{} completionHandler:nil];
                        }
                        else
                        {
                            [[UIApplication sharedApplication] openURL:turnUrl];
                        }
                    }
                }];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle: @"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
                }];
                [loginAlertVC addAction:go];
                [loginAlertVC addAction:cancel];
                [self presentViewController:loginAlertVC animated:true completion:nil];
                
            }
            else{
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"警告" message:@"使用权限已过期，是否需要重新登录？" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
                alertView.tag = ALERT_IMPALOGIN_TAG;
                [alertView show];
            }
        });
    }else{
        //kPOP(@"网络请求失败");
        [self closeStartupPageView];
    }
}
//去下载imap
-(void)goToDwonImap{
    [self cancelAllAlert];
    if ([BDHttpService isReachNetWork]) {
        double delay = POP_ALERT_DELAY_TIME; // 延迟多少秒
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (@available(iOS 8.0, *)) {
                imapAlertVC = [UIAlertController alertControllerWithTitle:@"警告" message:@"未找到iMapApp，是否否前往下载？" preferredStyle:UIAlertControllerStyleAlert];
                //[self.loginAlertVC.view setTag:1001];
                UIAlertAction *go = [UIAlertAction actionWithTitle: @"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* action) {
                    if (startPageImgv.alpha) {
                        [self closeStartupPageView];
                    }
                    NSURL *turnUrl = [NSURL URLWithString:IMAP_URL_DOWNLOAD_ADDRESS];
                    if ([[UIApplication sharedApplication] canOpenURL:turnUrl]) {
                        if (@available(iOS 10.0,*)) {
                            [[UIApplication sharedApplication] openURL:turnUrl options:@{} completionHandler:nil];
                        }
                        else
                        {
                            [[UIApplication sharedApplication] openURL:turnUrl];
                        }
                    }
                }];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle: @"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
                }];
                [imapAlertVC addAction:go];
                [imapAlertVC addAction:cancel];
                [self presentViewController:imapAlertVC animated:true completion:nil];
                
            }
            else{
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"警告" message:@"未找到iMapApp，是否否前往下载？" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                alertView.tag = ALERT_IMPADOWN_TAG;
                [alertView show];
            }
        });
    }else{
        [self closeStartupPageView];
        //kPOP(@"网络请求失败");
    }
}
//是否下载旧版本
-(void)goToDwonOldZip{
    [self cancelAllAlert];
    if ([BDHttpService isReachNetWork]) {
        double delay = POP_ALERT_DELAY_TIME; // 延迟多少秒
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (@available(iOS 8.0, *)) {
                oldUpdateAlertVC = [UIAlertController alertControllerWithTitle:@"警告" message:@"您有旧版本下载，是否前去下载？" preferredStyle:UIAlertControllerStyleAlert];
                //[self.loginAlertVC.view setTag:1001];
                UIAlertAction *go = [UIAlertAction actionWithTitle: @"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* action) {
                    if (startPageImgv.alpha) {
                        [self closeStartupPageView];
                    }
                    [self startDownload];
                }];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle: @"放弃下载" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
                    NSMutableDictionary *breakpointHistoryDictionary = [[BDNetServerDownLoadTool sharedTool] breakpointHistoryDictionary];
                    NSMutableDictionary *dicData = breakpointHistoryDictionary[@"dicData"];
                    NSString *key = [dicData allKeys][0];
                    [[SRDownloadManager sharedManager] deleteFileOfURL:[NSURL URLWithString:key]];
                    [[BDNetServerDownLoadTool sharedTool] setBreakpointHistoryDictionaryToNil];
                    [self closeStartupPageView];
                }];
                [oldUpdateAlertVC addAction:go];
                [oldUpdateAlertVC addAction:cancel];
                [self presentViewController:oldUpdateAlertVC animated:true completion:nil];
                
            }
            else{
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"警告" message:@"您有旧版本下载，是否前去下载？" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"放弃下载", nil];
                alertView.tag = ALERT_OLDDOWN_TAG;
                [alertView show];
            }
        });
    }else{
        //kPOP(@"网络请求失败");
        [self closeStartupPageView];
    }
}
//判断更新后前去下载
-(void)isUpdateAndGotoDownload{
    [self cancelAllAlert];
    if ([BDHttpService isReachNetWork]) {
        [self.activityIndicator startAnimating];
        double delay = POP_ALERT_DELAY_TIME; // 延迟多少秒
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[BDHttpService shareInstance] loadVersion:nil completionHandler:^(BDBaseResutInfo *info) {
                [self.activityIndicator stopAnimating];
                if (info.code != 200) {
                    kPOP(info.msg);
                    return;
                }
                NSArray *zipArray = [[BDNetServerDownLoadTool sharedTool] getVersionList:info];
                BOOL appcurVersionFlag = [info.data[@"curAppVersion"][@"forceUpdateFlag"] boolValue];
                NSString *appupatedesc = info.data[@"curAppVersion"][@"upatedesc"];
                NSString *appversion = info.data[@"curAppVersion"][@"version"];
                NSString *curVersion = [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleShortVersionString"];

                NSString *h5version = info.data[@"curH5Version"][@"version"];
//                NSString *h5unzipPwd = info.data[@"curH5Version"][@"unzipPwd"];
                NSString *h5upatedesc = info.data[@"curH5Version"][@"upatedesc"];
//                NSString *h5downloadUrl = info.data[@"curH5Version"][@"downloadUrl"];
                BOOL h5curVersionFlag = [info.data[@"curH5Version"][@"forceUpdateFlag"] boolValue];
                NSString *h5CurVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"localCachingH5Version"];;
                
                //提示是否前往更新
                if(appcurVersionFlag && (![appversion isEqualToString:curVersion])){
                    appAlertVC = [UIAlertController alertControllerWithTitle:@"提示" message:appupatedesc preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *go = [UIAlertAction actionWithTitle: @"前往下载" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
                        NSURL *turnUrl = [NSURL URLWithString:EOPENING_URL_DOWNLOAD_ADDRESS];
                        if ([[UIApplication sharedApplication] canOpenURL:turnUrl]) {
                            if (@available(iOS 10.0,*)) {
                                [[UIApplication sharedApplication] openURL:turnUrl options:@{} completionHandler:nil];
                            }
                            else
                            {
                                [[UIApplication sharedApplication] openURL:turnUrl];
                            }
                        }else{
                            kPOP(@"未找到下载地址");
                        }
                    }];
                    [appAlertVC addAction:go];
                    [self presentViewController:appAlertVC animated:true completion:nil];
                }else if(h5curVersionFlag && (![h5version isEqualToString:h5CurVersion])){
                    h5AlertVC = [UIAlertController alertControllerWithTitle:@"提示" message:h5upatedesc preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *go = [UIAlertAction actionWithTitle: @"前往下载" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
                        [self downLoadH5Zip];
                    }];
                    [h5AlertVC addAction:go];
                    [self presentViewController:h5AlertVC animated:true completion:nil];
                }else{
                    //提示是否前往更新
                    if(zipArray.count > 0 && ![h5version isEqualToString:h5CurVersion] && !h5curVersionFlag){
                        if (@available(iOS 8.0, *)) {
                            updateAlertVC = [UIAlertController alertControllerWithTitle:@"提示" message:h5upatedesc preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *go = [UIAlertAction actionWithTitle: @"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* action) {
                                [self downLoadH5Zip];
                            }];
                            UIAlertAction *cancel = [UIAlertAction actionWithTitle: @"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
                                NSString *newPath = [[BDNetServerDownLoadTool sharedTool] getIndexFileLocal];
                                NSFileManager *manager = [NSFileManager  defaultManager];
                                if ([manager fileExistsAtPath:newPath]) {
                                    NSURL *fileURL = [NSURL fileURLWithPath:newPath];
                                    if (@available(iOS 9.0, *)) {
                                        [_webView loadFileURL:fileURL allowingReadAccessToURL:fileURL.URLByDeletingLastPathComponent];
                                    } else {
                                        // Fallback on earlier versions
                                    }
                                    [self closeStartupPageView];
                                }
                            }];
                            [updateAlertVC addAction:go];
                            [updateAlertVC addAction:cancel];
                            [self presentViewController:updateAlertVC animated:true completion:nil];
                        }
                        
                    }else{
                        NSLog(@"没有更新");
                        [self closeStartupPageView];
                        [self.activityIndicator stopAnimating];
                    }
                }
                
            } errorHandler:^(NSURLSessionDataTask *operation, NSError *error) {
                [self closeStartupPageView];
                [self.activityIndicator stopAnimating];
                kPOPERROR(error);
                //                kPOP(@"网络请求失败");
            }];
        });
    }
    else{
        [self closeStartupPageView];
        kPOP(@"网络请求失败，请检查网络配置！");
    }
}
-(void)cancelAllAlert{
    if(appAlertVC){
        [appAlertVC dismissViewControllerAnimated:YES completion:^{
            appAlertVC = nil;
        }];
    }
    if(h5AlertVC){
        [h5AlertVC dismissViewControllerAnimated:YES completion:^{
            h5AlertVC = nil;
        }];
    }
    if(updateAlertVC){
        [updateAlertVC dismissViewControllerAnimated:YES completion:^{
            updateAlertVC = nil;
        }];
    }
    if(oldUpdateAlertVC){
        [oldUpdateAlertVC dismissViewControllerAnimated:YES completion:^{
            oldUpdateAlertVC = nil;
        }];
    }
    if(imapAlertVC){
        [imapAlertVC dismissViewControllerAnimated:YES completion:^{
            imapAlertVC = nil;
        }];
        //imapAlertVC = nil;
    }
    if(loginAlertVC){
        [loginAlertVC dismissViewControllerAnimated:YES completion:^{
            loginAlertVC = nil;
        }];
    }
}

//刷新和下载
-(void)refreshAndDownload{
    //    是否存在imap
    //    if(![self isHaveImap]){
    //        [self goToDwonImap];
    //        return;
    //    }
    //    是否登录
    //    if(![self loginAction]){
    //        [self goToLogin];
    //        return;
    //    }
    //如果在下载，是->返回
    if([[BDNetServerDownLoadTool sharedTool] downLoadIng]){
        return;
    }
    //是否有旧版本
    //    if([self isHaveOldVersion]){
    //        [self goToDwonOldZip];
    //        return;
    //    }
  
    [self isUpdateAndGotoDownload];  //热更新要放开，静态h5暂时注释
    [self loadAiZhaoMuUserdata];

}
//下载h5版本zip
- (void)downLoadH5Zip{
    //打开下载进度条界面
    if([BDHttpService isReachNetWork]){
        [ProgressView sharedView].progress = 0;
        [ProgressView sharedView].measureNetLabel.text = @"下载速度:0KB/秒";
    }
    //
    __block NSDate *currentDate = [NSDate date];
    __block NSInteger currentSize = 0.0;
    __block BOOL stap;
    [[BDNetServerDownLoadTool sharedTool] getAppAndH5Version:nil dProgress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if((expectedSize/1024.0/1024.0)>[BDTools getFreeSize]){
                [[ProgressView sharedView] dismissAnimated:YES completion:nil];
                [self closeStartupPageView];
                [[BDNetServerDownLoadTool sharedTool] stopAllDownLoadTasks];
                kPOP(@"设备内存不足");
            }
            if([[NSDate date] timeIntervalSinceDate:currentDate] > 1 && !stap){
                stap = YES;
                currentDate = [NSDate date];
                currentSize = receivedSize;
            }
            if([[NSDate date] timeIntervalSinceDate:currentDate] > 2){
                long long int s = (receivedSize - currentSize) /[[NSDate date] timeIntervalSinceDate:currentDate];
                [ProgressView sharedView].measureNetLabel.text = [NSString stringWithFormat:@"下载速度:%@",[BDTools formatNetWork:s]];
                currentDate = [NSDate date];
                currentSize = receivedSize;
            }
            [ProgressView sharedView].progress = progress;
            NSLog(@"%.6f",progress);
            if(progress > 0.999){
                stap = NO;
                [ProgressView sharedView].progressLabel.text = @"文件解压中...";
                [ProgressView sharedView].measureNetLabel.text = @"";
            }
        });
    } dSuccessBlock:^(NSURL *fileUrlPath) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[ProgressView sharedView] dismissAnimated:YES completion:nil];
            [self goToHomeIndex];
        });
    } dfailBlock:^(NSError *error, NSInteger statusCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(statusCode == -1000){
                [self startDownload];
            }else{
                //                kPOP(@"网络请求失败");
                kPOPERROR(error);
                [[ProgressView sharedView] dismissAnimated:YES completion:nil];
                [self closeStartupPageView];
            }
            
        });
    } completionLocalUrlHandler:^(NSString *localUrl) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[ProgressView sharedView] dismissAnimated:YES completion:nil];
        });
    }];
}
//继续下载
-(void)startDownload{
    NSMutableDictionary *breakpointHistoryDictionary = (NSMutableDictionary *)[[BDNetServerDownLoadTool sharedTool] breakpointHistoryDictionary];
    NSMutableDictionary *dicData = breakpointHistoryDictionary[@"dicData"];
    NSMutableDictionary *dicVersion = breakpointHistoryDictionary[@"dicList"];
    NSString *key = [dicData allKeys][0];
    // 下载的版本号为
    NSString *curVersion = [dicVersion objectForKey:@"curVersion"];
    //解压密码
    NSString *password = [dicVersion objectForKey:@"password"];
    // 解压的文件位置
    NSString *unZipFileLocal = [[BDNetServerDownLoadTool sharedTool] unzipFileLocalWithVersion:curVersion];
    //打开下载进度条界面
    if([BDHttpService isReachNetWork]){
        [ProgressView sharedView].progress = [[SRDownloadManager sharedManager] fileHasDownloadedProgressOfURL:[NSURL URLWithString:key]];
        [ProgressView sharedView].measureNetLabel.text = @"下载速度:0KB/秒";
    }
    [[BDNetServerDownLoadTool sharedTool] setCurrentDownLoadUrl:key];
    [[BDNetServerDownLoadTool sharedTool] setDownLoadIng:YES];
    __block NSDate *currentDate = [NSDate date];
    __block NSInteger currentSize = 0.0;
    __block BOOL stap;
    [[SRDownloadManager sharedManager] downloadFileOfURL:[NSURL URLWithString:key]
                                                   state:^(SRDownloadState state) {}
                                                progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if((expectedSize/1024.0/1024.0)>[BDTools getFreeSize]){
                [[ProgressView sharedView] dismissAnimated:YES completion:nil];
                [self closeStartupPageView];
                [[BDNetServerDownLoadTool sharedTool] stopAllDownLoadTasks];
                kPOP(@"设备内存不足");
            }
            if([[NSDate date] timeIntervalSinceDate:currentDate] > 1 && !stap){
                stap = YES;
                currentDate = [NSDate date];
                currentSize = receivedSize;
            }
            if([[NSDate date] timeIntervalSinceDate:currentDate] > 2){
                long long int s = (receivedSize - currentSize)/[[NSDate date] timeIntervalSinceDate:currentDate];
                [ProgressView sharedView].measureNetLabel.text = [NSString stringWithFormat:@"下载速度:%@",[BDTools formatNetWork:s]];
                currentDate = [NSDate date];
                currentSize = receivedSize;
            }
            [ProgressView sharedView].progress = progress;
            NSLog(@"%.6f",progress);
            if(progress > 0.999){
                [ProgressView sharedView].progressLabel.text = @"文件解压中...";
                [ProgressView sharedView].measureNetLabel.text = @"";
            }
        });
    }
                                              completion:^(BOOL success, NSString *filePath, NSError *error) {
        if (success) {
            NSLog(@"FilePath: %@", filePath);
            NSString *currenVersion = [[BDTools getCurH5Version] floatValue]>0?[BDTools getCurH5Version]:@"0.00";
            [[BDNetServerDownLoadTool sharedTool] fixIndexFileNameWithVersion:currenVersion toVersion:curVersion];
            if ([[BDNetServerDownLoadTool sharedTool] unzipFile:filePath withDstPath:unZipFileLocal password:password]) {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:curVersion forKey:@"localCachingH5Version"];
                [userDefaults synchronize];

                //保存下载的plist
                [[BDNetServerDownLoadTool sharedTool] downLoadHistoryDictionaryToSave:dicVersion curVersion:curVersion];
                [[BDNetServerDownLoadTool sharedTool] setBreakpointHistoryDictionaryToNil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[ProgressView sharedView] dismissAnimated:YES completion:nil];
                    [self goToHomeIndex];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[BDNetServerDownLoadTool sharedTool] fixIndexFileNameWithVersion:curVersion toVersion:currenVersion];
                    [[ProgressView sharedView] dismissAnimated:YES completion:nil];
                    [self closeStartupPageView];
                });
            }
            [[BDNetServerDownLoadTool sharedTool] setDownLoadIng:NO];
        } else {
            NSLog(@"Error: %@", error); //发送一个信号
            dispatch_async(dispatch_get_main_queue(), ^{
                if(downErrorCount>=20){
                    //                                                              kPOP(@"网络请求失败");
                    kPOPERROR(error);
                    downErrorCount = 0;
                    [[BDNetServerDownLoadTool sharedTool] setDownLoadIng:NO];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[ProgressView sharedView] dismissAnimated:YES completion:nil];
                        [self closeStartupPageView];
                    });
                    return ;
                }else{
                    downErrorCount++;
                    [[BDNetServerDownLoadTool sharedTool] stopAllDownLoadTasks];
                    [self startDownload];
                }
            });
        }
    }];
}

#pragma UI
- (void)addStartupPageView{
    UIImageView *imageView = [[UIImageView alloc] init];
    startPageImgv = imageView;
    [self.webView addSubview:imageView];
    [imageView setImage:[UIImage imageNamed:@"startPage"]];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
}
-(void)closeStartupPageView{
    [UIView animateWithDuration:0.35 animations:^{
        startPageImgv.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
}
-(UIActivityIndicatorView *)activityIndicator{
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
        [self.view addSubview:_activityIndicator];
        //设置小菊花的frame
        [_activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(20, 20));
            make.centerY.equalTo(self.view);
            make.centerX.equalTo(self.view);
        }];
        //设置小菊花颜色
        _activityIndicator.color = [UIColor grayColor];
        //设置背景颜色
        //_activityIndicator.backgroundColor = [UIColor cyanColor];
    }
    return _activityIndicator;
}

- (WKWebView *)webView {
    if (_webView == nil) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        //设置是否允许画中画技术 在特定设备上有效
        if (@available(iOS 9.0, *)) {
            configuration.allowsPictureInPictureMediaPlayback = YES;
        } else {
            // Fallback on earlier versions
        }
        //这个类主要用来做native与JavaScript的交互管理
        WKUserContentController * wkUController = [[WKUserContentController alloc] init];
        //以下代码适配文本大小，由UIWebView换为WKWebView后，会发现字体小了很多，这应该是WKWebView与html的兼容问题，解决办法是修改原网页，要么我们手动注入JS
        NSString *jSString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
        //用于进行JavaScript注入
        WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jSString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        [configuration.userContentController addUserScript:wkUScript];
        //注册一个name为jsToOcNoPrams的js方法
        //        [wkUController addScriptMessageHandler:self name:@"jsToOc"];
        configuration.userContentController = wkUController;
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = YES;
        configuration.preferences.javaScriptEnabled = true; //支持JavaScript
        [configuration.preferences setValue:@YES forKey:@"allowFileAccessFromFileURLs"];//支持跨域
        
        //! 使用configuration对象初始化webView
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
        
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        _webView.scrollView.bounces = NO;
        _webView.allowsBackForwardNavigationGestures = YES;
        
        
    }
    return _webView;
}

-(void)loadAppData{
    if ([BDTools isBlankString:[FTDKeyChain load:KEYCHAIN_UUID]]) {
        NSString *identifierStr = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [FTDKeyChain save:KEYCHAIN_UUID data:identifierStr];
    }
    
    if([self loginAction]){
        //加载收藏（自动）
        [[BDHttpService shareInstance] loadAppData:nil idNo:[FTDKeyChain load:KEYCHAIN_LOGININFO_AGENTCODE] type:@"collection" finishBlock:^(id responseObject, NSError *error) {
            if([responseObject[@"success"] integerValue]==1){
                NSString *content = @"";
                if([responseObject[@"data"][@"flag"] integerValue]==1){
                    NSString *agentCode = [BDTools isBlankString:[FTDKeyChain load:KEYCHAIN_LOGININFO_AGENTCODE]]?[FTDKeyChain load:KEYCHAIN_UUID]:[FTDKeyChain load:KEYCHAIN_LOGININFO_AGENTCODE];
                    BOOL isDeleteMore=[self.dbHelper deleteWithClass:[CollectionModel class] where:[NSString stringWithFormat:@"agentCode = '%@'",agentCode]];
                    if(isDeleteMore){
                        content = responseObject[@"data"][@"appData"][@"content"];
                        NSArray *dataArr = [BDTools jsonToObject:content];
                        
                        for (int i  = 0; i<dataArr.count; i++) {
                            NSDictionary *obj = dataArr[i];
                            CollectionModel *model = [[CollectionModel alloc] init];
                            model.mainTitle = obj[@"mainTitle"];
                            model.subTitle = obj[@"subTitle"];
                            model.time = obj[@"time"];
                            model.date = obj[@"date"];
                            model.dateTime = obj[@"dateTime"];
                            model.imgData = obj[@"imgData"];
                            model.agentCode = obj[@"agentCode"];
                            model.currentUrl = obj[@"currentUrl"];
                            [self saveImage:obj[@"imgData"] imageName:obj[@"dateTime"]];
                            [self.dbHelper insertToDB:model];
                        }
                    }
                }
            }
            else{
                kPOP(responseObject[@"errorMsg"]);
            }
        }];
    }
    
    //    //更新收藏（手动）
    //    [bridge registerHandler:@"loadAppData" handler:^(id data, WVJBResponseCallback responseCallback) {
    //        NSLog(@"loadAppData called: %@", data);
    //        if(![self loginAction]){
    //            [self collectionViewCancelPressed:nil];
    //            [self goToLogin];
    //            return;
    //        }
    //        if([BDTools isBlankString:data[@"mainTitle"]]){
    //            mainTitle = @"暂无";
    //        }
    //        if([BDTools isBlankString:data[@"subTitle"]]){
    //            subTitle = @"暂无";
    //        }
    //        CollectionView *collection = [[CollectionView alloc] initWithOffsetY:[data[@"offectY"] integerValue]];
    //        collection.delegate = self;
    //        collection.offectY = [data[@"offectY"] integerValue];
    //        offectY = data[@"offectY"];
    //        mainTitle = data[@"mainTitle"];
    //        subTitle = data[@"subTitle"];
    //        [self presentPopupView:collection animationType:PopupViewAnimationFadeSlideRight];
    //    }];
    //
    //    //跳转财务规划
    //    [bridge registerHandler:@"jumpFinancialplan" handler:^(id data, WVJBResponseCallback responseCallback) {
    //        NSURL *turnUrl = [NSURL URLWithString:IMAP_URL_FPLAN];
    //        if ([[UIApplication sharedApplication] canOpenURL:turnUrl]) {
    //            if (@available(iOS 10.0,*)) {
    //                [[UIApplication sharedApplication] openURL:turnUrl options:@{} completionHandler:nil];
    //            }
    //            else
    //            {
    //                [[UIApplication sharedApplication] openURL:turnUrl];
    //            }
    //        }else{
    //            [self goToDwonImap];
    //        }
    //    }];
    //
    //    //跳转首页
    //    [bridge registerHandler:@"jumpImapMain" handler:^(id data, WVJBResponseCallback responseCallback) {
    //        NSURL *turnUrl = [NSURL URLWithString:IMAP_URL_MAIN];
    //        if ([[UIApplication sharedApplication] canOpenURL:turnUrl]) {
    //            if (@available(iOS 10.0,*)) {
    //                [[UIApplication sharedApplication] openURL:turnUrl options:@{} completionHandler:nil];
    //            }
    //            else
    //            {
    //                [[UIApplication sharedApplication] openURL:turnUrl];
    //            }
    //        }else{
    //            [self goToDwonImap];
    //        }
    //    }];
}
-(void)openIMAP{
    NSURL *turnUrl = [NSURL URLWithString:IMAP_URL_MAIN];
    if ([[UIApplication sharedApplication] canOpenURL:turnUrl]) {
//        if (@available(iOS 10.0,*)) {
//            [[UIApplication sharedApplication] openURL:turnUrl options:@{} completionHandler:nil];
//        }
//        else
//        {
//            [[UIApplication sharedApplication] openURL:turnUrl];
//        }
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"警告" message:@"使用权限已过期，是否需要重新登录？" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        alertView.tag = ALERT_IMPALOGIN_TAG;
        [alertView show];
        
    }else{
        [self goToDwonImap];
    }
}
//截图保存
-(NSString *)saveImage:(NSString *)imageName rect:(CGRect)rect{
    //截图
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0.0);
    [self.webView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGRect clipFrame = rect;//CGRectMake(0, 132, SCREEN_WIDTH*2, SCREEN_HEIGHT*2-132);
    CGImageRef refImage = CGImageCreateWithImageInRect(image.CGImage, clipFrame);
    UIImage *newImage = [UIImage imageWithCGImage:refImage];
    CGImageRelease(refImage);
    NSData *decodedImageData = [UIImage compressImage:newImage];//UIImageJPEGRepresentation(newImage, 1.0f);
    //将图片的data转化为字符串
    NSString *strimage64 = [decodedImageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    //saveImage = strimage64;
    NSString *filePath = [BDTools locationOfScreenshotsSaved];
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@.jpg",filePath,imageName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        if ([decodedImageData writeToFile:imagePath atomically:YES]) {
            NSLog(@"写入成功");
        };
    }else{
        if([fileManager createDirectoryAtPath:[imagePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil]){
            if ([decodedImageData writeToFile:imagePath atomically:YES]) {
                NSLog(@"写入成功");
            };
        }
    }
    return strimage64;
}
-(void)saveImage:(NSString *)base64Str imageName:(NSString *)imageName{
    NSData *decodedImageData = [[NSData alloc]initWithBase64EncodedString:base64Str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSString *filePath = [BDTools locationOfScreenshotsSaved];
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@.jpg",filePath,imageName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        if ([decodedImageData writeToFile:imagePath atomically:YES]) {
            NSLog(@"写入成功");
        };
    }else{
        if([fileManager createDirectoryAtPath:[imagePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil]){
            if ([decodedImageData writeToFile:imagePath atomically:YES]) {
                NSLog(@"写入成功");
            };
        }
    }
}

#pragma WKNavigationDelegate
//在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    if (navigationAction.targetFrame ==nil) {
        
        [webView loadRequest:navigationAction.request];
        
    }
    // 没有这一句页面就不会显示
    decisionHandler(WKNavigationActionPolicyAllow);
}
// 根据客户端受到的服务器响应头以及response相关信息来决定是否可以跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSString * urlStr = navigationResponse.response.URL.absoluteString;
    NSLog(@"当前跳转地址：%@",urlStr);
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationResponsePolicyCancel);
}
// 页面是弹出窗口 _blank 处理
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    //加载动画界面
    //[SVProgressHUD show];
    NSLog(@"开始加载");
    
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"加载失败；%@",error);
    
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    [self getCookie];
    NSLog(@"加载完成");
    //        NSString *htmlTitle = @"document.title";
    //        NSString *allHtmlInfo = [webView stringByEvaluatingJavaScriptFromString:htmlTitle];
    NSLog(@"title==%@",webView.title);
    if([webView.title isEqualToString:@"首页"]){
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        // app版本
        NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        NSString *h5_Version = [[BDTools getCurH5Version] floatValue]>0?[BDTools getCurH5Version]:@"0.00";
        [versionLab setText:[NSString stringWithFormat:@"当前版本号为:%@_%@",app_Version,h5_Version]];
        [versionLab setAlpha:1.0];
    }else{
        [versionLab setAlpha:0.0];
    }
    
}
//提交发生错误时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
}
//进程被终止时调用
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{
    [webView reload];
}

#pragma mark - WKScriptMessageHandler
//! WKWebView收到ScriptMessage时回调此方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    //JS调用OC
    if([message.name isEqualToString:@"loadAiZhaoMuUserdata"]){
        [self sendUserDataToJs];
    }
    
}
-(void)sendUserDataToJs{
    // 将结果返回给js
    NSDictionary * dic = [self getUserDataFunction];
    if (dic == nil) {
        return;
    }
    //    NSString * jsonStr = [BDTools objectToJson:dic];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"string2:%@",jsonStr);
    NSString *jsStr = [NSString stringWithFormat:@"getUserData('%@')",jsonStr];
    [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@----%@",result, error);
    }];
}

//- (void)webViewDidFinishLoad:(UIWebView *)webView
//{
//    [self closeStartupPageView];
//    //禁止长按 复制粘贴
//    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
//    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
//
//    NSString *htmlTitle = @"document.title";
//    NSString *allHtmlInfo = [webView stringByEvaluatingJavaScriptFromString:htmlTitle];
//    if([allHtmlInfo isEqualToString:@"首页"]){
//        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//        // app版本
//        NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
//        NSString *h5_Version = [[BDTools getCurH5Version] floatValue]>0?[BDTools getCurH5Version]:@"0.00";
//        [versionLab setText:[NSString stringWithFormat:@"当前版本号为:%@_%@",app_Version,h5_Version]];
//        [versionLab setAlpha:1.0];
//    }else{
//        [versionLab setAlpha:0.0];
//    }
//}
//解决 页面内跳转（a标签等）还是取不到cookie的问题
- (void)getCookie{
    
    //取出cookie
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    //js函数
    NSString *JSFuncString =
    @"function setCookie(name,value,expires)\
    {\
    var oDate=new Date();\
    oDate.setDate(oDate.getDate()+expires);\
    document.cookie=name+'='+value+';expires='+oDate+';path=/'\
    }\
    function getCookie(name)\
    {\
    var arr = document.cookie.match(new RegExp('(^| )'+name+'=([^;]*)(;|$)'));\
    if(arr != null) return unescape(arr[2]); return null;\
    }\
    function delCookie(name)\
    {\
    var exp = new Date();\
    exp.setTime(exp.getTime() - 1);\
    var cval=getCookie(name);\
    if(cval!=null) document.cookie= name + '='+cval+';expires='+exp.toGMTString();\
    }";
    
    //拼凑js字符串
    NSMutableString *JSCookieString = JSFuncString.mutableCopy;
    for (NSHTTPCookie *cookie in cookieStorage.cookies) {
        NSString *excuteJSString = [NSString stringWithFormat:@"setCookie('%@', '%@', 1);", cookie.name, cookie.value];
        [JSCookieString appendString:excuteJSString];
    }
    //执行js
    [_webView evaluateJavaScript:JSCookieString completionHandler:nil];
    
}
#pragma AlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *btnTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if(alertView.tag == ALERT_UPDATE_TAG){//是否去下载
        if ([btnTitle isEqualToString:@"取消"]) {
            NSString *path = [[BDNetServerDownLoadTool sharedTool] getIndexFileLocal];
            NSFileManager *manager = [NSFileManager  defaultManager];
            if ([manager fileExistsAtPath:path]) {
                NSURLRequest *request= [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
                [self.webView loadRequest:request];
            }
        }else if([btnTitle isEqualToString:@"确定"]){
            [self downLoadH5Zip];
        }
    }else if(alertView.tag == ALERT_IMPALOGIN_TAG){//是否去登录
        if ([btnTitle isEqualToString:@"取消"]) {
        }else if([btnTitle isEqualToString:@"确定"]){
            NSURL *turnUrl = [NSURL URLWithString:IMAP_URL_LOGIN];
            if ([[UIApplication sharedApplication] canOpenURL:turnUrl]) {
                if (@available(iOS 10.0,*)) {
                    [[UIApplication sharedApplication] openURL:turnUrl options:@{} completionHandler:nil];
                }
                else
                {
                    [[UIApplication sharedApplication] openURL:turnUrl];
                }
            }
        }
    }else if(alertView.tag == ALERT_IMPADOWN_TAG){
        if ([btnTitle isEqualToString:@"取消"]) {//是否存在impa，是->去下载
        }else if([btnTitle isEqualToString:@"确定"]){
            NSURL *turnUrl = [NSURL URLWithString:IMAP_URL_DOWNLOAD_ADDRESS];
            if ([[UIApplication sharedApplication] canOpenURL:turnUrl]) {
                if (@available(iOS 10.0,*)) {
                    [[UIApplication sharedApplication] openURL:turnUrl options:@{} completionHandler:nil];
                }
                else
                {
                    [[UIApplication sharedApplication] openURL:turnUrl];
                }
            }
        }
    }else if(alertView.tag == ALERT_OLDDOWN_TAG){
        if ([btnTitle isEqualToString:@"放弃下载"]) {//放弃下载
            NSMutableDictionary *breakpointHistoryDictionary = (NSMutableDictionary *)[[BDNetServerDownLoadTool sharedTool] breakpointHistoryDictionary];
            NSMutableDictionary *dicData = breakpointHistoryDictionary[@"dicData"];
            NSString *key = [dicData allKeys][0];
            [[SRDownloadManager sharedManager] deleteFileOfURL:[NSURL URLWithString:key]];
            [[BDNetServerDownLoadTool sharedTool] setBreakpointHistoryDictionaryToNil];
        }else if([btnTitle isEqualToString:@"确定"]){
            NSURL *turnUrl = [NSURL URLWithString:IMAP_URL_DOWNLOAD_ADDRESS];
            if ([[UIApplication sharedApplication] canOpenURL:turnUrl]) {
                [self startDownload];
            }
        }
    }
    
    
}
#pragma Keychain Verification
/**
 判断是否登录
 */
-(BOOL)isLogin{
    NSString *online = @"N";
    online = [FTDKeyChain load:KEYCHAIN_LOGININFO_STATUS];
    if([online isEqualToString:@"Y"]){
        return YES;
    }else{
        return NO;
    }
    return YES;
}
/**
 判断会话是否过期
 */
-(BOOL)isConversationOut{
    
    NSString *timestap = [FTDKeyChain load:KEYCHAIN_UPDATELOGININFO_TIME];
    //会话登录的时间+30天 < 当前时间的话 判断为过期
    if(([timestap integerValue]+30*24*3600)<[[BDTools getTimeStamp] integerValue]){
        return YES;
    }else{
        return NO;
    }
    return YES;
}
#pragma mark localDB
- (NSString *)filePath{
    if (!_filePath){
        NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        path = [path stringByAppendingPathComponent:SQLiteFile];
        NSFileManager *fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:path]) {
            [fm createFileAtPath:path contents:nil attributes:nil];
        }
        _filePath = path;
        NSLog(@"filePath %@", _filePath);
    }
    return _filePath;
}
- (LKDBHelper *)dbHelper{
    if (!_dbHelper){
        _dbHelper = [[LKDBHelper alloc] initWithDBPath:self.filePath];
    }
    return _dbHelper;
}
#pragma Collection Delegate
-(void)collectionViewCancelPressed:(UIButton *)button{
    [self dismissPopupViewController:PopupViewAnimationFadeSlideRight];
    //    [bridge callHandler:@"loadAppDataHandler" data:@{}];
}
-(void)collectionView:(id)collectionView saveCollectionPressed:(UIButton *)button{//get_sp(@"UUID")
    NSString *agentCode = [BDTools isBlankString:[FTDKeyChain load:KEYCHAIN_LOGININFO_AGENTCODE]]?[FTDKeyChain load:KEYCHAIN_UUID]:[FTDKeyChain load:KEYCHAIN_LOGININFO_AGENTCODE];
    //    NSString *currentUrl = [BDTools getRelativeUrlStr:[_webView stringByEvaluatingJavaScriptFromString:@"document.location.href"]];
    NSString *currentUrl = [BDTools getRelativeUrlStr:@""];
    [self.dbHelper search:[CollectionModel class] where:[NSString stringWithFormat:@"currentUrl = '%@' and agentCode = '%@'",currentUrl,agentCode] orderBy:@"dateTime desc" offset:0 count:1 callback:^(NSMutableArray * _Nullable array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //主线程执行
            if(array.count>0){
                kPOP(@"此页面已被收藏");
            }else{
                NSString *timeStamp = [BDTools getTimeStamp];
                CollectionView *cv = (CollectionView *)collectionView;
                CollectionModel *model = [[CollectionModel alloc] init];
                model.mainTitle = mainTitle;
                model.subTitle = subTitle;
                model.time = [BDTools getTimeStr];
                model.date = [BDTools getDateStr];
                model.dateTime = timeStamp;
                model.imgData =  [self saveImage:timeStamp rect:CGRectMake(0, [offectY integerValue]*2, SCREEN_WIDTH*2, SCREEN_HEIGHT*2-[offectY integerValue]*2)];
                model.agentCode = [FTDKeyChain load:KEYCHAIN_LOGININFO_AGENTCODE];
                model.currentUrl = currentUrl;
                [self.dbHelper insertToDB:model callback:^(BOOL result) {
                    [cv refreshDataIsSave:YES];
                }];
            }
        });
    }];
}
-(void)collectionViewJumpOtherHtml:(NSString *)urlStr{
    [self collectionViewCancelPressed:nil];
    NSString *newPath = [[BDNetServerDownLoadTool sharedTool] getIndexFileLocal];
    newPath = [NSString stringWithFormat:@"%@%@",[newPath substringWithRange:NSMakeRange(0, newPath.length-10)],urlStr];
    NSURL *url = [NSURL URLWithString:newPath];
    NSURLRequest *request= [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}


#pragma mark 获取爱招募代理人信息
-(void)loadAiZhaoMuUserdata{
    [[BDHttpService shareInstance] loadAiZhaoMuData:nil completionHandler:^(BDBaseResutInfo *info) {
        if (info.code == 200) {
            NSMutableDictionary * mdic = [[NSMutableDictionary alloc]initWithDictionary:info.data];
            [self saveUserDataFunction:mdic];
            
        }
    } errorHandler:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error);
        
    }];
    
}
- (void)saveUserDataFunction:(NSMutableDictionary *)dic {
    if ([[dic objectForKey:@"label"] isEqual:[NSNull null]]) {
        NSArray * arr = [[NSArray alloc]init];
        [dic setObject:arr forKey:@"label"];
    }
    if ([[dic objectForKey:@"honorList"] isEqual:[NSNull null]]) {
        NSArray * arr = [[NSArray alloc]init];
        [dic setObject:arr forKey:@"honorList"];
    }
    if ([[dic objectForKey:@"elegantPictures"] isEqual:[NSNull null]]) {
        NSArray * arr = [[NSArray alloc]init];
        [dic setObject:arr forKey:@"elegantPictures"];
    }
    if ([[dic objectForKey:@"elegantPicturesId"] isEqual:[NSNull null]]) {
        NSArray * arr = [[NSArray alloc]init];
        [dic setObject:arr forKey:@"elegantPicturesId"];
    }
    
    NSMutableDictionary * writeDic = [BDTools deleteNull:dic];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [documentsPath stringByAppendingPathComponent:@"azm_user_data.plist"];
    
    NSArray * lableArr = writeDic[@"label"];
    NSMutableArray * mlableArr = [[NSMutableArray alloc]init];
    for (NSDictionary * lableDic in lableArr) {
        NSDictionary * newlableDic = [BDTools deleteNull:lableDic];
        [mlableArr addObject:newlableDic];
    }
    [writeDic setObject:mlableArr forKey:@"label"];
    
        NSArray * honorList = writeDic[@"honorList"];
        NSMutableArray * mHonorList = [[NSMutableArray alloc]init];
        for (NSDictionary * itemDic in honorList) {
            NSDictionary * newItemDic = [BDTools deleteNull:itemDic];
            [mHonorList addObject:newItemDic];
        }
        [writeDic setObject:mHonorList forKey:@"honorList"];

    [writeDic writeToFile:fileName atomically:YES];
    
    NSLog(@"文件存储路径———— ： %@",documentsPath);
    
}
//读取数据
- (NSDictionary *)getUserDataFunction {
    //1、获取Documents路径
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //2、拼接文件名称
    NSString *fileName = [path stringByAppendingPathComponent:@"azm_user_data.plist"];
    //3、读取数据
    NSDictionary *dic = [[NSDictionary alloc]initWithContentsOfFile:fileName];
    NSLog(@"———— ： %@",dic);
    return dic;
}
@end
