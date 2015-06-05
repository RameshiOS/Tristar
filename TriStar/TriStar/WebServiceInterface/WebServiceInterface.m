
//
//  WebServiceInterface.m
//  DDMForms
//
//  Created by Manulogix on 19/07/13.
//  Copyright (c) 2013 Manulogix. All rights reserved.
//

#import "WebServiceInterface.h"
#import "ViewController.h"
#import "WSLogin.h"
#import "SBJson.h"

//#import "WSGetForm.h"
//#import "WSGetLookUp.h"
//#import "WSProfile.h"
//#import "WSSyncData.h"
//#import <QuartzCore/QuartzCore.h>
//#import "WSSyncDeletedData.h"
//#import "WSUploadDatabase.h"

@interface WebServiceInterface ()

@property(nonatomic, strong) UIViewController    *wsiParentVC;
@property(nonatomic, strong) MBProgressHUD       *wsiActivityIndicator;
@end

@implementation WebServiceInterface
@synthesize receivedData= _recievedData;
@synthesize delegate;
@synthesize wsiParentVC;
@synthesize wsiActivityIndicator;

#pragma mark -
#pragma mark init Methods
-(id) initWithVC: (UIViewController *)parentVC {
    self = [super init];
    if(self) {
        self.wsiParentVC = parentVC; // DO NOT allocate as we should point only
        //        self.delegate    = (id)parentVC; // DO NOT allocate as we should point only
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }return self;
}

#pragma mark -
#pragma mark Progress Bar Hud

#pragma mark - Indicator APIs

-(void) releaseActivityIndicator {
    if (wsiActivityIndicator) {
        [wsiActivityIndicator removeFromSuperview];
        //        RELEASE_MEM(wsiActivityIndicator);
    }
}
- (void) myTask {
	sleep(REQUEST_TIMEOUT_INTERVAL);
}

- (void) hideIndicator {
    [wsiActivityIndicator setHidden:YES];
}
- (void) showIndicator {
    [self releaseActivityIndicator];
    wsiActivityIndicator             = [[MBProgressHUD alloc] initWithView:wsiParentVC.view];
    wsiActivityIndicator.minShowTime = 30.0f;
    wsiActivityIndicator.delegate    = self;
    wsiActivityIndicator.labelText   = @"Loading...";
    [wsiParentVC.view addSubview:wsiActivityIndicator];
    [wsiActivityIndicator showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
}

#pragma MBProgressHUD delegate methods
- (void) hudWasHidden:(MBProgressHUD *)hud {
	// Remove wsiActivityIndicator from screen when the wsiActivityIndicator was hidded
    [self releaseActivityIndicator];
}

#pragma mark -
#pragma mark Request Methods

-(void) sendRequest:(NSString *)postString PostJsonData:(NSData *)postData Req_Type:(NSString *)reqType Req_url:(NSString *)reqUrl{
    [self showIndicator];
    postReqString = postString;
    postReqData = postData;
    postReqType=reqType;
    postReqUrl = reqUrl;
    [self postRequest];
}

-(void)postRequest{
    NSString *postLength = [NSString stringWithFormat:@"%d", [postReqData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *poststring = [[NSString alloc]initWithData:postReqData encoding:NSUTF8StringEncoding];
    NSLog(@"postString : %@",poststring);
    NSLog(@"postReqUrl : %@",postReqUrl);

    NSString *posturl = [NSString stringWithFormat:@"%@",postReqUrl];
    
    [request setURL:[NSURL URLWithString:posturl]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postReqData];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.connection = connection;
    [connection start];
  
}

/* this method might be calling more than one times according to incoming data size */
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    receivedData = data;
}

/* this method called to store cached response for this connection  */
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

/* if there is an error occured, this method will be called by connection */
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [self hideIndicator];
    if (statusCode!=200) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
                                    message:[error localizedDescription]
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                          otherButtonTitles:nil] show];
    }
    NSLog(@"FailWithError %@" , error);
}

