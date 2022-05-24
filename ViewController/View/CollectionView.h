//
//  CollectionView.h
//  eOpening
//
//  Created by jren on 2018/12/7.
//  Copyright © 2018年 枫叶砂. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CollectionViewDelegate <NSObject>
-(void)collectionViewCancelPressed:(UIButton *)button;
-(void)collectionView:(id)collectionView saveCollectionPressed:(UIButton *)button;
-(void)collectionViewJumpOtherHtml:(NSString *)urlStr;
@end

@interface CollectionView : UIView

@property(nonatomic, assign)CGFloat offectY;
@property(nonatomic, weak)id<CollectionViewDelegate>delegate;
- (instancetype)initWithOffsetY:(CGFloat)offsetY;
-(void)refreshDataIsSave:(BOOL)isSave;

@end
