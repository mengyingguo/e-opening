//
//  BDHttpServiceHead.h
//  FHC
//
//  Created by 枫叶砂 on 16/9/21.
//  Copyright © 2016年 bluedeer-ban. All rights reserved.
//

#ifndef BDHttpServiceHead_h
#define BDHttpServiceHead_h

//#define CERNAME @"eopening_prod"
#define CERNAME @"metlife_uat"

//#define ROOT_URL @"https://nbs-int.metlife.com.cn/"
#define ROOT_URL @"https://nbs-sit.metlife.com.cn/"

//#define ROOT_URL @"https://jay.tohours.com/"
//#define ROOT_URL @"https://map-int.metlife.com.cn/" //uat
//#define ROOT_URL @"https://eopening.metlife.com.cn/" //production

//接口地址
#define SERVICE_URL [ROOT_URL stringByAppendingString:@"eopening/"]

#endif /* BDHttpServiceHead_h */
