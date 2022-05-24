//
//  CollectionView.m
//  eOpening
//
//  Created by jren on 2018/12/7.
//  Copyright © 2018年 枫叶砂. All rights reserved.
//

#define RDM (arc4random() % 255)

#import "CollectionView.h"
#import "CollectionCell.h"
#import "LKDBHelper.h"
#import "CollectionModel.h"
#import <objc/runtime.h>
@interface CollectionView()<UITableViewDataSource,UITableViewDelegate>{
}
@property (nonatomic, strong)LKDBHelper *dbHelper;
@property (nonatomic, strong)NSString *filePath;
@property(nonatomic, strong)NSMutableArray *dataArr;
@property(nonatomic, strong)UITableView *collectionTableView;
@end

@implementation CollectionView

- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = RGBA(255, 255, 255, 0);
        [self addContentView];
        [self refreshDataIsSave:NO];
    }
    return self;
}

- (instancetype)initWithOffsetY:(CGFloat)offsetY{
    if (self = [super init]) {
        self.backgroundColor = RGBA(255, 255, 255, 0);
        _offectY = offsetY;
        [self addContentView];
        [self refreshDataIsSave:NO];
    }
    return self;
}

- (void)addContentView{
    [self setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:cancelBtn];
    [cancelBtn addTarget:self action:@selector(cancelPressed:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT));
        make.left.equalTo(self.mas_left).offset(0);
        make.top.equalTo(self.mas_top).offset(0);
    }];
    
    UIView *view01 = [[UIView alloc] init];
    [view01 setBackgroundColor:RGBA(255, 255, 255, 0.9)];
    //[view01 setBackgroundColor:RGB(RDM, RDM, RDM)];
    [self addSubview:view01];
    
    [view01 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(256, SCREEN_HEIGHT-_offectY));
        make.top.equalTo(self.mas_top).offset(_offectY);
        make.right.equalTo(self.mas_right).offset(0);
    }];
    
    UITableView *tbv = [[UITableView alloc] init];
    self.collectionTableView = tbv;
    [tbv setDelegate:self];
    [tbv setDataSource:self];
    [tbv setShowsHorizontalScrollIndicator:NO];
    [tbv setShowsVerticalScrollIndicator:NO];
    [tbv setSeparatorColor:[UIColor clearColor]];
    [tbv setBackgroundColor:[UIColor clearColor]];
    [view01 addSubview:tbv];
    [tbv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view01.mas_left).offset(0);
        make.top.equalTo(view01.mas_top).offset(0);
        make.bottom.equalTo(view01.mas_bottom).offset(0);
        make.right.equalTo(view01.mas_right).offset(0);
    }];
//    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0)
//    {
//        tbv.cellLayoutMarginsFollowReadableWidth = NO;// 9.0以上才有这个属性,针对ipad。
//    }
    
    UIView *headView = [[UIView alloc] init];
    [headView setFrame:CGRectMake(0, 0, 256, 110)];
    [tbv setTableHeaderView:headView];

    UIButton *collectionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [collectionBtn setFrame:CGRectMake(15, 15, 226, 80)];
    [collectionBtn setImage:[UIImage imageNamed:@"collection"] forState:UIControlStateNormal];
    [collectionBtn addTarget:self action:@selector(collectionBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:collectionBtn];

    UIView *lineView = [[UIView alloc] init];
    [lineView setFrame:CGRectMake(18, 109.5, 220, 0.5)];
    [lineView setBackgroundColor:RGB(160, 160, 160)];
    [headView addSubview:lineView];
    
}


- (NSDictionary *)dicFromObject:(NSObject *)object {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int count;
    objc_property_t *propertyList = class_copyPropertyList([object class], &count);
    
    for (int i = 0; i < count; i++) {
        objc_property_t property = propertyList[i];
        const char *cName = property_getName(property);
        NSString *name = [NSString stringWithUTF8String:cName];
        NSObject *value = [object valueForKey:name];//valueForKey返回的数字和字符串都是对象
        
        if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
            //string , bool, int ,NSinteger
            [dic setObject:value forKey:name];
            
        } else if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
            //字典或字典
            [dic setObject:[self arrayOrDicWithObject:(NSArray*)value] forKey:name];
            
        } else if (value == nil) {
            //null
            //[dic setObject:[NSNull null] forKey:name];//这行可以注释掉?????
            
        } else {
            //model
            [dic setObject:[self dicFromObject:value] forKey:name];
        }
    }
    
    return [dic copy];
}

