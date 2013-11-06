//
//  SUCoolTool.m
//  CoolTool
//
//  Created by Alex Saenko on 9/19/13.
//  Copyright (c) 2013 Sigma Ukraine. All rights reserved.
//

#import "SUCoolTool.h"
#import "SUGridViewController.h"
#import "SUScreenshotUtil.h"
#import "SUZGestureView.h"
#import <CoreMotion/CoreMotion.h>

static CGFloat const kSUAccelerationThreshold = 1.7f;
static CGFloat const kSUAccelerometerUpdateInterval = (1.0f/10.0f);

@interface SUCoolTool () <UIAccelerometerDelegate, SUGridViewControllerDelegate>

@property (nonatomic, weak) UIAlertView *alertView;
@property (nonatomic, strong) UIWindow *debugWindow;
@property (nonatomic, strong) UIWindow *parentWindow;
@property (nonatomic, strong) CMMotionManager *motionManager;

@end

@implementation SUCoolTool 

#pragma mark - Singleton stuff

static id __sharedInstance;

+ (SUCoolTool *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[SUCoolTool alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:__sharedInstance
                                                 selector:@selector(orientationChanged:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:__sharedInstance
                                                 selector:@selector(removeWindowForDebug)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    });
    return __sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = nil;
        __sharedInstance = [super allocWithZone:zone];
    });
	
    return __sharedInstance;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)init
{
    if (self = [super init]) {
        self.motionManager = [[CMMotionManager alloc] init];
        self.motionManager.accelerometerUpdateInterval = (1.0f/10.0f);
        
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                                 withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                                     if (error) {
                                                         [self.motionManager stopAccelerometerUpdates];
                                                     } else {
                                                         [self performSelectorOnMainThread:@selector(handleShake:) withObject:accelerometerData waitUntilDone:YES];
                                                     }
                                                 }];
    }
    
    return self;
}

#pragma mark - Public init
+ (void)setup
{
    [SUCoolTool sharedInstance];
}

#pragma mark - Accelerometer delegate

- (void)handleShake:(CMAccelerometerData *)accelerometerData
{
    CMAcceleration acceleration = accelerometerData.acceleration;
    if (acceleration.x > kSUAccelerationThreshold
        || acceleration.y > kSUAccelerationThreshold
        || acceleration.z > kSUAccelerationThreshold) {
        if (self.alertView == nil && self.debugWindow == nil) {
            [self createZGestureView];
        }

    }
}

- (void)showAlert

{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedStringFromTable(@"ENTER_UI_DEBUG_MODE", @"CoolTool", @"Enter UI debug mode")
                              message:nil
                              delegate:self
                              cancelButtonTitle:NSLocalizedStringFromTable(@"CANCEL", @"CoolTool", @"Cancel")
                              otherButtonTitles:NSLocalizedStringFromTable(@"ENTER", @"CoolTool", @"Enter"),
                              nil];
    
    
    [alertView show];
    self.alertView = alertView;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1: {
            // Create grid
            [self createWindowForDebugWithImage:[SUScreenshotUtil convertViewToImage:
                                                 [[[[[UIApplication sharedApplication] windows] objectAtIndex:0] rootViewController] view]]];
        }
            break;

            
        default:
            break;
    }
}

- (void)createZGestureView
{
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    SUZGestureView *zGestureView = [[SUZGestureView alloc] initWithFrame:window.rootViewController.view.frame];
    [zGestureView.zGestureRecognizer addTarget:self action:@selector(showAlert)];
    [window.rootViewController.view addSubview:zGestureView];
}

- (void)createWindowForDebugWithImage:(UIImage *)image
{
    self.parentWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    self.debugWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    SUGridViewController *viewController = [[SUGridViewController alloc] initWithScreenshotImage:[SUScreenshotUtil convertViewToImage:
                                                                                                  [[[[[UIApplication sharedApplication] windows] objectAtIndex:0] rootViewController] view]]];
    viewController.delegate = self;
    self.debugWindow.rootViewController = viewController;
    self.parentWindow.hidden = YES;
    [self.debugWindow makeKeyAndVisible];
}

- (void)removeWindowForDebug
{
    self.parentWindow.hidden = NO;
    self.debugWindow = nil;
    [self.alertView dismissWithClickedButtonIndex:0 animated:NO];
}

#pragma mark - Orientation handling
- (void)orientationChanged:(NSNotification *)notification
{
    [self.debugWindow.rootViewController.view setNeedsLayout];
    [((SUGridViewController *)self.debugWindow.rootViewController).gridRootView layoutViewsDependingOnOrientation];
}

- (void)tapOnCloseButton
{
    [self removeWindowForDebug];
}

@end
