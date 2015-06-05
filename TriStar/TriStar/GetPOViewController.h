//
//  GetPOViewController.h
//  TriStar
//
//  Created by Manulogix on 17/01/14.
//  Copyright (c) 2014 Manulogix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "WebServiceInterface.h"
#import "POLineReceiptListCell.h"

@interface GetPOViewController : UIViewController<WebServiceInterfaceDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>{
    NSString *poValStr;
    
    NSArray *getPoOrderRecords,*tableGetPOHeading;
    WebServiceInterface    *webServiceInterface;
    UILabel *headingLabelView;
    
    
    IBOutlet UIScrollView  *getPOScrollView;

    // Po details
    IBOutlet UILabel    *getPODetailsHeadingLabel;
    IBOutlet UIView     *getPODetailsSubView;
    IBOutlet UILabel    *getPONumValLabel;
    IBOutlet UILabel    *getPOStatusValLabel;
    
    //Vendor details
    IBOutlet UILabel    *getPOVendorDetailsHeadingLabel;
    IBOutlet UIView     *getPOVendorDetailsSubView;
    
    IBOutlet UILabel *getPOShortNameValLabel;
    IBOutlet UILabel *getPONameValLabel;
    IBOutlet UILabel *getPOAddrValLabel;
    IBOutlet UILabel *getPOContactValLabel;
    IBOutlet UILabel *getPOPhoneValLabel;
    
        
    //Summary Details
    IBOutlet UILabel *getPOSummaryDetailsHeadingLabel;
    IBOutlet UIView  *getPOSummaryDetailsSubView;
   
    IBOutlet UILabel *getPOSubTotalValLabel;
    IBOutlet UILabel *getPOShippingValLabel;
    IBOutlet UILabel *getPOTaxValLabel;
    IBOutlet UILabel *getPOTotalValLabel;
    
    
    //Order Details
    IBOutlet UILabel        *getPOOrderDetailsHeadingLabel;
    IBOutlet UITableView    *getPOOrderDetailsTableView;
    
    
    // po actions
    
    UIButton *selectedGetPOActionBtn;

    
    // line item sub view
    IBOutlet UIScrollView *lineItemReceiptSubView;
    NSMutableDictionary *lineOrderDetailsDict;
    int remainingPartQuantity;
    NSArray *getPoReceiptTableValues;
    BOOL isEditing;
    UIButton *clickedLineRecieptBtn;
    NSDictionary *lineReceiptsEditingDict;

    IBOutlet UILabel *partNumberValInLineDetailsSubView;
    IBOutlet UILabel *statusValInLineDetailsSubView;
    IBOutlet UIButton *lineAddReceiptSubviewAddBtn;
    IBOutlet UITableView *lineItemReceiptsTableView;
   
    
    IBOutlet UIButton *addOrUpdateEntryBtn;
    BOOL animationStarted;
    BOOL lineDetailsAddBtnClicked;
    NSArray *lineReceiptDetailsArray;

    // entry sub view
    
    IBOutlet UITextField *lineReceiptRecvQty;
    IBOutlet UITextField *lineReceiptRecvDate;
    IBOutlet UITextField *lineReceiptVendorInvoice;
    IBOutlet UITextView  *lineReceiptCommentsTextView;

    
    // table subview
    IBOutlet UIView *lineItemsTableSubView;
    
    // advanced search
    
    int selectedGetPOActionBtnTag;
    
    NSInteger orderQty;
    NSInteger recvQty;
    
    BOOL addLineReciptBtnCalled;
    
    
    IBOutlet UILabel *partLocationVal;
    
    
}

@property(nonatomic,retain) NSString *poValStr;
@property(nonatomic,assign) BOOL isPartSelected;
@property(nonatomic,retain)NSString *selectedPart;



-(IBAction)lineReceiptSubViewCloseBtnClicked:(id)sender;
-(IBAction)lineAddReceiptSubviewAddBtnClicked:(id)sender;
-(IBAction)lineAddReceiptSubviewAddSaveBtnClicked:(id)sender;
-(IBAction)lineAddReceiptSubviewAddCancelBtnClicked:(id)sender;



@end
