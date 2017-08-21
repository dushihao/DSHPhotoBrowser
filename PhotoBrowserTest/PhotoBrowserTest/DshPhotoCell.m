//
//  DshPhotoCell.m
//  PhotoBrowserTest
//
//  Created by shihao on 2017/8/15.
//  Copyright © 2017年 shihao. All rights reserved.
//

#import "DshPhotoCell.h"

@implementation DshPhotoCell


- (instancetype)initWithBrowserWithPhotoItems:(NSArray *)items currentSelectedRow:(NSInteger)row{
    self = [super init];
    if (self) {
        
    }
    return self;
}


+ (instancetype)browserWithPhotoItems:(NSArray *)items currentSelectedRow:(NSInteger)row{
    
    return [[self alloc]initWithBrowserWithPhotoItems:items currentSelectedRow:row];
    
}
@end
