//
//  GetRAViewController.m
//  TriStar
//
//  Created by Manulogix on 17/01/14.
//  Copyright (c) 2014 Manulogix. All rights reserved.
//

#import "GetRAViewController.h"
#import "OverlayView.h"
#include <ifaddrs.h>
#include <arpa/inet.h>


@interface GetRAViewController ()

@end

@implementation GetRAViewController
@synthesize raValStr;
@synthesize isRAPartSelected;
@synthesize selectedRAPart;
@synthesize actionString;

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
    
    checkInClicked = NO;
    docsBtnClicked = NO;
    
    self.navigationItem.title = @"Repair Details";

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backClicked:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    
    UIColor *headingColor = [FAUtilities getUIColorObjectFromHexString:@"#314F9B" alpha:1];
    getRADetailsSubView.backgroundColor = headingColor;
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){//setting the form list table frame when returing back to the form list view
        [getRAScrollView setContentSize:(CGSizeMake(768, 1024))];
        keyboardHeight = 264 + 44;
    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
        keyboardHeight = 352 + 44;
    }
    tableGetRAHeading = [[NSArray alloc]initWithObjects:@"Line#",@"Part#",@"Barcode",@"Consumed Qty",@"In Stock",@"Action", nil];
  
    actionsListAry = [[NSMutableArray alloc]initWithObjects:@"CheckIn",@"CheckOut",@"Browse Documents",@"Substitute Parts",@"Delete", nil];
    
    
    partDocumentsHeadingAry = [[NSArray alloc]initWithObjects:@"Title",@"FileName",@"Notes", nil];
    partSubstitutePartsHeadingAry = [[NSArray alloc]initWithObjects:@"Part#",@"In Stock",@"Choose", nil];
    
    
    
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

    
    [self postRequest:GET_RA_TYPE];
    
    isSubViewClicked = NO;
  
    
    
    NSString *ipAddress = [self getIPAddress];
    NSLog(@"ipAddress %@",ipAddress);
    


    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        // the slow stuff to be done in the background
        
        NSString *getExternalIpAddress = [self externalIPAddress];
        NSLog(@"getExternalIpAddress %@",getExternalIpAddress);
        
        
        NSUserDefaults *defaults = [[NSUserDefaults alloc]init];
        [defaults setObject:getExternalIpAddress forKey:@"ExternalIpAddress"];
        [defaults synchronize];

    });

    
    
    
    
    
    
    
    
    
    
    
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



