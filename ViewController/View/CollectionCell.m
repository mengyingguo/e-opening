//
//  CollectionCell.m
//  eOpening
//
//  Created by jren on 2018/12/10.
//  Copyright © 2018年 枫叶砂. All rights reserved.
//

#define kCellHeight  35.0f

#import "CollectionCell.h"

@implementation CollectionCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        [self setBackgroundColor:RGBA(255, 255, 255, 0)];
        [self addCellView];
    }
    return self;
}

- (void)addCellView{
    
    //缩略图
    UIImageView *thumbnailImgv = [[UIImageView alloc] init];
    _thumbnailImgv = thumbnailImgv;
    [thumbnailImgv setImage:[UIImage imageNamed:@"ch1"]];
    [self.contentView addSubview:thumbnailImgv];
    [thumbnailImgv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 80));
        make.left.equalTo(self.contentView.mas_left).offset(20);
        make.top.equalTo(self.contentView.mas_top).offset(10);
    }];
    //副标题
    UILabel *subTitleLab = [[UILabel alloc] init];
    _subTitleLab = subTitleLab;
    [subTitleLab setText:@"拥抱美丽人生"];
    [subTitleLab setFont:[UIFont boldSystemFontOfSize:16]];
    [subTitleLab setTextColor:RGB(0, 97, 160)];
    [self.contentView addSubview:subTitleLab];
    [subTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(thumbnailImgv.mas_right).offset(12);
        make.right.equalTo(self.contentView.mas_right).offset(-10);
        make.top.equalTo(self.contentView.mas_top).offset(5);
    }];
    //主标题
    UILabel *mainTitleLab = [[UILabel alloc] init];
    _mainTitleLab = mainTitleLab;
    [mainTitleLab setText:@"首页"];
    [mainTitleLab setFont:[UIFont systemFontOfSize:16]];
    [mainTitleLab setTextColor:RGB(0, 97, 160)];
    [self.contentView addSubview:mainTitleLab];
    [mainTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(thumbnailImgv.mas_right).offset(12);
        make.right.equalTo(self.contentView.mas_right).offset(-10);
        make.top.equalTo(subTitleLab.mas_bottom).offset(5);
    }];
    //时间
    UILabel *timeLab = [[UILabel alloc] init];
    _timeLab = timeLab;
    [timeLab setText:@"12:12:12"];
    [timeLab setFont:[UIFont boldSystemFontOfSize:16]];
    [timeLab setTextColor:RGB(51, 51, 51)];
    [self.contentView addSubview:timeLab];
    [timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(thumbnailImgv.mas_right).offset(12);
        make.top.equalTo(mainTitleLab.mas_bottom).offset(5);
    }];
    //日期
    UILabel *dateLab = [[UILabel alloc] init];
    _dateLab = dateLab;
    [dateLab setText:@"2012/12/30"];
    [dateLab setFont:[UIFont boldSystemFontOfSize:16]];
    [dateLab setTextColor:RGB(51, 51, 51)];
    [self.contentView addSubview:dateLab];
    [dateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(thumbnailImgv.mas_right).offset(12);
        make.top.equalTo(timeLab.mas_bottom).offset(0);
    }];
    //下方的分割线
    UIView *lineView = [[UIView alloc] init];
    [lineView setBackgroundColor:RGB(160, 160, 160)];
    [self.contentView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.size.height.mas_equalTo(0.5);
        make.top.equalTo(self.contentView.mas_bottom).offset(-1);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-0.5);
        make.left.equalTo(self.contentView.mas_left).offset(18);
        make.right.equalTo(self.contentView.mas_right).offset(-18);
    }];
    
}

-(void)setData:(CollectionModel *)model{
    NSString *newPath = [BDTools locationOfScreenshotsSaved];
    newPath = [NSString stringWithFormat:@"%@/%@.jpg",newPath,model.dateTime];
    //根据路径读取image
    UIImage *image=[UIImage imageWithContentsOfFile:newPath];
    [_thumbnailImgv setImage:image];
    _subTitleLab.text = model.subTitle;
    _mainTitleLab.text = model.mainTitle;
    _timeLab.text = model.time;
    _dateLab.text = model.date;
}

@end
