//
//  AppDelegate.h
//  TriStar
//
//  Created by Manulogix on 09/12/13.
//  Copyright (c) 2013 Manulogix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplashViewController.h"
//@class ViewController;
@class SplashViewController;
@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@property (strong, nonatomic) SplashViewController *splashViewController;
@property (nonatomic,retain) UINavigationController *navigationController;

@end
