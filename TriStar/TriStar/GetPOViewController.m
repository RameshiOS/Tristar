//
//  GetPOViewController.m
//  TriStar
//
//  Created by Manulogix on 17/01/14.
//  Copyright (c) 2014 Manulogix. All rights reserved.
//

#import "GetPOViewController.h"
#import "FAUtilities.h"
#import "OrderListCell.h"

@interface GetPOViewController ()

@end

@implementation GetPOViewController
@synthesize poValStr;
@synthesize isPartSelected;
@synthesize selectedPart;


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
    
    
    NSLog(@"poValStr %@", poValStr);
    NSLog(@"selectedPart %@", selectedPart);
    NSLog(@"isPartSelected %c", isPartSelected);
    
    if (selectedPart.length !=0 ) {
        addLineReciptBtnCalled = YES;
    }else{
        addLineReciptBtnCalled = NO;
    }
    
    self.navigationItem.title = @"Purchase Orders Details";

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backClicked:)];
    self.navigationItem.leftBarButtonItem = backButton;

    UIColor *headingColor = [FAUtilities getUIColorObjectFromHexString:@"#314F9B" alpha:1];
    getPODetailsSubView.backgroundColor = headingColor;

    
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){//setting the form list table frame when returing back to the form list view
        [getPOScrollView setContentSize:(CGSizeMake(768, 1024))];
    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
    }

    tableGetPOHeading = [[NSArray alloc]initWithObjects:@"Line#",@"Part#",@"Order Qty",@"Recv Qty",@"Price($)",@"Total($)",@"Status", nil];
    lineReceiptDetailsArray = [[NSArray alloc]initWithObjects:@"Line#",@"Recv Qty",@"Recv Date",@"Recv By",@"Vendor Invoice",@"Comments", nil];

    if (![poValStr isEqual:[NSNull null]]) {
        [self postRequest:GET_PO_TYPE];
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


-(void)postRequest:(NSString *)reqType{
    NSString *postDataInString;
    if ([reqType isEqualToString:GET_PO_TYPE]) {
        NSMutableDictionary *test = [[NSMutableDictionary alloc]init];
        [test setObject:poValStr forKey:@"getPONumberValue"];
        NSString *reqValStr = [self jsonFormat:GET_PO_TYPE withDictionary:test];
        postDataInString = [NSString stringWithFormat: @"{\"JsonRequest\":\"%@\"}",reqValStr];
    }else if([reqType isEqualToString:GET_PO_RECEIPT]){
        NSLog(@"lineOrderDetailsDict %@", lineOrderDetailsDict);
        
        if (lineOrderDetailsDict != NULL) {
            NSString *reqValStr = [self jsonFormat:GET_PO_RECEIPT withDictionary:lineOrderDetailsDict];
            postDataInString = [NSString stringWithFormat: @"{\"JsonRequest\":\"%@\"}",reqValStr];
        }
        
    }else if([reqType isEqualToString:PO_RECEIPT_ENTRY]){
        NSLog(@"lineOrderDetailsDict %@", lineOrderDetailsDict);
        
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]init];
        [tempDict setObject:[lineOrderDetailsDict objectForKey:@"LineID"] forKey:@"LineID"];
        [tempDict setObject:[lineOrderDetailsDict objectForKey:@"LineNo"] forKey:@"LineNo"];
        [tempDict setObject:lineReceiptVendorInvoice.text forKey:@"VendorInvoice"];
        
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *defautlsDict = [standardUserDefaults objectForKey:@"UserDetails"];
        [tempDict setObject:[defautlsDict objectForKey:@"ID"] forKey:@"RecvBy"];
        [tempDict setObject:lineReceiptRecvDate.text forKey:@"RecvDate"];
        [tempDict setObject:lineReceiptRecvQty.text forKey:@"RecvQty"];
        [tempDict setObject:lineReceiptCommentsTextView.text forKey:@"Comments"];
        
        
        if (isEditing == YES) {
            [tempDict setObject:@"UPDATE" forKey:@"Flag"];
            [tempDict setObject:[lineReceiptsEditingDict objectForKey:@"LineNo"] forKey:@"ReceiptLineId"];
            isEditing = NO;
        }else{
            [tempDict setObject:@"INSERT" forKey:@"Flag"];
            [tempDict setObject:@"0" forKey:@"ReceiptLineId"];
        }
        
        
        
        NSString *reqValStr = [self jsonFormat:PO_RECEIPT_ENTRY withDictionary:tempDict];
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
    
    if ([type isEqualToString:GET_PO_TYPE]){
        dataStr = [NSString stringWithFormat:@"Body:{PONumber:\\\"%@\\\"}}",[formatDict valueForKey:@"getPONumberValue"]];
    }else if ([type isEqualToString:GET_PO_RECEIPT]){
        dataStr = [NSString stringWithFormat:@"Body:{LineID:\\\"%@\\\",LineNo:\\\"%@\\\"}}",[formatDict valueForKey:@"LineID"],[formatDict valueForKey:@"LineNo"]];
    }else if ([type isEqualToString:PO_RECEIPT_ENTRY]){
        dataStr = [NSString stringWithFormat:@"Body:{LineID:\\\"%@\\\",LineNo:\\\"%@\\\",VendorInvoice:\\\"%@\\\",RecvBy:\\\"%@\\\",RecvDate:\\\"%@\\\",RecvQty:\\\"%@\\\",Comments:\\\"%@\\\",Flag:\\\"%@\\\",ReceiptLineId:\\\"%@\\\"}}",[formatDict valueForKey:@"LineID"],[formatDict valueForKey:@"LineNo"],[formatDict valueForKey:@"VendorInvoice"],[formatDict valueForKey:@"RecvBy"],[formatDict valueForKey:@"RecvDate"],[formatDict valueForKey:@"RecvQty"],[formatDict valueForKey:@"Comments"],[formatDict valueForKey:@"Flag"],[formatDict valueForKey:@"ReceiptLineId"]];
    }
    
    NSString *finalReq = [NSString stringWithFormat:@"%@,%@", bodyStr,dataStr];
    return finalReq;
    
}