-(void)postRequest:(NSString *)reqType{
    NSString *postDataInString;
    
    if ([reqType isEqualToString:GET_RA_TYPE]) {
        NSMutableDictionary *test = [[NSMutableDictionary alloc]init];
        [test setObject:raValStr forKey:@"getRANumberValue"];
        NSString *reqValStr = [self jsonFormat:GET_RA_TYPE withDictionary:test];
        postDataInString = [NSString stringWithFormat: @"{\"JsonRequest\":\"%@\"}",reqValStr];

    }else if ([reqType isEqualToString:RA_UPDATE_BOM]){
        NSString *reqValStr = [self jsonFormat:RA_UPDATE_BOM withDictionary:bomFinalReqDict];
        postDataInString = [NSString stringWithFormat: @"{\"JsonRequest\":\"%@\"}",reqValStr];
    }else if ([reqType isEqualToString:RA_PART_CHECKIN]){
        NSString *reqValStr = [self jsonFormat:RA_PART_CHECKIN withDictionary:bomCheckInReqDict];
        postDataInString = [NSString stringWithFormat: @"{\"JsonRequest\":\"%@\"}",reqValStr];
    }else if ([reqType isEqualToString:RA_PART_CHECKOUT]){
        NSString *reqValStr = [self jsonFormat:RA_PART_CHECKOUT withDictionary:bomCheckOutReqDict];
        postDataInString = [NSString stringWithFormat: @"{\"JsonRequest\":\"%@\"}",reqValStr];
    }else if ([reqType isEqualToString:GET_PART_DOCUMENTS]){
       
        NSString *reqValStr = [self jsonFormat:GET_PART_DOCUMENTS withDictionary:getDocumnetsPartNumber];
        postDataInString = [NSString stringWithFormat: @"{\"JsonRequest\":\"%@\"}",reqValStr];
    }else if ([reqType isEqualToString:ADD_RA_BOM_PART]){
//        NSMutableDictionary *test = [[NSMutableDictionary alloc]init];
//      
//        [test setObject:getRANumValLabel.text forKey:@"RANumber"];
//        [test setObject:barcodeLabel.text forKey:@"BarCode"];
//        [test setObject:addPartCheckOutQty.text forKey:@"CheckOutQty"];
        NSString *reqValStr = [self jsonFormat:ADD_RA_BOM_PART withDictionary:addBomPartDict];
        postDataInString = [NSString stringWithFormat: @"{\"JsonRequest\":\"%@\"}",reqValStr];
    
    }else if ([reqType isEqualToString:GET_SUBSTITUTE_PARTS]){
       
        NSString *reqValStr = [self jsonFormat:GET_SUBSTITUTE_PARTS withDictionary:getSelectedPartNumber];
        postDataInString = [NSString stringWithFormat: @"{\"JsonRequest\":\"%@\"}",reqValStr];
    }else if ([reqType isEqualToString:REPLACE_SUBSTITUTE_PART]){
        
        NSString *reqValStr = [self jsonFormat:REPLACE_SUBSTITUTE_PART withDictionary:postReplacePartDict];
        postDataInString = [NSString stringWithFormat: @"{\"JsonRequest\":\"%@\"}",reqValStr];

    }else if ([reqType isEqualToString:GET_PART]){

        NSString *reqValStr = [self jsonFormat:GET_PART withDictionary:getPartBarcodeDict];
        postDataInString = [NSString stringWithFormat: @"{\"JsonRequest\":\"%@\"}",reqValStr];

        
    }else if ([reqType isEqualToString:DELETE_BOM_PART]){
        NSString *reqValStr = [self jsonFormat:DELETE_BOM_PART withDictionary:deletedBompartDict];
        postDataInString = [NSString stringWithFormat: @"{\"JsonRequest\":\"%@\"}",reqValStr];

    }else if ([reqType isEqualToString:CHECK_DOCUMENT_ACCESS]){
        
        
        NSString *reqValStr = [self jsonFormat:CHECK_DOCUMENT_ACCESS withDictionary:loadPartDocumentDict];
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

-(NSString*)jsonFormat:(NSString *)type withDictionary:(NSMutableDictionary *)formatDict{
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *authDict = [standardUserDefaults objectForKey:@"LoginDetails"];
    NSString *bodyStr = [NSString stringWithFormat:@"{Type:\\\"%@\\\",Authentication:{UserName:\\\"%@\\\", Password:\\\"%@\\\"}", type,[authDict valueForKey:@"Username" ], [authDict valueForKey:@"Password"]];
    
    NSString *dataStr;
    
    if ([type isEqualToString:GET_RA_TYPE]){
        dataStr = [NSString stringWithFormat:@"Body:{RANumber:\\\"%@\\\"}}",[formatDict valueForKey:@"getRANumberValue"]];
    }else if ([type isEqualToString:RA_UPDATE_BOM]){
        NSMutableString *testStr= [[NSMutableString alloc]init];
        
        for (int i=0; i< [getRaRecords count]; i++) {
            NSString *addOrRemoveVal = [[formatDict objectForKey:@"BomAddOrRemoveVals"] objectForKey:[NSString stringWithFormat:@"%d",i]];
            if (addOrRemoveVal == nil) {
                addOrRemoveVal = [NSString stringWithFormat:@"%d",0];
            }
            NSString *temp = [NSString stringWithFormat:@"{BomID:\\\"%@\\\",AddOrRemoveQty:\\\"%@\\\"}",[[formatDict objectForKey:@"BomID"] objectForKey:[NSString stringWithFormat:@"%d",i]],addOrRemoveVal];
            
            [testStr appendString:[NSString stringWithFormat:@"%@,",temp]];
        }
        [testStr deleteCharactersInRange:NSMakeRange([testStr length]-1, 1)];
        dataStr = [NSString stringWithFormat:@"Body:{RANumber:\\\"%@\\\",BOM:[%@]}}",getRANumValLabel.text,testStr];

        
    }else if ([type isEqualToString:RA_PART_CHECKIN] || [type isEqualToString:RA_PART_CHECKOUT]){
        NSString *temp = [NSString stringWithFormat:@"{BomID:\\\"%@\\\",PartId:\\\"%@\\\",Quantity:\\\"%@\\\"}",[formatDict objectForKey:@"BomID"],[formatDict objectForKey:@"PartId"],[formatDict objectForKey:@"BomQuantity"]];
        dataStr = [NSString stringWithFormat:@"Body:{RANumber:\\\"%@\\\",BOM:%@}}",getRANumValLabel.text,temp];
    }else if ([type isEqualToString:GET_PART_DOCUMENTS]){
        
        dataStr = [NSString stringWithFormat:@"Body:{PartID:\\\"%@\\\"}}",[formatDict objectForKey:@"PartId"]];
    }else if ([type isEqualToString:ADD_RA_BOM_PART]){
      
        NSString *temp = [NSString stringWithFormat:@"{PartId:\\\"%@\\\",CheckOutQty:\\\"%@\\\"}",[formatDict objectForKey:@"AddBarCodePartID"],[formatDict objectForKey:@"AddPartCheckOutQty"]];
        dataStr = [NSString stringWithFormat:@"Body:{RANumber:\\\"%@\\\",BOM:%@}}",[formatDict objectForKey:@"RANumber"],temp];
    
    }else if ([type isEqualToString:GET_SUBSTITUTE_PARTS]){
        dataStr = [NSString stringWithFormat:@"Body:{PartID:\\\"%@\\\"}}",[formatDict objectForKey:@"PartId"]];
    }else if ([type isEqualToString:REPLACE_SUBSTITUTE_PART]){
//        dataStr = [NSString stringWithFormat:@"Body:{RANumber:\\\"%@\\\",RAPartID:\\\"%@\\\",ComponentPartID:\\\"%@\\\",SubstitutePartNumber:\\\"%@\\\"}}",[formatDict objectForKey:@"RANumber"],[formatDict objectForKey:@"RAPartID"],[formatDict objectForKey:@"BomPartID"],[formatDict objectForKey:@"SubstitutePartNumber"]];
        
        dataStr = [NSString stringWithFormat:@"Body:{RANumber:\\\"%@\\\",RAPartID:\\\"%@\\\",ComponentPartID:\\\"%@\\\",SubstitutePartID:\\\"%@\\\"}}",[formatDict objectForKey:@"RANumber"],[formatDict objectForKey:@"RAPartID"],[formatDict objectForKey:@"BomPartID"],[formatDict objectForKey:@"SubstitutePartId"]];

        
    }else if ([type isEqualToString:GET_PART]){
        dataStr = [NSString stringWithFormat:@"Body:{BARCodeOrPart:\\\"%@\\\"}}",[formatDict objectForKey:@"Barcode"]];
    }else if ([type isEqualToString:DELETE_BOM_PART]){
        dataStr = [NSString stringWithFormat:@"Body:{BomID:\\\"%@\\\",RAnumber:\\\"%@\\\"}}",[formatDict objectForKey:@"BomId"],getRANumValLabel.text];
    }else if ([type isEqualToString:CHECK_DOCUMENT_ACCESS]){
        
        dataStr = [NSString stringWithFormat:@"Body:{Type:\\\"%@\\\",TypeId:\\\"%@\\\"}}",[loadPartDocumentDict objectForKey:@"Type"],[loadPartDocumentDict objectForKey:@"TypeID"]];
        
    }
    
    
    

    NSString *finalReq = [NSString stringWithFormat:@"%@,%@", bodyStr,dataStr];
    return finalReq;
}


-(void)getResponse:(NSDictionary *)resp type:(NSString *)respType{
    
    if ([respType isEqualToString:GET_RA_TYPE]) {
        
        NSDictionary *getRAStatusDict = [resp valueForKey:@"Status"];
        NSDictionary *getRADataDict = [resp valueForKey:@"Data"];

        NSString *statusVal = [getRAStatusDict objectForKey:@"STATUS"];
        NSString *statusDesc = [getRAStatusDict objectForKey:@"DESCRIPTION"];
        
        if ([statusVal isEqualToString:@"0"]) {
            [FAUtilities showAlert:statusDesc withTitle:@""];
            getRADetailsHeadingLabel.hidden = YES;
            getRADetailsSubView.hidden = YES;
            
            getRACustomerDetailsHeadingLabel.hidden = YES;
            getRACustomerDetailsSubView.hidden = YES;
            
            getRARepairDetailsHeadingLabel.hidden = YES;
            getRARepairDetailsSubView.hidden = YES;
            
            getRARepairDetailsHedingLabel.hidden = YES;
            getRADetailsTableView.hidden = YES;
            updateBomDetailsBtn.hidden = YES;
            
            scanBomPartsBtn.hidden = YES;

        }else{
            
            getRADetailsHeadingLabel.hidden = NO;
            getRADetailsSubView.hidden = NO;
            
            getRACustomerDetailsHeadingLabel.hidden = NO;
            getRACustomerDetailsSubView.hidden = NO;
            
            getRARepairDetailsHedingLabel.hidden = NO;
            getRADetailsTableView.hidden = NO;
            updateBomDetailsBtn.hidden = NO;
            
            getRARepairDetailsHeadingLabel.hidden = NO;
            getRARepairDetailsSubView.hidden = NO;

            
            getRARepairDetailsSubView.backgroundColor = [UIColor clearColor];
            
            getRARepairDetailsSubView.layer.borderWidth = 1;
            getRARepairDetailsSubView.layer.borderColor = [[FAUtilities getUIColorObjectFromHexString:@"314F9B" alpha:1] CGColor];

            getRACustomerDetailsSubView.backgroundColor = [UIColor clearColor];
            
            getRACustomerDetailsSubView.layer.borderWidth = 1;
            getRACustomerDetailsSubView.layer.borderColor = [[FAUtilities getUIColorObjectFromHexString:@"314F9B" alpha:1] CGColor];

            
            NSString *getRANum              =[getRADataDict objectForKey:@"RANumber"];
            NSString *getRAStatus           =[getRADataDict objectForKey:@"Status"];
            
            
            if (![getRANum isEqual:[NSNull null]]) {
                getRANumValLabel.text = getRANum;
            }
           
            if (![getRAStatus isEqual:[NSNull null]]) {
                getRAStatusValLabel.text = getRAStatus;
            }
            
            NSString *getRACustID           = [getRADataDict objectForKey:@"CustomerID"];
            NSString *getRACustName         = [getRADataDict objectForKey:@"CustomerName"];
            NSString *getRACustShortName         = [getRADataDict objectForKey:@"CustomerShortName"];

            NSString *getRACustPhone        = [getRADataDict objectForKey:@"Phone"];
            NSString *getRACustContact      = [getRADataDict objectForKey:@"Contact"];
            NSString *getRACustAddr         = [getRADataDict objectForKey:@"Address"];
            NSString *getRACustState        = [getRADataDict objectForKey:@"State"];
            
            NSString *getRARaVal            = [getRADataDict objectForKey:@"RANumber"];
            NSString *getRAStatusVal        = [getRADataDict objectForKey:@"Status"];
            NSString *getRAPartVal          = [getRADataDict objectForKey:@"PartNumber"];
            NSString *getRAPartnote         = [getRADataDict objectForKey:@"PartNote"];
            NSString *getRARecvDateVAl      = [getRADataDict objectForKey:@"ReceivedDate"];
            NSString *getRABarcodeVal       = [getRADataDict objectForKey:@"BarCode"];

            raPartID = [getRADataDict objectForKey:@"PartId"];
            
            browseRAPartDocumentsPartID = [getRADataDict objectForKey:@"PartId"];
            
            NSRange range = [getRARecvDateVAl rangeOfString:@" "];
            
            NSString *newGetRARecvDateVAl = [getRARecvDateVAl substringToIndex:range.location];
            if (![getRACustID isEqual:[NSNull null]]) {
                getRACustIdValLabel.text = getRACustID;
            }
            if (![getRACustName isEqual:[NSNull null]]) {
                getRACustNameValLabel.text = getRACustName;
            }
            
            if (![getRACustShortName isEqual:[NSNull null]]) {
                getRACustShortNmaeValLabel.text = getRACustShortName;
            }

            
            
            if (![getRACustPhone isEqual:[NSNull null]]) {
                getRACustPhoneValLabel.text = getRACustPhone;
            }

            if (![getRACustContact isEqual:[NSNull null]]) {
                getRACustContactValLabel.text = getRACustContact;
            }

            if (![getRACustAddr isEqual:[NSNull null]]) {
                if (getRACustAddr.length >= 26) {
                    getRACustAddrValLabel.lineBreakMode = UILineBreakModeWordWrap;
                    getRACustAddrValLabel.numberOfLines=0;
                }

                
                getRACustAddrValLabel.text = getRACustAddr;
            }
            if (![getRACustState isEqual:[NSNull null]]) {
                getRACustStateValLabel.text = getRACustState;
            }
            
            if (![getRARaVal isEqual:[NSNull null]]) {
                getRASummaryNumValLabel.text = getRARaVal;
            }
            if (![getRAStatusVal isEqual:[NSNull null]]) {
                getRASummaryStatusValLabel.text = getRAStatusVal;
            }
            if (![getRAPartVal isEqual:[NSNull null]]) {
                getRASummaryPartNumValLabel.text = getRAPartVal;
            }
            
            if (![getRAPartnote isEqual:[NSNull null]]) {
                getRASummaryPartNoteValLabel.text = getRAPartnote;
            }
            if (![getRARecvDateVAl isEqual:[NSNull null]]) {
                getRASummaryRecvDateValLabel.text = newGetRARecvDateVAl;
            }
            if (![getRABarcodeVal isEqual:[NSNull null]]) {
                getRASummaryBarcodeValLabel.text = getRABarcodeVal;
            }


            getRADetailsTableView.delegate = self;
            getRADetailsTableView.dataSource = self;

            getRaRecords = [getRADataDict objectForKey:@"lstBom"];
            
//            if (getRaRecords.count >0) {
                scanBomPartsBtn.hidden = NO;
//            }else{
//                scanBomPartsBtn.hidden = YES;
//            }
            
            getRADetailsTableView.backgroundColor = [UIColor clearColor];
            
            getRADetailsTableView.layer.borderWidth =1;
            getRADetailsTableView.layer.borderColor = [[FAUtilities getUIColorObjectFromHexString:@"#314F9B" alpha:1] CGColor];
            
            [getRADetailsTableView reloadData];
            
            if (selectedRAPart.length !=0) {
                if ([actionString isEqualToString:@"CheckIn"]) {
                    [self checkInButtonClicked:nil];
                }else if ([actionString isEqualToString:@"CheckOut"]){
                    [self checkOutButtonClicked:nil];
                }
            }

        }
    }else if ([respType isEqualToString:RA_UPDATE_BOM] || [respType isEqualToString:RA_PART_CHECKIN] || [respType isEqualToString:RA_PART_CHECKOUT]){
        bomAddOrRemoveValsDict = [[NSMutableDictionary alloc]init];
        
        NSDictionary *getRAStatusDict = [resp valueForKey:@"Status"];
        NSDictionary *getRADataDict = [resp valueForKey:@"Data"];
        
        NSString *statusVal = [getRAStatusDict objectForKey:@"STATUS"];
        NSString *statusDesc = [getRAStatusDict objectForKey:@"DESCRIPTION"];
        
        if ([statusVal isEqualToString:@"0"]) {
//            [FAUtilities showAlert:@"Updation Failed"];
            [FAUtilities showAlert:statusDesc withTitle:@""];
        }else{
            NSArray *tempGetRaRecords = [[NSArray alloc]init];
            tempGetRaRecords = [getRADataDict objectForKey:@"lstBom"];

            
            if (tempGetRaRecords.count == 0) {
                [FAUtilities showAlert:@"Updation Failed" withTitle:@""];
            }else{
                getRaRecords = [[NSArray alloc]init];
                getRaRecords = [getRADataDict objectForKey:@"lstBom"];
                [getRADetailsTableView reloadData];
                if ([respType isEqualToString:RA_PART_CHECKIN]) {
                    [FAUtilities showAlert:@"CheckIn Successful" withTitle:@""];
                }else if ([respType isEqualToString:RA_PART_CHECKOUT]){
                    [FAUtilities showAlert:@"CheckOut Successful" withTitle:@""];
                }
//                [FAUtilities showAlert:@"Updation Successful"];
            }
        }
    }else if ([respType isEqualToString:GET_PART_DOCUMENTS]){
        
        NSDictionary *getPartDocStatusDict = [resp valueForKey:@"Status"];
        NSString *statusVal = [getPartDocStatusDict objectForKey:@"STATUS"];
        NSString *statusDesc = [getPartDocStatusDict objectForKey:@"DESCRIPTION"];

        if ([statusVal isEqualToString:@"0"]) {
            [FAUtilities showAlert:@"No documents found" withTitle:@""];
        }else{
            partDocumnetListArray = [[NSMutableArray alloc]init];
            partDocumnetListArray = [resp valueForKey:@"Data"];
            [self getDocumentsBtnClicked:selectedPopOverDocBtn];
        }
    }else if ([respType isEqualToString:ADD_RA_BOM_PART]){
        NSDictionary *getRespStatus = [resp valueForKey:@"Status"];
//        NSDictionary *getRespDataDict = [resp valueForKey:@"Data"];
        
        NSString *statusVal = [getRespStatus objectForKey:@"STATUS"];
        NSString *statusDesc = [getRespStatus objectForKey:@"DESCRIPTION"];
        
        if ([statusVal isEqualToString:@"0"]) {
            [FAUtilities showAlert:statusDesc withTitle:@""];
        }else{
            NSArray *tempGetRaRecords = [[NSArray alloc]init];
            tempGetRaRecords = [resp valueForKey:@"Data"];
            if (tempGetRaRecords.count == 0) {
                [FAUtilities showAlert:@"Updation Failed" withTitle:@""];
            }else{
                getRaRecords = [[NSArray alloc]init];
                getRaRecords = [resp valueForKey:@"Data"];
                [getRADetailsTableView reloadData];
                [FAUtilities showAlert:@"Bom part added" withTitle:@""];
                
                [self addParttSubViewCloseBtnClicked:nil];
                
            }
        }
    }else if ([respType isEqualToString:GET_SUBSTITUTE_PARTS]){
        NSLog(@"resposne %@", resp);
        
        substitutePartsListArray = [[NSMutableArray alloc]init];
        
        NSDictionary *getSubstitutePartsStatusDict = [resp valueForKey:@"Status"];
        
        NSString *statusVal = [getSubstitutePartsStatusDict objectForKey:@"STATUS"];
        NSString *statusDesc = [getSubstitutePartsStatusDict objectForKey:@"DESCRIPTION"];
        
        if ([statusVal isEqualToString:@"0"]) {
            [FAUtilities showAlert:@"No substitute parts found" withTitle:@""];
        }else{
            substitutePartsListArray = [resp valueForKey:@"Data"];
            
            if (substitutePartsListArray.count ==0) {
                [FAUtilities showAlert:@"No substitute parts found" withTitle:@""];
            }else{
                [self getSubstitutePartsBtnClicked:selectedSubstitutePartsBtn];
            }
        }
   

    }else if([respType isEqualToString:REPLACE_SUBSTITUTE_PART]){
        NSLog(@"resposne %@", resp);
        NSDictionary *getRespStatus = [resp valueForKey:@"Status"];
        NSString *statusVal = [getRespStatus objectForKey:@"STATUS"];
        NSString *statusDesc = [getRespStatus objectForKey:@"DESCRIPTION"];
        
        if ([statusVal isEqualToString:@"0"]) {
            [FAUtilities showAlert:statusDesc withTitle:@""];
        }else{
            NSArray *tempGetRaRecords = [[NSArray alloc]init];
            tempGetRaRecords = [resp valueForKey:@"Data"];
            if (tempGetRaRecords.count == 0) {
                [FAUtilities showAlert:@"Updation Failed" withTitle:@""];
            }else{
                getRaRecords = [[NSArray alloc]init];
                getRaRecords = [[resp valueForKey:@"Data"] objectForKey:@"lstBom"];
                [getRADetailsTableView reloadData];
                [FAUtilities showAlert:@"BOM part replaced" withTitle:@""];
                
                [self partDocumentSubViewCloseBtnClicked:nil];
            }
        }
    }else if ([respType isEqualToString:GET_PART]){
        NSLog(@"get part response");
        NSLog(@"resposne %@", resp);
        NSDictionary *getRespStatus = [resp valueForKey:@"Status"];
        NSString *statusVal = [getRespStatus objectForKey:@"STATUS"];
        NSString *statusDesc = [getRespStatus objectForKey:@"DESCRIPTION"];
        if ([statusVal isEqualToString:@"0"]) {
            [FAUtilities showAlert:statusDesc withTitle:@""];
        }else{
            NSArray *tempGetRaRecords = [[NSArray alloc]init];
            tempGetRaRecords = [resp valueForKey:@"Data"];
            if (tempGetRaRecords.count == 0) {
                [FAUtilities showAlert:statusDesc withTitle:@""];
            }else{
                NSArray *getPartArray = [resp valueForKey:@"Data"];
                bomNewPartDict = [getPartArray objectAtIndex:0];
                [self addingBomPartSubViewWithBarCode:bomNewPartDict];
            }
        }
    }else if ([respType isEqualToString:DELETE_BOM_PART]){
        NSLog(@"get part response");
        NSLog(@"resposne %@", resp);
        NSDictionary *getRespStatus = [resp valueForKey:@"Status"];
        NSString *statusVal = [getRespStatus objectForKey:@"STATUS"];
        NSString *statusDesc = [getRespStatus objectForKey:@"DESCRIPTION"];
        
        if ([statusVal isEqualToString:@"0"]) {
//            [FAUtilities showAlert:statusDesc];
            if ([statusDesc isEqualToString:@"BOM part not found."]) {
                [FAUtilities showAlert:statusDesc withTitle:@""];

                getRaRecords = [[NSArray alloc]init];
                getRaRecords = [resp valueForKey:@"Data"];
                [getRADetailsTableView reloadData];
            }else{
                [FAUtilities showAlert:statusDesc withTitle:@""];
            }
            
        }else{
            getRaRecords = [[NSArray alloc]init];
            
//            if ([[resp valueForKey:@"Data"] isEqual:[NSNull null]] || [resp valueForKey:@"Data"] == nil || [[resp valueForKey:@"Data"] isEqualToString:@"<null>"] ){
//            }else{
                getRaRecords = [resp valueForKey:@"Data"];
                [getRADetailsTableView reloadData];
//            }
            
        }
    }else if ([respType isEqualToString:CHECK_DOCUMENT_ACCESS]){
        
        NSLog(@"get part response");
        NSLog(@"resposne %@", resp);
        NSDictionary *getRespStatus = [resp valueForKey:@"Status"];
        NSString *statusVal = [NSString stringWithFormat:@"%@",[getRespStatus objectForKey:@"STATUS"]];
        NSString *statusDesc = [NSString stringWithFormat:@"%@",[getRespStatus objectForKey:@"DESCRIPTION"]];

        NSString *data = [NSString stringWithFormat:@"%@",[resp valueForKey:@"Data"]];
        
        if ([statusVal isEqualToString:@"1"]) {
            //            if document access is there, load in present view
            //            [self loadWebViewWithPath:selectedUrlPath];
            
            
//            if ([data containsString:@"User have access"]) {
            if ([data isEqualToString:@"User have access"]) {

                getDocumnetsPartNumber = [[NSMutableDictionary alloc]init];
                [getDocumnetsPartNumber setObject:browseDocsPartID forKey:@"PartId"];
                [self postRequest:GET_PART_DOCUMENTS];
            }else{
                [FAUtilities showAlert:data withTitle:@""];
            }
            
            
        }else{
            
            NSString *alertMsg;
            
            if (statusDesc.length ==0) {
                alertMsg = @"Unable to read response";
            }else{
                alertMsg = statusDesc;
            }
            
            
            [FAUtilities showAlert:alertMsg withTitle:@""];

            
        }
        
    }
}



-(void)loadWebViewWithPath:(NSString *)urlpath{
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
        documentWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0,10,1024,768)];
    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
        documentWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0,10,768,1024)];
    }
    
    
    [documentWebView setScalesPageToFit:YES];
    documentWebView.contentMode = UIViewContentModeScaleToFill;
    