- (id)arrayOrDicWithObject:(id)origin {
    if ([origin isKindOfClass:[NSArray class]]) {
        //数组
        NSMutableArray *array = [NSMutableArray array];
        for (NSObject *object in origin) {
            if ([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]]) {
                //string , bool, int ,NSinteger
                [array addObject:object];
                
            } else if ([object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSDictionary class]]) {
                //数组或字典
                [array addObject:[self arrayOrDicWithObject:(NSArray *)object]];
                
            } else {
                //model
                [array addObject:[self dicFromObject:object]];
            }
        }
        
        return [array copy];
        
    } else if ([origin isKindOfClass:[NSDictionary class]]) {
        //字典
        NSDictionary *originDic = (NSDictionary *)origin;
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        for (NSString *key in originDic.allKeys) {
            id object = [originDic objectForKey:key];
            
            if ([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]]) {
                //string , bool, int ,NSinteger
                [dic setObject:object forKey:key];
                
            } else if ([object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSDictionary class]]) {
                //数组或字典
                [dic setObject:[self arrayOrDicWithObject:object] forKey:key];
                
            } else {
                //model
                [dic setObject:[self dicFromObject:object] forKey:key];
            }
        }
        
        return [dic copy];
    }
    
    return [NSNull null];
}


-(void)refreshDataIsSave:(BOOL)isSave{
    NSString *agentCode = [BDTools isBlankString:[FTDKeyChain load:KEYCHAIN_LOGININFO_AGENTCODE]]?[FTDKeyChain load:KEYCHAIN_UUID]:[FTDKeyChain load:KEYCHAIN_LOGININFO_AGENTCODE];
    [self.dbHelper search:[CollectionModel class] where:[NSString stringWithFormat:@"agentCode = '%@'",agentCode] orderBy:@"dateTime desc" offset:0 count:20 callback:^(NSMutableArray * _Nullable array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //主线程执行
            self.dataArr = array;
            [self.collectionTableView reloadData];
            if ([BDHttpService isReachNetWork] && isSave) {
                NSMutableArray *muArr = [[NSMutableArray alloc] init];
                for (int i = 0; i<array.count; i++) {
                    [muArr insertObject:[self dicFromObject:array[i]] atIndex:0];
                }
                NSString *content = [BDTools objectToJson:muArr];
                [[BDHttpService shareInstance] saveAppData:nil uuid:[FTDKeyChain load:KEYCHAIN_UUID] idNo:[FTDKeyChain load:KEYCHAIN_LOGININFO_AGENTCODE] type:@"collection" content:content finishBlock:^(id responseObject, NSError *error) {
                    if([responseObject[@"success"] integerValue]==0){
                        kPOP(responseObject[@"errorMsg"]);
                    }
                }];
            }
        });
    }];

}

-(void)cancelPressed:(UIButton *)btn{
    if(_delegate && [_delegate respondsToSelector:@selector(collectionViewCancelPressed:)]){
        [_delegate collectionViewCancelPressed:btn];
    }
}
-(void)collectionBtnPressed:(UIButton *)btn{
    if(_delegate && [_delegate respondsToSelector:@selector(collectionView:saveCollectionPressed:)]){
        [_delegate collectionView:self saveCollectionPressed:btn];
    }
}
#pragma UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *indentifier = @"indentifier";
    
    CollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    
    if (cell == nil){
        cell = [[CollectionCell alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:indentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    NSInteger row = indexPath.row;
    CollectionModel *model = self.dataArr[row];
    [cell setData:model];
    
    return cell;
}

#pragma UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    CollectionModel *model = self.dataArr[row];
    if(_delegate && [_delegate respondsToSelector:@selector(collectionViewJumpOtherHtml:)]){
        [_delegate collectionViewJumpOtherHtml:model.currentUrl];
    }
}
// 设置 cell 是否允许左滑
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}
// 设置默认的左滑按钮的title
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}
// 点击左滑出现的按钮时触发
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"点击左滑出现的按钮时触发");
    NSInteger row = indexPath.row;
    CollectionModel *model = self.dataArr[row];
    [self.dbHelper deleteToDB:model callback:^(BOOL result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeFile:model.dateTime];
            [self.dataArr removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            NSMutableArray *muArr = [[NSMutableArray alloc] init];
            for (int i = 0; i<self.dataArr.count; i++) {
                [muArr insertObject:[self dicFromObject:self.dataArr[i]] atIndex:0];
            }
            NSString *content = [BDTools objectToJson:muArr];
            [[BDHttpService shareInstance] saveAppData:nil uuid:[FTDKeyChain load:KEYCHAIN_UUID] idNo:[FTDKeyChain load:KEYCHAIN_LOGININFO_AGENTCODE] type:@"collection" content:content finishBlock:^(id responseObject, NSError *error) {
                
            }];
        });
    }];
}
// 左滑结束时调用(只对默认的左滑按钮有效，自定义按钮时这个方法无效)
-(void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"左滑结束");
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

#pragma mark delete file
//删除文件
-(BOOL)removeFile:(NSString*)fileName{
    BOOL ret =  NO;
    NSString *filePath = [BDTools locationOfScreenshotsSaved];
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@.jpg",filePath,fileName];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:imagePath]) {
        ret = [fm removeItemAtPath:imagePath error:nil];
    }
    return ret;
}
@end
