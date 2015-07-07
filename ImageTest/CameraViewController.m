//
//  CameraViewController.m
//  ImageTest
//
//  Created by Ray Lin on 7/6/15.
//  Copyright (c) 2015 BananaFoundation. All rights reserved.
//

#import "CameraViewController.h"
@import AVFoundation;

@interface CameraViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lensLabel;
@property (nonatomic) AVCaptureDevice *videoCaptureDevice;

@end

@implementation CameraViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
    self.videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.videoCaptureDevice error:&error];
    if (videoInput) {
        [captureSession addInput:videoInput];
        AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
        UIView *aView = self.view;
        previewLayer.frame = aView.bounds; // Assume you want the preview layer to fill the view.
        [aView.layer addSublayer:previewLayer];
        [captureSession startRunning];
        [self.videoCaptureDevice addObserver:self forKeyPath:@"lensPosition" options:NSKeyValueObservingOptionNew context:nil];
    }
    else {
        NSLog(@"fuck");
    }
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.videoCaptureDevice removeObserver:self forKeyPath:@"lensPosition"];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSNumber *number = [change objectForKey:@"new"];
    NSString *textString = [NSString stringWithFormat:@"%@", number];
    dispatch_async(dispatch_get_main_queue(), ^{
       self.lensLabel.text = textString;
       self.title = textString;
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