-(void)getResponse:(NSDictionary *)resp type:(NSString *)respType{
    
    if ([respType isEqualToString:GET_PO_TYPE]) {
        NSDictionary *getPOStatusDict = [resp valueForKey:@"Status"];
        NSDictionary *getPODataDict = [resp valueForKey:@"Data"];
        
        NSLog(@"getPODataDict %@", getPODataDict);
        
        NSString *statusVal = [getPOStatusDict objectForKey:@"STATUS"];
        NSString *statusDesc = [getPOStatusDict objectForKey:@"DESCRIPTION"];
        NSLog(@"status %@ - %@", statusVal,statusDesc);
        
        if ([statusVal isEqualToString:@"0"]) {
            [FAUtilities showAlert:statusDesc withTitle:@""];
            getPoOrderRecords = [[NSArray alloc]init];
            
            
            // po details
            
            getPODetailsHeadingLabel.hidden = YES;
            getPODetailsSubView.hidden = YES;
            
            // vendor details
            
            getPOVendorDetailsHeadingLabel.hidden = YES;
            getPOVendorDetailsSubView.hidden = YES;
            
            //summary details
            
            getPOSummaryDetailsHeadingLabel.hidden = YES;
            getPOSummaryDetailsSubView.hidden = YES;
            
            // order details
            getPOOrderDetailsHeadingLabel.hidden = YES;
            getPOOrderDetailsTableView.hidden = YES;
            
            [getPOOrderDetailsTableView reloadData];

            
            
        }else{
            getPODetailsHeadingLabel.hidden = NO;
            getPOVendorDetailsHeadingLabel.hidden = NO;
            getPOSummaryDetailsHeadingLabel.hidden = NO;
            
            getPODetailsSubView.hidden = NO;
            getPOSummaryDetailsSubView.hidden = NO;
            getPOVendorDetailsSubView.hidden = NO;
            
//            getPODetailsSubView.backgroundColor = [UIColor clearColor];
            getPOSummaryDetailsSubView.backgroundColor = [UIColor clearColor];
            getPOVendorDetailsSubView.backgroundColor = [UIColor clearColor];

//            getPODetailsSubView.layer.borderWidth = 1;
//            getPODetailsSubView.layer.borderColor = [[FAUtilities getUIColorObjectFromHexString:@"314F9B" alpha:1] CGColor];
            
            getPOVendorDetailsSubView.layer.borderWidth =1;
            getPOVendorDetailsSubView.layer.borderColor = [[FAUtilities getUIColorObjectFromHexString:@"#314F9B" alpha:1] CGColor];
            
            getPOSummaryDetailsSubView.layer.borderWidth =1;
            getPOSummaryDetailsSubView.layer.borderColor = [[FAUtilities getUIColorObjectFromHexString:@"#314F9B" alpha:1] CGColor];

            
            NSLog(@"getPOStatusDict , getPODataDict %@ %@", getPOStatusDict, getPODataDict);
            NSMutableDictionary *getPOObjPOMasterDetails = [getPODataDict objectForKey:@"objPOMaster"];
            NSLog(@"getPOObjPOMasterDetails %@", getPOObjPOMasterDetails);

            
            getPoOrderRecords = [getPODataDict objectForKey:@"lstPOLine"];
            
            
            
//            if (getPOObjPOMasterDetails != [NSNull null]) {
                if ([getPOObjPOMasterDetails count] !=0) {
                    NSString *getPONumber       = [getPOObjPOMasterDetails objectForKey:@"PONo"];
                    NSString *getPOStatus       = [getPOObjPOMasterDetails objectForKey:@"Status"];
                    NSString *getPOShortName    = [getPOObjPOMasterDetails objectForKey:@"ShortName"];
                    NSString *getPOName         = [getPOObjPOMasterDetails objectForKey:@"Name"];
                    NSString *getPOAddr         = [getPOObjPOMasterDetails objectForKey:@"Address"];
                    NSString *getPOContact      = [getPOObjPOMasterDetails objectForKey:@"Contact"];
                    NSString *getPOPhone        = [getPOObjPOMasterDetails objectForKey:@"Phone"];
                    NSString *getPOSubTotal     = [getPOObjPOMasterDetails objectForKey:@"SubTotal"];
                    NSString *getPOShipping     = [getPOObjPOMasterDetails objectForKey:@"Shipping"];
                    NSString *getPOTax          = [getPOObjPOMasterDetails objectForKey:@"Tax"];
                    NSString *getPOTotal        = [getPOObjPOMasterDetails objectForKey:@"Total"];
                    
                    
                    if (![getPONumber isEqual:[NSNull null]]) {
                        getPONumValLabel.text = getPONumber;
                    }
                    
                    if (![getPOStatus isEqual:[NSNull null]]) {
                        getPOStatusValLabel.text = getPOStatus;
                    }
                    
                    if (![getPOShortName isEqual:[NSNull null]]) {
                        getPOShortNameValLabel.text = getPOShortName;
                    }
                    if (![getPOName isEqual:[NSNull null]]) {
                        
                        if (getPOName.length >= 52) {
                            getPONameValLabel.lineBreakMode = UILineBreakModeWordWrap;
                            getPONameValLabel.numberOfLines=0;
                        }
                        
                        getPONameValLabel.text = getPOName;
                    }
                    if (![getPOAddr isEqual:[NSNull null]]) {
                        if (getPOAddr.length >= 52) {
                            getPOAddrValLabel.lineBreakMode = UILineBreakModeWordWrap;
                            getPOAddrValLabel.numberOfLines=0;
                        }
                        getPOAddrValLabel.text = getPOAddr;
                    }
                    
                    if (![getPOContact isEqual:[NSNull null]]) {
                        getPOContactValLabel.text = getPOContact;
                    }
                    if (![getPOPhone isEqual:[NSNull null]]) {
                        getPOPhoneValLabel.text = getPOPhone;
                    }
                    
                    if (![getPOSubTotal isEqual:[NSNull null]]) {
                        getPOSubTotalValLabel.text = getPOSubTotal;
                    }
                    if (![getPOShipping isEqual:[NSNull null]]) {
                        getPOShippingValLabel.text = getPOShipping;
                    }
                    if (![getPOTax isEqual:[NSNull null]]) {
                        getPOTaxValLabel.text = getPOTax;
                    }
                    if (![getPOTotal isEqual:[NSNull null]]) {
                        getPOTotalValLabel.text = getPOTotal;
                    }
                }
//            }

        }
        
        
        
//        for (int i = 0; i<[getPoOrderRecords count]; i++) {
//            savePoDict = [[NSMutableDictionary alloc]init];
//            NSString *savePoLineNumber = [[getPoOrderRecords objectAtIndex:i] valueForKey:@"LineNo"];
//            NSString *savePoLineId = [[getPoOrderRecords objectAtIndex:i] valueForKey:@"LineID"];
//            
//            NSString *savePoPartNumber = [[getPoOrderRecords objectAtIndex:i] valueForKey:@"PartNo"];
//            NSString *savePoRecivedQty = [[getPoOrderRecords objectAtIndex:i] valueForKey:@"RecvQty"];
//            NSString *savePoStatus = [[getPoOrderRecords objectAtIndex:i] valueForKey:@"Status"];
//            
//            [savePoDictionary setValue:savePoLineNumber forKey:@"LineNo"];
//            [savePoDictionary setValue:savePoLineId forKey:@"LineID"];
//            [savePoDictionary setValue:savePoPartNumber forKey:@"PartNo"];
//            [savePoDictionary setValue:savePoRecivedQty forKey:@"RecvQty"];
//            [savePoDictionary setValue:savePoStatus forKey:@"Status"];
//            [savePoDict addEntriesFromDictionary:savePoDictionary];
//            [savessPoDetailsDictArray addObject:savePoDict];
//        }
        if ([getPoOrderRecords count]!=0) {
            
            getPOOrderDetailsHeadingLabel.hidden = NO;
            getPOOrderDetailsTableView.hidden = NO;
            getPOOrderDetailsTableView.backgroundColor = [UIColor clearColor];
            getPOOrderDetailsTableView.layer.borderWidth =1;
            getPOOrderDetailsTableView.layer.borderColor = [[FAUtilities getUIColorObjectFromHexString:@"#314F9B" alpha:1] CGColor];
            [getPOOrderDetailsTableView reloadData];
            
            NSLog(@"getPoOrderRecords %@", getPoOrderRecords);
            
            NSString *updatedStatus;
            
            for (int i=0 ; i<[getPoOrderRecords count]; i++) {
                NSDictionary *tempDict = [getPoOrderRecords objectAtIndex:i];
                
                NSString *tempPartNum = partNumberValInLineDetailsSubView.text;
                NSString *partNumFromDict = [tempDict objectForKey:@"PartNo"];
                
                if ([tempPartNum isEqualToString:partNumFromDict]) {
                    updatedStatus = [tempDict objectForKey:@"Status"];
                }                
            }
            if (![updatedStatus isEqual:[NSNull null]]) {
                statusValInLineDetailsSubView.text = updatedStatus;
            }
            
            if ([updatedStatus isEqualToString:@"Completed"]) {
                //        [lineAddReceiptSubviewAddBtn setEnabled:NO]; // To toggle enabled / disabled
                lineAddReceiptSubviewAddBtn.hidden = YES;
                [lineItemReceiptsTableView reloadData];
            
            }else{
                lineAddReceiptSubviewAddBtn.hidden = NO;
            }

            if (selectedPart.length !=0) {
                [self getPOActionBtnClicked:nil];
            }
        }
    }else if ([respType isEqualToString:GET_PO_RECEIPT] || [respType isEqualToString:PO_RECEIPT_ENTRY]){
        NSLog(@"Resp %@", resp);
        
        NSDictionary *getPOReceiptStatusDict = [resp valueForKey:@"Status"];
        //        NSDictionary *getPOReceiptDataDict = [resp valueForKey:@"Data"];
        
        NSString *statusVal = [getPOReceiptStatusDict objectForKey:@"STATUS"];
        NSString *statusDesc = [getPOReceiptStatusDict objectForKey:@"DESCRIPTION"];
        NSLog(@"status %@ - %@", statusVal,statusDesc);
        
        if ([statusVal isEqualToString:@"0"]) {
            if ([statusDesc isEqualToString:@"PURCHASE ORDER RECEIPT UPDATED SUCCESSFULLY"]) {
                [self lineAddReceiptSubviewAddCancelBtnClicked:nil];
            }
            [FAUtilities showAlert:statusDesc withTitle:@""];

        }else{
            
            getPoReceiptTableValues = [resp valueForKey:@"Data"];
            NSLog(@"findPODataDict %@", getPoReceiptTableValues);
            [lineItemReceiptsTableView reloadData];
            
            if ([respType isEqualToString:PO_RECEIPT_ENTRY]) {
                [self lineAddReceiptSubviewAddCancelBtnClicked:nil];
            }
            
        }
    }

}

