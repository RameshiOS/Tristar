//
//  HomeViewController.h
//  TriStar
//
//  Created by Manulogix on 11/12/13.
//  Copyright (c) 2013 Manulogix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "WebServiceInterface.h"
#import "POListCell.h"
#import "OrderListCell.h"
#import "RAListCell.h"
#import "RepairListCell.h"
#import <QuartzCore/QuartzCore.h>
#import "ZBarReaderViewController.h"
#import "GIKPopoverBackgroundView.h"
#import "FAUtilities.h"
#import "DjuPickerView.h"
#import "SEFilterControl.h"
#import <AVFoundation/AVAudioPlayer.h>
#import "POLineReceiptListCell.h"
#import <AVFoundation/AVFoundation.h>
//#import "ZBarCaptureReader.h"


@interface HomeViewController : UIViewController<WebServiceInterfaceDelegate,UITableViewDataSource,UITableViewDelegate,UIPopoverControllerDelegate,ZBarReaderDelegate,UIScrollViewDelegate,UITextFieldDelegate>{
    
    IBOutlet UIPickerView  *pickerView;
    IBOutlet UIView        *findPoSubView,*findRaSubView,*getRaSubView,*adjustPartsSubView,*partDetailsView;
    IBOutlet UITableView   *findPoRecordsTableView,*findRaRecordsTableView;
    IBOutlet UITextField   *findPoSearchByValField;
    IBOutlet UITextField    *findRaSearchByValField;
    IBOutlet UITextField    *getAdjustPartSearchByValField;
    IBOutlet UITextField    *checkInOutValue;
    IBOutlet UILabel       *repairDetailsLabel,*headingLabelView,*orderDetailsLabel,*partDetailsLabelView;
    
    NSMutableArray *savePoDetailsDictArray;
    NSMutableDictionary *savePoDictionary;
    NSMutableDictionary *savePoDict;
    
    NSMutableArray *saveRaDetailsDictArray;
    NSMutableDictionary *saveRaDictionary;
    NSMutableDictionary *saveRaDict;
    
    IBOutlet UIButton     *adjustPartsSaveBtn;
    IBOutlet UIButton     *adjustPartBarcodeBtn;
    IBOutlet UIButton     *findPoBarcodeBtn;
    IBOutlet UIButton     *findRaBarcodeBtn;


    IBOutlet UIScrollView  *adjustPartScrollView;

    UIButton *selectedMenuBtn;
    
    UIButton *readBarCodeButton;
    
    NSArray *pickerValues;
    
    
    NSArray *findPoPickerValues, *findRaPickerValues, *statusPickerValues;
    
    NSArray                *findPoRecords,*findRaRecords,*getRaRecords,*tabArray,*tableGetRAHeading,*tableFindPOHeading,*tableFindRAHeading;
    NSMutableDictionary    *usedQTY,*recivedQTY,*poStatusValues,*raStatusValues,*poStatusValuesFromResp,*raStatusValuesFromResp,*totalPoStatusValues,*totalRaStatusValues;
    UIPopoverController    *pickerPopOverController;
    NSIndexPath            *hitIndexInTextEditingRA,*hitIndexInTextEditingPO,*hitIndexInPickerView;
    
    WebServiceInterface    *webServiceInterface;
    
    UIView *poCustomPickerView;
    UIView *raCustomPickerView;

    
    
    SEFilterControl *filter;
    int tabBarIndex;

    float keyboardHeight;
    int statusBtnSenderTag;
    BOOL poStatusValueSelected;
    BOOL raStatusValueSelected;
    
        
    BOOL orientationFlag;
    
    ZBarReaderViewController *reader;
    
    
    IBOutlet UIView *searchViewForFindPO;

    
    IBOutlet UIView *searchViewForFindRA;
    IBOutlet UIView *searchViewForAdjustParts;

    // find po buttons
    
    IBOutlet UIButton *findPOPONumRadioBtn;
    IBOutlet UIButton *findPOvendorRadioBtn;
    IBOutlet UIButton *findPOPartNumRadioBtn;
    
    NSString *currentFindPOSeachValue;

    
    
    // find ra buttons
    
    IBOutlet UIButton *findRARaNumRadioBtn;
    IBOutlet UIButton *findRACustomerRadioBtn;
    IBOutlet UIButton *findRAPartNumRadioBtn;
    
    NSString *currentFindRASeachValue;

    
    
