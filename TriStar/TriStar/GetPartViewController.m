//
//  GetPartViewController.m
//  TriStar
//
//  Created by Manulogix on 17/01/14.
//  Copyright (c) 2014 Manulogix. All rights reserved.
//

#import "GetPartViewController.h"
#import "FAUtilities.h"
#import "HomeViewController.h"

@interface GetPartViewController ()

@end

@implementation GetPartViewController
@synthesize partDetails;
@synthesize currentRoleStr;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"part details %@", partDetails);
    self.navigationController.navigationBarHidden = NO;
    
    self.navigationItem.title = @"Part Details";
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backClicked:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    
    partDetailsSubview.backgroundColor = [UIColor clearColor];
    partDetailsSubview.layer.borderWidth =1;
    partDetailsSubview.layer.borderColor = [[FAUtilities getUIColorObjectFromHexString:@"#314F9B" alpha:1] CGColor];

    
    partLocationSubview.backgroundColor = [UIColor clearColor];
    partLocationSubview.layer.borderWidth =1;
    partLocationSubview.layer.borderColor = [[FAUtilities getUIColorObjectFromHexString:@"#314F9B" alpha:1] CGColor];

    partStatusSubview.backgroundColor = [UIColor clearColor];
    partStatusSubview.layer.borderWidth =1;
    partStatusSubview.layer.borderColor = [[FAUtilities getUIColorObjectFromHexString:@"#314F9B" alpha:1] CGColor];

    
    
    NSString *partNum               = [partDetails objectForKey:@"PartNumber"];
    NSString *barCodeNum            = [partDetails objectForKey:@"Barcode"];
    NSString *partDesc              = [partDetails objectForKey:@"Description"];
    NSString *partType              = [partDetails objectForKey:@"PartType"];
    NSString *partCategory          = [partDetails objectForKey:@"PartCategory"];
    NSString *partArea              = [partDetails objectForKey:@"Area"];
    NSString *partShelf             = [partDetails objectForKey:@"Shelf"];
    NSString *partLevel             = [partDetails objectForKey:@"Level"];
    NSString *inStock               = [partDetails objectForKey:@"InStock"];
    NSString *onOrder               = [partDetails objectForKey:@"OnOrder"];
    NSString *threshold             = [partDetails objectForKey:@"Threshold"];
    
    if (![partNum isEqual:[NSNull null]]) {
        partNumber.text = partNum;
    }
    if (![barCodeNum isEqual:[NSNull null]]) {
        barcodeNum.text = barCodeNum;
    }
    
    if (![partDesc isEqual:[NSNull null]]) {
        desc.text = partDesc;
    }
    
    if (![partType isEqual:[NSNull null]]) {
        partTypeVal.text = partType;
    }
    
    if (![partCategory isEqual:[NSNull null]]) {
        partCategoryVal.text = partCategory;
    }
    
    if (![partArea isEqual:[NSNull null]]) {
        partAreaVal.text = partArea;
    }
    
    if (![partShelf isEqual:[NSNull null]]) {
        partShelfVal.text = partShelf;
    }
    if (![partLevel isEqual:[NSNull null]]) {
        partLevelVal.text = partLevel;
    }
    
    
    if (![inStock isEqual:[NSNull null]]) {
        inStockVal.text = inStock;
        if (inStockVal.text.length == 0) {
            inStockVal.text = @"0";
        }
    }
    
    if (![threshold isEqual:[NSNull null]]) {
        thresholdVal.text = threshold;
        if (thresholdVal.text.length == 0) {
            thresholdVal.text = @"0";
        }
    }
    
    if (![onOrder isEqual:[NSNull null]]) {
        onOrderVal.text = onOrder;
        if (onOrderVal.text.length == 0) {
            onOrderVal.text = @"0";
        }
    }
    
    UIColor *headingColor = [FAUtilities getUIColorObjectFromHexString:@"#314F9B" alpha:1];
    partHeadingView.backgroundColor = headingColor;

    if ([currentRoleStr isEqualToString:@"Purchase"]) {
        raCheckInBtn.hidden = YES;
        raCheckOutBtn.hidden = YES;
    }
    
    // Do any additional setup after loading the view from its nib.
}


- (IBAction)backClicked:(id)sender{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        [standardUserDefaults setObject:@"" forKey:@"CurrentView"];
        [standardUserDefaults synchronize];
    }

    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)poCheckInBtnClicked:(id)sender{
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        [standardUserDefaults setObject:@"POCheckIn" forKey:@"CurrentView"];
        [standardUserDefaults setObject:partNumber.text forKey:@"Part#"];
        [standardUserDefaults synchronize];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)raCheckInBtnClicked:(id)sender{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        [standardUserDefaults setObject:@"RACheckIn" forKey:@"CurrentView"];
        [standardUserDefaults setObject:partNumber.text forKey:@"Part#"];
        [standardUserDefaults synchronize];
    }
    [self.navigationController popViewControllerAnimated:YES];

}


-(IBAction)raCheckOutBtnClicked:(id)sender{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        [standardUserDefaults setObject:@"RACheckOut" forKey:@"CurrentView"];
        [standardUserDefaults setObject:partNumber.text forKey:@"Part#"];
        [standardUserDefaults synchronize];
    }
    [self.navigationController popViewControllerAnimated:YES];

}


// latest changes 16-10

-(IBAction)scanBomPartsBtnClicked:(id)sender{

    
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
