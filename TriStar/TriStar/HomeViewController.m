//
//  HomeViewController.m
//  TriStar
//
//  Created by Manulogix on 11/12/13.
//  Copyright (c) 2013 Manulogix. All rights reserved.
//

#import "HomeViewController.h"
#import "OverlayView.h"
#import "GetPOViewController.h"
#import "GetRAViewController.h"
#import "PartListCell.h"
#import "GetPartViewController.h"

@interface HomeViewController ()<DjuPickerViewDelegate, DjuPickerViewDataSource>
@end

@implementation HomeViewController

@synthesize findPoSearchByValField;//findpo
@synthesize findRaSearchByValField;//find ra
@synthesize getRaSearchByValField;//get ra

@synthesize rolesArray; // Roles Ary

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    
    self.tabBarController.navigationItem.hidesBackButton=YES;
    self.tabBarController.navigationController.navigationBarHidden = NO;
    self.tabBarController.title = PURCHESED_ORDER_LIST;
   
    if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
        findPoSubView.frame =CGRectMake(0, 0, 770, 880);
        findRaSubView.frame =CGRectMake(0, 0, 770, 880);
        getRaSubView.frame =CGRectMake(0, 0, 770, 880);
        adjustPartsSubView.frame =CGRectMake(0, 0, 770, 880);
        
    }else if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
        findPoSubView.frame =CGRectMake(0, 0, 1024, 640);
        findRaSubView.frame =CGRectMake(0, 0, 1024, 640);
        getRaSubView.frame =CGRectMake(0, 0, 1024, 640);
        adjustPartsSubView.frame =CGRectMake(0, 0, 1024, 640);
    }
    
    
    if (orientationFlag == NO) {
        [filter removeFromSuperview];
        if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
            if ([tabArray count] !=0 ) {
                filter = [[SEFilterControl alloc]initWithFrame:CGRectMake(55, 700, 934,60) Titles:tabArray];
                filter.backgroundColor = [UIColor clearColor];
            }
        }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
            if ([tabArray count] !=0 ) {
                filter = [[SEFilterControl alloc]initWithFrame:CGRectMake(55, 950, 678, 70) Titles:tabArray];
                filter.backgroundColor = [UIColor clearColor];
            }
        }
    }

    
    if ([tabArray count] !=0) {
        filter.backgroundColor = [UIColor clearColor];
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"filterBackground.png"]];
        [filter setSelectedIndex:tabBarIndex];
        [filter addTarget:self action:@selector(filterValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:filter];
    }else{
        if ([currentViewStr isEqualToString:@"Repair"]) {
            [self.view addSubview:findRaSubView];
            [findRaRecordsTableView reloadData];
        }
    }
    
    
    [findPoRecordsTableView reloadData];
    [findRaRecordsTableView reloadData];
    [partsTableView reloadData];
    
    
//    [getRaDetailsTableView reloadData];
    orientationFlag = NO;
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *currentView = [standardUserDefaults objectForKey:@"CurrentView"];
    if (currentView.length !=0) {
        if ([currentView isEqualToString:@"ViewLoad"]) {
            if ([partsAry count] == 0) {
                partsTableView.hidden = YES;
            }else{
                partsTableView.hidden = NO;
            }
        }else{
            partsTableView.hidden = YES;
            [self tempMethod];
            [standardUserDefaults setObject:@"" forKey:@"CurrentView"];
        }
    }else{
        if ([partsAry count] == 0) {
            partsTableView.hidden = YES;
        }else{
            partsTableView.hidden = NO;
        }
//        partsTableView.hidden = NO;
    }
}

-(void)tempMethod{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *currentView = [standardUserDefaults objectForKey:@"CurrentView"];
    NSString *partNum = [standardUserDefaults objectForKey:@"Part#"];
    if ([currentView isEqualToString:@"POCheckIn"]) {
        [self poCheckInBtnClickedWithPart:partNum];
    }else if ([currentView isEqualToString:@"RACheckIn"]){
        [self raCheckInBtnClickedWithPart:partNum];
    }else if ([currentView isEqualToString:@"RACheckOut"]){
        [self raCheckOutBtnClickedWithPart:partNum];
    }
}



- (void)viewDidLoad{
    [super viewDidLoad];
    
    orientationFlag = NO;
    
    findPoSearchByValField.layer.borderWidth = 2.0f;
    findPoSearchByValField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    findPoSearchByValField.layer.cornerRadius = 8;
    findPoSearchByValField.clipsToBounds      = YES;
    UIView *leftView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 35)];
    findPoSearchByValField.leftView = leftView1;
    findPoSearchByValField.leftViewMode = UITextFieldViewModeAlways;
    
    currentFindPOSeachValue = @"Part#";
    currentFindRASeachValue = @"Part#";
    
    findRaSearchByValField.layer.borderWidth = 2.0f;
    findRaSearchByValField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    findRaSearchByValField.layer.cornerRadius = 8;
    findRaSearchByValField.clipsToBounds      = YES;
    UIView *leftView3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 35)];
    findRaSearchByValField.leftView = leftView3;
    findRaSearchByValField.leftViewMode = UITextFieldViewModeAlways;
    
    getRaSearchByValField.layer.borderWidth = 2.0f;
    getRaSearchByValField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    getRaSearchByValField.layer.cornerRadius = 8;
    getRaSearchByValField.clipsToBounds      = YES;
    UIView *leftView4 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 35)];
    getRaSearchByValField.leftView = leftView4;
    getRaSearchByValField.leftViewMode = UITextFieldViewModeAlways;
    
    getAdjustPartSearchByValField.layer.borderWidth = 2.0f;
    getAdjustPartSearchByValField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    getAdjustPartSearchByValField.layer.cornerRadius = 8;
    getAdjustPartSearchByValField.clipsToBounds      = YES;
    UIView *leftView5 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 35)];
    getAdjustPartSearchByValField.leftView = leftView5;
    getAdjustPartSearchByValField.leftViewMode = UITextFieldViewModeAlways;
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBarHidden = NO;
    
    UIBarButtonItem *logOutBtn = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logout:)];
    [[UIBarButtonItem appearance]setTintColor:[UIColor colorWithRed:26.0f/255.0f green:62.0f/255.0f blue:138.0f/255.0f alpha:1.0f]];
    self.navigationItem.rightBarButtonItem = logOutBtn;

    
    
    self.navigationController.navigationBarHidden = NO;
    recivedQTY = [[NSMutableDictionary alloc]init];
    
    findPoPickerValues = [[NSArray alloc]initWithObjects:@"PO#",@"Vendor",@"Part#", nil];
    
    poStatusValuesFromResp = [[NSMutableDictionary alloc]init];
    raStatusValuesFromResp = [[NSMutableDictionary alloc]init];
    
    
    totalPoStatusValues = [[NSMutableDictionary alloc]init];
    totalRaStatusValues = [[NSMutableDictionary alloc]init];
    
    
    
    
    UIColor *color = [FAUtilities getUIColorObjectFromHexString:@"#9F9FA0" alpha:1];
    searchViewForFindPO.backgroundColor = color;
    searchViewForFindRA.backgroundColor = color;
    searchViewForAdjustParts.backgroundColor = color;
    
    
    
    UIColor *headingColor = [FAUtilities getUIColorObjectFromHexString:@"#314F9B" alpha:1];
    partDetailsHeadingViewInAdjustParts.backgroundColor = headingColor;
    
    
    
    usedQTY = [[NSMutableDictionary alloc]init];
    tableFindPOHeading = [[NSArray alloc]initWithObjects:@"PO#",@"Vendor",@"Created On",@"Amount", nil];
    [self.view addSubview:findPoSubView];

    
    NSString *purchaseStr;
    NSString *repairStr;
    NSString *shippingStr;
    
    NSLog(@"rolesArray %@",rolesArray);
    for (int i=0; i<[rolesArray count]; i++) {
        NSString *tempValue = [rolesArray objectAtIndex:i];
//        if ([tempValue isEqualToString:@"Purchase"]) {
        
        if ([tempValue isEqualToString:@"Purchasing"]) {
            purchaseStr = tempValue;
        }
        if ([tempValue isEqualToString:@"Repair"]) {
            repairStr = tempValue;
        }
        if ([tempValue isEqualToString:@"Shipping"]) {
            shippingStr = tempValue;
        }
    }

    if (purchaseStr.length !=0 && repairStr.length !=0 && shippingStr.length !=0) {
        tabArray = [[NSArray alloc]initWithObjects:@"Purchasing Orders",@"Repairs",@"Parts", nil];
        self.navigationItem.title = @"Find Purchase Orders";
    }else if (shippingStr.length !=0){
        tabArray = [[NSArray alloc]initWithObjects:@"Purchasing Orders",@"Repairs", nil];
        self.navigationItem.title = @"Find Purchase Orders";
    }else if (purchaseStr.length !=0){
        tabArray = [[NSArray alloc]initWithObjects:@"Purchasing Orders",@"Parts", nil];
        currentViewStr = @"Purchase";        
        self.navigationItem.title = @"Find Purchase Orders";
    }else if (repairStr.length !=0){
        NSLog(@"No filter");
        currentViewStr = @"Repair";

//        CGRect frameRect = findRaRecordsTableView.frame;
//        frameRect.size.height = findRaRecordsTableView.frame.size.height +100;
//        findRaRecordsTableView.frame = frameRect;
        
//        CGRect *temp = CGRectMake(findRaRecordsTableView.frame.origin.x, findRaRecordsTableView.frame.origin.y, findRaRecordsTableView.frame.size.width, findRaRecordsTableView.frame.size.height);
        
        self.navigationItem.title = @"Find Repair Authorization";
    }
    