#pragma mark -
#pragma mark TableView Datasource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView==getPOOrderDetailsTableView){
        return [getPoOrderRecords count];
    }else{
        recvQty = 0;
        return [getPoReceiptTableValues count];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    
    if (tableView == getPOOrderDetailsTableView) {
        float cellWidth = getPOOrderDetailsTableView.frame.size.width;
        NSLog(@"Get PO Cell width %f", cellWidth);
        CGFloat width = 0.0f;
        
        CGFloat originX = 0.0f;
        UIView *headerView = [[UIView alloc] init];
        
        headerView.frame = CGRectMake(0, 0, getPOOrderDetailsTableView.frame.size.width, 80);
        
        headerView.backgroundColor = [UIColor clearColor];
        for (int i=0; i<[tableGetPOHeading count]; i++) {
            headingLabelView = [[UILabel alloc]init];
            switch (i) {
                    
                case 0:
                {
                    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                        width = 58;
                        
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                        
                    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                        width = 44;
                        
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                        
                    }
                    
                    break;
                }
                    
//                case 1:
//                {
//                    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
//                        width = 58;
//                        
//                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
//                        
//                    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
//                        width = 44;
//                        
//                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
//                        
//                    }
//                    break;
//                }
                case 1:
                {
                    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                        width = 336;
                        
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                        
                    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                        width = 252;
                        
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                        
                    }
                    break;
                }
                case 2:
                {
                    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                        width = 99;
                        
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                        
                    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                        width = 74;
                        
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                        
                    }
                    break;
                }
                case 3:
                {
                    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                        width = 99;
                        
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                        
                    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                        width =74;
                        
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
                        width = 104;
                        
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                        
                    }
                    break;
                }
                case 5:
                {
                    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                        width = 140;
                        
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                        
                    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                        width = 105;
                        
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                        
                    }
                    break;
                }
                case 6:
                {
                    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                        width = 124;
                        
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                        
                    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                        width = 94;
                        
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                        
                    }
                    break;
                }
                    
                    
                default:
                    break;
            }
            
            headingLabelView.text = [tableGetPOHeading objectAtIndex:i];
            headingLabelView.backgroundColor = [UIColor  grayColor];
            headingLabelView.font=[UIFont fontWithName:@"Arial-BoldMT" size:17];
            headingLabelView.lineBreakMode = NSLineBreakByWordWrapping;
            headingLabelView.numberOfLines=2;
            headingLabelView.adjustsFontSizeToFitWidth = YES;
            headingLabelView.textAlignment = NSTextAlignmentCenter;
            [headerView addSubview:headingLabelView];
            
            if (i==0) {
                if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                    originX += width;
                    
                }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                    originX += width;
                    
                }
            }else{
                if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                    originX += width+2;
                    
                }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                    originX += width+1;
                    
                }
            }
            
            headingLabelView.tag = 100+i;
        }
        return headerView;

    }else {
                
        CGFloat width = 0.0f;
        CGFloat originX = 20.0f;
        UIView *headerView = [[UIView alloc] init];
        
        headerView.frame = CGRectMake(0, 0, lineItemReceiptsTableView.frame.size.width, 80);

        headerView.backgroundColor = [UIColor grayColor];
        for (int i=0; i<[lineReceiptDetailsArray count]; i++) {
            headingLabelView = [[UILabel alloc]init];
            
            switch (i) {
                case 0:
                {
                    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                        width = 54;
                        
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                        
                    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                        width = 46;
                        
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                        
                    }
                    break;
                }
                case 1:
                {
                    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                        width = 54;
                        
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                        
                    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                        width = 46;
                        
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                        
                    }
                    break;
                }
                case 2:
                {
                    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                        width = 128;
                        
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                        
                    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                        width = 109;
                        
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                        
                    }
                    break;
                }
                case 3:
                {
                    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                        width = 130;
                        
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                        
                    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                        width =111;
                        
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                        
                    }
                    break;
                }
                case 4:
                {
                    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                        width = 130;
                        
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                        
                    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                        width = 111;
                        
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                        
                    }
                    break;
                }
                case 5:
                {
                    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                        width = 130;
                        
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                        
                    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                        width = 111;
                        
                        headingLabelView.frame=CGRectMake(originX, 0.0f, width, 42.0f);
                        
                    }
                    break;
                }
                default:
                    break;
            }
            
            //            headingLabelView = [[UILabel alloc]initWithFrame:CGRectMake(originX, originY, width, height)];
            headingLabelView.text = [lineReceiptDetailsArray objectAtIndex:i];
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
        
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == getPOOrderDetailsTableView) {
        NSDictionary *orderDict = [getPoOrderRecords objectAtIndex:indexPath.row];
        static NSString *TableCellIdentifier = @"OrderListCell";
        OrderListCell *cell =(OrderListCell *) [getPOOrderDetailsTableView dequeueReusableCellWithIdentifier:TableCellIdentifier];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"OrderListCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSString *getPoLineNumStr   = [orderDict valueForKey:@"LineNo"];
        NSString *getPoPartNumStr   = [orderDict valueForKey:@"PartNo"];
        NSString *getPoOrdQtyStr    = [orderDict valueForKey:@"OrderQty"];
        NSString *getPoRecQtyStr    = [orderDict valueForKey:@"RecvQty"];
        NSString *getPoStatusStr    = [orderDict valueForKey:@"Status"];
        
        
        
        
        NSString *getPoPriceValStr  = [NSString stringWithFormat:@"%@   ",[orderDict valueForKey:@"Price"]];
        NSString *getPoTotalStr     = [NSString stringWithFormat:@"%@   ",[orderDict valueForKey:@"Total"]];
        
        
        
        if (![getPoLineNumStr isEqual:[NSNull null]]) {
            cell.lineNumber.text = getPoLineNumStr;
        }
        
        if (![getPoPartNumStr isEqual:[NSNull null]]) {
            cell.partNumber.text = getPoPartNumStr;
        }
        
        if (![getPoOrdQtyStr isEqual:[NSNull null]]) {
            cell.orderedQty.text = getPoOrdQtyStr;
        }
        
        if (![getPoRecQtyStr isEqual:[NSNull null]]) {
            cell.recivedQty.text = getPoRecQtyStr;
        }
        
        if (![getPoStatusStr isEqual:[NSNull null]]) {
            cell.statusValue.text = getPoStatusStr;
        }
        
        if (![getPoPriceValStr isEqual:[NSNull null]]) {
            cell.priceValue.text = getPoPriceValStr;
        }
        
        if (![getPoTotalStr isEqual:[NSNull null]]) {
            cell.totalValue.text = getPoTotalStr;
        }
        
        
        
        //        [cell.statusBtn setTitle:[totalPoStatusValues objectForKey:key] forState:UIControlStateNormal];
        //        cell.statusBtn.tag=indexPath.row;
        //        [cell.statusBtn addTarget:self action:@selector(statusGetPoBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.getPOActionBtn.tag = indexPath.row;
//        [cell.getPOActionBtn addTarget:self action:@selector(getPOActionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
//        if (getPOOrderDetailsTableView.isEditing) {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
//        }else{
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        }

        return cell;

    }else{
        NSDictionary *orderLineVal = [getPoReceiptTableValues objectAtIndex:indexPath.row];
        static NSString *TableCellIdentifier = @"POLineReceiptListCell";
        POLineReceiptListCell *cell =(POLineReceiptListCell *) [lineItemReceiptsTableView dequeueReusableCellWithIdentifier:TableCellIdentifier];
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"POLineReceiptListCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSString *lineRecQtyRecvStr         = [orderLineVal objectForKey:@"RecvQty"];
        NSString *tempDate                  = [orderLineVal objectForKey:@"RecvDate"];
        
        NSRange range = [tempDate rangeOfString:@" "];
        NSString *lineRecQtyRecvDateStr = [tempDate substringToIndex:range.location];
        
        //        NSString *lineRecQtyRecvDateStr     = [orderLineVal objectForKey:@"RecvDate"];
        
        NSString *lineRecQtyRecvBy          = [orderLineVal objectForKey:@"RecvBy"];
        NSString *lineRecQtyRecvVendor      = [orderLineVal objectForKey:@"VendorInvoice"];
        NSString *lineRecQtyRecvComments    = [orderLineVal objectForKey:@"Comments"];
        NSString *lineNumVal                = [orderLineVal objectForKey:@"LineNo"];
        NSString *lineRecRecvBy                = [orderLineVal objectForKey:@"User"];

        recvQty = recvQty + [lineRecQtyRecvStr intValue];
        if (![lineNumVal isEqual:[NSNull null]]) {
            cell.lineNumber.text = lineNumVal;
        }
        
        if (![lineRecQtyRecvStr isEqual:[NSNull null]]) {
            cell.lineReceiptQtyReceived.text = lineRecQtyRecvStr;
        }
        
        if (![lineRecQtyRecvDateStr isEqual:[NSNull null]]) {
            cell.lineReceiptQtyReceivedDate.text = lineRecQtyRecvDateStr;
        }
        
        if (![lineRecQtyRecvBy isEqual:[NSNull null]]) {
            cell.lineReceiptQtyReceivedBy.text = lineRecQtyRecvBy;
        }
        
        if (![lineRecQtyRecvVendor isEqual:[NSNull null]]) {
            cell.lineReceiptQtyReceivedvendor.text = lineRecQtyRecvVendor;
        }
        if (![lineRecQtyRecvComments isEqual:[NSNull null]]) {
            cell.lineReceiptQtyReceivedComments.text = lineRecQtyRecvComments;
        }
        
        if (![lineRecRecvBy isEqual:[NSNull null]]) {
            cell.lineReceiptQtyReceivedBy.text = lineRecRecvBy;
        }
        
        
        
        
        cell.lineAddReceiptSubviewEditBtn.tag = indexPath.row;
        [cell.lineAddReceiptSubviewEditBtn addTarget:self action:@selector(lineAddReceiptSubviewEditBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        
        lineOrderDetailsDict = [getPoOrderRecords objectAtIndex:selectedGetPOActionBtnTag];
        
        
        NSString *tempNumber = [lineOrderDetailsDict objectForKey:@"PartNo"];
        
        
        if (![tempNumber isEqual:[NSNull null]]) {
            partNumberValInLineDetailsSubView.text = tempNumber;
        }
        
        
        //        partNumberValInLineDetailsSubView.text =tempNumber;
        
        NSString *statusVal = [lineOrderDetailsDict objectForKey:@"Status"];
        
        if ([statusVal isEqualToString:@"Completed"]) {
            cell.lineAddReceiptSubviewEditBtn.hidden = YES;
            [cell.lineAddReceiptSubviewEditBtn setEnabled:NO]; // To toggle enabled / disabled
        }else{
            cell.lineAddReceiptSubviewEditBtn.hidden = NO;
            [cell.lineAddReceiptSubviewEditBtn setEnabled:YES]; // To toggle enabled / disabled
        }
        return cell;
    }
}


-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return  42.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == getPOOrderDetailsTableView) {
        UIButton *tempBtn = [[UIButton alloc]init];
        tempBtn.tag = indexPath.row;
        [self getPOActionBtnClicked:tempBtn];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}