    // adjust parts
    
    IBOutlet UILabel *partNumLabelInAdjustParts;
    IBOutlet UILabel *partNumLabelValInAdjustParts;
    IBOutlet UILabel *partBarCodeLabelInAdjustParts;
    IBOutlet UILabel *partBarCodeLabelValInAdjustParts;

    IBOutlet UILabel *partDescLabelInAdjustParts;
    IBOutlet UILabel *partDescLabelValInAdjustParts;
    
    IBOutlet UILabel *locationDetailsHeadingLabelInAdjustParts;
    IBOutlet UILabel *statusDetailsHeadingLabelInAdjustParts;
    
    IBOutlet UIView *locationDetailsSubViewInAdjustParts;
    IBOutlet UIView *statusDetailsSubViewInAdjustParts;
    
    
    IBOutlet UIView *partDetailsHeadingViewInAdjustParts;
    IBOutlet UIView *partDetailsSubViewInAdjustParts;
    
    IBOutlet UILabel *partTypeValInAdjustParts;
    IBOutlet UILabel *partCategoryValInAdjustParts;
    IBOutlet UILabel *partLocIdValInAdjustParts;
    IBOutlet UILabel *partAreaValInAdjustParts;
    IBOutlet UILabel *partShelfValInAdjustParts;
    IBOutlet UILabel *partLevelValInAdjustParts;
    
    IBOutlet UILabel *partInStockValInAdjustParts;
    IBOutlet UILabel *partThresholdValInAdjustParts;
    IBOutlet UILabel *partOnOrderValInAdjustParts;
    
    
    IBOutlet UIImageView *testBarcodeImage;

    IBOutlet UIButton *cancelBtn;
    

    
    BOOL isPoPartSelected;
    BOOL isRaPartSelected;
    
    NSString *raAction;
    
    // go btn checking
    
    IBOutlet UIButton *findPOGoBtn;
    IBOutlet UIButton *findRAGoBtn;
    
    
    IBOutlet UIButton *poCheckInBtn;
    IBOutlet UIButton *raCheckInBtn;
    IBOutlet UIButton *raCheckOutBtn;
    
    
    
    // barcode reader view
    
    UIView *barCodeReaderView;
    UIButton *barCodeCancelButton;
    BOOL showCamera;
    BOOL isCameraPresent;
    
    UIViewController *tempReaderVC;
    
    
    
    // find parts
    
    
    IBOutlet UITableView *partsTableView;
    NSArray *partsAry;
    NSArray *partsHeadingValues;
//    NSString *findPoPart;
    
    
    // for handling tabs
    
    NSString *currentViewStr;
    
}

//findPo
@property(nonatomic,retain) IBOutlet UITextField *findPoSearchByValField;
@property(nonatomic,retain) NSArray *rolesArray;


-(IBAction)findPOGoBtnClicked:(id)sender;
-(IBAction)findPOCancelBtnClicked:(id)sender;


//findRa
@property(nonatomic,retain) IBOutlet UITextField *findRaSearchByValField;
-(IBAction)findRAGoBtnClicked:(id)sender;
-(IBAction)findRACancelBtnClicked:(id)sender;

//getRa
@property(nonatomic,retain) IBOutlet UITextField *getRaSearchByValField;



//adjustParts
-(IBAction)getAdjustPartsBtnClicked:(id)sender;
-(IBAction)readBarCodeBtnClicked:(id)sender;
-(IBAction)saveAdjustPartsBtnClicked:(id)sender;
-(IBAction)adjustPartsCancelBtnClicked:(id)sender;




-(IBAction)poCheckInBtnClicked:(id)sender;
-(IBAction)raCheckInBtnClicked:(id)sender;
-(IBAction)raCheckOutBtnClicked:(id)sender;


// find po radio Btns

-(IBAction)findPOPONumRadioBtnClicked:(id)sender;
-(IBAction)findPOVendorRadioBtnClicked:(id)sender;
-(IBAction)findPOPartNumRadioBtnClicked:(id)sender;

// find ra radio buttons

-(IBAction)findRARaNumRadioBtnClicked:(id)sender;
-(IBAction)findRACustomerRadioBtnClicked:(id)sender;
-(IBAction)findRAPartNumRadioBtnClicked:(id)sender;



// global methods

-(void)poCheckInBtnClickedWithPart:(NSString *)part;



@end