//    tabArray = [[NSArray alloc]initWithObjects:@"Purchase Orders",@"Repairs",@"Parts", nil];
    
//    self.navigationItem.title = @"Find Purchase Orders";
    
    tableGetRAHeading = [[NSArray alloc]initWithObjects:@"",@"Line#",@"Part#",@"Required Qty",@"Used Qty",@"Status",@"Price($)",@"Total($)", nil];

    findRaPickerValues = [[NSArray alloc]initWithObjects:@"RA#",@"Customer",@"Part#", nil];
    tableFindRAHeading = [[NSArray alloc]initWithObjects:@"RA#",@"Customer",@"Customer Ref#",@"Customer PO#",@"Received Date",@"Status",nil];
    partsHeadingValues = [[NSArray alloc]initWithObjects:@"Patr#",@"BarCode",@"Instock",@"Location", nil];
    
    
    
    savePoDetailsDictArray = [[NSMutableArray alloc]init];
    savePoDictionary = [[NSMutableDictionary alloc]init];
    
    saveRaDetailsDictArray = [[NSMutableArray alloc]init];
    saveRaDictionary = [[NSMutableDictionary alloc]init];
    
    
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
        keyboardHeight = 264 + 44;
    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
        keyboardHeight = 352 + 44;
    }
    
    // Zbarreader
    
    // must be created in view did load , to avoid multiple click loading problem
    
    [ZBarReaderViewController class];
    reader =[ZBarReaderViewController new];
    reader.readerDelegate = self;
    ZBarImageScanner *scanner = reader.scanner;
    [scanner setSymbology: ZBAR_CODE128 config: ZBAR_CFG_ENABLE to: 1];
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    OverlayView *overlay = [[OverlayView alloc] init];
    reader.cameraOverlayView = overlay;
    reader.wantsFullScreenLayout = NO;
    reader.modalPresentationStyle = UIModalPresentationFormSheet;
    reader.showsZBarControls = NO;
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        [standardUserDefaults setObject:@"ViewLoad" forKey:@"CurrentView"];
        [standardUserDefaults synchronize];
    }

}


- (void) focusAtPoint:(CGPoint)point
{
    CGRect rect = CGRectMake(point.x-30, point.y-30, 160, 60);
    UIView *focusRect = [[UIView alloc] initWithFrame:rect];
    focusRect.layer.borderColor = [UIColor whiteColor].CGColor;
    focusRect.layer.borderWidth = 2;
    focusRect.tag = 99;
    
    
    NSArray *devices = [AVCaptureDevice devices];
    for (AVCaptureDevice *device in devices){
        if ([device hasMediaType:AVMediaTypeVideo]) {
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
                NSError *error;
                
                if ([device lockForConfiguration:&error]) {
                    
                    [device setFocusPointOfInterest:point];
                    [device setFocusMode:AVCaptureFocusModeAutoFocus];
                                        
                    
                    [reader.cameraOverlayView addSubview:focusRect];
                    
                    
                    [device unlockForConfiguration];
                }else{
                    
                }
        }
    }
  }
}

#pragma mark -
#pragma mark TabBar Filter Method
-(void)filterValueChanged:(SEFilterControl *) sender{
    
    tabBarIndex = filter.SelectedIndex;
    
    if (tabBarIndex == 2) {
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        NSString *currentView = [standardUserDefaults objectForKey:@"CurrentView"];
        if ([currentView isEqualToString:@"ViewLoad"]) {
            
        }else{
            if ([partsAry count] == 0) {
                partsTableView.hidden = YES;
            }else{
                partsTableView.hidden = NO;
            }

//            partsTableView.hidden = NO;
        }
    }
    
    isCameraPresent = NO;
    
    NSLog(@"%@ selected index", [NSString stringWithFormat:@"%d", sender.SelectedIndex]);
    NSString *currentSelectedTab = [tabArray  objectAtIndex:sender.SelectedIndex];
    NSArray *subViews = [self.view subviews];
    UIView *previousSubView,*currentSubView;
    
    for (int i=0; i<[subViews count]; i++) {
        UIView *view = [subViews objectAtIndex:i];
        if ([view isKindOfClass:[UIControl class]]) {
            NSLog(@"UIcontrol ");
        }else if ([view isKindOfClass:[MBProgressHUD class]]){
            NSLog(@"MD progress ");
        }else{
            UIView *tempView = (UIView *)view;
            
            if (tempView.tag == 5000) {
                NSLog(@"camera view ");
                isCameraPresent = YES;
                barCodeReaderView = (UIView *)view;
            }else{
                NSLog(@"previousSubView %@", previousSubView);
                previousSubView = (UIView *)view;
            }
        }
    }
    
    
    filter.hidden = YES;
    
    if ([currentSelectedTab isEqualToString:@"Purchasing Orders"]) {
        
        findPoPickerValues = [[NSArray alloc]initWithObjects:@"PO#",@"Vendor",@"Part#", nil];
        tableFindPOHeading = [[NSArray alloc]initWithObjects:@"PO#",@"Vendor",@"Created On",@"Amount", nil];
        self.navigationItem.title = @"Find Purchase Orders";
        currentSubView = findPoSubView;
        
        [findPoRecordsTableView reloadData];
    }
    else if ([currentSelectedTab isEqualToString:@"Repairs"]){
        self.navigationItem.title = @"Find Repair Authorization";
        currentSubView = findRaSubView;
        [findRaRecordsTableView reloadData];
    }
    else{
        self.navigationItem.title = @"Adjust Parts";
        currentSubView = adjustPartsSubView;
        if ([partsAry count] == 0) {
            partsTableView.hidden = YES;
        }else{
            partsTableView.hidden = NO;
        }
    }
    
    if ([currentSubView isEqual:previousSubView]) {
        [self.view addSubview:currentSubView];
        filter.hidden = NO;
        if (isCameraPresent == YES) {
            [currentSubView addSubview:barCodeReaderView];
            isCameraPresent = NO;
        }
        
    }else{
        isCameraPresent = NO;
        if (isCameraPresent == NO) {
            [self cameraCancelBtnClicked:nil];
        }

        [previousSubView removeFromSuperview];
        [self.view sendSubviewToBack:previousSubView];
        [self.view addSubview:currentSubView];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1.0];
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.view cache:NO];
        [UIView commitAnimations];
        filter.hidden = NO;
    }
}

#pragma mark - TabBar Filter Controller Actions
-(IBAction)findPOGoBtnClicked:(id)sender{
    [self.view endEditing:YES];
    
    if (sender == nil) {
        NSLog(@"Need To heighlet particularpart");
        isPoPartSelected = YES;
    }else{
        isPoPartSelected = NO;
    }
    
    
    if ([findPoSearchByValField.text isEqualToString:@""]) {
        [FAUtilities showAlert:@"Enter value to search" withTitle:@""];
        return;
    }
    
    if ([currentFindPOSeachValue isEqualToString:@"PO#"]) {
        NSRegularExpression *regex = [[NSRegularExpression alloc]
                                       initWithPattern:@"[a-zA-Z]" options:0 error:NULL];
        
        // Assuming you have some NSString `myString`.
        NSUInteger matches = [regex numberOfMatchesInString:findPoSearchByValField.text options:0
                                                      range:NSMakeRange(0, [findPoSearchByValField.text length])];
        
        if (matches > 0) {
            [FAUtilities showAlert:@"Enter only intergers for PO#" withTitle:@""];
            return;
        }
    }
    
    
    findPoRecords = [[NSArray alloc]init];
    [findPoRecordsTableView reloadData];
    [self postRequest:FIND_PO_TYPE];
}