/* if data is successfully received, this method will be called by connection */
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{

    NSLog(@"timer started");
    if ([postReqType isEqualToString:GET_PART]) {
        [NSThread sleepForTimeInterval:2.5];
        NSLog(@"timer 2.5");
    }else{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"timer 1.0");
    }

    receivedData = [[NSMutableData alloc] init];
    NSHTTPURLResponse *httpResponse;
    httpResponse = (NSHTTPURLResponse *)response;
    statusCode = [httpResponse statusCode];
    NSLog(@"Status code  %d", statusCode);
    if (statusCode == 200) {
        
    }else{
        [FAUtilities showAlert:STATUS_CODE_FAILED_ERROR withTitle:@""];
        [self hideIndicator];
    }
    
}

/* if data is finished loading, this method will be called by connection */
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    responseString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    NSLog(@"responseString %@" , responseString);
        
    if (IS_EMPTY(responseString)) {
    

    }else{
        [self doParse:receivedData];
    }
}



#pragma mark -
#pragma mark Response Methods
-(void)doParse:(NSData *)data{
    NSDictionary *responseDict;
    
    responseDict = [self parseJsonResponse:data];

    NSString *respResult = [responseDict valueForKey:@"ProcessRequestResult"];
    NSDictionary *tempResp = [respResult JSONValue];

    if ([postReqType isEqualToString:LOGIN_TYPE] || [postReqType isEqualToString:FIND_PO_TYPE] || [postReqType isEqualToString:GET_PO_TYPE] || [postReqType isEqualToString:GET_PO_RECEIPT] || [postReqType isEqualToString:PO_RECEIPT_ENTRY] || [postReqType isEqualToString:FIND_RA_TYPE]  || [postReqType isEqualToString:GET_RA_TYPE] || [postReqType isEqualToString:GET_PART] || [postReqType isEqualToString:RA_UPDATE_BOM] || [postReqType isEqualToString:RA_PART_CHECKIN] || [postReqType isEqualToString:RA_PART_CHECKOUT] || [postReqType isEqualToString:GET_PART_DOCUMENTS] || [postReqType isEqualToString:ADD_RA_BOM_PART] || [postReqType isEqualToString:GET_SUBSTITUTE_PARTS] || [postReqType isEqualToString:REPLACE_SUBSTITUTE_PART] || [postReqType isEqualToString:DELETE_BOM_PART] || [postReqType isEqualToString:CHECK_DOCUMENT_ACCESS]) {
        [self sendResponse:tempResp];
    }else{
        [self sendResponse:responseDict];
    }
}


-(NSDictionary *) parseJsonResponse:(NSData *)response{
    NSString *respStr;
   
    NSData *respData = [respStr dataUsingEncoding:NSUTF8StringEncoding];
    
    if ([postReqType isEqualToString:LOGIN_TYPE] || [postReqType isEqualToString:FIND_PO_TYPE] || [postReqType isEqualToString:GET_PO_TYPE] || [postReqType isEqualToString:GET_PO_RECEIPT] || [postReqType isEqualToString:PO_RECEIPT_ENTRY] || [postReqType isEqualToString:FIND_RA_TYPE] || [postReqType isEqualToString:GET_RA_TYPE] ||[postReqType isEqualToString:GET_PART] || [postReqType isEqualToString:RA_UPDATE_BOM] || [postReqType isEqualToString:RA_PART_CHECKIN] || [postReqType isEqualToString:RA_PART_CHECKOUT] || [postReqType isEqualToString:GET_PART_DOCUMENTS] || [postReqType isEqualToString:ADD_RA_BOM_PART] || [postReqType isEqualToString:GET_SUBSTITUTE_PARTS] || [postReqType isEqualToString:REPLACE_SUBSTITUTE_PART] || [postReqType isEqualToString:DELETE_BOM_PART] || [postReqType isEqualToString:CHECK_DOCUMENT_ACCESS]) {
        respData = response;
    }
    
    NSDictionary *rspDic = [self getJSONObjectFromData:respData];
    NSArray *rspAry = [self getJSONObjectFromData:respData];
    NSLog(@"respAry %@", rspAry);
    
    return rspDic;
}


-(id) getJSONObjectFromData:(NSData *)data {
    if ((!data) || ([data length] <=0)) return nil;
    
    if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
        //#if (__has_feature(objc_arc))
        NSString *dataInString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //#else
        //        NSString *dataInString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        //#endif
        return [dataInString JSONValue];
    } else {
        return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    }
    return nil;
}


-(void) sendResponse:(NSDictionary *)respDict{
    [self hideIndicator];
    [delegate getResponse:respDict type:postReqType];
}


- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end
