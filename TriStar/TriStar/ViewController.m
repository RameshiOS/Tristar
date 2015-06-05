//
//  ViewController.m
//  TriStar
//
//  Created by Manulogix on 09/12/13.
//  Copyright (c) 2013 Manulogix. All rights reserved.
//

#import "ViewController.h"
#import "SBJson.h"


@interface ViewController ()

@end

@implementation ViewController
@synthesize userNameField;
@synthesize passwordField;
@synthesize loginButton;
- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;

    UIColor *color = [FAUtilities getUIColorObjectFromHexString:@"#D7D7D7" alpha:1];
    self.view.backgroundColor = color;

    
    passwordField.layer.borderWidth = 2.0f;
    passwordField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    passwordField.layer.cornerRadius = 8;
    passwordField.clipsToBounds      = YES;
    
    
    userNameField.layer.borderWidth = 2.0f;
    userNameField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    userNameField.layer.cornerRadius = 8;
    userNameField.clipsToBounds      = YES;
    
    UIView *leftView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 35)];
    passwordField.leftView = leftView1;
    passwordField.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *leftView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 35)];
    userNameField.leftView = leftView2;
    userNameField.leftViewMode = UITextFieldViewModeAlways;
    
}
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    passwordField.text = @"";
}
-(void) textFieldDidBeginEditing:(UITextField *)textField {
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
        [self animateTextField:textField up:YES];
    }
}

-(void) textFieldDidEndEditing:(UITextField *)textField {
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
        [self animateTextField:textField up:NO];
    }
} 

//This method is to animate the view based on the text field clicked
- (void) animateTextField:(UITextField*)textField up:(BOOL)up {
    
    int movementDistance = 0;
    if(textField == userNameField) movementDistance = 40;
    else if(textField == passwordField) movementDistance = 100;
    float movementDuration = 0.3f; // tweak as needed
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"loginScreen" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

-(IBAction)loginBtnClicked:(id)sender{
    [self.view endEditing:YES];

    if (IS_EMPTY(userNameField.text)) {
        [FAUtilities showAlert:USER_EMPTY_EMAIL withTitle:@""];
        return;
    } else if (IS_EMPTY(passwordField.text)) {
        [FAUtilities showAlert:USER_EMPTY_PWD withTitle:@""];
        return;
    }
    [self postRequest:LOGIN_TYPE];
}

-(void)postRequest:(NSString *)reqType{
    NSMutableDictionary *test = [[NSMutableDictionary alloc]init];
    [test setObject:userNameField.text forKey:@"Username"];
    [test setObject:passwordField.text forKey:@"Password"];
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        [standardUserDefaults setObject:test forKey:@"LoginDetails"];
        [standardUserDefaults synchronize];
    }

    
    NSString *formattedBodyStr = [self jsonFormat:LOGIN_TYPE withDictionary:test];
    NSString *postDataInString = [NSString stringWithFormat: @"{\"JsonRequest\":\"%@\"}",formattedBodyStr];
    
    NSData *postJsonData = [postDataInString dataUsingEncoding:NSUTF8StringEncoding];
    webServiceInterface = [[WebServiceInterface alloc]initWithVC:self];
    webServiceInterface.delegate =self;
    NSString *REQ_URL;
  
    if ([userNameField.text isEqualToString:@"demouser"]) {
        REQ_URL = @"http://portal.tristarcnc.com/TriStarServicedev/Tristarservice.svc/ProcessRequest";
    }else{
        REQ_URL = @"http://portal.tristarcnc.com/TriStarService/Tristarservice.svc/ProcessRequest";//live URl
    }

    
    
//  REQ_URL = @"http://portal.tristarcnc.com/TriStarServicedev/Tristarservice.svc/ProcessRequest";//test dev
  //REQ_URL = @"http://portal.tristarcnc.com/TriStarService/Tristarservice.svc/ProcessRequest";
    
//    shabbir's system
//    REQ_URL = @"http://192.168.137.14/TCS_SERVICE/TriStarService.svc/ProcessRequest";
//    Bhavani's system
 //   REQ_URL = @"http://192.168.137.229/TriStarService/Tristarservice.svc/ProcessRequest";
//    REQ_URL = @"http://portal.tristarcnc.com/TriStarServicedev/Tristarservice.svc/ProcessRequest";

    
//    REQ_URL = @"http://192.168.137.16/TriStarService/TriStarService.svc/ProcessRequest";
    
//    REQ_URL = @"http://192.168.137.1/TriStarService/TriStarService.svc/ProcessRequest";
  
//      REQ_URL = @"http://192.168.137.25/TriStarService/TriStarService.svc/ProcessRequest";
    
 //    REQ_URL = @"http://192.168.137.242/TCS_PUBSVC/TriStarService.svc/ProcessRequest";

    
//      REQ_URL = @"http://192.168.137.25/TriStarService/TriStarService.svc/ProcessRequest";

//    REQ_URL = @"http://192.168.137.61/TCSSvc/TriStarService.svc/ProcessRequest";
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (userDefaults) {
        [userDefaults setObject:REQ_URL forKey:@"RequestURL"];
        [userDefaults synchronize];
    }
    [webServiceInterface sendRequest:postDataInString PostJsonData:postJsonData Req_Type:reqType Req_url:REQ_URL];
}