-(IBAction)findPOCancelBtnClicked:(id)sender{

    [self.view endEditing:YES];
    
    findPoSearchByValField.text= @"";
    findPoRecords = [[NSArray alloc]init];
    findPoRecordsTableView.hidden = YES;
}



-(IBAction)findRAGoBtnClicked:(id)sender{
    [self.view endEditing:YES];
    
    
    if (sender == nil) {
        NSLog(@"Need To heighlet particularpart");
        isRaPartSelected = YES;
    }else{
        isRaPartSelected = NO;
    }

    
    if ([findRaSearchByValField.text isEqualToString:@""]) {
        [FAUtilities showAlert:@"Enter value to search" withTitle:@""];
        return;
    }
    
    if ([currentFindRASeachValue isEqualToString:@"RA#"]) {
        NSRegularExpression *regex = [[NSRegularExpression alloc]
                                      initWithPattern:@"[a-zA-Z]" options:0 error:NULL];
        
        // Assuming you have some NSString `myString`.
        NSUInteger matches = [regex numberOfMatchesInString:findRaSearchByValField.text options:0
                                                      range:NSMakeRange(0, [findRaSearchByValField.text length])];
        
        if (matches > 0) {
            [FAUtilities showAlert:@"Enter only intergers for RA#" withTitle:@""];
            return;
        }
    }
    
    findRaRecords = [[NSArray alloc]init];
    [findRaRecordsTableView reloadData];

    [self postRequest:FIND_RA_TYPE];
}

-(IBAction)findRACancelBtnClicked:(id)sender{
    [self.view endEditing:YES];

    findRaSearchByValField.text =@"";
    findRaRecords = [[NSArray alloc]init];
    findRaRecordsTableView.hidden = YES;

}

// find po radio Btns

-(IBAction)findPOPONumRadioBtnClicked:(id)sender{
    UIImage *radioOnImage = [UIImage imageNamed:@"radioOn.png"]; //the radioButton image when selected
    UIImage *radioOffImage = [UIImage imageNamed:@"radioOff.png"]; //the radioButton image when not selected

    
    [findPoSearchByValField setKeyboardType:UIKeyboardTypeNumberPad];
    [findPoSearchByValField becomeFirstResponder];
    [findPoSearchByValField reloadInputViews];

    
    [findPOPONumRadioBtn setBackgroundImage:radioOnImage forState:UIControlStateNormal];
    [findPOPONumRadioBtn setBackgroundImage:radioOnImage forState:UIControlStateSelected];
    [findPOPONumRadioBtn setBackgroundImage:radioOnImage forState:UIControlStateHighlighted];
    currentFindPOSeachValue = @"PO#";
    
    [findPOvendorRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateNormal];
    [findPOvendorRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateSelected];
    [findPOvendorRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateHighlighted];

    [findPOPartNumRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateNormal];
    [findPOPartNumRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateSelected];
    [findPOPartNumRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateHighlighted];

    
}
-(IBAction)findPOVendorRadioBtnClicked:(id)sender{
    UIImage *radioOnImage = [UIImage imageNamed:@"radioOn.png"]; //the radioButton image when selected
    UIImage *radioOffImage = [UIImage imageNamed:@"radioOff.png"]; //the radioButton image when  not selected
    
  
    [findPoSearchByValField setKeyboardType:UIKeyboardTypeDefault];
    [findPoSearchByValField becomeFirstResponder];
    [findPoSearchByValField reloadInputViews];

    
    [findPOPONumRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateNormal];
    [findPOPONumRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateSelected];
    [findPOPONumRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateHighlighted];
    
    [findPOvendorRadioBtn setBackgroundImage:radioOnImage forState:UIControlStateNormal];
    [findPOvendorRadioBtn setBackgroundImage:radioOnImage forState:UIControlStateSelected];
    [findPOvendorRadioBtn setBackgroundImage:radioOnImage forState:UIControlStateHighlighted];
    currentFindPOSeachValue = @"Vendor";
    
    
    [findPOPartNumRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateNormal];
    [findPOPartNumRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateSelected];
    [findPOPartNumRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateHighlighted];

}

-(IBAction)findPOPartNumRadioBtnClicked:(id)sender{
    
    UIImage *radioOnImage = [UIImage imageNamed:@"radioOn.png"]; //the radioButton image when selected
    UIImage *radioOffImage = [UIImage imageNamed:@"radioOff.png"]; //the radioButton image when not selected

    findPoSearchByValField.keyboardType = UIKeyboardTypeDefault;

    
    [findPOPONumRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateNormal];
    [findPOPONumRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateSelected];
    [findPOPONumRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateHighlighted];
    
    [findPOvendorRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateNormal];
    [findPOvendorRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateSelected];
    [findPOvendorRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateHighlighted];
    
    [findPOPartNumRadioBtn setBackgroundImage:radioOnImage forState:UIControlStateNormal];
    [findPOPartNumRadioBtn setBackgroundImage:radioOnImage forState:UIControlStateSelected];
    [findPOPartNumRadioBtn setBackgroundImage:radioOnImage forState:UIControlStateHighlighted];
    currentFindPOSeachValue = @"Part#";

}

// find ra radio buttons

-(IBAction)findRARaNumRadioBtnClicked:(id)sender{
    
    UIImage *radioOnImage = [UIImage imageNamed:@"radioOn.png"]; //the radioButton image when selected
    UIImage *radioOffImage = [UIImage imageNamed:@"radioOff.png"]; //the radioButton image when not selected
    
    [findRaSearchByValField setKeyboardType:UIKeyboardTypeNumberPad];
    [findRaSearchByValField becomeFirstResponder];
    [findRaSearchByValField reloadInputViews];

    [findRARaNumRadioBtn setBackgroundImage:radioOnImage forState:UIControlStateNormal];
    [findRARaNumRadioBtn setBackgroundImage:radioOnImage forState:UIControlStateSelected];
    [findRARaNumRadioBtn setBackgroundImage:radioOnImage forState:UIControlStateHighlighted];
    
    [findRACustomerRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateNormal];
    [findRACustomerRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateSelected];
    [findRACustomerRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateHighlighted];
    
    [findRAPartNumRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateNormal];
    [findRAPartNumRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateSelected];
    [findRAPartNumRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateHighlighted];
    currentFindRASeachValue = @"RA#";

}
-(IBAction)findRACustomerRadioBtnClicked:(id)sender{
    UIImage *radioOnImage = [UIImage imageNamed:@"radioOn.png"]; //the radioButton image when selected
    UIImage *radioOffImage = [UIImage imageNamed:@"radioOff.png"]; //the radioButton image when not selected
    
    [findRaSearchByValField setKeyboardType:UIKeyboardTypeDefault];
    [findRaSearchByValField becomeFirstResponder];
    [findRaSearchByValField reloadInputViews];
    
    [findRARaNumRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateNormal];
    [findRARaNumRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateSelected];
    [findRARaNumRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateHighlighted];
    
    [findRACustomerRadioBtn setBackgroundImage:radioOnImage forState:UIControlStateNormal];
    [findRACustomerRadioBtn setBackgroundImage:radioOnImage forState:UIControlStateSelected];
    [findRACustomerRadioBtn setBackgroundImage:radioOnImage forState:UIControlStateHighlighted];
    
    [findRAPartNumRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateNormal];
    [findRAPartNumRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateSelected];
    [findRAPartNumRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateHighlighted];
    currentFindRASeachValue = @"Customer";

}
-(IBAction)findRAPartNumRadioBtnClicked:(id)sender{
    UIImage *radioOnImage = [UIImage imageNamed:@"radioOn.png"]; //the radioButton image when selected
    UIImage *radioOffImage = [UIImage imageNamed:@"radioOff.png"]; //the radioButton image when not selected
    
    findRaSearchByValField.keyboardType = UIKeyboardTypeDefault;

    
    [findRARaNumRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateNormal];
    [findRARaNumRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateSelected];
    [findRARaNumRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateHighlighted];
    
    [findRACustomerRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateNormal];
    [findRACustomerRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateSelected];
    [findRACustomerRadioBtn setBackgroundImage:radioOffImage forState:UIControlStateHighlighted];
    
    [findRAPartNumRadioBtn setBackgroundImage:radioOnImage forState:UIControlStateNormal];
    [findRAPartNumRadioBtn setBackgroundImage:radioOnImage forState:UIControlStateSelected];
    [findRAPartNumRadioBtn setBackgroundImage:radioOnImage forState:UIControlStateHighlighted];
    currentFindRASeachValue = @"Part#";

}

