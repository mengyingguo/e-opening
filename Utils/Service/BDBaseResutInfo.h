//
//  BDBaseResutInfo.h
//  FHC
//
//  Created by 枫叶砂 on 16/9/21.
//  Copyright © 2016年 bluedeer-ban. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDBaseResutInfo : NSObject
@property (nonatomic,assign) NSInteger code;
//@property (nonatomic,retain) NSString *code;
@property (nonatomic,retain) NSString *msg;
@property (nonatomic,retain) NSDictionary *data;

-(id)initWithJsonDic:(NSDictionary *)jsonDic;
@end