-(void)getPOActionBtnClicked:(id)sender{
    selectedGetPOActionBtn = (UIButton*)sender;
    NSLog(@"selectedGetPOActionBtn %@", selectedGetPOActionBtn);
    // create one request
    
    
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){//setting the form list table frame when returing back to the form list view
        lineItemReceiptSubView.frame = CGRectMake(60+80, 150, 628+100, 540);
    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
        lineItemReceiptSubView.frame = CGRectMake(60, 220, 628, 540);
    }
    
    lineItemReceiptSubView.layer.borderWidth = 2;
    lineItemReceiptSubView.layer.borderColor = [[FAUtilities getUIColorObjectFromHexString:@"#314F9B" alpha:1] CGColor];
    
    //    lineOrderDetailsDict = [savePoDetailsDictArray objectAtIndex:selectedGetPOActionBtn.tag];
    
    selectedGetPOActionBtnTag = selectedGetPOActionBtn.tag;
    
    if (sender == nil) {
        NSLog(@"selected part %@", selectedPart);
        NSLog(@"getPoOrderRecords %@", getPoOrderRecords);
        
        for (int i=0; i<[getPoOrderRecords count]; i++) {
            NSDictionary *tempDict = [getPoOrderRecords objectAtIndex:i];
            NSString *tempPartNo = [tempDict objectForKey:@"PartNo"];
            
            if ([tempPartNo isEqualToString:selectedPart]) {
                selectedGetPOActionBtnTag = i;
                lineOrderDetailsDict = [tempDict mutableCopy];
                break;
            }else{
                continue;
            }
        }
    }else{
        selectedPart = @"";
        lineOrderDetailsDict = [getPoOrderRecords objectAtIndex:selectedGetPOActionBtnTag];

    }
    
    
    if (lineOrderDetailsDict !=nil) {
        NSString *tempNumber    = [lineOrderDetailsDict objectForKey:@"PartNo"];
        NSString *statusVal     = [lineOrderDetailsDict objectForKey:@"Status"];
        NSString *orderQtyVal   = [lineOrderDetailsDict objectForKey:@"OrderQty"];
        NSString *recvQtyVal    = [lineOrderDetailsDict objectForKey:@"RecvQty"];
        
        NSString *partArea      = [lineOrderDetailsDict objectForKey:@"Area"];
        NSString *partShelf     = [lineOrderDetailsDict objectForKey:@"Shelf"];
        NSString *partLevel     = [lineOrderDetailsDict objectForKey:@"Level"];
        
        NSString *location;
        
        if (partArea.length != 0  && partShelf.length != 0 && partLevel.length != 0) {
            location = [NSString stringWithFormat:@"%@/%@/%@",partArea,partShelf,partLevel];
        }
        
        
        partLocationVal.text = location;
        
        
        //    NSInteger orderQty = [orderQtyVal integerValue];
        //    NSInteger recvQty = [recvQtyVal integerValue];
        
        orderQty = [orderQtyVal integerValue];
        recvQty = [recvQtyVal integerValue];
        
        remainingPartQuantity = orderQty-recvQty;
        NSLog(@"remainingPartQuantity %d", remainingPartQuantity);
        
        if (![tempNumber isEqual:[NSNull null]]) {
            partNumberValInLineDetailsSubView.text = tempNumber;
        }
        
        if (![statusVal isEqual:[NSNull null]]) {
            statusValInLineDetailsSubView.text = statusVal;
        }
        
        //    partNumberValInLineDetailsSubView.text =tempNumber;
        //    statusValInLineDetailsSubView.text = statusVal;
        
        
        
        if ([statusVal isEqualToString:@"Completed"]) {
            //        [lineAddReceiptSubviewAddBtn setEnabled:NO]; // To toggle enabled / disabled
            lineAddReceiptSubviewAddBtn.hidden = YES;
        }else{
            
            lineAddReceiptSubviewAddBtn.hidden = NO;
            if (sender == nil) {
                if (addLineReciptBtnCalled == YES) {
                    [self lineAddReceiptSubviewAddBtnClicked:nil];
                    addLineReciptBtnCalled = NO;
                }
                
            }
        }
        
        
        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        
        //    testScroll.frame = CGRectMake(60, 150, testScroll.frame.size.width, testScroll.frame.size.height);
        [self.view addSubview:lineItemReceiptSubView];
        
        if (lineOrderDetailsDict !=NULL) {
            [self postRequest:GET_PO_RECEIPT];
            addOrUpdateEntryBtn.userInteractionEnabled = YES;
        }else{
            addOrUpdateEntryBtn.userInteractionEnabled = NO;
        }
        
        getPOOrderDetailsTableView.userInteractionEnabled = NO;

    }
    
    
}