-(IBAction)getAdjustPartsBtnClicked:(id)sender{
    [self.view endEditing:YES];
    
    if(getAdjustPartSearchByValField.text.length ==0){
        [FAUtilities showAlert:@"Please Enter Part#" withTitle:@""];
    }else{

        partsAry = [[NSArray alloc]init];
        [partsTableView reloadData];

        [self postRequest:GET_PART];
    }
}

#pragma mark -
#pragma mark WebService Methods
-(void)postRequest:(NSString *)reqType{
    NSString *postDataInString;
    if ([reqType isEqualToString:FIND_PO_TYPE]) {
        
        NSString *searchTypeVal ;
        if ([currentFindPOSeachValue isEqualToString:@"PO#"]) {
            searchTypeVal = @"ID";
        }else if ([currentFindPOSeachValue isEqualToString:@"Vendor"]){
            searchTypeVal = @"Name";
        }else{
            searchTypeVal = @"Part";
        }
        
        NSMutableDictionary *test = [[NSMutableDictionary alloc]init];
        [test setObject:searchTypeVal forKey:@"SearchKey"];
        [test setObject:findPoSearchByValField.text forKey:@"SearchValue"];
        
        
        NSString *reqValStr = [self jsonFormat:FIND_PO_TYPE withDictionary:test];
        postDataInString = [NSString stringWithFormat: @"{\"JsonRequest\":\"%@\"}",reqValStr];
        
    } else if ([reqType isEqualToString:FIND_RA_TYPE]){
        
        NSString *searchTypeVal ;
        if ([currentFindRASeachValue isEqualToString:@"RA#"]) {
            searchTypeVal = @"ID";
        }else if ([currentFindRASeachValue isEqualToString:@"Customer"]){
            searchTypeVal = @"Name";
        }else{
            searchTypeVal = @"Part";
        }
        
        NSMutableDictionary *test = [[NSMutableDictionary alloc]init];
        [test setObject:searchTypeVal forKey:@"SearchKey"];
        [test setObject:findRaSearchByValField.text forKey:@"SearchValue"];

        NSString *reqValStr = [self jsonFormat:FIND_RA_TYPE withDictionary:test];
        postDataInString = [NSString stringWithFormat: @"{\"JsonRequest\":\"%@\"}",reqValStr];
    }

    else if ([reqType isEqualToString:GET_PART]){
        NSMutableDictionary *test = [[NSMutableDictionary alloc]init];
        [test setObject:getAdjustPartSearchByValField.text forKey:@"BARCodeOrPart"];
        NSString *reqValStr = [self jsonFormat:GET_PART withDictionary:test];
        postDataInString = [NSString stringWithFormat: @"{\"JsonRequest\":\"%@\"}",reqValStr];
    }
    
    NSData *postJsonData = [postDataInString dataUsingEncoding:NSUTF8StringEncoding];
    webServiceInterface = [[WebServiceInterface alloc]initWithVC:self];
    webServiceInterface.delegate =self;
   
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *reqUrl = [userDefaults objectForKey:@"RequestURL"];
    [webServiceInterface sendRequest:postDataInString PostJsonData:postJsonData Req_Type:reqType Req_url:reqUrl];

//    [webServiceInterface sendRequest:postDataInString PostJsonData:postJsonData Req_Type:reqType Req_url:REQ_URL];
}


-(void)getResponse:(NSDictionary *)resp type:(NSString *)respType{
    
    if ([respType isEqualToString:FIND_PO_TYPE]) {
        
        NSDictionary *findPOStatusDict = [resp valueForKey:@"Status"];
        NSDictionary *findPODataDict = [resp valueForKey:@"Data"];
        
        NSString *statusVal = [findPOStatusDict objectForKey:@"STATUS"];
        NSString *statusDesc = [findPOStatusDict objectForKey:@"DESCRIPTION"];
        NSLog(@"status %@ - %@", statusVal,statusDesc);
        
        if ([statusVal isEqualToString:@"0"]) {
            [FAUtilities showAlert:statusDesc withTitle:@""];
        }else{
            
            findPoRecords = [resp valueForKey:@"Data"];
            if ([findPoRecords count] !=0) {
                NSLog(@"findPODataDict %@", findPODataDict);
                findPoRecordsTableView.hidden = NO;
                [findPoRecordsTableView reloadData];
                findPoRecordsTableView.layer.borderWidth = 4;
                findPoRecordsTableView.layer.cornerRadius = 4;
                findPoRecordsTableView.layer.borderColor = (__bridge CGColorRef)([UIColor darkGrayColor]);
            }

        }
    } else if ([respType isEqualToString:FIND_RA_TYPE]){
        
        NSDictionary *findRAStatusDict = [resp valueForKey:@"Status"];
        NSDictionary *findRADataDict = [resp valueForKey:@"Data"];
        
        NSString *statusVal = [findRAStatusDict objectForKey:@"STATUS"];
        NSString *statusDesc = [findRAStatusDict objectForKey:@"DESCRIPTION"];
        NSLog(@"status %@ - %@", statusVal,statusDesc);

        if ([statusVal isEqualToString:@"0"]) {
            [FAUtilities showAlert:statusDesc withTitle:@""];
        }else{
            
            findRaRecords = [resp valueForKey:@"Data"];
            if ([findRaRecords count] !=0) {
                NSLog(@"findPODataDict %@", findRADataDict);
                findRaRecordsTableView.hidden = NO;
                [findRaRecordsTableView reloadData];
                findRaRecordsTableView.layer.borderWidth = 4;
                findRaRecordsTableView.layer.cornerRadius = 4;
                findRaRecordsTableView.layer.borderColor = (__bridge CGColorRef)([UIColor darkGrayColor]);
            }
            
        }
    }
    
    else if ([respType isEqualToString:GET_PART]){
        
        if (resp != NULL) {
            NSDictionary *getPartStatusDict = [resp valueForKey:@"Status"];
            partsAry = [resp valueForKey:@"Data"];
            NSString *statusVal = [getPartStatusDict objectForKey:@"STATUS"];
            NSString *statusDesc = [getPartStatusDict objectForKey:@"DESCRIPTION"];
            NSLog(@"status %@ - %@", statusVal,statusDesc);
            
            if ([statusVal isEqualToString:@"0"]) {
                [FAUtilities showAlert:statusDesc withTitle:@""];
            }else{
                if ([partsAry count] !=0) {
                    NSLog(@"partsAry %@", partsAry);
                    partsTableView.hidden = NO;
                    [partsTableView reloadData];
                    partsTableView.layer.borderWidth = 4;
                    partsTableView.layer.cornerRadius = 4;
                    partsTableView.layer.borderColor = (__bridge CGColorRef)([UIColor darkGrayColor]);
                }
            }
            
            NSDictionary *getPartDict = [resp valueForKey:@"getPart"];
            NSDictionary *partDict = [getPartDict valueForKey:@"partDetails"];
            NSLog(@"partDict %@", partDict);
        }else{
            [FAUtilities showAlert:@"Unable to read response, Please try again" withTitle:@""];
        }
    }
}

#pragma mark -
#pragma mark ZBarReaderDelegate

-(IBAction)readBarCodeBtnClicked:(id)sender{
    
    [self.view endEditing:YES];
    
    readBarCodeButton = (UIButton*)sender;
    
    if (readBarCodeButton ==findPoBarcodeBtn){
          [self findPOPartNumRadioBtnClicked:nil];
    }else if (readBarCodeButton ==findRaBarcodeBtn){
          [self findRAPartNumRadioBtnClicked:nil];
    }

    
     if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
        NSLog(@"Landscape mode");
    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
        NSLog(@"Portrait mode");
    }

    NSLog(@"scanner showed.");
    NSLog(@"test Reader %@", reader);
    
    tempReaderVC = [[UIViewController alloc]init];
    tempReaderVC.view.frame = CGRectMake(0, 0, 540, 620);
    [self presentCustomModalViewController:reader];
    
}


