//
//  BDBaseResutInfo.m
//  FHC
//
//  Created by 枫叶砂 on 16/9/21.
//  Copyright © 2016年 bluedeer-ban. All rights reserved.
//

#import "BDBaseResutInfo.h"

@implementation BDBaseResutInfo

-(id)initWithJsonDic:(NSDictionary *)jsonDic
{
    if ((self = [super init])) {
        if ([jsonDic objectForKey:@"success"] != [NSNull null]) {
            self.code = [[jsonDic objectForKey:@"success"] longValue];
        }
//        if ([jsonDic objectForKey:@"success"] != [NSNull null]) {
//            self.code = [[NSString alloc] initWithFormat:@"%d",[[jsonDic objectForKey:@"success"] boolValue]];
////            if ([[jsonDic objectForKey:@"success"] boolValue]) {
////                self.resultCode = @"1";
////            }
////            else
////            {
////                self.resultCode = @"0";
////            }
//        }
        if ([jsonDic objectForKey:@"code"] != [NSNull null]) {
            self.code = [[jsonDic objectForKey:@"code"] integerValue];
        }
        if ([jsonDic objectForKey:@"errorMsg"] != [NSNull null]) {
            self.resultMessage = [jsonDic objectForKey:@"errorMsg"];
        }
        if ([jsonDic objectForKey:@"data"] != [NSNull null]) {
            self.data = [jsonDic objectForKey:@"data"];
        }
    }
    return self;
}
- (void)setResultMessage:(NSString *)resultMessage
{
    if ([BDTools isBlankString:resultMessage] && _code == 0) {
        resultMessage = @"返回数据异常";
    }
    _msg = resultMessage;
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}
@end