-(IBAction)lineReceiptSubViewCloseBtnClicked:(id)sender{
    getPOOrderDetailsTableView.userInteractionEnabled = YES;
    addOrUpdateEntryBtn.titleLabel.text = @"";
    
    [addOrUpdateEntryBtn setTitle:@"" forState:UIControlStateNormal];
    
    [lineItemReceiptSubView removeFromSuperview];
    animationStarted = NO;
    
    if (lineDetailsAddBtnClicked == YES) {
        [lineItemsTableSubView setFrame:CGRectMake(lineItemsTableSubView.frame.origin.x,lineItemsTableSubView.frame.origin.y-164,lineItemsTableSubView.frame.size.width,lineItemsTableSubView.frame.size.height+164)];
        //        [lineAddReceiptSubviewAddBtn setEnabled:YES]; // To toggle enabled / disabled
        
        lineAddReceiptSubviewAddBtn.hidden = NO;
        lineDetailsAddBtnClicked = NO;
    }
    
}



-(IBAction)lineAddReceiptSubviewAddBtnClicked:(id)sender{
    NSLog(@"Add btn Clicked");
    
    
    NSDate* currentDate = [NSDate date];
    
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
    [formatter1 setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *dateString = [formatter1 stringFromDate:currentDate];
    
    NSLog(@"dateString %@", dateString);
    
    NSRange range = [dateString rangeOfString:@" "];
    
    remainingPartQuantity = orderQty-recvQty;
    
    if ( addOrUpdateEntryBtn.titleLabel.text.length  == 0  ) {
        [addOrUpdateEntryBtn setTitle:@"Add Entry" forState:UIControlStateNormal];
        lineReceiptRecvQty.text = [NSString stringWithFormat:@"%d", remainingPartQuantity];
        lineReceiptRecvDate.text = [dateString substringToIndex:range.location];
        
    }
    
    
    if (animationStarted == YES) {
        
    }else{
        addOrUpdateEntryBtn.userInteractionEnabled = NO;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1.0];
        [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:[self view]      cache:YES];
        
        [lineItemsTableSubView setFrame:CGRectMake(lineItemsTableSubView.frame.origin.x,lineItemsTableSubView.frame.origin.y+164,lineItemsTableSubView.frame.size.width,lineItemsTableSubView.frame.size.height-164)];
        [UIView commitAnimations];
        animationStarted = YES;
        
    }
    
    //    [lineAddReceiptSubviewAddBtn setEnabled:NO]; // To toggle enabled / disabled
    addOrUpdateEntryBtn.userInteractionEnabled = YES;
    lineAddReceiptSubviewAddBtn.hidden = YES;
    lineDetailsAddBtnClicked = YES;
}



