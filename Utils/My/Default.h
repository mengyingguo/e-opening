//
//  Default.h
//  eOpening
//
//  Created by duanmingyang on 2018/8/15.
//  Copyright © 2018年 枫叶砂. All rights reserved.
//

#ifndef Default_h
#define Default_h
//NSLog()
#if DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"[%s:%d行] %s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(FORMAT, ...) nil
#endif
//NSUserDefaults 通过key(a)获取value
#define get_sp(a) [[NSUserDefaults standardUserDefaults] objectForKey:a]
//NSUserDefaults 设置key(a)的数值为value(b)
#define set_sp(a,b) [[NSUserDefaults standardUserDefaults] setObject:b forKey:a]
//网络变更消息通知
#define kNetworkChangedNotification @"kNetworkChangedNotification"
//刷新home的消息通知
#define kDidBecomeActiveNotification @"kDidBecomeActiveNotification"
//跳转imap重新登录
#define kHomeOpenImapNotification @"kHomeOpenImapNotification"

//rgb()
#define RGB(r, g, b) [UIColor colorWithRed:(r) / 255.0 green:(g) / 255.0 blue:(b) / 255.0 alpha:1.0]
//rgba()
#define RGBA(r, g, b,a) [UIColor colorWithRed:(r) / 255.0 green:(g) / 255.0 blue:(b) / 255.0 alpha:a]
//消息弹框
#define kPOPERROR(error)  [[FCPopToast sharedInstance]popShowWithError:error AndTime:3.0 AndPopViewLocationType:popViewLocationType_Center];
#define kPOP(mess)  [[FCPopToast sharedInstance]popShowWithTitle:mess AndTime:3.0 AndPopViewLocationType:popViewLocationType_Center];
//屏幕宽度
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
//屏幕高度
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
//数据库名称
#define SQLiteFile @"SQLiteFile.db"

#define NSStringFormat(format,...) [NSString stringWithFormat:format,##__VA_ARGS__]

#endif /* Default_h */
