//
//  BDTools.h
//  FHC
//
//  Created by 枫叶砂 on 16/9/20.
//  Copyright © 2016年 bluedeer-ban. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BDTools : NSObject
/** 判断字符串是否为空（含均为空格的情况）*/
+(BOOL)isBlankString:(NSString *)string;
/** 获取uuid */
+(NSString*)get_uuid;
+( CGFloat )getBDMeasureValue:(CGFloat)value;
/** 根据color创建图片 */
+(UIImage*)createImageWithColor: (UIColor*) color;
/** 限制输入小数点后两位 */
+(BOOL)shouldChangeTextField:(NSString *)text changeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
/** 限制输入小数点后四位 */
+(BOOL)calculatorOfCompoundInterestViewShouldChangeTextField:(NSString *)text changeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
/** 截图 */
+(UIImage *)getImage:(UIScrollView *)scrollView;
/**
 * @brief 把格式化的JSON格式的字符串转换成字典
 * @param jsonString JSON格式的字符串
 * @return 返回字典
 */
+(NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
/** 字典转成json字符串 */
+(NSString*)dictionaryToJson:(NSDictionary *)dic;
/** URL转字典 */
+(NSDictionary *)urlTurnToDataDictionary:(NSURL *)url;
/** 返回营销员编号 */
+(NSString *)getSalesmanNum:(NSString *)value;
/** 传入参数与url，拼接为一个带参数的url */
+(NSString *)connectUrlWithDictionary:(NSMutableDictionary *)params url:(NSString *) urlLink;
+(UIViewController *)getCurrentVC;
/**
 webView
 @param webView webView webview
 @param url url 请求链接
 @param params params 参数
 */
+(void)webView:(UIWebView *)webView GetRequestWithHostUrl:(NSString *)url andParams:(NSString *)params;
/**
 webView
 @param webView webView webview
 @param url url 请求链接
 @param params params 参数
 */
+(void)webView:(UIWebView *)webView PostRequestWithHostUrl:(NSString *)url andParams:(NSString *)params;
/** 获取时间戳 */
+(NSString *)getTimeStamp;
/** 获取毫秒时间戳 */
+(long)getTimeStamp2;
/** 下载zip的地址 */
+(NSString *)downZipURL;
/** NSArray、NSDictionary转换为json */
+(NSString *)objectToJson:(id)obj;
/** json转NSArray、NSDictionary */
+(id)jsonToObject:(NSString *)json;
/** 特殊json转NSDictionary */
+(NSDictionary *)jsonToData:(id)responseObject;
/** 获取时间 */
+(NSString *)getTimeStr;
/** 获取日期 */
+(NSString *)getDateStr;
/** 获取日期和时间 */
+(NSString *)getDateTimeStr;
/** 获取当前web的相对地址 */
+(NSString *)getRelativeUrlStr:(NSString *)absolutelyUrlStr;
/**截图保存的位置*/
+(NSString *)locationOfScreenshotsSaved;
/**获取储存空间剩余大小*/
+(CGFloat)getFreeSize;
/**转换下载速度 **/
+(NSString*)formatNetWork:(long long int)rate;
/**获取当前h5版本号*/
+(NSString*)getCurH5Version;
/**过滤字典null*/
+ (NSMutableDictionary *)deleteNull:(NSDictionary *)dic;

@end