-(void)presentCustomModalViewController:(UIViewController *)theController
{
    float x,y,width,height;
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
        x = 244;
        y = 310;
    }else {
        x = 114;
        y = 410;
    }
    
    
    width = 544;
    height = 200;
    barCodeReaderView  = theController.view;
    barCodeReaderView.tag = 5000;
    barCodeReaderView.hidden = NO;
    
    [theController.view setFrame:CGRectMake(x, y, width, height)];
    CGFloat scanX,scanY,scanWidth,scanHeight;
    
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
        CGFloat scanYViewVal =tempReaderVC.view.frame.size.height/2;
        
        CGFloat barcodeWidth = tempReaderVC.view.frame.size.width/6;
        
        
        UIView *scanView = [[UIView alloc]initWithFrame:CGRectMake(barcodeWidth, scanYViewVal-80, 4*barcodeWidth, 100)];
        
        scanX = scanView.frame.origin.x / tempReaderVC.view.frame.size.width;
        scanY = scanView.frame.origin.y / tempReaderVC.view.frame.size.height;
        scanWidth = scanView.frame.size.width / tempReaderVC.view.frame.size.width;
        scanHeight = scanView.frame.size.height / tempReaderVC.view.frame.size.width;
        [theController.view addSubview:scanView];
        reader.scanCrop = CGRectMake(scanX, scanY, scanWidth, scanHeight); // x,y,w,h
        
    }else{
        CGFloat scanYViewVal =tempReaderVC.view.frame.size.height/2;
        CGFloat barcodeWidth = tempReaderVC.view.frame.size.width/6;

        UIView *scanView = [[UIView alloc]initWithFrame:CGRectMake(barcodeWidth, scanYViewVal-80, 4*barcodeWidth, 100)];
        
        scanX = scanView.frame.origin.x / tempReaderVC.view.frame.size.width;
        scanY = scanView.frame.origin.y / tempReaderVC.view.frame.size.height;
        scanWidth = scanView.frame.size.width / tempReaderVC.view.frame.size.width;
        scanHeight = scanView.frame.size.height / tempReaderVC.view.frame.size.height;
        [theController.view addSubview:scanView];
        reader.scanCrop = CGRectMake(scanY, scanX, scanHeight, scanWidth); // x,y,w,h
        
    }

    UIView *tabbarView = [[UIView alloc]initWithFrame:CGRectMake(0, height-50, width, 50)];
    tabbarView.backgroundColor = [UIColor grayColor];
    
    
    barCodeCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [barCodeCancelButton setFrame:CGRectMake(0, 10, 100, 30)];
    [barCodeCancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [barCodeCancelButton addTarget:self action:@selector(cameraCancelBtnClicked:)forControlEvents:UIControlEventTouchUpInside];

    [tabbarView addSubview:barCodeCancelButton];
    [theController.view addSubview:tabbarView];
    
    
    [theController.view setFrame:CGRectMake(x, height+y+100, width, height)];
    [UIView beginAnimations:@"animateTableView" context:nil];
    [UIView setAnimationDuration:0.6];
    [theController.view setFrame:CGRectMake(x, y, width, height)];
    [UIView commitAnimations];
  
   

    
    // for Find PO
    searchViewForFindPO.userInteractionEnabled = NO;
    findPoRecordsTableView.userInteractionEnabled = NO;
    
    // For Find RA
    searchViewForFindRA.userInteractionEnabled = NO;
    findRaRecordsTableView.userInteractionEnabled = NO;
    
    // for Adjust parts
    searchViewForAdjustParts.userInteractionEnabled = NO;
    partsTableView.userInteractionEnabled = NO;
    [self.view addSubview:theController.view];
    
}

-(void)cameraCancelBtnClicked:(UIButton*)sender{
    
    [barCodeReaderView removeFromSuperview];

    // For Find PO
    searchViewForFindPO.userInteractionEnabled = YES;
    findPoRecordsTableView.userInteractionEnabled = YES;

    // For Find RA
    searchViewForFindRA.userInteractionEnabled = YES;
    findRaRecordsTableView.userInteractionEnabled = YES;
    
    // for Adjust parts
    searchViewForAdjustParts.userInteractionEnabled = YES;
    partsTableView.userInteractionEnabled = YES;
}

- (void) readerControllerDidFailToRead: (ZBarReaderController*) reader
                             withRetry: (BOOL) retry{
    NSLog(@"the image picker failing to read");
    
}


- (NSString *)base64Decode:(NSString *)base64String {
    NSData *plainTextData = [NSData dataFromBase64String:base64String];
    NSString *plainText = [[NSString alloc] initWithData:plainTextData encoding:NSUTF8StringEncoding];
    return plainText;
}


