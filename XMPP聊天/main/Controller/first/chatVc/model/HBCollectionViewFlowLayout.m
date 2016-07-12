//
//  HBCollectionViewFlowLayout.m
//  XMPP_Chat
//
//  Created by 伍宏彬 on 15/12/17.
//  Copyright © 2015年 Wow_我了个去. All rights reserved.
//

#import "HBCollectionViewFlowLayout.h"

@implementation HBCollectionViewFlowLayout

static CGFloat lineCount = 7;//列
//static CGFloat rowCount = 3;//行
//static CGFloat itemSizeWH = 35;
static CGFloat paddingFlowLayout = 20;

- (void)prepareLayout
{
    [super prepareLayout];
    
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    CGFloat itemSizeW = ([UIScreen mainScreen].bounds.size.width - (lineCount + 1) * paddingFlowLayout)/lineCount;
//    CGFloat itemSizeH = (165 - (rowCount + 1) * paddingFlowLayout)/rowCount;
    self.itemSize = CGSizeMake(itemSizeW, itemSizeW);
//    CGFloat mid = ([UIScreen mainScreen].bounds.size.width - itemSizeWH * lineCount)/(lineCount + 1);
//    CGFloat mid2 = (self.collectionView.HB_H - itemSizeWH * rowCount) / (rowCount + 1);
    self.minimumLineSpacing = paddingFlowLayout;
    self.minimumInteritemSpacing = paddingFlowLayout;
//    self.collectionView.contentInset = UIEdgeInsetsMake(mid, mid, mid, mid);
    self.sectionInset = UIEdgeInsetsMake(paddingFlowLayout, paddingFlowLayout, paddingFlowLayout, paddingFlowLayout);
}

@end