-(IBAction)lineAddReceiptSubviewAddSaveBtnClicked:(id)sender{
    
    [self.view endEditing:YES];
    
    if ([lineReceiptRecvQty.text isEqualToString:@""]) {
        [FAUtilities showAlert:@"Please Enter Line Reciept Recieved Quantity" withTitle:@""];
    }else if ([lineReceiptRecvDate.text isEqualToString:@""]){
        [FAUtilities showAlert:@"Please Enter Line Reciept Recieved Date" withTitle:@""];
    }
//    else if ([lineReceiptVendorInvoice.text isEqualToString:@""]){
//        [FAUtilities showAlert:@"Please Enter Line Reciept Vendor Invoice"];
//    }
    else if ([lineReceiptRecvQty.text intValue] > remainingPartQuantity){
        [FAUtilities showAlert:@"Recv Qty should be less than or equal to Ordered Qty" withTitle:@""];
    }
    else{
        
        BOOL isValidDate = [self getDateFromString:lineReceiptRecvDate.text];
        if (isValidDate == NO) {
            lineReceiptRecvDate.text = @"";
            NSLog(@"valid date no");
        }else{
            NSLog(@"valid date");
            
            NSRegularExpression *regex = [[NSRegularExpression alloc]
                                          initWithPattern:@"[a-zA-Z]" options:0 error:NULL];
            NSRegularExpression *regex1 = [[NSRegularExpression alloc]
                                           initWithPattern:@"[-%@#$&*!()_]" options:0 error:NULL];
            // Assuming you have some NSString `myString`.
            NSUInteger matches = [regex numberOfMatchesInString:lineReceiptRecvQty.text options:0
                                                          range:NSMakeRange(0, [lineReceiptRecvQty.text length])];
            
            NSUInteger matches1 = [regex1 numberOfMatchesInString:lineReceiptRecvQty.text options:0
                                                            range:NSMakeRange(0, [lineReceiptRecvQty.text length])];
            
            
            if (matches > 0) {
                [FAUtilities showAlert:@"Enter only positive integers for Recv Qty" withTitle:@""];
                return;
            }
            
            if (matches1 > 0) {
                [FAUtilities showAlert:@"Enter only positive integers for Recv Qty" withTitle:@""];
                return;
            }
            
            [self postRequest:PO_RECEIPT_ENTRY];
        }
        
    }
    NSLog(@"lineRecieptRecvQty.text %@, lineRecieptRecvDate.text %@, lineRecieptvendoeInvoice.text %@",lineReceiptRecvQty.text,lineReceiptRecvDate.text,lineReceiptVendorInvoice.text );
}