- (void)  imagePickerController: (UIImagePickerController*) picker didFinishPickingMediaWithInfo: (NSDictionary*) info{
    SystemSoundID soundID;
    
    NSString *soundFile = [[NSBundle mainBundle] pathForResource:@"beep" ofType:@"wav"];
    
    NSURL *fileURL = [NSURL URLWithString:[soundFile stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    AudioServicesCreateSystemSoundID (CFBridgingRetain(fileURL), &soundID);
    AudioServicesPlaySystemSound(soundID);
    
    UIImage *image = [info objectForKey: UIImagePickerControllerOriginalImage];
    testBarcodeImage.image = image;

    [reader dismissViewControllerAnimated:NO completion:nil];
    
    [self cameraCancelBtnClicked:nil];
    
    NSLog(@"read bar code button %@", readBarCodeButton);
    BOOL getPORequest= NO;
    BOOL getRARequest= NO;
    BOOL getPartsRequest= NO;
    
    
    
    id <NSFastEnumeration> syms =[info objectForKey: ZBarReaderControllerResults];
    for(ZBarSymbol *sym in syms) {
        if (readBarCodeButton ==adjustPartBarcodeBtn ) {
            getAdjustPartSearchByValField.text = sym.data;
            getPartsRequest = YES;
        }else if (readBarCodeButton ==findPoBarcodeBtn){
            findPoSearchByValField.text = sym.data;
            getPORequest = YES;
        }else if (readBarCodeButton ==findRaBarcodeBtn){
            findRaSearchByValField.text = sym.data;
            getRARequest = YES;
        }
        
        NSLog(@"sym.data %@", sym.data);
        break;
    }
    
    [filter setSelectedIndex:tabBarIndex];
    
    
    if (getPartsRequest == YES) {
        [self getAdjustPartsBtnClicked:nil];
    }else if (getPORequest == YES) {
        [self findPOGoBtnClicked:findPOGoBtn];
    }else if (getRARequest == YES){
        [self findRAGoBtnClicked:findRAGoBtn];
    }
}

#pragma mark -
#pragma mark TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView==findPoRecordsTableView) {
        return [findPoRecords count];
    }
    else if (tableView == findRaRecordsTableView){
        return [findRaRecords count];
    }else if (tableView == partsTableView){
        return [partsAry count];
    }else{
        return 1;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView==findPoRecordsTableView) {
        
        CGFloat originX =0.0f;
        CGFloat originY = 0.0f;
        CGFloat width =0.0f;
        CGFloat height = 42.0f;
        UIView *headerView = [[UIView alloc] init];
        
        if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
            headerView.frame = CGRectMake(0, 0, findPoRecordsTableView.frame.size.width, 80);
            originX = 30.0f;
            width = 218.0f;
        }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
            headerView.frame = CGRectMake(0, 0, findPoRecordsTableView.frame.size.width, 80);
            originX = 24.0f;
            width = 162.0f;
        }
        
        headerView.backgroundColor = [UIColor grayColor];
        for (int i=0; i<[tableFindPOHeading count]; i++) {
            
            headingLabelView = [[UILabel alloc]initWithFrame:CGRectMake(originX, originY, width, height)];
            headingLabelView.text = [tableFindPOHeading objectAtIndex:i];
            headingLabelView.backgroundColor = [UIColor  grayColor];
            headingLabelView.font=[UIFont fontWithName:@"Arial-BoldMT" size:17];
            headingLabelView.numberOfLines=0;
            headingLabelView.textAlignment = NSTextAlignmentCenter;
            [headerView addSubview:headingLabelView];
            if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                originX += width+30;
            }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                originX += width+24;
            }
            headingLabelView.tag = 100+i;
        }
        return headerView;
    }else if (tableView==findRaRecordsTableView){
        float cellWidth = findRaRecordsTableView.frame.size.width;
        NSLog(@"Find RA Cell width %f", cellWidth);
        
        CGFloat width = 0.0f;
        CGFloat originX = 0.0f;
        UIView *headerView = [[UIView alloc] init];

        headerView.backgroundColor = [UIColor grayColor];
        for (int i=0; i<[tableFindRAHeading count]; i++) {
            
            headingLabelView = [[UILabel alloc]init];
            switch (i) {
                case 0:
                {
                    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                        width = 216;
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                        width = 162;
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                    }
                    break;
                }
                    
                case 1:
                {
                    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                        width = 216;
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                        width = 162;
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                    }
                    break;
                }
                case 2:
                {
                    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                        width = 138;
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                        width = 103;
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                    }
                    break;
                }
                case 3:
                {
                    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                        width = 138;
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                        width = 103;
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                    }
                    break;
                }
                case 4:
                {
                    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                        width = 138;
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                        width =103;
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                    }
                    break;
                }
                    
                case 5:
                {
                    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                        width = 138;
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                        width = 103;
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                    }
                    break;
                }
                default:
                    break;
            }
            
            headingLabelView.text = [tableFindRAHeading objectAtIndex:i];
            headingLabelView.backgroundColor = [UIColor  grayColor];
            headingLabelView.font=[UIFont fontWithName:@"Arial-BoldMT" size:17];
            headingLabelView.numberOfLines=0;
            headingLabelView.textAlignment = NSTextAlignmentCenter;
            [headerView addSubview:headingLabelView];
            if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                originX += width+8;
            }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                originX += width+6;
            }
            headingLabelView.tag = 100+i;
        }
        return headerView;
    }else if (tableView==partsTableView){
        float cellWidth = partsTableView.frame.size.width;
        NSLog(@"Find RA Cell width %f", cellWidth);
        
        CGFloat width = 0.0f;
        CGFloat originX = 0.0f;
        UIView *headerView = [[UIView alloc] init];
        headerView.backgroundColor = [UIColor grayColor];
        
        for (int i=0; i<[partsHeadingValues count]; i++) {
            headingLabelView = [[UILabel alloc]init];
            switch (i) {
                case 0:
                {
                    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                        width = 320;
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                        width = 240;
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                    }
                    break;
                }
                case 1:
                {
                    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                        width = 280;
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                        width = 210;
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                    }
                    break;
                }

            
                case 2:
                {
                    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                        width = 94;
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                        width = 70;
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                    }
                    break;
                }
                case 3:
                {
                    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                        width = 320;
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                        width = 240;
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                    }
                    break;
                }
            }

            headingLabelView.text = [partsHeadingValues objectAtIndex:i];
            headingLabelView.backgroundColor = [UIColor  grayColor];
            headingLabelView.font=[UIFont fontWithName:@"Arial-BoldMT" size:17];
            headingLabelView.lineBreakMode = NSLineBreakByWordWrapping;
            headingLabelView.numberOfLines=2;
            headingLabelView.adjustsFontSizeToFitWidth = YES;
            headingLabelView.textAlignment = NSTextAlignmentCenter;
            [headerView addSubview:headingLabelView];

            if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                originX += width+2;
            }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                originX += width+1;
            }
            headingLabelView.tag = 100+i;
        }
        return headerView;

    }else{
        return tableView.tableHeaderView;
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView==findPoRecordsTableView) {
        NSDictionary *poVal = [findPoRecords objectAtIndex:indexPath.row];
        static NSString *TableCellIdentifier = @"POListCell";
        POListCell *cell =(POListCell *) [findPoRecordsTableView dequeueReusableCellWithIdentifier:TableCellIdentifier];
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"POListCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        NSString *poNumStr = [poVal objectForKey:@"PONumber"];
        NSString *poVendorNameStr = [poVal objectForKey:@"VendorName"];
        NSString *poCreatedOnStr = [poVal objectForKey:@"CreatedDate"];
        NSString *poAmountStr = [poVal objectForKey:@"Amount"];
        
        if (![poNumStr isEqual:[NSNull null]]) {
            cell.poNumber.text = poNumStr;
        }
        
        if (![poVendorNameStr isEqual:[NSNull null]]) {
            cell.VendorName.text = poVendorNameStr;
        }

        if (![poCreatedOnStr isEqual:[NSNull null]]) {
            cell.createdOn.text = poCreatedOnStr;
        }

        if (![poAmountStr isEqual:[NSNull null]]) {
            cell.amount.text = poAmountStr;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        return cell;
    } else if (tableView==findRaRecordsTableView){
        NSDictionary *raVal = [findRaRecords objectAtIndex:indexPath.row];
        static NSString *TableCellIdentifier = @"RAListCell";
        RAListCell *cell =(RAListCell *) [findRaRecordsTableView dequeueReusableCellWithIdentifier:TableCellIdentifier];
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RAListCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        
        NSString *raNum         = [raVal objectForKey:@"RANumber"];
        NSString *custName      = [raVal objectForKey:@"CustomerName"];
        NSString *recvDate      = [raVal objectForKey:@"ReceivedDate"];
        NSString *custRefId     = [raVal objectForKey:@"CustomerRefNum"];
        NSString *custPONum     =[raVal objectForKey:@"CustomerPo"];
        NSString *raStatus      = [raVal objectForKey:@"Status"];
        
        
        
        if (![raNum isEqual:[NSNull null]]) {
            cell.raNumber.text = raNum;
        }
        
        if (![custName isEqual:[NSNull null]]) {
            cell.customerName.text = custName;
        }

        if (![recvDate isEqual:[NSNull null]]) {
            cell.createdOn.text = recvDate;
        }
        
        if (![custRefId isEqual:[NSNull null]]) {
            cell.customerRefId.text = custRefId;
        }
        
        
        if (![custPONum isEqual:[NSNull null]]) {
            cell.customerPoNum.text = custPONum;
        }
        
        if (![raStatus isEqual:[NSNull null]]) {
            cell.status.text = raStatus;
        }

        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        return cell;
    }else if (tableView == partsTableView){
        NSDictionary *partDic = [partsAry objectAtIndex:indexPath.row];
        static NSString *TableCellIdentifier = @"PartListCell";
        PartListCell *cell =(PartListCell *) [partsTableView dequeueReusableCellWithIdentifier:TableCellIdentifier];
       
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PartListCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        
        NSString *partNum           = [partDic objectForKey:@"PartNumber"];
        NSString *barcodeNum        = [partDic objectForKey:@"Barcode"];
        NSString *inStock           = [partDic objectForKey:@"InStock"];
        NSString *partArea          = [partDic objectForKey:@"Area"];
        NSString *partShelf         = [partDic objectForKey:@"Shelf"];
        NSString *partLevel         = [partDic objectForKey:@"Level"];
        NSString *location;
        
        
        if (![partArea isEqual:[NSNull null]] && ![partArea isEqual:[NSNull null]] && ![partArea isEqual:[NSNull null]]) {
            location = [NSString stringWithFormat:@"%@/%@/%@",partArea,partShelf,partLevel];
        }
       
        if (![partNum isEqual:[NSNull null]]) {
            cell.partNumber.text = partNum;
        }
        
        if (![barcodeNum isEqual:[NSNull null]]) {
            cell.barcode.text = barcodeNum;
        }
        
        if (![inStock isEqual:[NSNull null]]) {
            cell.inStock.text = inStock;
        }
        
        if (![location isEqual:[NSNull null]]) {
            cell.location.text = location;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        return cell;
    }
    
    else{
        static NSString *CellIdentifier = @"Cell";

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        return cell;
    }
}


-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return  42.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (tableView==findPoRecordsTableView) {
        NSDictionary *singlePoVal = [findPoRecords objectAtIndex:indexPath.row];
        NSLog(@"singlePoVal %@", singlePoVal);
        GetPOViewController *poDetails = [[GetPOViewController alloc]initWithNibName:@"GetPOViewController" bundle:nil];
        poDetails.poValStr = [singlePoVal valueForKey:@"PONumber"];
        
        if (isPoPartSelected  == YES) {
            poDetails.isPartSelected = YES;
            poDetails.selectedPart = findPoSearchByValField.text;
        }
        
        [self.navigationController pushViewController:poDetails animated:YES];
    }else if(tableView==findRaRecordsTableView){
        
        NSDictionary *singleRaVal = [findRaRecords objectAtIndex:indexPath.row];
        NSLog(@"singleRaVal %@", singleRaVal);
       
        GetRAViewController *raDetails = [[GetRAViewController alloc]initWithNibName:@"GetRAViewController" bundle:nil];
        raDetails.raValStr = [singleRaVal valueForKey:@"RANumber"];
        if (isRaPartSelected  == YES) {
            raDetails.isRAPartSelected = YES;
            raDetails.selectedRAPart = findRaSearchByValField.text;
            raDetails.actionString = raAction;
        }
        [self.navigationController pushViewController:raDetails animated:YES];

    }else if (tableView == partsTableView){
        NSDictionary *currentPartDict = [partsAry objectAtIndex:indexPath.row];
        GetPartViewController *partDetails = [[GetPartViewController alloc]initWithNibName:@"GetPartViewController" bundle:nil];
        partDetails.partDetails = currentPartDict;
        partDetails.currentRoleStr = currentViewStr;
        [self.navigationController pushViewController:partDetails animated:YES];
        partsTableView.hidden = YES;

    }
}

