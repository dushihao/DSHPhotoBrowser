//
//  LargePhotoCollectionViewCell.m
//  PhotoBrowserTest
//
//  Created by shihao on 2017/8/17.
//  Copyright © 2017年 shihao. All rights reserved.
//

#import "LargePhotoCollectionViewCell.h"
#import "PhotoItem.h"
#import <UIImageView+WebCache.h>
#import "Dsh_scrollView.h"



@implementation LargePhotoCollectionViewCell{
    CGPoint _currentLocation;
    UIPanGestureRecognizer *_panGesture;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
   // self.contentView.backgroundColor = [UIColor colorWithRed:(arc4random()%256) /255.0 green:(arc4random()%256) /255.0 blue:(arc4random()%256) /255.0 alpha:1];
    // 添加手势
    [self addSomeGesture];
    self.scrollView.delaysContentTouches = NO;
    [self.scrollView addSubview:self.imageView];
    self.scrollView.delegate = self;
    self.scrollView.bounces = NO;
}

- (void)setupUI{

    //添加 imageView
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.userInteractionEnabled = YES;
    imageView.layer.shouldRasterize = YES; // 抗锯齿 处理
    self.imageView = imageView;
    
}

//更新图片的大小
- (void)updateImageViewSize{
    
    if (_imageView.image) {
        CGSize imageSize = _imageView.image.size;
        CGFloat width = self.bounds.size.width;
        CGFloat height = width * (imageSize.height / imageSize.width);
        CGRect rect = CGRectMake(0, 0, width, height);
        _imageView.frame = rect;
        
        // If image is very high, show top content.
        if (height <= self.bounds.size.height) {
            _imageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        } else {
            _imageView.center = CGPointMake(self.bounds.size.width/2, height/2);
        }
        
        // If image is very wide, make sure user can zoom to fullscreen.
        if (width / height > 2) {
            self.scrollView.maximumZoomScale = self.bounds.size.height / height;
        }
    } else {
        
        CGFloat width = self.frame.size.width - 2 * 10;
        _imageView.frame = CGRectMake(0, 0, width, width * 2.0 / 3);
        _imageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    }
    self.scrollView.contentSize = _imageView.frame.size;
}



- (void)setPhotoItem:(PhotoItem *)photoItem{
    _photoItem = photoItem;
    
    
    [_panGesture requireGestureRecognizerToFail:self.superCollectionView.panGestureRecognizer];
    
    __weak __typeof(self) weakSelf = self;
    [self.imageView sd_setImageWithURL:_photoItem.imageUrl placeholderImage:_photoItem.thumbImage completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf updateImageViewSize];
    }];
    
}

#pragma mark - GESTURE

- (void)addSomeGesture{
    
    // 单击
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
    // 双击
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapGesture:)];
    doubleTap.numberOfTapsRequired = 2;
    [tap requireGestureRecognizerToFail:doubleTap];
    //拖拽
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGesture:)];
    pan.delegate = self;
    
    [self.contentView addGestureRecognizer:tap];
    [self.contentView addGestureRecognizer:doubleTap];
    [self.imageView addGestureRecognizer:pan];
}

- (void)tapClick:(UITapGestureRecognizer *)gesture{
    NSLog(@"单机");
    [self.delegate photoCollectionCell:self didEndAnimation:NO];
}

- (void)doubleTapGesture:(UITapGestureRecognizer *)gesture{

    NSLog(@"双击");
    
    // 拿到触摸点
    CGPoint location = [gesture locationInView:self.contentView];
    // 判断图片缩放比例 >1 ?
    // 进行缩放
    if (self.scrollView.zoomScale > 1) {
        [self.scrollView setZoomScale:1 animated:YES];
    }else{

        CGFloat maxScale = self.scrollView.maximumZoomScale;
        CGFloat width = self.scrollView.bounds.size.width / maxScale;
        CGFloat height = self.scrollView.bounds.size.height/ maxScale;
        [self.scrollView zoomToRect:CGRectMake(location.x - width /2, location.y - height/2, width, height) animated:YES];
    }
}

