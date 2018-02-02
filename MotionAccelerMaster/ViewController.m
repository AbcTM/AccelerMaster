//
//  ViewController.m
//  MotionAccelerMaster
//
//  Created by feng on 2018/2/2.
//  Copyright © 2018年 feng. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>


/**
 typedefNS_ENUM(NSInteger, UIDeviceOrientation) {
 UIDeviceOrientationUnknown,
 UIDeviceOrientationPortrait,           // 竖向，home键向下
 UIDeviceOrientationPortraitUpsideDown, // 竖向，home键向上
 UIDeviceOrientationLandscapeLeft,      // 横向，home键向右
 UIDeviceOrientationLandscapeRight,     // 横向，home键向左
 UIDeviceOrientationFaceUp,             // 屏幕平放，向上
 UIDeviceOrientationFaceDown            // 屏幕平放，向下
 }
 typedef NS_ENUM(NSInteger, UIInterfaceOrientation) {
 UIInterfaceOrientationUnknown            = UIDeviceOrientationUnknown,
 UIInterfaceOrientationPortrait           = UIDeviceOrientationPortrait,
 UIInterfaceOrientationPortraitUpsideDown = UIDeviceOrientationPortraitUpsideDown,
 UIInterfaceOrientationLandscapeLeft      = UIDeviceOrientationLandscapeRight,
 UIInterfaceOrientationLandscapeRight     = UIDeviceOrientationLandscapeLeft
 }
 
 
 2、对于获取手机屏幕
 （1） [[UIDevicecurrentDevice]beginGeneratingDeviceOrientationNotifications];
 dispatch_async(dispatch_get_main_queue(), ^{
 NSLog(@"=========%zd",[[UIDevicecurrentDevice]orientation]);
 });
 [[UIDevicecurrentDevice]endGeneratingDeviceOrientationNotifications];
 （2）UIInterfaceOrientation orientation = [UIApplicationsharedApplication].statusBarOrientation;
 */

@interface ViewController ()

//@property (assign, nonatomic) BOOL lockDeviceOrientation;
@property (assign, nonatomic) NSTimeInterval updateInterval;
@property (strong, nonatomic) CMMotionManager *mManager;
@property (weak, nonatomic) IBOutlet UILabel *showLabel;
@property (weak, nonatomic) IBOutlet UIView *showView;
@property (assign, nonatomic) UIDeviceOrientation orientation;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.lockDeviceOrientation = NO;
//    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [self startUpDateAccelerometer];
    self.orientation = UIDeviceOrientationPortrait;
    [self transformView:self.orientation];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    
    
//    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [self stopUpdate];
}

- (CMMotionManager *)mManager {
    if (!_mManager) {
        _updateInterval = 1.0/15.0;
        _mManager = [[CMMotionManager alloc] init];
    }
    return _mManager;
}



- (void)startUpDateAccelerometer {
    if (![self.mManager isAccelerometerAvailable]) {
        return;
    }
    
    
    __weak typeof(self) weakSelf = self;
    [self.mManager setAccelerometerUpdateInterval:_updateInterval];
    [self.mManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;

        if (error != nil) {
            
            NSLog(@"startAccelerometerUpdatesToQueue: %@", error.localizedDescription);
            return;
        }
        
        [strongSelf handle2AccelerometerData:accelerometerData];
    }];
}



- (void) stopUpdate {
    if ([self.mManager isAccelerometerAvailable]) {
        [self.mManager stopAccelerometerUpdates];
    }
}

- (void)dealloc
{
    _mManager = nil;
}

#pragma mark -
//- (void)handleDeviceOrientationDidChange: (NSNotification *)noti {
//    UIDevice *device = [UIDevice currentDevice];
//
//    _lockDeviceOrientation = NO;
//    self.orientation = device.orientation;
////    [self transformView:device.orientation];
//}


- (void)handle1AccelerometerData: (CMAccelerometerData * _Nullable) accelerometerData {
    double x = accelerometerData.acceleration.x;
    double y = accelerometerData.acceleration.y;
//    double z = accelerometerData.acceleration.z;
    
    if (fabs(y) >= fabs(x))
    {
        if (y >= 0){
            //Down
            
            [self.showLabel setText:@"当前的方向：Down"];
            NSLog(@"当前的方向：Down");
        }
        else{
            //Portrait
            
            [self.showLabel setText:@"当前的方向：Portrait"];
            NSLog(@"当前的方向：Portrait");
        }
    }
    else
    {
        if (x >= 0){
            //Right
            [self.showLabel setText:@"当前的方向：Right"];
            NSLog(@"当前的方向：Right");
        }
        else{
            //Left
            [self.showLabel setText:@"当前的方向：Left"];
            NSLog(@"当前的方向：Left");
        }
    }
}

