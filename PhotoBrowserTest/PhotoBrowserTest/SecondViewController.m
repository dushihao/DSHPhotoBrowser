

//
//  SecondViewController.m
//  PhotoBrowserTest
//
//  Created by shihao on 2017/8/8.
//  Copyright © 2017年 shihao. All rights reserved.
//

#import "SecondViewController.h"
#import "LargePhotoCollectionViewCell.h"
#import <UIImageView+WebCache.h>
#import <SDImageCache.h>


#define kScreen_width [UIScreen mainScreen].bounds.size.width
#define kScreen_height [UIScreen mainScreen].bounds.size.height

static const CGFloat kAnimationTime = 0.3;
static NSString *const collectionCellID = @"LargePhotoCollectionViewCell";

@interface SecondViewController ()<CAAnimationDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate,LargePhotoCollectionViewCellDelegate,UIGestureRecognizerDelegate>

@property (strong,nonatomic)UIImageView *laoziImageView;

@property (strong,nonatomic)UIScrollView *dsh_scrollView;

@property (strong,nonatomic)UICollectionView *dsh_collectionView;

@property (strong,nonatomic) UIPageControl *pageControl;
@end

@implementation SecondViewController{
    CGPoint _currentLocation;
}

# pragma mark - 初始化方法


- (instancetype)initWithBrowserWithPhotoItems:(NSArray *)items currentSelectedRow:(NSInteger)row{
    
    self = [super init];
    if (self) {
        
        // 弹出风格
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        _photoItems = items;
        _selectedIndex = row;
        
        _selectedItem = items[row];
        _selectedImgView = _selectedItem.sourceView;
        
    }
    return self;
}

+ (instancetype)browserWithPhotoItems:(NSArray *)items currentSelectedRow:(NSInteger)row{
    return [[self alloc] initWithBrowserWithPhotoItems:items currentSelectedRow:row];
}

# pragma mark - life circle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.itemSize = CGSizeMake(kScreen_width, kScreen_height);
    
    // 内容scrollview
    UICollectionView *bigPhotoView =  [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:layout];
    bigPhotoView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    bigPhotoView.delegate = self;
    bigPhotoView.dataSource = self;
    bigPhotoView.pagingEnabled = YES;
    bigPhotoView.delaysContentTouches = NO;
    [bigPhotoView setContentSize:CGSizeMake(kScreen_width * self.photoItems.count, kScreen_height)];
    [bigPhotoView registerNib:[UINib nibWithNibName:@"LargePhotoCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:collectionCellID];
    self.dsh_collectionView = bigPhotoView;
    [self.view addSubview:bigPhotoView];
    
    
    UIPageControl *pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height-40, self.view.bounds.size.width, 30)];
    pageControl.numberOfPages = self.photoItems.count;
    pageControl.currentPage = _selectedIndex;
    [self.view addSubview:pageControl];
    self.pageControl = pageControl;
    
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.dsh_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    
    UIImageView *placeHoderImageView = [[UIImageView alloc]initWithImage:_selectedImgView.image];
  //  [placeHoderImageView sd_setImageWithURL:_selectedItem.imageUrl placeholderImage:_selectedImgView.image];
    
  //  [placeHoderImageView sd_setImageWithURL:_selectedItem.imageUrl];
    
    [placeHoderImageView setContentMode:UIViewContentModeScaleAspectFill];
    placeHoderImageView.layer.cornerRadius = 0.001;
    placeHoderImageView.clipsToBounds = YES;
    [self.view addSubview:placeHoderImageView];
    
    //判断缓存(内存)中 是否已经存在大图
    UIImage *cacheImage = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:[_selectedItem.imageUrl absoluteString]] ;
    if (cacheImage) {
        placeHoderImageView.image = cacheImage;
    }
    
    //初始位置
    CGRect originRect = [self.view convertRect:_selectedImgView.frame fromView:_selectedImgView.superview];
    placeHoderImageView.frame = originRect;
    
    
    CGSize tempSize = placeHoderImageView.image.size;
    CGFloat width = tempSize.width;
    CGFloat height = tempSize.height;
    //动画结束位置
    CGSize endSize = CGSizeMake(kScreen_width, (height * kScreen_width / width) > kScreen_height ? kScreen_height:(height * kScreen_width / width));
    
    self.dsh_collectionView.hidden =  YES;
    [UIView animateWithDuration:kAnimationTime delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.view.backgroundColor = [UIColor blackColor];
        placeHoderImageView.center = self.view.center;
        placeHoderImageView.bounds = (CGRect){CGPointZero,endSize};
    } completion:^(BOOL finished) {
        self.dsh_collectionView.hidden = NO;
        
        [UIView animateWithDuration:0.3 animations:^{
            [placeHoderImageView setAlpha:0];
        } completion:^(BOOL finished) {
            [placeHoderImageView removeFromSuperview];
        }];

    }];
    
}