#pragma mark -
#pragma mark Go Click Actions

-(void)getRAActionBtnClicked:(id)sender{
    NSLog(@"testing ");
}


#pragma mark -
#pragma mark Picker Functions
-(UIView *) customDJPickerView{
    DjuPickerView *djuPickerView = [[DjuPickerView alloc] initWithFrame:CGRectMake(0, 0, 280, 170)];
    djuPickerView.delegate = self;
    djuPickerView.dataSource = self;
    djuPickerView.backgroundColor = [UIColor whiteColor];
    djuPickerView.overlayCell.backgroundColor = [UIColor grayColor];
    return djuPickerView;
}
-(void)showPopOverForView:(UIView *)aView withTitle:(NSString *)aTitle{
    UIViewController* popoverContent = [[UIViewController alloc] init];
    UIView* popoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240,170)];
    popoverView.backgroundColor = [UIColor whiteColor];
    [popoverView addSubview:aView];
    popoverContent.view = popoverView;
    popoverContent.title = aTitle;
    UINavigationController *pickerNavigationController = [[UINavigationController alloc] initWithRootViewController:popoverContent];
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissPopOverController:)];
	pickerNavigationController.navigationItem.rightBarButtonItem = doneButton;
    
    pickerNavigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor colorWithRed:64.0f/255.0f green:100.0f/255.0f blue:150.0f/255.0f alpha:1.0] forKey:UITextAttributeTextColor];
    popoverContent.contentSizeForViewInPopover = CGSizeMake(280, 170);
    pickerPopOverController = [[UIPopoverController alloc] initWithContentViewController:pickerNavigationController];
    CGRect popoverRect = [self.view convertRect:[selectedMenuBtn frame] fromView:[selectedMenuBtn superview]];
    
    popoverRect.size.width = MIN(popoverRect.size.width, 100) ;
    popoverRect.origin.x  = popoverRect.origin.x;
    pickerPopOverController.popoverBackgroundViewClass = [GIKPopoverBackgroundView class];
    [pickerPopOverController presentPopoverFromRect:popoverRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark - Save functions
-(IBAction)saveAdjustPartsBtnClicked:(id)sender{
    NSLog(@"saveAdjustParts clicked");
}

#pragma mark - DjuPickerViewDelegate functions
- (NSString *)djuPickerView:(DjuPickerView *)djuPickerView titleForRow:(NSInteger)row {
    return [pickerValues objectAtIndex:row];
}
- (void)djuPickerView:(DjuPickerView*)djuPickerView didSelectRow:(NSInteger)row {
    NSString *key = [NSString stringWithFormat:@"%d-%ld",hitIndexInPickerView.section,(long)hitIndexInPickerView.row];
    [selectedMenuBtn setTitle:(NSString *)[pickerValues objectAtIndex:row]  forState:UIControlStateNormal];
    
    if (poStatusValueSelected == YES) {
        [poStatusValues setObject:[pickerValues objectAtIndex:row] forKey:key];
        for (int i = 0; i<[savePoDetailsDictArray count]; i++) {
            NSString *status;
            if (i == hitIndexInPickerView.row) {
                status  =selectedMenuBtn.titleLabel.text;
                NSLog(@"Status savePoDictionary%@",savePoDictionary);
            }
        }
    }else if (raStatusValueSelected == YES){
        [raStatusValues setObject:[pickerValues objectAtIndex:row] forKey:key];
        for (int i = 0; i<[saveRaDetailsDictArray count]; i++) {
            NSString *status;
            if (i == hitIndexInPickerView.row) {
                status  =selectedMenuBtn.titleLabel.text;
                saveRaDictionary = [saveRaDetailsDictArray objectAtIndex: hitIndexInPickerView.row];
                [saveRaDictionary removeObjectForKey:[tableGetRAHeading objectAtIndex:5]];
                [saveRaDictionary setObject:status forKey:[tableGetRAHeading objectAtIndex:5]];
                NSLog(@"Status saveRaDictionary%@",saveRaDictionary);
            }
        }
    }
}
- (CGFloat)rowHeightForDjuPickerView:(DjuPickerView *)djuPickerView {
    return 30.0;
}
- (void)labelStyleForDjuPickerView:(DjuPickerView*)djuPickerView forLabel:(UILabel*)label {
    label.textColor = [UIColor colorWithRed:64.0f/255.0f green:100.0f/255.0f blue:150.0f/255.0f alpha:1.0];
    label.font = [UIFont fontWithName:@"Arial-BoldMT" size:22];
    
}
#pragma mark - DjuPickerViewDataSource functions
- (NSInteger)numberOfRowsInDjuPickerView:(DjuPickerView*)djuPickerView {
    return [pickerValues count];
}

#pragma mark - UITextField functions
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    NSString *currentSelectedTab = [tabArray  objectAtIndex:tabBarIndex];
    NSLog(@"currentSelectedTab %@",currentSelectedTab);
//    if ([currentSelectedTab isEqualToString:@"Get RA"]){
//        CGPoint hitPointRA = [textField convertPoint:CGPointZero toView:getRaDetailsTableView];
//        hitIndexInTextEditingRA = [getRaDetailsTableView indexPathForRowAtPoint:hitPointRA];
//    }
    
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self scrollToControl:textField];
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    [self scrollToControl:nil];
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [self scrollToControl:nil];
    
    NSString *currentSelectedTab = [tabArray  objectAtIndex:tabBarIndex];
    NSLog(@"currentSelectedTab %@",currentSelectedTab);
    return YES;
}

#pragma mark - ScrollControl functions
- (void) scrollToControl:(UIView*)control {
    NSString *currentSelectedTab = [tabArray  objectAtIndex:tabBarIndex];
    
    
    if ([currentSelectedTab isEqualToString:@"Parts"]){
        CGRect rectToScroll = CGRectZero;
        
        if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
            if (control != nil) {
                rectToScroll = CGRectMake(adjustPartScrollView.frame.origin.x, adjustPartScrollView.frame.origin.y, adjustPartScrollView.frame.size.width, adjustPartScrollView.frame.size.height+300);
                adjustPartScrollView.contentSize =CGSizeMake(adjustPartScrollView.frame.size.width, 500);
                
            }else{
                rectToScroll = CGRectMake(adjustPartScrollView.frame.origin.x, adjustPartScrollView.frame.origin.y, adjustPartScrollView.frame.size.width, adjustPartScrollView.frame.size.height-500);
                adjustPartScrollView.contentSize =CGSizeMake(adjustPartScrollView.frame.size.width, adjustPartScrollView.frame.size.height);
                
            }
            [adjustPartScrollView scrollRectToVisible:rectToScroll animated:YES];
        }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
//            adjustPartScrollView.contentSize =CGSizeMake(728, 376);
        }
    }
}

#pragma mark - Advanced part search 
-(IBAction)poCheckInBtnClicked:(id)sender{
    [filter setSelectedIndex:0];
    findPoSearchByValField.text = partNumLabelValInAdjustParts.text;
    [self findPOPartNumRadioBtnClicked:nil];
    currentFindPOSeachValue = @"Part#";
    [self findPOGoBtnClicked:nil];
}

-(void)poCheckInBtnClickedWithPart:(NSString *)part{
    [filter setSelectedIndex:0];
    [self findPOPartNumRadioBtnClicked:nil];
    findPoSearchByValField.text = part;
    currentFindPOSeachValue = @"Part#";
    [self findPOGoBtnClicked:nil];
}


-(IBAction)raCheckInBtnClicked:(id)sender{
    [filter setSelectedIndex:1];
    findRaSearchByValField.text= partNumLabelValInAdjustParts.text;
    [self findRAPartNumRadioBtnClicked:nil];
    raAction = @"CheckIn";
    [self findRAGoBtnClicked:nil];
}