//    NSURL *filePathURL = [NSURL fileURLWithPath:urlpath];
    
    NSURL *filePathURL = [NSURL URLWithString:urlpath];
    
    NSLog(@"loading started ");
    
    
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:filePathURL];
    [documentWebView setUserInteractionEnabled:YES];
    [documentWebView setDelegate:self];
    
    documentWebView.delegate = self;

    documentWebView.scalesPageToFit = YES;
    [[documentWebView.subviews objectAtIndex:0] setBounces:NO]; //to stop bouncing
    [documentWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.querySelector('meta[name=viewport]').setAttribute('content', 'width=%d;', false); ",(int)self.view.frame.size.width]];
    
    documentWebView.scalesPageToFit = YES;
    documentWebView.multipleTouchEnabled = YES;
    documentWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [documentWebView loadRequest:requestObj];
    
    
    
    webViewcontroller = [[UIViewController alloc] init];
    webViewcontroller.view = documentWebView;
    
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cancelBtn:)];
    
//    UIBarButtonItem *rightBarbuttonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionBtn:)];
    
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewcontroller];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    webViewcontroller.navigationItem.leftBarButtonItem = leftBarButton;
//    webViewcontroller.navigationItem.rightBarButtonItem = rightBarbuttonItem;
    //            webViewcontroller.navigationItem.title = itemName;
    
    
    NSLog(@"Present view");

    [self presentViewController:navigationController animated:YES completion:NULL];
}

-(void)cancelBtn:(id)Sender{
    [webViewcontroller dismissViewControllerAnimated:YES completion:nil];
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"Error : %@",error);
}


#pragma mark -
#pragma mark TableView Datasource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == getRADetailsTableView) {
        cellHeightsDict = [[NSMutableDictionary alloc]init];
        return [getRaRecords count];
    }else if (tableView == partDocumnetsTableView){
        if([partsSubViewHeadingLabel.text isEqualToString:@"Part Documents"]){
            return  [partDocumnetListArray count];
        }else if ([partsSubViewHeadingLabel.text isEqualToString:@"Substitute Parts"]){
            return [substitutePartsListArray count];
        }
    }else if (tableView == actionOptionListTableView){
        return  [actionsListAry count];
    }
}


