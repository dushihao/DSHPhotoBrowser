//
//  photoItem.m
//  PhotoBrowserTest
//
//  Created by shihao on 2017/8/16.
//  Copyright © 2017年 shihao. All rights reserved.
//

#import "PhotoItem.h"

@implementation PhotoItem


- (instancetype)initWithPhotoItemWithSourceView:(UIImageView *)sourceView thumbImage:(UIImage *)thumbImage imageUrl:(NSURL *)url{
    
    if (self = [super init]) {
        _sourceView = sourceView;
        _thumbImage = thumbImage;
        _imageUrl = url;
    }
    return self;

}

- (instancetype)initWithPhotoItemWithSourceView:(UIImageView *)sourceView imageUrl:(NSURL *)url{
    
    return [self initWithPhotoItemWithSourceView:sourceView thumbImage:sourceView.image imageUrl:url];
    
}

+ (instancetype)photoItemWithSourceView:(UIImageView *)sourceView
                               imageUrl:(NSURL *)url{
    return [[self alloc]initWithPhotoItemWithSourceView:sourceView imageUrl:url];
}

@end