-(void)raCheckInBtnClickedWithPart:(NSString *)part{
    [filter setSelectedIndex:1];
    findRaSearchByValField.text= part;
    [self findRAPartNumRadioBtnClicked:nil];
    raAction = @"CheckIn";
    [self findRAGoBtnClicked:nil];
}


-(IBAction)raCheckOutBtnClicked:(id)sender{
    [filter setSelectedIndex:1];
    findRaSearchByValField.text= partNumLabelValInAdjustParts.text;
    [self findRAPartNumRadioBtnClicked:nil];
    raAction = @"CheckOut";
    [self findRAGoBtnClicked:nil];

}



-(void)raCheckOutBtnClickedWithPart:(NSString *)part{
    [filter setSelectedIndex:1];
    findRaSearchByValField.text= part;
    [self findRAPartNumRadioBtnClicked:nil];
    raAction = @"CheckOut";
    [self findRAGoBtnClicked:nil];
}




-(IBAction)adjustPartsCancelBtnClicked:(id)sender{
    NSLog(@"Adjust parts cancel Btn clicked");
    partsAry = [[NSArray alloc]init];
    [partsTableView reloadData];
    partsTableView.hidden = YES;
    getAdjustPartSearchByValField.text =@"";
}




#pragma mark - format JSON

-(NSString*)jsonFormat:(NSString *)type withDictionary:(NSMutableDictionary *)formatDict{
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *authDict = [standardUserDefaults objectForKey:@"LoginDetails"];
    NSString *bodyStr = [NSString stringWithFormat:@"{Type:\\\"%@\\\",Authentication:{UserName:\\\"%@\\\", Password:\\\"%@\\\"}", type,[authDict valueForKey:@"Username" ], [authDict valueForKey:@"Password"]];
   
    NSString *dataStr;
    
    if ([type isEqualToString:FIND_PO_TYPE]) {
        dataStr = [NSString stringWithFormat:@"Body:{SearchKey:\\\"%@\\\",SearchValue:\\\"%@\\\",Status:\\\"OPEN\\\"}}",[formatDict valueForKey:@"SearchKey"],[formatDict valueForKey:@"SearchValue"]];
    }else if ([type isEqualToString:FIND_RA_TYPE]) {
        dataStr = [NSString stringWithFormat:@"Body:{SearchKey:\\\"%@\\\",SearchValue:\\\"%@\\\",Status:\\\"AllRepairs\\\"}}",[formatDict valueForKey:@"SearchKey"],[formatDict valueForKey:@"SearchValue"]];
    }else if ([type isEqualToString:GET_PO_TYPE]){
        dataStr = [NSString stringWithFormat:@"Body:{PONumber:\\\"%@\\\"}}",[formatDict valueForKey:@"getPONumberValue"]];
    }else if ([type isEqualToString:GET_PO_RECEIPT]){
        dataStr = [NSString stringWithFormat:@"Body:{LineID:\\\"%@\\\",LineNo:\\\"%@\\\"}}",[formatDict valueForKey:@"LineID"],[formatDict valueForKey:@"LineNo"]];
    }else if ([type isEqualToString:PO_RECEIPT_ENTRY]){
        dataStr = [NSString stringWithFormat:@"Body:{LineID:\\\"%@\\\",LineNo:\\\"%@\\\",VendorInvoice:\\\"%@\\\",RecvBy:\\\"%@\\\",RecvDate:\\\"%@\\\",RecvQty:\\\"%@\\\",Comments:\\\"%@\\\",Flag:\\\"%@\\\",ReceiptLineId:\\\"%@\\\"}}",[formatDict valueForKey:@"LineID"],[formatDict valueForKey:@"LineNo"],[formatDict valueForKey:@"VendorInvoice"],[formatDict valueForKey:@"RecvBy"],[formatDict valueForKey:@"RecvDate"],[formatDict valueForKey:@"RecvQty"],[formatDict valueForKey:@"Comments"],[formatDict valueForKey:@"Flag"],[formatDict valueForKey:@"ReceiptLineId"]];
    }else if ([type isEqualToString:GET_RA_TYPE]){
        dataStr = [NSString stringWithFormat:@"Body:{RANumber:\\\"%@\\\"}}",[formatDict valueForKey:@"getRANumberValue"]];
    }else if ([type isEqualToString:GET_PART]){
        dataStr = [NSString stringWithFormat:@"Body:{BARCodeOrPart:\\\"%@\\\"}}",[formatDict valueForKey:@"BARCodeOrPart"]];
    }

    NSString *finalReq = [NSString stringWithFormat:@"%@,%@", bodyStr,dataStr];
    return finalReq;
}


#pragma mark - logout function
- (IBAction)logout:(id)sender{
    [UIView animateWithDuration:0.75 animations:^{[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];}];
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - orientation function
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    NSLog(@"didRotateFromInterfaceOrientation");
    
    
    if ([self.presentedViewController isKindOfClass:[ZBarReaderViewController class]]){
        NSLog(@"Reader calss present ");
        [reader dismissViewControllerAnimated:NO completion:nil];        
        id sender = (id)readBarCodeButton;
        [self readBarCodeBtnClicked:sender];
    }
    
    NSArray *tempArt = [self.view subviews];
    NSLog(@"tempArt %@",tempArt);
    
//

//    for (int i=0; i<[tempArt count]; i++) {
//        UIView *tempView = (UIView *)[tempArt objectAtIndex:i];
//        if (tempView.tag == 5000) {
//            NSLog(@"Reader calss present ");
//            tempView.hidden = NO;
//            id sender = (id)readBarCodeButton;
//            [self readBarCodeBtnClicked:sender];
//        }
//    }
    
    if (showCamera == YES) {
        id sender = (id)readBarCodeButton;
        [self readBarCodeBtnClicked:sender];
    }
}


-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{

//    barCodeReaderView.hidden = YES;

    NSArray *subviews = [self.view subviews];
    for (int i=0; i<[subviews count]; i++) {
        UIView *tempView = (UIView *)[subviews objectAtIndex:i];
        if (tempView.tag == 5000) {
            [self cameraCancelBtnClicked:barCodeCancelButton];
//            id sender = (id)readBarCodeButton;
//            [self readBarCodeBtnClicked:sender];
            showCamera = YES;
            break;
        }else{
            showCamera = NO;
            continue;
        }
    }

    
//    if ([self.presentedViewController isKindOfClass:[ZBarReaderViewController class]]){
//        [reader dismissViewControllerAnimated:NO completion:nil];
//        
//        if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
//            NSLog(@"Landscape mode");
//            reader.scanCrop = CGRectMake(0.375, 0, 0.25, 1); // x,y,w,h
//        }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
//            NSLog(@"Portrait mode");
//            reader.scanCrop = CGRectMake(0, 0.375, 1, 0.25); // x,y,w,h
//        }
//        NSLog(@"scanner showed.");
//        [self presentModalViewController:reader animated:YES];
//    }

    
    orientationFlag = YES;
    
    tabBarIndex = filter.SelectedIndex;
    [filter removeFromSuperview];
    
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
        filter = [[SEFilterControl alloc]initWithFrame:CGRectMake(55, 950, 678, 70) Titles:tabArray];
        filter.backgroundColor = [UIColor clearColor];
    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
        filter = [[SEFilterControl alloc]initWithFrame:CGRectMake(55, 700, 934, 60) Titles:tabArray];
        filter.backgroundColor = [UIColor clearColor];
    }
    
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
//        adjustPartScrollView.contentSize =CGSizeMake(728, 376);
        
    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
//        adjustPartScrollView.contentSize =CGSizeMake(728, 376);
    }
    [self viewWillAppear:YES];
    
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
        findPoSubView.frame =CGRectMake(0, 0, 770, 880);
        findRaSubView.frame =CGRectMake(0, 0, 770, 880);
        getRaSubView.frame =CGRectMake(0, 0, 770, 880);
        adjustPartsSubView.frame =CGRectMake(0, 0, 770, 880);
        
    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
        findPoSubView.frame =CGRectMake(0, 0, 1024, 640);
        findRaSubView.frame =CGRectMake(0, 0, 1024, 640);
        getRaSubView.frame =CGRectMake(0, 0, 1024, 640);
        adjustPartsSubView.frame =CGRectMake(0, 0, 1024, 640);
    }
    
    if ([pickerPopOverController isPopoverVisible]) {
        [pickerPopOverController dismissPopoverAnimated:YES];
    }
    
//    [getRaDetailsTableView reloadData];
    [findRaRecordsTableView reloadData];
    [findPoRecordsTableView reloadData];
    [partsTableView reloadData];
    [self.view endEditing:YES];
    
}


- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end
