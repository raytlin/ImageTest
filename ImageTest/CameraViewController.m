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
@property (nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic) UIView *focusSquare;
@end

@implementation CameraViewController

#pragma mark - Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    
    // Hide navigation controller
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    // Add gesture recognizer to toggle navigation bar
    UISwipeGestureRecognizer *swipeGestureDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(navBarDown)];
    swipeGestureDown.direction = UISwipeGestureRecognizerDirectionDown;
    UISwipeGestureRecognizer *swipeGestureUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(navBarUp)];
    swipeGestureUp.direction = UISwipeGestureRecognizerDirectionUp;
    
    [self.view addGestureRecognizer:swipeGestureDown];
    [self.view addGestureRecognizer:swipeGestureUp];
    
    // Create focus square and set to center of screen
    self.focusSquare = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    self.focusSquare.center = self.view.center;
    self.focusSquare.layer.borderColor = [UIColor yellowColor].CGColor;
    self.focusSquare.layer.borderWidth = 1.0f;
    [self.view addSubview:self.focusSquare];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Set up the camera and preview layer
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
    self.videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.videoCaptureDevice error:&error];
    if (videoInput) {
        [captureSession addInput:videoInput];
        self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
        UIView *aView = self.captureView;
        self.previewLayer.frame = [[UIScreen mainScreen] bounds];
        [aView.layer addSublayer:self.previewLayer];
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        [captureSession startRunning];
        [self.videoCaptureDevice addObserver:self forKeyPath:@"lensPosition" options:NSKeyValueObservingOptionNew context:nil];
    }
    else {
        NSLog(@"fuck");
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Stop key value observer
    [self.videoCaptureDevice removeObserver:self forKeyPath:@"lensPosition"];
}

#pragma mark - Nav and status bar hiding

-(void)navBarDown {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)navBarUp {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

// Get rid of status bar
-(BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark - Lens Position readout

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSNumber *number = [change objectForKey:@"new"];
    NSString *textString = [NSString stringWithFormat:@"%@", number];
    dispatch_async(dispatch_get_main_queue(), ^{
       self.lensLabel.text = textString;
       self.title = textString;
    });
}

- (IBAction)printToConsole:(id)sender {
    NSLog(@"%@", [NSNumber numberWithDouble:self.videoCaptureDevice.lensPosition]);
}

#pragma mark - Touch to focus

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [touches enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        
        UITouch *touch = obj;
        CGPoint touchPoint = [touch locationInView:touch.view];
        CGPoint focusPoint = [self.previewLayer captureDevicePointOfInterestForPoint:touchPoint];
        
        NSError *error =nil;
        [self.videoCaptureDevice lockForConfiguration:&error];
        self.videoCaptureDevice.focusPointOfInterest = focusPoint;
        self.videoCaptureDevice.focusMode = AVCaptureFocusModeAutoFocus;
        if (error) {
            NSLog(@"%@", error);
        }
        // Set the focus indicator 
        self.focusSquare.center = touchPoint;
        [self.videoCaptureDevice unlockForConfiguration];

    }];
}

#pragma mark - Useless

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"Go fudge yourself");
}

@end
