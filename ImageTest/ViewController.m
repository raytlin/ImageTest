//
//  ViewController.m
//  ImageTest
//
//  Created by Ray Lin on 7/5/15.
//  Copyright (c) 2015 BananaFoundation. All rights reserved.
//

#import "ViewController.h"
@import Photos;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong) PHFetchResult *assetsFetchResults;
@property (strong) PHAssetCollection *assetCollection;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.assetsFetchResults = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:nil];
    
    [[PHImageManager defaultManager] requestImageForAsset:[self.assetsFetchResults lastObject] targetSize:CGSizeMake(320, 320) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage *result, NSDictionary *info){
        self.imageView.image = result;
        NSLog(@"%@", info);
    }];
    
    [[PHImageManager defaultManager] requestImageDataForAsset:[self.assetsFetchResults lastObject]
                                                      options:nil
                                                resultHandler:
     ^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
         CIImage* ciImage = [CIImage imageWithData:imageData];
         NSLog(@"Metadata : %@", ciImage.properties);
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
