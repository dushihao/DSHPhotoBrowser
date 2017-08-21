//
//  LargePhotoCollectionViewCell.h
//  PhotoBrowserTest
//
//  Created by shihao on 2017/8/17.
//  Copyright © 2017年 shihao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoItem;
@class Dsh_scrollView;
@class LargePhotoCollectionViewCell;
@class UICollectionView;

@protocol LargePhotoCollectionViewCellDelegate<NSObject>

/**
 手势触发的动画结束 的回调

 @param cell 当前cell
 @param flag 预留参数 no use(没什么卵用:P)
 */
- (void)photoCollectionCell:(LargePhotoCollectionViewCell *)cell didEndAnimation:(BOOL)flag;

@optional

/**
 拖拽展示图片 回调

 @param cell self
 @param percent 拖拽的当前百分比
 */
- (void)photoCollectionCell:(LargePhotoCollectionViewCell *)cell didPanPercent:(double)percent;
@end


@interface LargePhotoCollectionViewCell : UICollectionViewCell<NSObject,UIScrollViewDelegate,CAAnimationDelegate,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet Dsh_scrollView *scrollView;
@property (strong, nonatomic)  UIImageView *imageView;
@property (strong,nonatomic) PhotoItem *photoItem;
@property (strong,nonatomic) UICollectionView *superCollectionView;

@property (weak,nonatomic) id<LargePhotoCollectionViewCellDelegate> delegate;

//更新位置
- (void)updateImageViewSize;

@end