-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (tableView == actionOptionListTableView){
        return 0;
    }else{
        return  42.0;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == getRADetailsTableView) {
        
        if (cancelBtnClicked == YES) {
            [cellHeightsDict setObject:@"42" forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
            return 42.0;
        }else{
            if(selectedIndexPath != nil
               && [selectedIndexPath compare:indexPath] == NSOrderedSame){
                if (checkInClicked == YES || checkOutClicked == YES || scanCheckInCheckOutClicked == YES) {
                    [cellHeightsDict setObject:@"185" forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
                    return 185;
                }else if (docsBtnClicked == YES ){
                    [cellHeightsDict setObject:@"300" forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
                    return 300;
                }
            }
            [cellHeightsDict setObject:@"42" forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
            return 42.0;
        }
        
    }else{
        return 42.0;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (tableView == getRADetailsTableView) {
        
        
        //        float cellWidth = getRADetailsTableView.frame.size.width;
        CGFloat width = 0.0f;
        
        CGFloat originX = 0.0f;
        UIView *headerView = [[UIView alloc] init];
        
        headerView.frame = CGRectMake(0, 0, getRADetailsTableView.frame.size.width, 80);
        
        headerView.backgroundColor = [UIColor clearColor];
        for (int i=0; i<[tableGetRAHeading count]; i++) {
            headingLabelView = [[UILabel alloc]init];
            switch (i) {
                case 0:
                {
                    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                        width = 72;
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                        width = 53;
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                    }
                    break;
                }
                case 1:
                {
                    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                        width = 307;
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                        
                    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                        width = 231;
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                    }
                    break;
                }
                case 2:
                {
                    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                        width = 239;
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                        width = 180;
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                    }
                    break;
                }
                case 3:
                {
                    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                        width = 134;
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                        width =100;
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                    }
                    break;
                }
                    
                    
                    
                    
                case 4:
                {
                    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                        width = 106;
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                        width =80;
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                    }
                    break;
                }
                case 5:
                {
                    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                        width = 131;
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                        width =101;
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                    }
                    break;
                }
                default:
                    break;
            }
            
            headingLabelView.text = [tableGetRAHeading objectAtIndex:i];
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
        
    }else if (tableView == partDocumnetsTableView){
        {
            
            if([partsSubViewHeadingLabel.text isEqualToString:@"Part Documents"]){
                CGFloat width = 0.0f;
                CGFloat originX = 20.0f;
                UIView *headerView = [[UIView alloc] init];
                
                headerView.frame = CGRectMake(0, 0, partDocumnetsTableView.frame.size.width, 80);
                
                headerView.backgroundColor = [UIColor grayColor];
                for (int i=0; i<[partDocumentsHeadingAry count]; i++) {
                    headingLabelView = [[UILabel alloc]init];
                    
                    switch (i) {
                        case 0:
                        {
                            width = 166;
                            headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                            break;
                        }
                        case 1:
                        {
                            width = 166;
                            headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                            break;
                        }
                        case 2:
                        {
                            width = 166;
                            headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                            break;
                        }
                        default:
                            break;
                    }
                    
                    //            headingLabelView = [[UILabel alloc]initWithFrame:CGRectMake(originX, originY, width, height)];
                    headingLabelView.text = [partDocumentsHeadingAry objectAtIndex:i];
                    headingLabelView.backgroundColor = [UIColor  grayColor];
                    headingLabelView.font=[UIFont fontWithName:@"Arial-BoldMT" size:17];
                    headingLabelView.numberOfLines=0;
                    headingLabelView.textAlignment = NSTextAlignmentCenter;
                    [headerView addSubview:headingLabelView];
                    
                    
                    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                        originX += width+7.5;
                        
                    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                        originX += width+6;
                        
                    }
                    headingLabelView.tag = 100+i;
                }
                return headerView;
            }else if ([partsSubViewHeadingLabel.text isEqualToString:@"Substitute Parts"]){
                CGFloat width = 0.0f;
                CGFloat originX = 24.0f;
                UIView *headerView = [[UIView alloc] init];
                
                headerView.frame = CGRectMake(0, 0, partDocumnetsTableView.frame.size.width, 80);
                
                headerView.backgroundColor = [UIColor grayColor];
                for (int i=0; i<[partSubstitutePartsHeadingAry count]; i++) {
                    headingLabelView = [[UILabel alloc]init];
                    
                    switch (i) {
                        case 0:
                        {
                            width = 226;
                            headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                            break;
                        }
                        case 1:
                        {
                            width = 226;
                            headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                            break;
                        }
                        case 2:
                        {
                            width = 100;
                            headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                            break;
                        }
                        default:
                            break;
                    }
                    
                    //            headingLabelView = [[UILabel alloc]initWithFrame:CGRectMake(originX, originY, width, height)];
                    headingLabelView.text = [partSubstitutePartsHeadingAry objectAtIndex:i];
                    headingLabelView.backgroundColor = [UIColor  grayColor];
                    headingLabelView.font=[UIFont fontWithName:@"Arial-BoldMT" size:17];
                    headingLabelView.numberOfLines=0;
                    headingLabelView.textAlignment = NSTextAlignmentCenter;
                    [headerView addSubview:headingLabelView];
                    
                    
                    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                        originX += width+10;
                        
                    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                        originX += width+10;
                        
                    }
                    headingLabelView.tag = 100+i;
                }
                return headerView;
            }
                
            
            
        }
        
        
    }
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == getRADetailsTableView) {
        NSDictionary *orderDict = [getRaRecords objectAtIndex:indexPath.row];
        static NSString *TableCellIdentifier = @"RepairListCell";
        RepairListCell *cell =(RepairListCell *) [getRADetailsTableView dequeueReusableCellWithIdentifier:TableCellIdentifier];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RepairListCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSString *getRALineNumStr   = [orderDict valueForKey:@"LineNum"];
        NSString *getRAPartNumStr   = [orderDict valueForKey:@"PartNumber"];
        NSString *getRADescStr    = [orderDict valueForKey:@"BomNotes"];
        NSString *getRABarCodeStr    = [orderDict valueForKey:@"BarCode"];
        NSString *getRAConsumedQtyStr    = [orderDict valueForKey:@"QuantityUsed"];
        NSString *getRARequireQtyStr    = [orderDict valueForKey:@"RequiredQuantity"];
        NSString *getRAInStockQtyStr     = [orderDict valueForKey:@"InStock"];
        
        
        if (![getRALineNumStr isEqual:[NSNull null]]) {
            cell.lineNumber.text = getRALineNumStr;
        }
        
        if (![getRAPartNumStr isEqual:[NSNull null]]) {
            cell.partNumber.text = getRAPartNumStr;
        }
        
        if (![getRADescStr isEqual:[NSNull null]]) {
            cell.desc.text = getRADescStr;
        }
        
        
        if (![getRABarCodeStr isEqual:[NSNull null]]) {
            cell.barCode.text = getRABarCodeStr;
        }
        
        //    if (![getRARequireQtyStr isEqual:[NSNull null]]) {
        //        if (getRARequireQtyStr.length ==0) {
        //            cell.requiredQty.text = @"0";
        //        }else{
        //            cell.requiredQty.text = getRARequireQtyStr;
        //        }
        //    }
        
        if (![getRAConsumedQtyStr isEqual:[NSNull null]]) {
            if (getRAConsumedQtyStr.length ==0) {
                cell.consumedQty.text = @"0";
            }else{
                cell.consumedQty.text = getRAConsumedQtyStr;
            }
        }
        
        if (![getRAInStockQtyStr isEqual:[NSNull null]]) {
            if (getRAInStockQtyStr.length ==0) {
                cell.inStock.text = @"0";
            }else{
                cell.inStock.text = getRAInStockQtyStr;
            }
        }
        
        
        cell.addOrRemoveQty.text = [bomAddOrRemoveValsDict objectForKey:[NSString stringWithFormat:@"%d",indexPath.row]];
        NSString *cellHeight = [cellHeightsDict objectForKey:[NSString stringWithFormat:@"%d",indexPath.row]];
        if ([cellHeight isEqualToString:@"42"] || [cellHeight isEqualToString:@"300"]) {
            cell.cellSubView.hidden = YES;
        }
        
        if ([cellHeight isEqualToString:@"42"] || [cellHeight isEqualToString:@"185"]) {
            cell.documentsListView.hidden = YES;
        }
        
        //    if (isSubViewClicked == YES) {
        //        UIButton *tempBtn = [[UIButton alloc]init];
        //        tempBtn.tag = indexPath.row;
        //        if (checkInClicked == YES) {
        //            [self checkInButtonClicked:tempBtn];
        //        }else if(checkOutClicked == YES){
        //            [self checkOutButtonClicked:tempBtn];
        //        }else if(scanCheckInCheckOutClicked == YES){
        //            [self scanCheckInOrCheckOutClicked:tempBtn];
        //        }
        //
        //    }
        
        
        [cell.checkInButton addTarget:self
                               action:@selector(checkInButtonClicked:)
                     forControlEvents:UIControlEventTouchUpInside];
        cell.checkInButton.tag = indexPath.row;
        
        [cell.checkOutButton addTarget:self
                                action:@selector(checkOutButtonClicked:)
                      forControlEvents:UIControlEventTouchUpInside];
        cell.checkOutButton.tag = indexPath.row;
        
        
        
        [cell.actionButton addTarget:self action:@selector(actionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        cell.actionButton.tag = indexPath.row;
        
        
        
        
        if (checkInClicked == YES) {
            cell.chekInOrCheckOutFieldLabel.text = @"CheckIn Qty";
            cell.reqQtyValueLabel.text = [orderDict objectForKey:@"RequiredQuantity"];
            cell.consumedQtyValueLabel.text = [orderDict objectForKey:@"UsedQuantity"];
            cell.subViewPartNum.text = [orderDict objectForKey:@"PartNumber"];
            cell.subViewBomNotes.text   =[orderDict objectForKey:@"BomNotes"];
            cell.scanBarCodeCheckInOrCheckOutBtn.hidden = YES;
            
            
            [cell.checkInOrCheckOutBtn setTitle:@"CheckIn" forState:UIControlStateNormal];
            cell.cellSubView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"checkInOrOut.png"]];
            
            
            [cell.cancelBtn addTarget:self
                               action:@selector(cancleBtnClicked:)
                     forControlEvents:UIControlEventTouchUpInside];
            cell.cancelBtn.tag = indexPath.row;
            [cell.checkInOrCheckOutBtn addTarget:self
                                          action:@selector(checkInSaveBtnClicked:)
                                forControlEvents:UIControlEventTouchUpInside];
            cell.checkInOrCheckOutBtn.tag = indexPath.row;
        }else if (checkOutClicked == YES){
            
            cell.chekInOrCheckOutFieldLabel.text = @"CheckOut Qty";
            cell.consumedQtyValueLabel.text = [orderDict objectForKey:@"UsedQuantity"];
            cell.subViewPartNum.text = [orderDict objectForKey:@"PartNumber"];
            cell.subViewBomNotes.text   =[orderDict objectForKey:@"BomNotes"];
            cell.scanBarCodeCheckInOrCheckOutBtn.hidden = YES;
            
            [cell.checkInOrCheckOutBtn setTitle:@"CheckOut" forState:UIControlStateNormal];
            cell.cellSubView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"checkInOrOut.png"]];
            
            [cell.cancelBtn addTarget:self
                               action:@selector(cancleBtnClicked:)
                     forControlEvents:UIControlEventTouchUpInside];
            cell.cancelBtn.tag = indexPath.row;
            [cell.checkInOrCheckOutBtn addTarget:self
                                          action:@selector(checkOutSaveBtnClicked:)
                                forControlEvents:UIControlEventTouchUpInside];
            cell.checkInOrCheckOutBtn.tag = indexPath.row;
        }else if (scanCheckInCheckOutClicked == YES){
            
            cell.chekInOrCheckOutFieldLabel.text = @"Enter Qty";
            cell.consumedQtyValueLabel.text = [orderDict objectForKey:@"UsedQuantity"];
            cell.subViewPartNum.text = [orderDict objectForKey:@"PartNumber"];
            cell.subViewBomNotes.text   =[orderDict objectForKey:@"BomNotes"];
            
            cell.cellSubView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"checkInOrOut.png"]];
            cell.scanBarCodeCheckInOrCheckOutBtn.hidden = NO;
            
            [cell.checkInOrCheckOutBtn setTitle:@"CheckIn" forState:UIControlStateNormal];
            [cell.scanBarCodeCheckInOrCheckOutBtn setTitle:@"CheckOut" forState:UIControlStateNormal];
            
            
            [cell.cancelBtn addTarget:self
                               action:@selector(cancleBtnClicked:)
                     forControlEvents:UIControlEventTouchUpInside];
            cell.cancelBtn.tag = subViewBtnTag;
            
            [cell.checkInOrCheckOutBtn addTarget:self
                                          action:@selector(checkInSaveBtnClicked:)
                                forControlEvents:UIControlEventTouchUpInside];
            cell.checkInOrCheckOutBtn.tag = subViewBtnTag;
            
            
            [cell.scanBarCodeCheckInOrCheckOutBtn addTarget:self
                                                     action:@selector(checkOutSaveBtnClicked:)
                                           forControlEvents:UIControlEventTouchUpInside];
            cell.scanBarCodeCheckInOrCheckOutBtn.tag = subViewBtnTag;
            
            
            
            
            
        }else if(docsBtnClicked == YES){
            cell.documentsListView.backgroundColor = [UIColor lightGrayColor];

         }
        
        return cell;
    }else if (tableView == partDocumnetsTableView){
        if ([partsSubViewHeadingLabel.text isEqualToString:@"Part Documents"]) {
            static NSString *TableCellIdentifier = @"RADocumentTableViewCell";
            RADocumentTableViewCell *cell =(RADocumentTableViewCell *) [partDocumnetsTableView dequeueReusableCellWithIdentifier:TableCellIdentifier];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RADocumentTableViewCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            NSDictionary *tempDict = [partDocumnetListArray objectAtIndex:indexPath.row];
            NSString *titleStr = [NSString stringWithFormat:@"%@",[tempDict objectForKey:@"Title"]];
            NSString *fileNameStr = [NSString stringWithFormat:@"%@",[tempDict objectForKey:@"FileName"]];
            NSString *noteStr = [NSString stringWithFormat:@"%@",[tempDict objectForKey:@"Notes"]];
            if ([titleStr isEqualToString:@"<null>"]) {
            }else{
                if (titleStr != nil || [titleStr isEqual:[NSNull null]]) {
                    cell.docTitle.text = [tempDict objectForKey:@"Title"];
                }
            }
            if ([fileNameStr isEqualToString:@"<null>"]) {
            }else{
                if (fileNameStr != nil || [fileNameStr isEqual:[NSNull null]]) {
                    cell.docFileName.text = [tempDict objectForKey:@"FileTitle"];
                }
            }
            if ([noteStr isEqualToString:@"<null>"]) {
                
            }else{
                if (noteStr != nil || [noteStr isEqual:[NSNull null]]) {
                    cell.docNotes.text = [tempDict objectForKey:@"Notes"];
                }
            }
            return cell;
        }else if ([partsSubViewHeadingLabel.text isEqualToString:@"Substitute Parts"]){
            
            static NSString *TableCellIdentifier = @"RABomSubstitutePartsTableViewCell";
            RABomSubstitutePartsTableViewCell *cell =(RABomSubstitutePartsTableViewCell *) [partDocumnetsTableView dequeueReusableCellWithIdentifier:TableCellIdentifier];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RABomSubstitutePartsTableViewCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            
            
            NSDictionary *tempDict = [substitutePartsListArray objectAtIndex:indexPath.row];
            cell.substitutePartNumber.text = [tempDict objectForKey:@"PartNumber"];
            cell.substitutePartInStock.text = [tempDict objectForKey:@"InStock"];
          
            if (selectedSubstitutePartDict.count != 0) {
                if(indexPath.row == selectedCell)
                {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    cell.selected = YES;
                }
                else
                {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selected = NO;
                }
            }
            
            return cell;
            
        }
    }else if (tableView == actionOptionListTableView){
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.textLabel.text = [actionsListAry objectAtIndex:indexPath.row];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.contentView.backgroundColor = [UIColor grayColor];
        
        return cell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == partDocumnetsTableView) {

        if ([partsSubViewHeadingLabel.text isEqualToString:@"Part Documents"]) {
            NSDictionary *tempDict = [partDocumnetListArray objectAtIndex:indexPath.row];
            NSString *tempPath = [tempDict objectForKey:@"Path"];
            NSLog(@"tempPath %@",tempPath);
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[tempPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
//            for checking browse document
            selectedUrlPath = tempPath;
            [self loadWebViewWithPath:selectedUrlPath];

            
            
            
          

            
            
            
            
        }else if([partsSubViewHeadingLabel.text isEqualToString:@"Substitute Parts"]){
            selectedCell = indexPath.row;

            
            selectedSubstitutePartDict = [substitutePartsListArray objectAtIndex:indexPath.row];
            [partDocumnetsTableView reloadData];

        }

    }else if (tableView == actionOptionListTableView){
        if (indexPath.row == 0) {
            [self popOverCheckInBtnClicked:actionBtn];
        }else if (indexPath.row == 1) {
            [self popOverCheckOutBtnClicked:actionBtn];
        }else if (indexPath.row == 2){
            [self popOverDocBtnClicked:actionBtn];
        }else if (indexPath.row == 3){
            [self popOverSubstitutePartBtnClicked:actionBtn];
        }else if (indexPath.row == 4){
            [popoverController dismissPopoverAnimated:YES];
            deleteAlertView = [[UIAlertView alloc]initWithTitle:@"Tri Star" message:@"Are you sure, you want to delete this item from BOM?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            deleteAlertView.tag = actionBtn.tag;
            [deleteAlertView show];
        }
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"button index %ld", (long)buttonIndex);
    
    if (alertView == deleteAlertView) {
        if (buttonIndex ==1) {
            NSDictionary *currentDict = [getRaRecords objectAtIndex:alertView.tag];

            NSLog(@"curent dict %@", currentDict);
            NSLog(@"delete bom part");

            deletedBompartDict = [[NSMutableDictionary alloc]init];
            [deletedBompartDict setObject:[currentDict objectForKey:@"PartId"] forKey:@"PartId"];
            [deletedBompartDict setObject:[currentDict objectForKey:@"BomId"] forKey:@"BomId"];

            [self postRequest:DELETE_BOM_PART];
        }
    }

}

-(void)checkInButtonClicked:(id)sender{
    
    isSubViewClicked = YES;

    cancelBtnClicked = NO;
    checkOutClicked = NO;
    checkInClicked = YES;
    docsBtnClicked = NO;

    UIButton *checkInBtn = (UIButton*)sender;
    NSDictionary *orderDict = [[NSDictionary alloc]init];
    
    if (sender == nil) {
        for (int i=0; i<[getRaRecords count]; i++) {
            NSDictionary *tempDict = [getRaRecords objectAtIndex:i];
            NSString *raPart = [tempDict objectForKey:@"PartNumber"];
            
            if ([raPart isEqualToString:selectedRAPart]) {
                orderDict = tempDict;
                subViewBtnTag = i;
                raCheckInPartFound = YES;
                break;
            }else{
                raCheckInPartFound = NO;
                continue;
            }
        }
        if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){//setting the form list table frame when returing back to the form list view
            CGRect rectToScroll = CGRectMake(getRAScrollView.frame.origin.x, getRAScrollView.frame.origin.y, getRAScrollView.frame.size.width, getRAScrollView.frame.size.height+300);
            [getRAScrollView scrollRectToVisible:rectToScroll animated:YES];            
        }

    }else{
        raCheckInPartFound = YES;

        subViewBtnTag = checkInBtn.tag;
        orderDict = [getRaRecords objectAtIndex:subViewBtnTag];
    }

    if (raCheckInPartFound == YES) {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:subViewBtnTag inSection:0];
        
        NSIndexPath *previousSelectedIndexPath = selectedIndexPath;  // <- save previously selected cell
        previousSelectedIndexPath = selectedIndexPath;  // <- save previously selected cell
        selectedIndexPath = newIndexPath;
        
        if (previousSelectedIndexPath) { // <- reload previously selected cell (if not nil)
            [getRADetailsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:previousSelectedIndexPath]
                                         withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [getRADetailsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedIndexPath]
                                     withRowAnimation:UITableViewRowAnimationAutomatic];
        
         
        [getRADetailsTableView scrollToRowAtIndexPath:selectedIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        RepairListCell *checkInCell = (RepairListCell*)[getRADetailsTableView cellForRowAtIndexPath:newIndexPath];
        checkInCell.cellSubView.hidden = NO;
        checkInCell.cellSubView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"checkInOrOut.png"]];
        //        NSDictionary *orderDict = [getRaRecords objectAtIndex:newIndexPath.row];
        checkInCell.scanBarCodeCheckInOrCheckOutBtn.hidden = YES;

        
        NSString *reqQty        = [orderDict objectForKey:@"RequiredQuantity"];
        NSString *consumedQty   = [orderDict objectForKey:@"UsedQuantity"];
        
        
        checkInCell.chekInOrCheckOutFieldLabel.text = @"CheckIn Qty";
        
        if (reqQty.length == 0 ||reqQty == (NSString*) [NSNull null]) {
            checkInCell.reqQtyValueLabel.text = @"0";
        }else{
            checkInCell.reqQtyValueLabel.text = reqQty;
        }
        
        if (consumedQty.length == 0 ||consumedQty == (NSString*) [NSNull null]) {
            checkInCell.consumedQtyValueLabel.text = @"0";
        }else{
            checkInCell.consumedQtyValueLabel.text = consumedQty;
        }
        
        
        checkInCell.subViewPartNum.text = [orderDict objectForKey:@"PartNumber"];
        checkInCell.subViewBomNotes.text   =[orderDict objectForKey:@"BomNotes"];
        
        [checkInCell.checkInOrCheckOutBtn setTitle:@"CheckIn" forState:UIControlStateNormal];
        [checkInCell.cancelBtn addTarget:self
                                  action:@selector(cancleBtnClicked:)
                        forControlEvents:UIControlEventTouchUpInside];
        checkInCell.cancelBtn.tag = subViewBtnTag;
        [checkInCell.checkInOrCheckOutBtn addTarget:self
                                             action:@selector(checkInSaveBtnClicked:)
                                   forControlEvents:UIControlEventTouchUpInside];
        checkInCell.checkInOrCheckOutBtn.tag = subViewBtnTag;

    }
}

