//
//  GetPartViewController.h
//  TriStar
//
//  Created by Manulogix on 17/01/14.
//  Copyright (c) 2014 Manulogix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface GetPartViewController : UIViewController{
    IBOutlet UILabel *partNumber;
    IBOutlet UILabel *barcodeNum;
    IBOutlet UILabel *desc;
    
    IBOutlet UILabel *partTypeVal;
    IBOutlet UILabel *partCategoryVal;
    IBOutlet UILabel *partAreaVal;
    IBOutlet UILabel *partShelfVal;
    IBOutlet UILabel *partLevelVal;
    
    IBOutlet UILabel *inStockVal;
    IBOutlet UILabel *onOrderVal;
    IBOutlet UILabel *thresholdVal;
    
    IBOutlet UIView *partDetailsSubview;
    IBOutlet UIView *partLocationSubview;
    IBOutlet UIView *partStatusSubview;
    
    IBOutlet UIView *partHeadingView;
    
    IBOutlet UIButton *poCheckInBtn;
    IBOutlet UIButton *raCheckInBtn;
    IBOutlet UIButton *raCheckOutBtn;
    
    

}

@property(nonatomic,retain)NSDictionary *partDetails;
@property(nonatomic,retain)NSString *currentRoleStr;


-(IBAction)poCheckInBtnClicked:(id)sender;
-(IBAction)raCheckInBtnClicked:(id)sender;
-(IBAction)raCheckOutBtnClicked:(id)sender;


@end