#pragma mark - Collectionview  datasource and delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.photoItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    LargePhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionCellID forIndexPath:indexPath];
    cell.superCollectionView = collectionView;
    cell.photoItem = self.photoItems[indexPath.row];
    cell.delegate = self;
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.selectedItem.sourceView) {
        [self dismissAnimationWithShouldBackLocation:YES];
    }else{
        //如果当前的cell图片，没有在预览界面展示出来，就不在做缩放效果
        [self dismissAnimationWithShouldBackLocation:NO];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    _selectedIndex = scrollView.contentOffset.x / scrollView.frame.size.width ;
    _pageControl.currentPage = _selectedIndex;
   // NSLog(@"当前下标 =====%@",@(_selectedIndex));
    
    // 更新属性
    _selectedItem = self.photoItems[_selectedIndex];
    _selectedImgView = _selectedItem.sourceView;
    
}

#pragma mark - LargePhotoCollectionCell delegate

- (void)photoCollectionCell:(LargePhotoCollectionViewCell *)cell didEndAnimation:(BOOL)flag{
    
    if (!flag) {
        if (self.selectedItem.sourceView) {
            [self dismissAnimationWithShouldBackLocation:YES];
        }else{
            //如果当前的cell图片，没有在预览界面展示出来，就不在做缩放效果
            [self dismissAnimationWithShouldBackLocation:NO];
        }
    }else{
            [self dismissAnimationWithShouldBackLocation:NO];
    }
    
}

- (void)photoCollectionCell:(LargePhotoCollectionViewCell *)cell didPanPercent:(double)percent{
    
   // NSLog(@"percent....%@",@(percent));
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:percent];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    NSLog(@" gestureRecognizer= %@ /n otherGestureRecognizer = %@",gestureRecognizer,otherGestureRecognizer);
    return YES;
}

#pragma mark - 私有方法
/**
 dismiss VC
 
 @param flag ：区分是通过点击 还是 通过拖拽导致的 dismiss
 */
- (void)dismissAnimationWithShouldBackLocation:(BOOL)flag{
    
    LargePhotoCollectionViewCell *cell = (LargePhotoCollectionViewCell *)[self.dsh_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0]];
    
    //初始位置
    CGRect originRect = [self.view convertRect:cell.imageView.frame fromView:cell];
    //结束位置
    CGRect endRect = [self.view convertRect:_selectedImgView.frame fromView:self.selectedImgView.superview];
    
    //动画image
    UIImageView *tempImgView = [[UIImageView alloc]initWithImage:cell.imageView.image];
    tempImgView.frame =  originRect;
    [self.view addSubview:tempImgView];
    
    
    //先隐藏，做动画前的准备工作
    self.selectedItem.sourceView.hidden = flag;
    self.dsh_collectionView.hidden = YES;
    
    [UIView animateWithDuration:kAnimationTime delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        if (flag) {
            tempImgView.frame = endRect;
        }
        self.view.backgroundColor = [UIColor clearColor];
        
    } completion:^(BOOL finished) {
        
        [tempImgView removeFromSuperview];
        _selectedItem.sourceView.hidden = NO;
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
    
}



@end