-(void)cancleBtnClickedForAction:(id)sender{
    isSubViewClicked = NO;
    docsBtnClicked = NO;
//    UIButton *cancelBtn = (UIButton*)sender;
    cancelBtnClicked = YES;

}


-(void)cancleBtnClicked:(id)sender{
    isSubViewClicked = NO;
    docsBtnClicked = NO;
    UIButton *cancelBtn = (UIButton*)sender;
    cancelBtnClicked = YES;
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:cancelBtn.tag inSection:0];
    [getRADetailsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                 withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)checkInSaveBtnClicked:(id)sender{
    
    [self.view endEditing:YES];
    bomCheckInReqDict = [[NSMutableDictionary alloc]init];
      UIButton *checkInSaveBtn = (UIButton*)sender;

    NSString *currentCheckInVal = [bomAddOrRemoveValsDict objectForKey:[NSString stringWithFormat:@"%d", checkInSaveBtn.tag]];
    
    if (currentCheckInVal.length == 0) {
        [FAUtilities showAlert:@"Please Enter Quantity" withTitle:@""];
    }else{
        NSDictionary *tempDic = [getRaRecords objectAtIndex:checkInSaveBtn.tag];
      
        NSString *consumedqty =[tempDic objectForKey:@"UsedQuantity"];
        NSString *bomID = [tempDic objectForKey:@"BomId"];
        NSString *partNumber = [tempDic objectForKey:@"PartNumber"];
        NSString *partID = [tempDic objectForKey:@"PartId"];
        
        [bomCheckInReqDict setObject:bomID forKey:@"BomID"];
        [bomCheckInReqDict setObject:partNumber forKey:@"PartNumber"];
        [bomCheckInReqDict setObject:partID forKey:@"PartId"];
        [bomCheckInReqDict setObject:currentCheckInVal forKey:@"BomQuantity"];

        if([currentCheckInVal intValue] <=0){
            [FAUtilities showAlert:@"CheckIn quantity must be greated than zero" withTitle:@""];
        }else{
            if ([currentCheckInVal intValue] >[consumedqty intValue] || [consumedqty intValue]<=0) {
                [FAUtilities showAlert:@"CheckIn quantity must be less than or equal to consumed quantity" withTitle:@""];
            }else{
                [self postRequest:RA_PART_CHECKIN];
                [self cancleBtnClicked:checkInSaveBtn];
            }
        }
    }
}



-(void)actionButtonClicked:(id)sender{
    
    
    [self cancleBtnClickedForAction:actionBtnForCancel];
    
    actionBtn = (UIButton*)sender;
    actionBtnForCancel = actionBtn;
    
    actionOptionListTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0,200,250)];
    actionOptionListTableView.delegate = self;
    actionOptionListTableView.dataSource = self;
    

//    UIView *tempView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
//
//    UIButton *popOverCheckInBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 2, 200, 40)];
//    [popOverCheckInBtn setTitle:@"CheckIn" forState:UIControlStateNormal];
//    [popOverCheckInBtn addTarget:self action:@selector(popOverCheckInBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [self customPopOverBtn:popOverCheckInBtn];
//
//    UIButton *popOverCheckOutBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, popOverCheckInBtn.frame.origin.y+popOverCheckInBtn.frame.size.height+2, 200, 40)];
//    [popOverCheckOutBtn setTitle:@"CheckOut" forState:UIControlStateNormal];
//    [popOverCheckOutBtn addTarget:self action:@selector(popOverCheckOutBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [self customPopOverBtn:popOverCheckOutBtn];
//
//    
//    UIButton *popOverDocBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, popOverCheckOutBtn.frame.origin.y+popOverCheckOutBtn.frame.size.height+2, 200, 40)];
//    [popOverDocBtn setTitle:@"Documents" forState:UIControlStateNormal];
//    [popOverDocBtn addTarget:self action:@selector(popOverDocBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [self customPopOverBtn:popOverDocBtn];
//
//    
//    popOverCheckInBtn.tag = actionBtn.tag;
//    popOverCheckOutBtn.tag = actionBtn.tag;
//    popOverDocBtn.tag = actionBtn.tag;
//    
//    
//    
//    [tempView addSubview:popOverDocBtn];
//    [tempView addSubview:popOverCheckOutBtn];
//    [tempView addSubview:popOverCheckInBtn];
    

    [self showPopOverForFilter:actionOptionListTableView withButton:actionBtn withTitle:@"Actions"];


}

#pragma mark Filter
/* Method for state picker popover */
-(void)showPopOverForFilter:(UIView *)aView withButton:(UIButton *)button withTitle:(NSString *)aTitle{
    
    

    
    //    searchOptions = [[NSMutableArray alloc]init];
    popoverContent = [[UIViewController alloc] init];
    
    UIView* popoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 250)];
    popoverView.backgroundColor = [UIColor whiteColor];
    [popoverView addSubview:aView];
    popoverContent.view = popoverView;
    popoverContent.title = aTitle;
    
    popOverNavigationController = [[UINavigationController alloc] initWithRootViewController:popoverContent];
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissPopOverController:)];
	popOverNavigationController.navigationItem.rightBarButtonItem = doneButton;
    
    popOverNavigationController.navigationBar.tintColor = [FAUtilities getUIColorObjectFromHexString:@"#236198" alpha:1];
    popOverNavigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [FAUtilities getUIColorObjectFromHexString:@"#236198" alpha:1]};
    
    //    popoverContent.contentSizeForViewInPopover = CGSizeMake(300,500);
    popoverContent.preferredContentSize = CGSizeMake(200,250);
    
    
    popoverController = [[UIPopoverController alloc] initWithContentViewController:popOverNavigationController];
    
    CGRect popoverRect = [self.view convertRect:[button frame] fromView:[button superview]];
    
    popoverRect.size.width = MIN(popoverRect.size.width, 100);
    popoverController.delegate =self;
    popoverRect.origin.x  = popoverRect.origin.x;
    
    
    [self popOverWithBtnFrame:popoverRect];
    
    //    [popoverController presentPopoverFromRect:popoverRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

-(void)popOverWithBtnFrame:(CGRect )popoverRect{
    [popoverController presentPopoverFromRect:popoverRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}


- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    // do something now that it's been dismissed
    [self dismissTableInset];
    
}



