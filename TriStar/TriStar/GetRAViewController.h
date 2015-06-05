//
//  GetRAViewController.h
//  TriStar
//
//  Created by Manulogix on 17/01/14.
//  Copyright (c) 2014 Manulogix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "WebServiceInterface.h"
#import "FAUtilities.h"
#import "RepairListCell.h"
#import "ZBarReaderViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "RADocumenmtsListTableViewCell.h"
#import "RADocumentTableViewCell.h"
#import "RABomSubstitutePartsTableViewCell.h"

@interface GetRAViewController : UIViewController<WebServiceInterfaceDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,ZBarReaderDelegate,UIPopoverControllerDelegate,UIWebViewDelegate>{
    NSString *raValStr;
    WebServiceInterface    *webServiceInterface;
    NSArray *getRaRecords;
//    NSMutableArray *getRaRecords;
    NSArray *tableGetRAHeading;
    UILabel *headingLabelView;

    IBOutlet UIScrollView  *getRAScrollView;
    
    // Ra details
    IBOutlet UILabel    *getRADetailsHeadingLabel;
    IBOutlet UIView     *getRADetailsSubView;
    IBOutlet UILabel    *getRANumValLabel;
    IBOutlet UILabel    *getRAStatusValLabel;
    
    //Cust details
    IBOutlet UILabel    *getRACustomerDetailsHeadingLabel;
    IBOutlet UIView     *getRACustomerDetailsSubView;
    
    IBOutlet UILabel *getRACustNameValLabel;
    IBOutlet UILabel *getRACustShortNmaeValLabel;
    IBOutlet UILabel *getRACustIdValLabel;
    IBOutlet UILabel *getRACustPhoneValLabel;
    IBOutlet UILabel *getRACustContactValLabel;
    IBOutlet UILabel *getRACustAddrValLabel;
    IBOutlet UILabel *getRACustStateValLabel;
    
    //repair Summary details
    IBOutlet UILabel    *getRARepairDetailsHeadingLabel;
    IBOutlet UIView     *getRARepairDetailsSubView;

    IBOutlet UILabel *getRASummaryNumValLabel;
    IBOutlet UILabel *getRASummaryStatusValLabel;
    IBOutlet UILabel *getRASummaryPartNumValLabel;
    IBOutlet UILabel *getRASummaryPartNoteValLabel;
    IBOutlet UILabel *getRASummaryRecvDateValLabel;
    IBOutlet UILabel *getRASummaryBarcodeValLabel;
    float keyboardHeight;

    
    
    // repair details
    
    IBOutlet UILabel        *getRARepairDetailsHedingLabel;
    IBOutlet UITableView    *getRADetailsTableView;
    
    
    // update bom values
    
    NSMutableDictionary     *bomAddOrRemoveValsDict;
    IBOutlet UIButton       *updateBomDetailsBtn;
    NSMutableDictionary     *bomFinalReqDict;
    
    
    // expand or collaps
    NSIndexPath *selectedIndexPath;

//    NSIndexPath *checkInSelectedIndexPath;
    UIView *myView;
    NSMutableDictionary *cellHeightsDict;
    BOOL checkInClicked;
    BOOL checkOutClicked;
    BOOL cancelBtnClicked;
    BOOL scanCheckInCheckOutClicked;

    BOOL docsBtnClicked;

    NSMutableDictionary     *bomCheckInReqDict;
    NSMutableDictionary     *bomCheckOutReqDict;


    
    // advance search
    
//    int checkInBtnTag;
//    int checkOutBtnTag;    
//    int checkInOrCheckOutBtnTag;
    
    
    
    int subViewBtnTag;
    
    BOOL raCheckInPartFound;
    BOOL raCheckOutPartFound;
    
    
    // for reading barcode
    