- (void)lineAddReceiptSubviewEditBtnClicked:(id)sender{
    
    [self.view endEditing:YES];
    
    //    [FAUtilities showAlert:@"In Progress"];
    clickedLineRecieptBtn = (UIButton*)sender;
    
    isEditing = YES;
    NSLog(@"edited line details %@", [getPoReceiptTableValues objectAtIndex:clickedLineRecieptBtn.tag]);
    
    lineReceiptsEditingDict = [getPoReceiptTableValues objectAtIndex:clickedLineRecieptBtn.tag];
    
    NSString *tempRecQty            = [lineReceiptsEditingDict objectForKey:@"RecvQty"];
    NSString *tempDate              = [lineReceiptsEditingDict objectForKey:@"RecvDate"];
    NSString *tempVendoeInvoice     = [lineReceiptsEditingDict objectForKey:@"VendorInvoice"];
    NSString *tempComments          = [lineReceiptsEditingDict objectForKey:@"Comments"];
    
//    remainingPartQuantity = orderQty-recvQty;

    if (![tempRecQty isEqual:[NSNull null]]) {
        lineReceiptRecvQty.text = tempRecQty;
    }
    if (![tempDate isEqual:[NSNull null]]) {
        NSRange range = [tempDate rangeOfString:@" "];
        lineReceiptRecvDate.text = [tempDate substringToIndex:range.location];
    }
    if (![tempVendoeInvoice isEqual:[NSNull null]]) {
        lineReceiptVendorInvoice.text = tempVendoeInvoice;
    }
    if (![tempComments isEqual:[NSNull null]]) {
        lineReceiptCommentsTextView.text = tempComments;
    }
    
    [addOrUpdateEntryBtn setTitle:@"Update Entry" forState:UIControlStateNormal];    
    [self lineAddReceiptSubviewAddBtnClicked:nil];
  
    if (![tempRecQty isEqual:[NSNull null]]) {
        remainingPartQuantity = remainingPartQuantity+[tempRecQty intValue];
    }
    
}