- (void)handle2AccelerometerData: (CMAccelerometerData * _Nullable) accelerometerData {
    double angle = atan2(accelerometerData.acceleration.y, accelerometerData.acceleration.x);
    if (angle >= -2.25 && angle <= -0.75) {
        // UIDeviceOrientationPortrait
        [self transformView:UIDeviceOrientationPortrait];
    }
    else if (angle >= -0.75 && angle <= 0.75) {
        //UIDeviceOrientationLandscapeLeft
        [self transformView:UIDeviceOrientationLandscapeLeft];
    }
    else if (angle >= 0.75 && angle <= 2.25) {
        //UIDeviceOrientationPortraitUpsideDown
        [self transformView:UIDeviceOrientationPortraitUpsideDown];
    }
    else if (angle <= -2.25 || angle >= 2.25) {
        //UIDeviceOrientationLandscapeRight
        [self transformView:UIDeviceOrientationLandscapeRight];
    }
}

// 推荐用这个方法
- (void)handle3AccelerometerData: (CMAccelerometerData * _Nullable) accelerometerData {
    
    UIDeviceOrientation orientationNew;
    if (accelerometerData.acceleration.x >= 0.75) {//home button left
        orientationNew= UIDeviceOrientationLandscapeRight;
    }
    else if (accelerometerData.acceleration.x <= -0.75) {//home button right
        orientationNew = UIDeviceOrientationLandscapeLeft;
    }
    else if (accelerometerData.acceleration.y <= -0.75) {
        orientationNew = UIDeviceOrientationPortrait;
    }
    else if (accelerometerData.acceleration.y >= 0.75) {
        orientationNew = UIDeviceOrientationPortraitUpsideDown;
    }
    else {
        // Consider same as last time
        return;
    }
    
    if (accelerometerData.acceleration.z < 0) {
//        NSLog(@"当前的方向：屏幕朝上");
    }else{
//        NSLog(@"当前的方向：屏幕朝下");
    }
    
    if (orientationNew == self.orientation) {
        return;
    }
    
    self.orientation = orientationNew;
    [self transformView:orientationNew];
}

- (BOOL)shouldAutorotate {
    return false;
}

- (void)setOrientation:(UIDeviceOrientation)orientation {
    if (_orientation != orientation) {
        _orientation = orientation;
    }
}

- (void)transformView:(UIDeviceOrientation)oritentation {
    switch (oritentation) {
        case UIDeviceOrientationLandscapeLeft:
//            NSLog(@"当前的方向：Left");
            
            [self.showLabel setText:@"当前的方向：Left"];
            [self.showLabel setTransform:CGAffineTransformMakeRotation(M_PI_2)];
            [self.showView setTransform:CGAffineTransformMakeRotation(M_PI_2)];
            break;
            
        case UIDeviceOrientationLandscapeRight:
//            NSLog(@"当前的方向：Right");
            
            [self.showLabel setText:@"当前的方向：Right"];
            [self.showLabel setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
            [self.showView setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
            break;
            
        case UIDeviceOrientationPortrait:
//            NSLog(@"当前的方向：Portrait");
            
            [self.showLabel setText:@"当前的方向：Portrait"];
            [self.showLabel setTransform:CGAffineTransformIdentity];
            [self.showView setTransform:CGAffineTransformIdentity];
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
//            NSLog(@"当前的方向：Down");
            
            [self.showLabel setText:@"当前的方向：Down"];
            [self.showLabel setTransform:CGAffineTransformMakeRotation(M_PI)];
            [self.showView setTransform:CGAffineTransformMakeRotation(M_PI)];
            break;
            
        default:
            break;
    }
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {

    [self transformView:self.orientation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)startUpdateJiBuQiAccelerometer
{
    /* 设置采样的频率，单位是秒 */
    NSTimeInterval updateInterval = 0.05; // 每秒采样20次
    
    //    CGSize size = [self superview].frame.size;
    //    __block CGRect f = [self frame];
    __block int stepCount = 0; // 步数
    //在block中，只能使用weakSelf。
    /* 判断是否加速度传感器可用，如果可用则继续 */
    if ([self.mManager isAccelerometerAvailable] == YES) {
        /* 给采样频率赋值，单位是秒 */
        [self.mManager  setAccelerometerUpdateInterval:updateInterval];
        
        /* 加速度传感器开始采样，每次采样结果在block中处理 */
        [self.mManager  startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error)
         {
             
             CGFloat sqrtValue =sqrt(accelerometerData.acceleration.x*accelerometerData.acceleration.x+accelerometerData.acceleration.y*accelerometerData.acceleration.y+accelerometerData.acceleration.z*accelerometerData.acceleration.z);
             
             // 走路产生的震动率
//             if (sqrtValue > 1.552188 && valiadCountStep)
//             {
//                 displayLink.paused = NO;
//                 [Database save:TableLocalFoot entity:[NSDictionary dictionaryWithObjectsAndKeys:@"1",@"footid",[[NSUserDefaults standardUserDefaults] valueForKey:@"token"],@"userid",[NSDate date],@"time", nil]];
                 
                 //                 [self.delegate totleNum:stepCount];
//                 stepCount +=1;
//                 valiadCountStep = NO;
//             }
             
         }];
    }
    
}

@end