- (void)panGesture:(UIPanGestureRecognizer *)panGesture{
    if (self.scrollView.zoomScale > 1.1) {
        // 图片方法 则不响应移动手势
        NSLog(@"比例大于1");
        return;
    }

    //获取触摸的点
    CGPoint location = [panGesture locationInView:self.contentView];
    // 获取移动距离
    CGPoint point = [panGesture translationInView:self.contentView];
    // 获取移动速度
    CGPoint velocity = [panGesture velocityInView:self.contentView];
    //判断移动的状态

    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            _currentLocation = location;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGFloat angel ;
            // 判断是从左侧滑动 还是右侧滑动
            if (_currentLocation.x > self.contentView.bounds.size.width /2) {
                // 右侧滑动
                angel = M_PI/2 * (point.y / self.contentView.bounds.size.height);
            }else{
                angel = - M_PI/2 * (point.y / self.contentView.bounds.size.width);
            }

            CGAffineTransform transformAngel = CGAffineTransformMakeRotation(angel);
            CGAffineTransform transformTranslation = CGAffineTransformMakeTranslation(0, point.y);
            CGAffineTransform transform = CGAffineTransformConcat(transformAngel, transformTranslation);

            self.imageView.transform = transform;

            // 背景
            double percent = 1 - fabs(point.y)/(self.contentView.frame.size.height/2);
            
            //collectionview 透明度
            
            if ([self.delegate respondsToSelector:@selector(photoCollectionCell:didPanPercent:)]) {
                [self.delegate photoCollectionCell:self didPanPercent:percent];
            }
            
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            NSLog(@"cancelled");
            

            if (fabs(point.y) > 200 || fabs(velocity.y) > 500) {
                [self showRotationCompletionAnimationFromPoint:point];
            } else {
                
                [self showCancellationAnimation];
            }
        }
            break;
        default:
            break;
    }
}


- (BOOL)commitTranslation:(CGPoint)translation{
    
    CGFloat absX = fabs(translation.x);
    CGFloat absY = fabs(translation.y);
    
    // 设置滑动有效距离
    if (MAX(absX, absY) < 10)
        return YES;
    
    
    if (absX > absY ) {
        
        if (translation.x<0) {
            
            //向左滑动
            return NO;
        }else{
            
            //向右滑动
            return NO;
        }
        
    } else if (absY > absX) {
        if (translation.y<0) {
            return YES;
            //向上滑动
        }else{
            
            //向下滑动
            return YES;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer{
    
    if (![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) return YES;
    
    // 判断是否是长图
    if (self.scrollView.contentSize.height > self.contentView.bounds.size.height) {
        return NO;
    }
    
    //判断滑动方向
    CGPoint velocity = [gestureRecognizer velocityInView:self.contentView];
    
    // 如果是左右滑动，不在响应拖拽手势；如果是上下滑动，就相应拖拽的手势
    if (fabs(velocity.x) > fabs(velocity.y)){
        return NO;
    }else{
        return YES;
    }
    
}

#pragma mark - scrollview delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {

    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;

    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;

    _imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                    scrollView.contentSize.height * 0.5 + offsetY);
}


#pragma mark - animation

- (void)showRotationCompletionAnimationFromPoint:(CGPoint)point{
    
    BOOL startFromLeft = _currentLocation.x < self.contentView.frame.size.width / 2;
    BOOL throwToTop = point.y < 0;
    CGFloat angle, toTranslationY;
    if (throwToTop) {
        angle = startFromLeft ? (M_PI / 2) : -(M_PI / 2);
        toTranslationY = -self.contentView.frame.size.height;
    } else {
        angle = startFromLeft ? -(M_PI / 2) : (M_PI / 2);
        toTranslationY = self.contentView.frame.size.height;
    }
    
    CGFloat angle0 = 0;
    if (_currentLocation.x < self.contentView.frame.size.width/2) {
        angle0 = -(M_PI / 2) * (point.y / self.contentView.frame.size.height);
    } else {
        angle0 = (M_PI / 2) * (point.y / self.contentView.frame.size.height);
    }
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = @(angle0);
    rotationAnimation.toValue = @(angle);
    CABasicAnimation *translationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    translationAnimation.fromValue = @(point.y);
    translationAnimation.toValue = @(toTranslationY);
    CAAnimationGroup *throwAnimation = [CAAnimationGroup animation];
    throwAnimation.duration = 0.6;
    throwAnimation.delegate = self;
    throwAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    throwAnimation.animations = @[rotationAnimation, translationAnimation];
    [throwAnimation setValue:@"throwAnimation" forKey:@"id"];
    [self.imageView.layer addAnimation:throwAnimation forKey:@"throwAnimation"];
    
    CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
    CGAffineTransform translation = CGAffineTransformMakeTranslation(0, toTranslationY);
    CGAffineTransform transform = CGAffineTransformConcat(rotation, translation);
    self.imageView.transform = transform;
    
    [UIView animateWithDuration:0.6 animations:^{
        self.contentView.backgroundColor = [UIColor clearColor];
    } completion:nil];
}

// 取消动画
- (void)showCancellationAnimation{
    
    [UIView animateWithDuration:.6 animations:^{
        self.imageView.transform = CGAffineTransformIdentity;
      //  self.contentView.backgroundColor = [UIColor blackColor];
        self.superCollectionView.superview.backgroundColor =[UIColor blackColor];
    } completion:^(BOOL finished) {
        
    }];
}

// MARK: -  animation delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if ([[anim valueForKey:@"id"] isEqualToString:@"throwAnimation"]) {
       // [self dismissAnimationWithShouldBackLocation:NO];
        BOOL is = [self.delegate respondsToSelector:@selector(photoCollectionCell:didEndAnimation:)];
        if (is) {
            [self.delegate photoCollectionCell:self didEndAnimation:YES];
         }
    }
}



@end