-(void)popOverCheckInBtnClicked:(id)sender{

    [popoverController dismissPopoverAnimated:YES];
    [self dismissTableInset];
    [self checkInButtonClicked:sender];
    
    
    NSLog(@"sender %@",sender);
    NSLog(@"pop over test");
    
}


-(void)popOverCheckOutBtnClicked:(id)sender{
    
    
    [popoverController dismissPopoverAnimated:YES];
    [self dismissTableInset];

    
    [self checkOutButtonClicked:sender];
    
  NSLog(@"pop over test");
    
}


-(void)popOverDocBtnClicked:(id)sender{
    isRADocuments = NO;
    [self dismissTableInset];
    [popoverController dismissPopoverAnimated:YES];
    selectedPopOverDocBtn = (UIButton*)sender;
    NSLog(@"doc Btn tag %ld", (long)selectedPopOverDocBtn.tag);
    NSString *getDocumnetsPartNumberStr = [[getRaRecords objectAtIndex:selectedPopOverDocBtn.tag] objectForKey:@"PartId"];
    
    
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc]init];
    NSString *role = [defaults objectForKey:@"DocumentsAccessRole"];
    
    if ([role isEqualToString:@"Manager"]) {
        
        getDocumnetsPartNumber = [[NSMutableDictionary alloc]init];
        [getDocumnetsPartNumber setObject:getDocumnetsPartNumberStr forKey:@"PartId"];
        [self postRequest:GET_PART_DOCUMENTS];

    }else{
        //            Broese document
        
        NSString *externalIp = [defaults objectForKey:@"ExternalIpAddress"];
        NSLog(@"ExternalIpAddress%@",externalIp);
        if([externalIp isEqual:[NSNull null]] || externalIp.length ==0 ) {
//            [FAUtilities showAlert:@"Unable to load ip address, Please try again..." withTitle:@"Alert"];
//            [self performSelector:@selector(LoadExternalIp:) withObject:nil afterDelay:0.1];
//            return;
            
            loadExternalIpHud = [[MBProgressHUD alloc] initWithView:self.view];
            loadExternalIpHud.mode = MBProgressHUDModeIndeterminate;
            loadExternalIpHud.labelText = @"Loading...";
            [loadExternalIpHud show:YES];
            [self.view addSubview:loadExternalIpHud];

            [self LoadExternalIp:@"PopOverBrowsePart" withSender:sender];


            
        
        }else{
            if ([externalIp isEqualToString:EXTERNAL_IP_ADDRESS] ) {
                loadPartDocumentDict = [[NSMutableDictionary alloc]init];
                [loadPartDocumentDict setObject:@"PART" forKey:@"Type"];
                [loadPartDocumentDict setObject:getDocumnetsPartNumberStr forKey:@"TypeID"];
                
                if (loadExternalIpHud != NULL) {
                    loadExternalIpHud.hidden = YES;
                    [loadExternalIpHud removeFromSuperview];
                }
                
                [self postRequest:CHECK_DOCUMENT_ACCESS];
                
                browseDocsPartID = getDocumnetsPartNumberStr;
                
            }else{
                [FAUtilities showAlert:@"You will be able to access this file, when you are at your designated work place" withTitle:@"Access Denied"];
            }
        }

        
        
    }
    
    

    
    
    
//    getDocumnetsPartNumber = [[NSMutableDictionary alloc]init];
//    [getDocumnetsPartNumber setObject:getDocumnetsPartNumberStr forKey:@"PartId"];
//    [self postRequest:GET_PART_DOCUMENTS];
}



-(void)getDocumentsBtnClicked:(UIButton *)tempBtn{
    
    substitutePartsBtnView.hidden = YES;
    partsSubViewHeadingLabel.text = @"Part Documents";
    
    selectedBomRADocsBtn = tempBtn;
    NSLog(@"selectedBomRADocsBtn %@", selectedBomRADocsBtn);
    // create one request
    
    if (isRADocuments == YES) {
        partNumberLabel.text = getRASummaryPartNumValLabel.text;
    }else{
        partNumberLabel.text = [[getRaRecords objectAtIndex:tempBtn.tag]objectForKey:@"PartNumber"];
    }
    
    partDocumnetsTableView.frame = CGRectMake(partDocumnetsTableView.frame.origin.x, partDocumnetsTableView.frame.origin.y, partDocumnetsTableView.frame.size.width, 400);

    
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){//setting the form list table frame when returing back to the form list view
        partDocumentsSubView.frame = CGRectMake(60+80+50, 150, 628, 540);
    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
        partDocumentsSubView.frame = CGRectMake(60, 220, 628, 540);
    }
    
    partDocumentsSubView.layer.borderWidth = 2;
    partDocumentsSubView.layer.borderColor = [[FAUtilities getUIColorObjectFromHexString:@"#314F9B" alpha:1] CGColor];
    selectedGetRAPartActionBtnTag = selectedBomRADocsBtn.tag;
    
   
    
    [partDocumnetsTableView reloadData];
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    [self.view addSubview:partDocumentsSubView];
    
    getRADetailsTableView.userInteractionEnabled = NO;
    scanBomPartsBtn.userInteractionEnabled = NO;

}

-(void)popOverSubstitutePartBtnClicked:(id)sender{

    [self dismissTableInset];
    [popoverController dismissPopoverAnimated:YES];
    selectedSubstitutePartsBtn = (UIButton*)sender;
    NSLog(@"doc Btn tag %ld", (long)selectedSubstitutePartsBtn.tag);
  
    NSString *getPartNumberStr = [[getRaRecords objectAtIndex:selectedSubstitutePartsBtn.tag] objectForKey:@"PartId"];
   
    getSelectedPartNumber = [[NSMutableDictionary alloc]init];
    [getSelectedPartNumber setObject:getPartNumberStr forKey:@"PartId"];
    [self postRequest:GET_SUBSTITUTE_PARTS];
}


-(void)getSubstitutePartsBtnClicked:(UIButton *)tempBtn{
   
    selectedSubstitutePartDict = [[NSMutableDictionary alloc]init];
    
    substitutePartsBtnView.hidden = NO;
    selectedCell = 0;
    partsSubViewHeadingLabel.text = @"Substitute Parts";
    partNumberLabel.text = [[getRaRecords objectAtIndex:tempBtn.tag]objectForKey:@"PartNumber"];

//    selectedSubstitutePartsBtn = tempBtn;
//    NSLog(@"selectedSubstitutePartsBtn %@", selectedSubstitutePartsBtn);

    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){//setting the form list table frame when returing back to the form list view
        partDocumentsSubView.frame = CGRectMake(60+80+50, 150, 628, 540);
    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
        partDocumentsSubView.frame = CGRectMake(60, 220, 628, 540);
    }
    
    partDocumnetsTableView.frame = CGRectMake(partDocumnetsTableView.frame.origin.x, partDocumnetsTableView.frame.origin.y, partDocumnetsTableView.frame.size.width, 380);
    
    partDocumentsSubView.layer.borderWidth = 2;
    partDocumentsSubView.layer.borderColor = [[FAUtilities getUIColorObjectFromHexString:@"#314F9B" alpha:1] CGColor];
    selectedGetRAPartActionBtnTag = selectedSubstitutePartsBtn.tag;
    
    
    [partDocumnetsTableView reloadData];
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    [self.view addSubview:partDocumentsSubView];
    
    getRADetailsTableView.userInteractionEnabled = NO;
    scanBomPartsBtn.userInteractionEnabled = NO;

    
}

    

-(IBAction)partDocumentSubViewCloseBtnClicked:(id)sender{
    getRADetailsTableView.userInteractionEnabled = YES;
    scanBomPartsBtn.userInteractionEnabled = YES;

    [partDocumentsSubView removeFromSuperview];
    
}

-(void)dismissTableInset{
//    getRADetailsTableView.contentInset = UIEdgeInsetsMake(getRADetailsTableView.contentInset.top,
//                                                          getRADetailsTableView.contentInset.left,
//                                                          getRADetailsTableView.contentInset.bottom-getRADetailsTableView.frame.size.height,
//                                                          getRADetailsTableView.contentInset.right);
}





-(void)checkOutButtonClicked:(id)sender{
    isSubViewClicked = YES;
    
    cancelBtnClicked = NO;
    checkInClicked = NO;
    checkOutClicked = YES;
    docsBtnClicked = NO;

    UIButton *checkOutBtn = (UIButton*)sender;
    
    NSDictionary *orderDict = [[NSDictionary alloc]init];
    
    if (sender == nil) {
        for (int i=0; i<[getRaRecords count]; i++) {
            NSDictionary *tempDict = [getRaRecords objectAtIndex:i];
            NSString *raPart = [tempDict objectForKey:@"PartNumber"];
            
            if ([raPart isEqualToString:selectedRAPart]) {
                orderDict = tempDict;
                subViewBtnTag = i;
                raCheckOutPartFound = YES;

                break;
            }else{
                raCheckOutPartFound = NO;

                continue;
            }
        }
        if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){//setting the form list table frame when returing back to the form list view
            CGRect rectToScroll = CGRectMake(getRAScrollView.frame.origin.x, getRAScrollView.frame.origin.y, getRAScrollView.frame.size.width, getRAScrollView.frame.size.height+300);
            
            [getRAScrollView scrollRectToVisible:rectToScroll animated:YES];
            
        }

    }else{
        raCheckOutPartFound = YES;

        subViewBtnTag = checkOutBtn.tag;
        orderDict = [getRaRecords objectAtIndex:subViewBtnTag];
    }

    
    if (raCheckOutPartFound == YES) {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:subViewBtnTag inSection:0];
        
        NSIndexPath *previousSelectedIndexPath = selectedIndexPath;  // <- save previously selected cell
        previousSelectedIndexPath = selectedIndexPath;  // <- save previously selected cell
        selectedIndexPath = newIndexPath;
        
        if (previousSelectedIndexPath) { // <- reload previously selected cell (if not nil)
            [getRADetailsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:previousSelectedIndexPath]
                                         withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [getRADetailsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedIndexPath]
                                     withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [getRADetailsTableView scrollToRowAtIndexPath:selectedIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        if (sender == nil) {
        }
        
        RepairListCell *cell = (RepairListCell*)[getRADetailsTableView cellForRowAtIndexPath:newIndexPath];
        cell.cellSubView.hidden = NO;
        cell.cellSubView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"checkInOrOut.png"]];
        
        cell.scanBarCodeCheckInOrCheckOutBtn.hidden = YES;

        
        //    NSDictionary *orderDict = [getRaRecords objectAtIndex:newIndexPath.row];
        
        NSString *reqQty        = [orderDict objectForKey:@"RequiredQuantity"];
        NSString *consumedQty   = [orderDict objectForKey:@"UsedQuantity"];
        
        cell.chekInOrCheckOutFieldLabel.text = @"CheckOut Qty";
        
        
        if (reqQty.length == 0 ||reqQty == (NSString*) [NSNull null]) {
            cell.reqQtyValueLabel.text = @"0";
        }else{
            cell.reqQtyValueLabel.text = reqQty;
        }
        
        if (consumedQty.length == 0 ||consumedQty == (NSString*) [NSNull null]) {
            cell.consumedQtyValueLabel.text = @"0";
        }else{
            cell.consumedQtyValueLabel.text = consumedQty;
        }
        
        cell.subViewPartNum.text = [orderDict objectForKey:@"PartNumber"];
        cell.subViewBomNotes.text   =[orderDict objectForKey:@"BomNotes"];
        
        [cell.checkInOrCheckOutBtn setTitle:@"CheckOut" forState:UIControlStateNormal];
        
        [cell.cancelBtn addTarget:self
                           action:@selector(cancleBtnClicked:)
                 forControlEvents:UIControlEventTouchUpInside];
        cell.cancelBtn.tag = subViewBtnTag;
        [cell.checkInOrCheckOutBtn addTarget:self
                                      action:@selector(checkOutSaveBtnClicked:)
                            forControlEvents:UIControlEventTouchUpInside];
        cell.checkInOrCheckOutBtn.tag = subViewBtnTag;

    }

}

