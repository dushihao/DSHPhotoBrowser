//
//  photoItem.h
//  PhotoBrowserTest
//
//  Created by shihao on 2017/8/16.
//  Copyright © 2017年 shihao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PhotoItem : NSObject


/**
 下图
 */
@property (nonatomic,strong,readonly) UIImage * thumbImage;
/**
 来源view
 */
@property (nonatomic,strong,readonly) UIImageView * sourceView;
/**
 大图
 */
@property (nonatomic,strong,readonly) UIImage * largeImage;

@property (copy,nonatomic)NSURL *imageUrl;

/**
 是否加载完成
 */
@property (nonatomic,assign) BOOL finish;




- (instancetype)initWithPhotoItemWithSourceView:(UIImageView *)sourceView
                                       imageUrl:(NSURL *)url;

+ (instancetype)photoItemWithSourceView:(UIImageView *)sourceView
                               imageUrl:(NSURL *)url;

@end