    UIButton *readBarCodeButton;
    UIViewController *tempReaderVC;
    UIView *barCodeReaderView;
    ZBarReaderViewController *reader;
    UIButton *barCodeCancelButton;
    IBOutlet UIButton *scanBomPartsBtn;
    IBOutlet UIImageView *testBarcodeImage;


    BOOL isSubViewClicked;
    BOOL showCamera;
    BOOL isCameraPresent;

    // for RA actions
    
    UITableView *actionOptionListTableView;
    UIViewController* popoverContent;
    UINavigationController *popOverNavigationController;
    UIPopoverController *popoverController;
    NSMutableDictionary *popOverDict; // for search


    NSMutableArray *actionsListAry;
    UIButton *actionBtnForCancel;
    
    NSMutableArray *documentDetailsAry;
    
    
    UIButton *selectedBomRADocsBtn;
    UIButton *selectedSubstitutePartsBtn;
    UIButton *actionBtn;
    
    
    
    // for subView
    
    
    IBOutlet UIScrollView *partDocumentsSubView;
    int selectedGetRAPartActionBtnTag;

    IBOutlet UITableView *partDocumnetsTableView;
    IBOutlet UILabel *partNumberLabel;
    
    NSMutableDictionary *getDocumnetsPartNumber;
    NSMutableDictionary *getSelectedPartNumber;

    NSMutableArray *partDocumnetListArray;
    NSMutableArray *substitutePartsListArray;
    
    UIButton *selectedPopOverDocBtn;
    UIButton *selectedPopOverSubstitutePartBtn;

    NSArray *partDocumentsHeadingAry;
    NSArray *partSubstitutePartsHeadingAry;

    
    // for no part found subview
    
    IBOutlet UIView *addPartSubView;
    IBOutlet UITextField *addPartCheckOutQty;
    IBOutlet UIButton *addPartBtn;
    
    
    NSString *browseRAPartDocumentsPartID;
    
    IBOutlet UILabel *barcodeLabel;

    BOOL isRADocuments;
    
    IBOutlet UILabel *partsSubViewHeadingLabel;

    int selectedCell;

    IBOutlet UIView *substitutePartsBtnView;
    IBOutlet UIButton *substitutePartsOkBtn;

    NSMutableDictionary *selectedSubstitutePartDict;

    NSString *raPartID;
    
    
    NSMutableDictionary *postReplacePartDict;
    NSMutableDictionary *getPartBarcodeDict;
    NSDictionary *bomNewPartDict;


    IBOutlet UILabel    *addedBOMPartNumLabel;
    IBOutlet UITextView *addedBomPartDesc;
    IBOutlet UILabel    *addedBomPartInStockVal;
    IBOutlet UILabel *addedBomPartBarcode;
    
    NSString *addbarcodePartID;
    
    NSMutableDictionary *addBomPartDict;
    
    IBOutlet UIButton *raPartBrowseDocsBtn;
    
    
    UIAlertView *deleteAlertView;
    
    
    NSMutableDictionary *deletedBompartDict;
    NSMutableDictionary *loadPartDocumentDict;
    
    
    UIWebView   *documentWebView;
    
    NSString *selectedUrlPath;
    UIViewController *webViewcontroller;

    NSString *browseDocsPartID;
    
    MBProgressHUD *loadExternalIpHud;
    
    
}

@property(nonatomic,retain) NSString *raValStr;

@property(nonatomic,assign) BOOL    isRAPartSelected;
@property(nonatomic,retain)NSString *selectedRAPart;
@property(nonatomic,retain)NSString *actionString;

-(IBAction)scanBomPartsBtnClicked:(id)sender;
-(IBAction)partDocumentSubViewCloseBtnClicked:(id)sender;


-(IBAction)addPartBtnClicked:(id)sender;
-(IBAction)addParttSubViewCloseBtnClicked:(id)sender;


-(IBAction)raPartBrowseDocsBtnClicked:(id)sender;
-(IBAction)testsubview:(id)sender;

-(IBAction)substitutePartsOkBtnClicked:(id)sender;

@end