-(void)checkOutSaveBtnClicked:(id)sender{
    bomCheckOutReqDict = [[NSMutableDictionary alloc]init];
    [self.view endEditing:YES];

    UIButton *checkOutSaveBtn = (UIButton*)sender;

    NSString *currentCheckOutVal = [bomAddOrRemoveValsDict objectForKey:[NSString stringWithFormat:@"%d", checkOutSaveBtn.tag]];
    
    if (currentCheckOutVal.length == 0) {
        [FAUtilities showAlert:@"Please Enter Quantity" withTitle:@""];
    }else{
        NSDictionary *tempDic = [getRaRecords objectAtIndex:checkOutSaveBtn.tag];
        NSString *inStock = [tempDic objectForKey:@"InStock"];
        NSString *bomID = [tempDic objectForKey:@"BomId"];
        NSString *partNumber = [tempDic objectForKey:@"PartNumber"];
        NSString *partID = [tempDic objectForKey:@"PartId"];

        [bomCheckOutReqDict setObject:bomID forKey:@"BomID"];
        [bomCheckOutReqDict setObject:partNumber forKey:@"PartNumber"]; 
        [bomCheckOutReqDict setObject:partID forKey:@"PartId"];
        [bomCheckOutReqDict setObject:currentCheckOutVal forKey:@"BomQuantity"];
        
        
        if ([currentCheckOutVal intValue] <=0) {
            [FAUtilities showAlert:@"CheckOut quantity must be greated than zero" withTitle:@""];
        }else{
            if ([currentCheckOutVal intValue] >[inStock intValue] || [inStock intValue]<=0) {
                [FAUtilities showAlert:@"CheckOut quantity must be less than or equal to InStock" withTitle:@""];
            }else{
                [self postRequest:RA_PART_CHECKOUT];
                [self cancleBtnClicked:checkOutSaveBtn];
            }
        }
    }
}








- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self scrollToControl:textField];
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    [self scrollToControl:nil];
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [self scrollToControl:nil];
    bomAddOrRemoveValsDict = [[NSMutableDictionary alloc]init];
    CGPoint hitPointRA = [textField convertPoint:CGPointZero toView:getRADetailsTableView];
    NSIndexPath *hitIndexRA = [getRADetailsTableView indexPathForRowAtPoint:hitPointRA];
    
    NSString *textFieldValRA = textField.text;
    [bomAddOrRemoveValsDict setObject:textFieldValRA forKey:[NSString stringWithFormat:@"%d",hitIndexRA.row]];
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return [string isEqualToString:filtered];
}




#pragma mark - ScrollControl functions
- (void) scrollToControl:(UIView*)control {
        int viewPortHeight = getRADetailsTableView.frame.size.height - keyboardHeight;
        
        CGRect rectToScroll = CGRectZero;
        int controlBottomLine = 0;
        
        if (control != nil) {
            rectToScroll = CGRectMake(getRAScrollView.frame.origin.x, getRAScrollView.frame.origin.y, getRAScrollView.frame.size.width, getRAScrollView.frame.size.height+300);
            
            CGPoint hitPoint = [control convertPoint:CGPointZero toView:getRADetailsTableView];
            NSIndexPath *hitIndex = [getRADetailsTableView indexPathForRowAtPoint:hitPoint];
            
            NSIndexPath *tempIndexPath = nil;
            UITableViewCell *tempCell = nil;
            
            tempIndexPath = [NSIndexPath indexPathForRow:hitIndex.row inSection:hitIndex.section];
            tempCell = [getRADetailsTableView cellForRowAtIndexPath:tempIndexPath];
            controlBottomLine = tempCell.frame.origin.y+130;
            
            if (controlBottomLine > (viewPortHeight)) {
                getRADetailsTableView.contentInset=UIEdgeInsetsMake(0,0,300,0);
                [getRADetailsTableView scrollToRowAtIndexPath:hitIndex atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            }
        }
        [getRAScrollView scrollRectToVisible:rectToScroll animated:YES];
}



-(IBAction)scanBomPartsBtnClicked:(id)sender{
    [self.view endEditing:YES];
    readBarCodeButton = (UIButton*)sender;
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
    
    [self.view addSubview:theController.view];
    
}


-(void)cameraCancelBtnClicked:(UIButton*)sender{    
    [barCodeReaderView removeFromSuperview];
}

- (void) readerControllerDidFailToRead: (ZBarReaderController*) reader
                             withRetry: (BOOL) retry{
    NSLog(@"the image picker failing to read");
    
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
    
    id <NSFastEnumeration> syms =[info objectForKey: ZBarReaderControllerResults];
    
    NSString *barcodeDataValue;
    
    for(ZBarSymbol *sym in syms) {
        barcodeDataValue = sym.data;
        NSLog(@"sym.data %@", sym.data);
        break;
    }
    
    
    NSLog(@"getRaRecords %@",getRaRecords);

    BOOL isPartPresent = '\0';
    int currentPartRow = 0;

    for (int i=0; i< [getRaRecords count]; i++) {
        NSDictionary *bomDetailsDict = [getRaRecords objectAtIndex:i];
        NSString *bomPartNumber = [bomDetailsDict objectForKey:@"BarCode"];

        if ([bomPartNumber isEqualToString:barcodeDataValue]) {
            isPartPresent = YES;
            currentPartRow = i;
            break;
        }else{
            isPartPresent = NO;
            continue;
        }
    }
    
    
    if (isPartPresent == YES) {
        
        NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:currentPartRow inSection:0];
        
        [getRADetailsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:tempIndexPath]
                                     withRowAnimation:UITableViewRowAnimationAutomatic];

        
        UIButton *tmepBtn = [[UIButton alloc]init];
        tmepBtn.tag = currentPartRow;
        [self checkInButtonClicked:tmepBtn];
        [self scanCheckInOrCheckOutClicked:tmepBtn];
        
    }else{
//        [self addingBomPartSubViewWithBarCode:barcodeDataValue];
        
//        {"JsonRequest":"{Type:\"GetPART\",Authentication:{UserName:\"demouser\", Password:\"demo123\"},Body:{BARCodeOrPart:\"1160085002008\"}}"}
//
        getPartBarcodeDict = [[NSMutableDictionary alloc]init];
        [getPartBarcodeDict setObject:barcodeDataValue forKey:@"Barcode"];
        
        [self postRequest:GET_PART];
        
        NSLog(@"Part not found");
    }


}


-(void)addingBomPartSubViewWithBarCode:(NSDictionary *)barcodeDict{

    addPartCheckOutQty.text = @"";
    
    NSLog(@"Part not found");

    NSLog(@"Bar code %@",barcodeDict);

    addbarcodePartID = [barcodeDict objectForKey:@"PartId"];
    
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){//setting the form list table frame when returing back to the form list view
        addPartSubView.frame = CGRectMake(60+100, 284, 628, 198);
    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
        addPartSubView.frame = CGRectMake(60, 412, 628 , 198);
    }
    

    NSString *partNumber;
    NSString *partDesc;
    NSString *partInStock;
    NSString *partBarCode;
    
    partNumber =[barcodeDict objectForKey:@"PartNumber"];
    partDesc = [barcodeDict objectForKey:@"Description"];
    partInStock = [barcodeDict objectForKey:@"InStock"];
    partBarCode = [barcodeDict objectForKey:@"Barcode"];
    
    if ([partNumber isEqual:[NSNull null]] || partNumber == nil || [partNumber isEqualToString:@"<null>"] || partNumber.length == 0 ) {
        partNumber = @"";
    }

    
    if ( [partDesc isEqual:[NSNull null]] || partDesc == nil || [partDesc isEqualToString:@"<null>"] || partDesc.length == 0) {
        partDesc = @"";
    }

    
    if (partInStock.length == 0 || [partInStock isEqual:[NSNull null]] || partInStock == nil || [partInStock isEqualToString:@"<null>"] || partInStock.length == 0 ) {
        partInStock = @"";
    }

    
    if ( [partBarCode isEqual:[NSNull null]] || partBarCode == nil || [partBarCode isEqualToString:@"<null>"] || partBarCode.length == 0) {
        partBarCode = @"";
    }

//    addedBOMPartNumLabel.text = partNumber;
    addedBomPartDesc.text = partDesc;
    addedBomPartInStockVal.text = partInStock;

    
    addedBomPartBarcode.text = [NSString stringWithFormat:@"(%@)",partBarCode];
    
    addedBOMPartNumLabel.text = [NSString stringWithFormat:@"%@(%@)",partNumber,partBarCode];
    
    
    addedBomPartDesc.layer.borderWidth = 1;
    addedBomPartDesc.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    
    addPartSubView.layer.borderWidth = 2;
    addPartSubView.layer.borderColor = [[FAUtilities getUIColorObjectFromHexString:@"#314F9B" alpha:1] CGColor];

    getRADetailsTableView.userInteractionEnabled = NO;
    scanBomPartsBtn.userInteractionEnabled = NO;
    raPartBrowseDocsBtn.userInteractionEnabled = NO;
    
    [self.view addSubview:addPartSubView];
}


-(IBAction)testsubview:(id)sender{
   
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]init];
    
    [tempDict setObject:@"Warehouse1" forKey:@"Area"];
    [tempDict setObject:@"0020320401018" forKey:@"Barcode"];
    [tempDict setObject:@"dfdsf" forKey:@"Description"];
    [tempDict setObject:@"" forKey:@"Group"];
    [tempDict setObject:@"10" forKey:@"InStock"];
    [tempDict setObject:@"1-F" forKey:@"Level"];

    [tempDict setObject:@"0" forKey:@"OnOrder"];
    [tempDict setObject:@"6044SPAMP" forKey:@"PartCategory"];
    [tempDict setObject:@"785" forKey:@"PartId"];
//    [tempDict setObject:@"1193" forKey:@"PartId"];
    [tempDict setObject:@"0" forKey:@"PartLocationId"];
    [tempDict setObject:@"A20B-0008-0470" forKey:@"PartNumber"];
  
    [tempDict setObject:@"GRAY" forKey:@"PartType"];
    [tempDict setObject:@"BINK" forKey:@"Shelf"];
    [tempDict setObject:@"" forKey:@"Threshold"];

   
//    A20B-0008-0470,785,10
    
    
    [self addingBomPartSubViewWithBarCode:tempDict];

}

-(IBAction)addParttSubViewCloseBtnClicked:(id)sender{
    [addPartSubView removeFromSuperview];
    getRADetailsTableView.userInteractionEnabled = YES;
    scanBomPartsBtn.userInteractionEnabled = YES;
    raPartBrowseDocsBtn.userInteractionEnabled = YES;

}




-(IBAction)addPartBtnClicked:(id)sender{
    NSLog(@"bar code value %@", barcodeLabel.text);
    NSLog(@"RA number %@",getRANumValLabel.text);
    NSLog(@"addPartCheckOutQty.text %@",addPartCheckOutQty.text);
    NSLog(@"instock %@", addedBomPartInStockVal.text);
    
    int instockVal = [addedBomPartInStockVal.text intValue];
    int checkOutVal = [addPartCheckOutQty.text intValue];
    
//    if(addPartCheckOutQty.text.length == 0){
//        [FAUtilities showAlert:@"Please enter checkout quantity"];
//    }else{
//        if (checkOutVal <=0) {
//            [FAUtilities showAlert:@"CheckOut quantity must be greated than zero"];
//        }else
    
        if (checkOutVal > instockVal) {
            [FAUtilities showAlert:@"CheckOut quantity must be less than or equal to InStock" withTitle:@""];
        }else{
            
            addBomPartDict = [[NSMutableDictionary alloc]init];
            
            [addBomPartDict setObject:getRANumValLabel.text forKey:@"RANumber"];
            [addBomPartDict setObject:addPartCheckOutQty.text forKey:@"AddPartCheckOutQty"];
            [addBomPartDict setObject:addbarcodePartID forKey:@"AddBarCodePartID"];
            
            
            [self.view endEditing:YES];
            [self postRequest:ADD_RA_BOM_PART];
            NSLog(@"post req for add part");
        }
//    }
}



