//
//  SplashViewController.m
//  TriStar
//
//  Created by Manulogix on 09/12/13.
//  Copyright (c) 2013 Manulogix. All rights reserved.
//

#import "SplashViewController.h"

@interface SplashViewController ()
@end

@implementation SplashViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"splash_Landscape.png"]];
    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"splash_Portrait.png"]];
    }
    
    tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToContinue:)];
    tapGesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGesture];
}

-(void)tapToContinue:(id)sender{
    viewController = [[ViewController alloc]initWithNibName:@"ViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){//setting the form list table frame when returing back to the form list view
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"splash_Portrait.png"]];
    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"splash_Landscape.png"]];
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end
