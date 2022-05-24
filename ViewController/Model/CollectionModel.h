//
//  CollectionModel.h
//  eOpening
//
//  Created by jren on 2018/12/10.
//  Copyright © 2018年 枫叶砂. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CollectionModel : NSObject

//时间
@property (nonatomic,strong) NSString *time;
//日期
@property (nonatomic,strong) NSString *date;
//时间戳
@property (nonatomic,strong) NSString *dateTime;
//副标题
@property (nonatomic,strong) NSString *subTitle;
//主标题
@property (nonatomic,strong) NSString *mainTitle;
//图片地址
@property (nonatomic,strong) NSString *imgUrl;
//图片base64编码
@property (nonatomic,strong) NSString *imgData;
//用户账号
@property (nonatomic,strong) NSString *agentCode;
//保存网页的url地址
@property (nonatomic,strong) NSString *currentUrl;

@end