-(NSString*)jsonFormat:(NSString *)type withDictionary:(NSMutableDictionary *)formatDict{
    
    NSString *bodyStr = [NSString stringWithFormat:@"{Type:\\\"%@\\\",Authentication:{UserName:\\\"%@\\\", Password:\\\"%@\\\"}}", type,[formatDict valueForKey:@"Username" ], [formatDict valueForKey:@"Password"]];
    return bodyStr;
}


-(void)getResponse:(NSDictionary *)resp type:(NSString *)respType{
    
    NSLog(@"resp %@", resp);

    NSDictionary *statusDict = [resp valueForKey:@"Status"];
    NSDictionary *dataDict = [resp valueForKey:@"Data"];
    NSLog(@"status %@", statusDict);
    
    
    NSString *statusVal = [statusDict objectForKey:@"STATUS"];
    NSString *statusDesc = [statusDict objectForKey:@"DESCRIPTION"];
    NSLog(@"status %@ - %@", statusVal,statusDesc);

    if ([statusVal isEqualToString:@"1"]) {
        
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]init];
        tempDict = [dataDict mutableCopy];
        
        
        for( id key in [tempDict allKeys] )
        {
            if( [[tempDict valueForKey:key] isKindOfClass:[NSNull class]] )
            {
                // doesn't work - values that are entered will never be removed from NSUserDefaults
                //[dict removeObjectForKey:key];
                [tempDict setObject:@"" forKey:key];
            }
        }
        
        
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        if (standardUserDefaults) {
            [standardUserDefaults setObject:tempDict forKey:@"UserDetails"];
            [standardUserDefaults synchronize];
        }

        
        NSLog(@"temp dict %@", [tempDict objectForKey:@"Role"]);
        
        NSArray *rolesAry = [[tempDict objectForKey:@"Role"] componentsSeparatedByString:@","];

        NSLog(@"roles Ary %@", rolesAry);
        NSString *purchaseStr;
        NSString *repairStr;
        NSString *shippingStr;
        
        
//        for chinking management role
        
        BOOL isManagement;
        
        for (int i=0; i<[rolesAry count]; i++) {
            NSString *tempValue = [rolesAry objectAtIndex:i];
            if ([tempValue isEqualToString:@"Management"]) {
                isManagement = YES;
                break;
            }else{
                isManagement = NO;
                continue;
            }
        }
        NSUserDefaults *defaults = [[NSUserDefaults alloc]init];
        
        if (isManagement == YES) {
            [defaults setObject:@"Manager" forKey:@"DocumentsAccessRole"];
        }else{
            [defaults setObject:@"" forKey:@"DocumentsAccessRole"];
        }
        [defaults synchronize];
        
        
        
        

        for (int i=0; i<[rolesAry count]; i++) {
            NSString *tempValue = [rolesAry objectAtIndex:i];
            if ([tempValue isEqualToString:@"Purchase"]) {
                purchaseStr = tempValue;
            }
            if ([tempValue isEqualToString:@"Repair"]) {
                repairStr = tempValue;
            }
            if ([tempValue isEqualToString:@"Shipping"]) {
                shippingStr = tempValue;
            }
        }
        
        if (purchaseStr.length ==0 && repairStr.length ==0 && shippingStr.length ==0) {
            [FAUtilities showAlert:@"You are not authorized. Role should be 'Repair or shipping or Purchase'" withTitle:@""];
        }else{
            HomeViewController *vc1 = [[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil];
            vc1.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Find PO" image:nil tag:0];
            vc1.rolesArray = rolesAry;
            [UIView animateWithDuration:0.75 animations:^{[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];[self.navigationController pushViewController:vc1 animated:NO];[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];}];
        }

        
        
        

    }else{
        [FAUtilities showAlert:statusDesc withTitle:@""];

    }
}

#pragma mark -
#pragma mark Orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
    
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


@end
