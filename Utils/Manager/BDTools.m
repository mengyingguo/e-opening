//
//  BDTools.m
//  FHC
//
//  Created by 枫叶砂 on 16/9/20.
//  Copyright © 2016年 bluedeer-ban. All rights reserved.
//

#import "BDTools.h"
#define BDDotNumbers     @"0123456789.\n"
#define BDNumbers        @"0123456789\n"

@implementation BDTools
+ (BOOL)isBlankString:(NSString *)string
{
    if (string == nil) {
        return YES;
    }
    if (string == NULL) {
        return YES;
    }
    if ([string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length==0) {
        return YES;
    }
    return NO;
}
/*
 * @brief 把格式化的JSON格式的字符串转换成字典
 * @param jsonString JSON格式的字符串
 * @return 返回字典
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers                                                          error:&err];
        if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
//字典转成json字符串
+ (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonStr;
}
+ (NSString*) get_uuid {
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    return result;
}
+ (CGFloat)getBDMeasureValue:(CGFloat)value
{
    CGFloat measureValue = 1.0f;
    if ([[UIScreen mainScreen] currentMode].size.width>1536) {
        measureValue = [[UIScreen mainScreen] currentMode].size.width/1636;
    }
    return value * measureValue;
}
// 根据color创建图片
+ (UIImage*) createImageWithColor: (UIColor*) color
{
    CGRect rect=CGRectMake(0,0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
+ (BOOL)shouldChangeTextField:(NSString *)text changeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
//    当执行删除操作时，不做判断
    if (string.length == 0) {
        return YES;
    }
    NSCharacterSet *cs;
//    判断"."的位置
    NSUInteger nDotLoc = [text rangeOfString:@"."].location;
//    判断可输入的字符
    if (NSNotFound == nDotLoc && 0 != range.location) {
        cs = [[NSCharacterSet characterSetWithCharactersInString:BDDotNumbers] invertedSet];
    }
    else {
        cs = [[NSCharacterSet characterSetWithCharactersInString:BDNumbers] invertedSet];
    }
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    BOOL basicTest = [string isEqualToString:filtered];
    if (!basicTest) {
        return NO;
    }
//    当“.”存在时，新添加的字符位置不能大于“.”的位置加2
    if (NSNotFound != nDotLoc && range.location > nDotLoc + 2) {
        return NO;
    }
    return YES;
}
+ (BOOL)calculatorOfCompoundInterestViewShouldChangeTextField:(NSString *)text changeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //    当执行删除操作时，不做判断
    if (string.length == 0) {
        return YES;
    }
    NSCharacterSet *cs;
    //    判断"."的位置
    NSUInteger nDotLoc = [text rangeOfString:@"."].location;
    //    判断可输入的字符
    if (NSNotFound == nDotLoc && 0 != range.location) {
        cs = [[NSCharacterSet characterSetWithCharactersInString:BDDotNumbers] invertedSet];
    }
    else {
        cs = [[NSCharacterSet characterSetWithCharactersInString:BDNumbers] invertedSet];
    }
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    BOOL basicTest = [string isEqualToString:filtered];
    if (!basicTest) {
        return NO;
    }
    //    当“.”存在时，新添加的字符位置不能大于“.”的位置加2
    if (NSNotFound != nDotLoc && range.location > nDotLoc + 4) {
        return NO;
    }
    return YES;
}

+ (UIImage *)getImage:(UIScrollView *)scrollView {
    UIImage* viewImage = nil;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height), scrollView.opaque=NO, 0.0);
    {
        CGPoint savedContentOffset = scrollView.contentOffset;
        CGRect savedFrame = scrollView.frame;
        
        scrollView.contentOffset = CGPointZero;
        scrollView.frame = CGRectMake(0,0, scrollView.contentSize.width, scrollView.contentSize.height);
        
        [scrollView.layer renderInContext: UIGraphicsGetCurrentContext()];
        viewImage = UIGraphicsGetImageFromCurrentImageContext();
        
        scrollView.contentOffset = savedContentOffset;
        scrollView.frame = savedFrame;
    }
    UIGraphicsEndImageContext();
    
    return viewImage;
}

+ (NSDictionary *)urlTurnToDataDictionary:(NSURL *)url{
{
    //用来作为函数的返回值，数组里里面可以存放每个url转换的字典
//    NSMutableArray *arrayData = [NSMutableArray arrayWithCapacity:4];
    
    //获取数组，数组里装得是url
//    NSMutableArray *arrayURL = appendURL();
//    NSLog(@"获取到得URL数组如下：n%@", arrayURL);
    
    //循环对数组中的每个url进行处理，把参数转换为字典
    NSString *urlString = [url absoluteString];
        //获取问号的位置，问号后是参数列表
        NSRange range = [urlString rangeOfString:@"?"];
//        NSLog(@"参数列表开始的位置：%d", (int)range.location);
    
        //获取参数列表
        NSString *propertys = [urlString substringFromIndex:(int)(range.location+1)];
//        NSLog(@"截取的参数列表：%@", propertys);
    
        //进行字符串的拆分，通过&来拆分，把每个参数分开
        NSArray *subArray = [propertys componentsSeparatedByString:@"&"];
//        NSLog(@"把每个参数列表进行拆分，返回为数组：n%@", subArray);
    
        //把subArray转换为字典
        //tempDic中存放一个URL中转换的键值对
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithCapacity:4];
        for (int j = 0 ; j < subArray.count; j++)
        {
            //在通过=拆分键和值
            NSArray *dicArray = [subArray[j] componentsSeparatedByString:@"="];
//            NSLog(@"再把每个参数通过=号进行拆分：n%@", dicArray);
            //给字典加入元素
            if (dicArray[0] && dicArray[1]) {
                [tempDic setObject:dicArray[1] forKey:dicArray[0]];
            }
        }
//        NSLog(@"打印参数列表生成的字典：n%@", tempDic);
    return tempDic;
    }
}
+ (NSString *)getSalesmanNum:(NSString *)value
{
    NSString *userId = [NSString stringWithFormat:@"%d",[value intValue]];
    NSRange range = NSMakeRange(9 - userId.length, userId.length);
    NSMutableString *salesmanNumString = [NSMutableString stringWithString:@"000000000"];
    [salesmanNumString replaceCharactersInRange:range withString: userId];
    return salesmanNumString;
}

/**
 * 传入参数与url，拼接为一个带参数的url
 **/
+(NSString *) connectUrlWithDictionary:(NSMutableDictionary *)params url:(NSString *) urlLink{
    // 初始化参数变量
    NSString *str = @"&";
    
    // 快速遍历参数数组
    for(id key in params) {
        str = [str stringByAppendingString:key];
        str = [str stringByAppendingString:@"="];
        str = [str stringByAppendingString:[params objectForKey:key]];
        str = [str stringByAppendingString:@"&"];
    }
    // 处理多余的&以及返回含参url
    if (str.length > 1) {
        // 去掉末尾的&
        str = [str substringToIndex:str.length - 1];
        str = [str substringFromIndex:1];
        str = [@"?" stringByAppendingString:str];
        // 返回含参url
        return [urlLink stringByAppendingString:str];
    }
    return Nil;
}
+(UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    //app默认windowLevel是UIWindowLevelNormal，如果不是，找到UIWindowLevelNormal的
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    id  nextResponder = nil;
    UIViewController *appRootVC=window.rootViewController;
    //    如果是present上来的appRootVC.presentedViewController 不为nil
    if (appRootVC.presentedViewController) {
        nextResponder = appRootVC.presentedViewController;
    }else{
        
        //        NSLog(@"===%@",[window subviews]);
        if ([[window subviews] count]) {
            UIView *frontView = [[window subviews] objectAtIndex:0];
            nextResponder = [frontView nextResponder];
        }
    }
    
    if ([nextResponder isKindOfClass:[UITabBarController class]]){
        UITabBarController * tabbar = (UITabBarController *)nextResponder;
        UINavigationController * nav = (UINavigationController *)tabbar.viewControllers[tabbar.selectedIndex];
        //        UINavigationController * nav = tabbar.selectedViewController ; 上下两种写法都行
        result=nav.childViewControllers.lastObject;
        
    }else if ([nextResponder isKindOfClass:[UINavigationController class]]){
        UIViewController * nav = (UIViewController *)nextResponder;
        result = nav.childViewControllers.lastObject;
    }else{
        result = nextResponder;
    }
    return result;
}
+ (void)webView:(UIWebView *)webView GetRequestWithHostUrl:(NSString *)url andParams:(NSString *)params
{
    NSURL *getUrl = [[ NSURL alloc] initWithString:[NSString stringWithFormat:@"%@?%@",url,params]];
    [webView  loadRequest:[ NSURLRequest requestWithURL: getUrl]];
}
+ (void)webView:(UIWebView *)webView PostRequestWithHostUrl:(NSString *)url andParams:(NSString *)params
{
    NSURL *postUrl = [[ NSURL alloc] initWithString:[NSString stringWithFormat:@"%@?%@",url,params]];
    NSString *body = [NSString stringWithFormat:@"%@",params];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:postUrl];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding: NSUTF8StringEncoding]];
    [webView loadRequest:request];
}
/** 获取时间戳 */
+(NSString *)getTimeStamp{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    //设置时区,这个对于时间的处理有时很重要
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    
    return timeSp;
}
/** 获取毫秒时间戳 */
+(long)getTimeStamp2{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss SSS"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    //设置时区,这个对于时间的处理有时很重要
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    
    //NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    
    return (long)[datenow timeIntervalSince1970];
    
    //return timeSp;
}
/** 下载zip的地址 */
+(NSString *)downZipURL{
    NSString *localPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    // 要检查的文件目录
    return localPath;
}
/** NSArray、NSDictionary转换为json */
+(NSString *)objectToJson:(id)obj{
    if (obj == nil) {
        return nil;
    }
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj
                                                       options:0
                                                         error:&error];
    
    if ([jsonData length] && error == nil){
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }else{
        return nil;
    }
}
/** json转NSArray、NSDictionary */
+(id)jsonToObject:(NSString *)json{
    //string转data
    NSData * jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    //json解析
    id obj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    return obj;
}
/** 特殊json转NSDictionary */
+(NSDictionary *)jsonToData:(id)responseObject{
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
/** 获取时间 */
+(NSString *)getTimeStr{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    //设置时区,这个对于时间的处理有时很重要
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    
    NSString *timeStr = [formatter stringFromDate:datenow];;
    
    return timeStr;
}
/** 获取日期 */
+(NSString *)getDateStr{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"YYYY/MM/dd"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    //设置时区,这个对于时间的处理有时很重要
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    
    NSString *dateStr = [formatter stringFromDate:datenow];;
    
    return dateStr;
}
/** 获取日期和时间 */
+(NSString *)getDateTimeStr{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"YYYY/MM/dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    //设置时区,这个对于时间的处理有时很重要
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    
    NSString *dateTimeStr = [formatter stringFromDate:datenow];;
    
    return dateTimeStr;
}
/** 获取当前web的相对地址 */
+(NSString *)getRelativeUrlStr:(NSString *)absolutelyUrlStr{
    absolutelyUrlStr = [NSString stringWithFormat:@"%@||",absolutelyUrlStr];
    NSRange startRange = [absolutelyUrlStr rangeOfString:[NSString stringWithFormat:@"/e_opening/"]];
    NSRange endRange = [absolutelyUrlStr rangeOfString:@"||"];
    NSRange range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
    NSString *resultUrl = [absolutelyUrlStr substringWithRange:range];
    return resultUrl;
}
/**截图保存的位置*/
+(NSString *)locationOfScreenshotsSaved{
    NSString *localPath = [BDTools downZipURL];
    // 要检查的文件目录
    NSString *filePath = [localPath stringByAppendingPathComponent:@"imageStore/"];
    return filePath;
}
/**获取储存空间剩余大小*/
+(CGFloat)getFreeSize{
    /// 剩余大小
    float freesize = 0.0;
    /// 是否登录
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    if (dictionary)
    {
        NSNumber *_free = [dictionary objectForKey:NSFileSystemFreeSize];
        freesize = [_free unsignedLongLongValue]*1.0/1024.0;
        
        //NSLog(@"freesize %f MB",freesize/1024.0);
    } else
    {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    
    return freesize;
}
+ (NSString*)formatNetWork:(long long int)rate{
    if(rate <1024) {
        return [NSString stringWithFormat:@"%lldB/秒", rate];
    }else if(rate >=1024&& rate <1024*1024){
        return [NSString stringWithFormat:@"%.0fKB/秒", (double)rate /1024];
    }else if(rate >=1024*1024&& rate <1024*1024*1024){
        return [NSString stringWithFormat:@"%.1fMB/秒", (double)rate / (1024*1024)];
    }else{
        return @"0Kb/秒";
    };
}
/**获取当前h5版本号*/
+(NSString*)getCurH5Version{
//    //获取Document路径
//    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
//    NSString *path=[paths objectAtIndex:0];
//    //本地历史版本数据
//    NSDictionary *downLoadHistoryDictionary = [[NSDictionary alloc] init];
//    NSString *fileHistoryPath=[path stringByAppendingPathComponent:@"fileDownLoadHistory.plist"];
//    if ([[NSFileManager defaultManager] fileExistsAtPath:fileHistoryPath]) {
//        downLoadHistoryDictionary =[NSMutableDictionary dictionaryWithContentsOfFile:fileHistoryPath];
//    }
//    //本地的版本
//    return [downLoadHistoryDictionary objectForKey:@"curVersion"];
//
    return get_sp(@"curH5Version");
}

+ (NSMutableDictionary *)deleteNull:(NSDictionary *)dic{

NSMutableDictionary *mutableDic = [[NSMutableDictionary alloc] init];
for (NSString *keyStr in dic.allKeys) {

    if ([[dic objectForKey:keyStr] isEqual:[NSNull null]]) {

        [mutableDic setObject:@"" forKey:keyStr];
    }
    else{

        [mutableDic setObject:[dic objectForKey:keyStr] forKey:keyStr];
    }
}
return mutableDic;
}

@end
