//
//  HBEmjoyView.m
//  XMPP_Chat
//
//  Created by 伍宏彬 on 15/12/17.
//  Copyright © 2015年 Wow_我了个去. All rights reserved.
//

#import "HBEmjoyView.h"
#import "HBEmjoyCollectionViewCell.h"
#import "HBCollectionViewFlowLayout.h"

@interface HBEmjoyView()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *buttomScrollerView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray * emjoyNames;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end
//#warning 计算分页偏移量
static NSString *collectionViewID = @"collectionViewID";

@implementation HBEmjoyView

- (void)awakeFromNib
{

    [self.collectionView registerNib:[UINib nibWithNibName:@"HBEmjoyCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:collectionViewID];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableArray *array = [NSMutableArray array];
        
        for (NSInteger i = 1; i < 141; i++) {
            NSString *str = [NSString stringWithFormat:@"%03ld",(long)i];
            [array addObject:str];
        }
        
        NSUInteger page = array.count / 20;
        NSUInteger less = array.count % 20;
        
        for (NSInteger z = 0; z < page; z++) {
    
            NSMutableArray *marray = [[array subarrayWithRange:NSMakeRange(page * z, 20)] mutableCopy];
            [marray addObject:@"cancel"];
            [self.emjoyNames addObject:marray];
        
        }
        
        if (less > 0)
        [self.emjoyNames addObject:[array subarrayWithRange:NSMakeRange(array.count - less, less)]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.pageControl.numberOfPages = ceilf(array.count / 20);
            [self.collectionView reloadData];
        });
        
    });

}


- (IBAction)leftAddbtnAction:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(emjoyViewDidTouchActionType:)]) {
        [self.delegate emjoyViewDidTouchActionType:actionTypeAdd];
    }
}
- (IBAction)rightSendAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(emjoyViewDidTouchActionType:)]) {
        [self.delegate emjoyViewDidTouchActionType:actionTypeSend];
    }
}
#pragma mark - UICollectionViewDataSource,UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.emjoyNames.count;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *array = self.emjoyNames[section];
    return array.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HBEmjoyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionViewID forIndexPath:indexPath];
    NSArray *array = self.emjoyNames[indexPath.section];
    NSString *name = array[indexPath.item];
    cell.emjoyImage.image = [UIImage imageNamed:name];
//    cell.backgroundColor = [UIColor redColor];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
    NSArray *array = self.emjoyNames[indexPath.section];
    NSString *name = array[indexPath.item];
    if ([self.delegate respondsToSelector:@selector(emjoyView:didChoose:)]) {
        [self.delegate emjoyView:self didChoose:name];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger currentPage = ceilf(scrollView.contentOffset.x / [UIScreen mainScreen].bounds.size.width);
    self.pageControl.currentPage = currentPage;
    
}
#pragma mark - getter
- (NSMutableArray *)emjoyNames
{
    if (!_emjoyNames) {
        _emjoyNames = [NSMutableArray array];
    }
    return _emjoyNames;
}
@end
