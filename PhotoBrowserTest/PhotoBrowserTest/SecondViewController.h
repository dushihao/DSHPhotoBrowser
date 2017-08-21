//
//  SecondViewController.h
//  PhotoBrowserTest
//
//  Created by shihao on 2017/8/8.
//  Copyright © 2017年 shihao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoItem.h"

// photobrowser VC

@interface SecondViewController : UIViewController

/**
 item数组
 */
@property(nonatomic) NSArray *photoItems;

/**
 当前展示的图片 下标
 */
@property(nonatomic,assign)NSInteger selectedIndex;
@property (nonatomic,strong) PhotoItem *selectedItem; //当前item

/**
 选中的图片ImgView
 */
@property (nonatomic,weak) UIImageView *selectedImgView;




+ (instancetype)browserWithPhotoItems:(NSArray *)items currentSelectedRow:(NSInteger)row;


@end