-(IBAction)lineAddReceiptSubviewAddCancelBtnClicked:(id)sender{
    

    [self.view endEditing:YES];
    lineDetailsAddBtnClicked = NO;
    
    animationStarted = NO;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:[self view]      cache:YES];
    
    [lineItemsTableSubView setFrame:CGRectMake(lineItemsTableSubView.frame.origin.x,lineItemsTableSubView.frame.origin.y-164,lineItemsTableSubView.frame.size.width,lineItemsTableSubView.frame.size.height+164)];
    [UIView commitAnimations];
    //    [lineAddReceiptSubviewAddBtn setEnabled:YES]; // To toggle enabled / disabled
    
    addOrUpdateEntryBtn.titleLabel.text = @"";
    [addOrUpdateEntryBtn setTitle:@"" forState:UIControlStateNormal];
    
    lineAddReceiptSubviewAddBtn.hidden = NO;
    
    lineReceiptRecvQty.text = @"";
    lineReceiptRecvDate.text = @"";
    lineReceiptVendorInvoice.text = @"";
    lineReceiptCommentsTextView.text = @"";
    if (sender == nil) {
        [self postRequest:GET_PO_TYPE];
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    if (textField == lineReceiptRecvQty) {
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        return [string isEqualToString:filtered];
    }else if (textField == lineReceiptRecvDate){
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789/"] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        return [string isEqualToString:filtered];
    }
    return YES;
}


- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == lineReceiptRecvDate) {
        
//        if (textField.text.length ==0) {
//            
//        }else{
//            BOOL isValidDate = [self getDateFromString:textField.text];
//            if (isValidDate == NO) {
////                textField.text = @"";
//                NSLog(@"valid date no");
//            }else{
//                NSLog(@"valid date");
//            }
//        }
    }
    
}


-(BOOL)getDateFromString:(NSString *)string
{
    NSString *dateStr = [NSString stringWithFormat: @"%@",string];
    NSDateFormatter *formate = [[NSDateFormatter alloc] init];
    [formate setDateFormat:@"MM/dd/yyyy"];
    NSDate *startDate = [formate dateFromString:@"01/01/1900"];
    NSDate *endDate = [formate dateFromString:@"01/01/3000"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/YYYY"];
    NSDate *currentDate = [formate dateFromString:dateStr];
    NSComparisonResult result1,result2;
    //has three possible values: NSOrderedSame,NSOrderedDescending, NSOrderedAscending
    result1 = [currentDate compare:startDate]; // comparing two dates
    result2 = [currentDate compare:endDate]; // comparing two dates
    if(result2==NSOrderedAscending && result1==NSOrderedDescending)
    {
        NSLog(@"Between the StartDate and Enddate");
    }else{
        [FAUtilities showAlert:DATE_INVALID withTitle:@""];
        return NO;
    }
    return YES;
}



-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){//setting the form list table frame when returing back to the form list view
    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
        [getPOScrollView setContentSize:(CGSizeMake(768, 1024))];
    }
    
    
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){//setting the form list table frame when returing back to the form list view
        lineItemReceiptSubView.frame = CGRectMake(60+80+10+20+10, 100, 628, 540);
//        lineItemReceiptSubView.frame = CGRectMake(60, 220, 628, 540);

    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
        lineItemReceiptSubView.frame = CGRectMake(20, 315, 628+100, 540);
//        lineItemReceiptSubView.frame = CGRectMake(60+80, 150, 628+100, 540);

    }

    [getPOOrderDetailsTableView reloadData];
    [lineItemReceiptsTableView reloadData];

}






- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
