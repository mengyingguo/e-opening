//
//  CollectionCell.h
//  eOpening
//
//  Created by jren on 2018/12/10.
//  Copyright © 2018年 枫叶砂. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionModel.h"

@interface CollectionCell : UITableViewCell

@property(nonatomic, strong)UIImageView *thumbnailImgv;
@property(nonatomic, strong)UILabel * subTitleLab;
@property(nonatomic, strong)UILabel * mainTitleLab;
@property(nonatomic, strong)UILabel * timeLab;
@property(nonatomic, strong)UILabel * dateLab;

-(void)setData:(CollectionModel *)model;

@end
