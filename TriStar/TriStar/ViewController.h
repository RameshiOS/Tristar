//
//  ViewController.h
//  TriStar
//
//  Created by Manulogix on 09/12/13.
//  Copyright (c) 2013 Manulogix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FAUtilities.h"
#import "WebServiceInterface.h"
#import "HomeViewController.h"
#import "WebServiceInterface.h"

@interface ViewController : UIViewController<UITabBarControllerDelegate,UITextFieldDelegate,WebServiceInterfaceDelegate>{
    IBOutlet UITextField    *userNameField;
    IBOutlet UITextField    *passwordField;
    IBOutlet UIButton    *loginButton;

    WebServiceInterface *webServiceInterface;
}
@property(nonatomic,retain) IBOutlet UIButton    *loginButton;
@property(nonatomic,retain) IBOutlet UITextField *userNameField;
@property(nonatomic,retain) IBOutlet UITextField *passwordField;
-(IBAction)loginBtnClicked:(id)sender;

@end
