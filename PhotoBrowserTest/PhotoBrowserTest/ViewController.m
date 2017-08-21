//
//  ViewController.m
//  PhotoBrowserTest
//
//  Created by shihao on 2017/8/8.
//  Copyright © 2017年 shihao. All rights reserved.
//

#import "ViewController.h"
#import "SecondViewController.h"
#import "DshPhotoCell.h"
#import "PhotoItem.h"

#import <UIImageView+WebCache.h>


@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic) NSArray *imgURLArray;
@property (nonatomic) NSMutableArray *photoItems;

@end

@implementation ViewController

- (NSArray *)imgURLArray{
    if (!_imgURLArray) {
        _imgURLArray = @[
                         @"http://ww3.sinaimg.cn/bmiddle/005WR3hOjw1eo3ltq2kyrj315o0rogq2.jpg",
                         @"http://ww2.sinaimg.cn/bmiddle/005WR3hOjw1eo3ltpfur8j30dw0a7q36.jpg",
                         @"http://ww3.sinaimg.cn/bmiddle/670721e9ly1fgna7r4w7vj20u010fdl6.jpg",
                         @"http://ww4.sinaimg.cn/bmiddle/6bacde9agw1dm5uqi9in4j.jpg",
                         @"http://ww4.sinaimg.cn/bmiddle/005XUU3ely1fidpy7iha9j30hs13y7eg.jpg",
                         @"http://wx3.sinaimg.cn/mw690/4b08ac5ely1fi6cnvl5kdj20zk18gwmi.jpg",
                         @"http://wx4.sinaimg.cn/mw690/4b08ac5ely1fi6cnybwb0j20tm18ggr7.jpg",
                         @"http://wx2.sinaimg.cn/mw690/006qaoP0gy1fhyv70qdpej32kw3vcnpg.jpg",
                         @"http://wx3.sinaimg.cn/mw690/4b08ac5ely1fi6cnvl5kdj20zk18gwmi.jpg",
                         @"http://wx4.sinaimg.cn/mw690/4b08ac5ely1fi6cnybwb0j20tm18ggr7.jpg",
                         @"http://wx2.sinaimg.cn/mw690/006qaoP0gy1fhyv70qdpej32kw3vcnpg.jpg"
                         ];
    }
    return _imgURLArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}


- (IBAction)presentButtonClick:(id)sender {
    
    SecondViewController *vc = [[SecondViewController alloc]init];
    vc.modalPresentationStyle = UIModalPresentationCustom;
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
   // vc.sourceImgView = self.imageView;
    [self presentViewController:vc animated:NO completion:nil];
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.imgURLArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
   
    DshPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DshPhotoCell" forIndexPath:indexPath];
    
    [cell.contentImgView sd_setImageWithURL:[NSURL URLWithString:self.imgURLArray[indexPath.row]] placeholderImage:[UIImage imageNamed:@"1.jpg"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
        if (image.size.height > self.view.bounds.size.height) {
            cell.contentImgView.contentMode =  UIViewContentModeTop;
            
            //期望宽高
            CGFloat width = cell.contentImgView.frame.size.width;
            CGFloat heigth =  image.size.height*width/image.size.width;
            
            // cores 2d 重新生成一张图片
            UIGraphicsBeginImageContext(CGSizeMake(width, heigth));
            [cell.contentImgView.image drawInRect:CGRectMake(0, 0, width, heigth)];
            cell.contentImgView.image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        
    }];
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
            
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:self.imgURLArray.count];
    
    for (NSInteger i = 0; i<self.imgURLArray.count; ++i) {
        DshPhotoCell *cell = (DshPhotoCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        NSString *urlStr = [self.imgURLArray[i] stringByReplacingOccurrencesOfString:@"bmiddle" withString:@"large"];
        PhotoItem *item = [PhotoItem photoItemWithSourceView:cell.contentImgView imageUrl:[NSURL URLWithString:urlStr]];
        [tempArray addObject:item];
    }
    _photoItems = [tempArray copy];
    
    SecondViewController *secondVC = [SecondViewController browserWithPhotoItems:_photoItems currentSelectedRow:indexPath.row];
    [self presentViewController:secondVC animated:NO completion:nil];
}






@end