-(void)scanCheckInOrCheckOutClicked:(id)sender{
    cancelBtnClicked = NO;
    checkOutClicked = NO;
    checkInClicked = NO;
    docsBtnClicked = NO;
    
    scanCheckInCheckOutClicked = YES;
    
    
    UIButton *checkInCheckOutBtn = (UIButton*)sender;
    NSDictionary *orderDict = [[NSDictionary alloc]init];
   
    
    raCheckInPartFound = YES;
    
    subViewBtnTag = checkInCheckOutBtn.tag;
    orderDict = [getRaRecords objectAtIndex:subViewBtnTag];

    
    if (raCheckInPartFound == YES) {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:subViewBtnTag inSection:0];
        
        NSIndexPath *previousSelectedIndexPath = selectedIndexPath;  // <- save previously selected cell
        previousSelectedIndexPath = selectedIndexPath;  // <- save previously selected cell
        selectedIndexPath = newIndexPath;
        
        if (previousSelectedIndexPath) { // <- reload previously selected cell (if not nil)
            [getRADetailsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:previousSelectedIndexPath]
                                         withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [getRADetailsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedIndexPath]
                                     withRowAnimation:UITableViewRowAnimationAutomatic];
        
        
        [getRADetailsTableView scrollToRowAtIndexPath:selectedIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        RepairListCell *checkInCell = (RepairListCell*)[getRADetailsTableView cellForRowAtIndexPath:newIndexPath];
        checkInCell.cellSubView.hidden = NO;
        checkInCell.cellSubView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"checkInOrOut.png"]];
        //        NSDictionary *orderDict = [getRaRecords objectAtIndex:newIndexPath.row];
        
        checkInCell.scanBarCodeCheckInOrCheckOutBtn.hidden = NO;
        
        NSString *reqQty        = [orderDict objectForKey:@"RequiredQuantity"];
        NSString *consumedQty   = [orderDict objectForKey:@"UsedQuantity"];
        
        
        checkInCell.chekInOrCheckOutFieldLabel.text = @"Enter Qty";
        
        if (reqQty.length == 0 ||reqQty == (NSString*) [NSNull null]) {
            checkInCell.reqQtyValueLabel.text = @"0";
        }else{
            checkInCell.reqQtyValueLabel.text = reqQty;
        }
        
        if (consumedQty.length == 0 ||consumedQty == (NSString*) [NSNull null]) {
            checkInCell.consumedQtyValueLabel.text = @"0";
        }else{
            checkInCell.consumedQtyValueLabel.text = consumedQty;
        }
        
        
        checkInCell.subViewPartNum.text = [orderDict objectForKey:@"PartNumber"];
        checkInCell.subViewBomNotes.text   =[orderDict objectForKey:@"BomNotes"];
        
        [checkInCell.checkInOrCheckOutBtn setTitle:@"CheckIn" forState:UIControlStateNormal];
        [checkInCell.scanBarCodeCheckInOrCheckOutBtn setTitle:@"CheckOut" forState:UIControlStateNormal];

        
        [checkInCell.cancelBtn addTarget:self
                                  action:@selector(cancleBtnClicked:)
                        forControlEvents:UIControlEventTouchUpInside];
        checkInCell.cancelBtn.tag = subViewBtnTag;
        [checkInCell.checkInOrCheckOutBtn addTarget:self
                                             action:@selector(checkInSaveBtnClicked:)
                                   forControlEvents:UIControlEventTouchUpInside];
        checkInCell.checkInOrCheckOutBtn.tag = subViewBtnTag;
        [checkInCell.scanBarCodeCheckInOrCheckOutBtn addTarget:self
                                             action:@selector(checkOutSaveBtnClicked:)
                                   forControlEvents:UIControlEventTouchUpInside];
        checkInCell.scanBarCodeCheckInOrCheckOutBtn.tag = subViewBtnTag;
    }
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
   
    NSArray *subviews = [self.view subviews];
    for (int i=0; i<[subviews count]; i++) {
        UIView *tempView = (UIView *)[subviews objectAtIndex:i];
        if (tempView.tag == 5000) {
            [self cameraCancelBtnClicked:barCodeCancelButton];
            showCamera = YES;
            break;
        }else{
            showCamera = NO;
            continue;
        }
    }
    
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){//setting the form list table frame when returing back to the form list view
    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
        [getRAScrollView setContentSize:(CGSizeMake(768, 1024))];
    }
    
    [getRADetailsTableView reloadData];
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    [popoverController dismissPopoverAnimated:YES];

    if ([self.presentedViewController isKindOfClass:[ZBarReaderViewController class]]){
        [reader dismissViewControllerAnimated:NO completion:nil];
        id sender = (id)readBarCodeButton;
        [self scanBomPartsBtnClicked:sender];
    }
    
    NSArray *tempArt = [self.view subviews];
    if (showCamera == YES) {
        id sender = (id)readBarCodeButton;
        [self scanBomPartsBtnClicked:sender];
    }
    
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){//setting the form list table frame when returing back to the form list view
        partDocumentsSubView.frame = CGRectMake(60+80+50, 150, 628, 540);
//        addPartSubView.frame = CGRectMake(327, 284, 370, 200);
        addPartSubView.frame = CGRectMake(60+100, 284, 628, 198);
        
    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
        partDocumentsSubView.frame = CGRectMake(60, 220, 628, 540);
//        addPartSubView.frame = CGRectMake(200, 412, 370 , 200);
        addPartSubView.frame = CGRectMake(60, 412, 628 , 198);
    }

    
    
 
    
}

-(void)customPopOverBtn:(UIButton *)popOverBtn{
    popOverBtn.titleLabel.textColor = [UIColor blackColor];
    popOverBtn.backgroundColor = [UIColor grayColor];
    popOverBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    popOverBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
}


-(IBAction)raPartBrowseDocsBtnClicked:(id)sender{
    isRADocuments = YES;

    
//            Broese document
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc]init];
    NSString *role = [defaults objectForKey:@"DocumentsAccessRole"];
    
    if ([role isEqualToString:@"Manager"]) {
        
        getDocumnetsPartNumber = [[NSMutableDictionary alloc]init];
        [getDocumnetsPartNumber setObject:browseRAPartDocumentsPartID forKey:@"PartId"];
        [self postRequest:GET_PART_DOCUMENTS];

        
    }else{
        NSString *externalIp = [defaults objectForKey:@"ExternalIpAddress"];
        
        if([externalIp isEqual:[NSNull null]] || externalIp.length ==0 ) {
//            [FAUtilities showAlert:@"Unable to load ip address, Please try again..." withTitle:@"Alert"];
//            [self performSelector:@selector(LoadExternalIp:) withObject:nil afterDelay:0.1];
//            return;
            
            loadExternalIpHud = [[MBProgressHUD alloc] initWithView:self.view];
            loadExternalIpHud.mode = MBProgressHUDModeIndeterminate;
            loadExternalIpHud.labelText = @"Loading...";
            [loadExternalIpHud show:YES];
            [self.view addSubview:loadExternalIpHud];

            [self LoadExternalIp:@"RaBrowsePart" withSender:sender];
            
            
        }else{
            NSLog(@"ExternalIpAddress%@",externalIp);

            if ([externalIp isEqualToString:EXTERNAL_IP_ADDRESS]) {
                loadPartDocumentDict = [[NSMutableDictionary alloc]init];
                [loadPartDocumentDict setObject:@"PART" forKey:@"Type"];
                [loadPartDocumentDict setObject:raPartID forKey:@"TypeID"];
                
                if (loadExternalIpHud != NULL) {
                    loadExternalIpHud.hidden = YES;
                    [loadExternalIpHud removeFromSuperview];
                }

                [self postRequest:CHECK_DOCUMENT_ACCESS];
                
                browseDocsPartID = browseRAPartDocumentsPartID;
                
            }else{
                [FAUtilities showAlert:@"You will be able to access this file, when you are at your designated work place" withTitle:@"Access Denied"];
            }
        }
            
        
        
    }
}


-(void)LoadExternalIp:(NSString *)method withSender:(id)sender{
    
    NSLog(@"Loading indication for external ip Addrss");
    
    
    NSString *getExternalIpAddress = [self externalIPAddress];
    NSLog(@"getExternalIpAddress %@",getExternalIpAddress);
    
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc]init];
    [defaults setObject:getExternalIpAddress forKey:@"ExternalIpAddress"];
    [defaults synchronize];
    
    
    if ([method isEqualToString:@"RaBrowsePart"]) {
        [self raPartBrowseDocsBtnClicked:sender];
    }else if([method isEqualToString:@"PopOverBrowsePart"]){
        [self popOverDocBtnClicked:sender];
    }
    
    
}




-(IBAction)substitutePartsOkBtnClicked:(id)sender{
    NSLog(@"substitute part ok Btn clicked , selected cell %d", selectedCell);
    

    
    if (selectedSubstitutePartDict.count == 0 || selectedSubstitutePartDict == NULL) {
        [FAUtilities showAlert:@"Please select substitute part" withTitle:@""];
    }else{
        NSLog(@"current selected cell %@", selectedSubstitutePartDict);
        NSString *getPartNumberStr = [[getRaRecords objectAtIndex:selectedSubstitutePartsBtn.tag] objectForKey:@"PartNumber"];
        NSString *getPartIDStr = [[getRaRecords objectAtIndex:selectedSubstitutePartsBtn.tag] objectForKey:@"PartId"];
        NSLog(@"getPartNumberStr %@", getPartNumberStr);
        NSLog(@"getPartIDStr %@", getPartIDStr);
        NSLog(@"ra part id %@", raPartID);
        
        postReplacePartDict = [[NSMutableDictionary alloc]init];
        
        [postReplacePartDict setObject:raPartID forKey:@"RAPartID"];
        [postReplacePartDict setObject:getPartIDStr forKey:@"BomPartID"];
        [postReplacePartDict setObject:[selectedSubstitutePartDict objectForKey:@"PartNumber"] forKey:@"SubstitutePartNumber"];
        [postReplacePartDict setObject:[selectedSubstitutePartDict objectForKey:@"PartId"] forKey:@"SubstitutePartId"];
        [postReplacePartDict setObject:getRANumValLabel.text forKey:@"RANumber"];

        
        [self postRequest:REPLACE_SUBSTITUTE_PART];
        
        
    }
    
}




















- (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}





-(NSString *)externalIPAddress {
    // Check if we have an internet connection then try to get the External IP Address
    
    // Get the external IP Address based on dynsns.org
    NSError *error = nil;
    NSString *theIpHtml = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.dyndns.org/cgi-bin/check_ip.cgi"]
                                                   encoding:NSUTF8StringEncoding
                                                      error:&error];
    if (!error) {
        NSUInteger  an_Integer;
        NSArray *ipItemsArray;
        NSString *externalIP;
        NSScanner *theScanner;
        NSString *text = nil;
        
        theScanner = [NSScanner scannerWithString:theIpHtml];
        
        while ([theScanner isAtEnd] == NO) {
            
            // find start of tag
            [theScanner scanUpToString:@"<" intoString:NULL] ;
            
            // find end of tag
            [theScanner scanUpToString:@">" intoString:&text] ;
            
            // replace the found tag with a space
            //(you can filter multi-spaces out later if you wish)
            theIpHtml = [theIpHtml stringByReplacingOccurrencesOfString:
                         [ NSString stringWithFormat:@"%@>", text]
                                                             withString:@" "] ;
            ipItemsArray = [theIpHtml  componentsSeparatedByString:@" "];
            an_Integer = [ipItemsArray indexOfObject:@"Address:"];
            externalIP =[ipItemsArray objectAtIndex:++an_Integer];
        }
        // Check that you get something back
        if (externalIP == nil || externalIP.length <= 0) {
            // Error, no address found
            return nil;
        }
        // Return External IP
        return externalIP;
    } else {
        // Error, no address found
        return nil;
    }
}










- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
