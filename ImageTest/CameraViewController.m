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
@property (weak, nonatomic) IBOutlet UIView *captureView;
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
        UIView *aView = self.captureView;
        previewLayer.frame = aView.bounds; // Assume you want the preview layer to fill the view.
        [aView.layer addSublayer:previewLayer];
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
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

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [touches enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        UITouch *touch = obj;
        CGPoint touchPoint = [touch locationInView:touch.view];
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        double focus_x = touchPoint.x/screenWidth;
        double focus_y = touchPoint.y/screenHeight;
        
        NSError *error =nil;
        [self.videoCaptureDevice lockForConfiguration:&error];
        self.videoCaptureDevice.focusMode = AVCaptureFocusModeAutoFocus;
        self.videoCaptureDevice.focusPointOfInterest = CGPointMake(focus_x,focus_y);
        if (error) {
            NSLog(@"%@", error);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
