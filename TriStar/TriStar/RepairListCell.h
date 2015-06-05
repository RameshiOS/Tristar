//
//  RepairListCell.h
//  TriStar
//
//  Created by Manulogix on 18/12/13.
//  Copyright (c) 2013 Manulogix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepairListCell : UITableViewCell{
    IBOutlet UILabel    *lineNumber;
    IBOutlet UILabel    *partNumber;
    IBOutlet UILabel    *desc;
    IBOutlet UILabel    *barCode;
//    IBOutlet UILabel    *requiredQty;
    IBOutlet UILabel    *consumedQty;
    IBOutlet UILabel    *inStock;
    
    IBOutlet UITextField *addOrRemoveQty;
    
    IBOutlet UIButton   *getRAActionBtn;
    
    IBOutlet UIView     *cellSubView;
    IBOutlet UIButton   *checkInButton;
    IBOutlet UIButton   *checkOutButton;
    
    // check in or check out subview
    
    IBOutlet UILabel        *reqQtyValueLabel;
    IBOutlet UILabel        *consumedQtyValueLabel;
    IBOutlet UILabel        *chekInOrCheckOutFieldLabel;
    IBOutlet UITextField    *checkInOrCheckOutValue;
    IBOutlet UIButton       *cancelBtn;
    IBOutlet UIButton       *checkInOrCheckOutBtn;
    
    
//    IBOutlet UILabel        *subViewBarCodeNum;
//    IBOutlet UILabel        *subViewBomNotes;
    
    IBOutlet UILabel        *subViewPartNum;
    IBOutlet UILabel     *subViewBomNotes;
    
   IBOutlet  UIButton       *scanBarCodeCheckInOrCheckOutBtn;
    
    
   IBOutlet UIButton   *actionButton;
    
    
    IBOutlet UIView *documentsListView;
}

@property(nonatomic,retain)UILabel      *lineNumber;
@property(nonatomic,retain)UILabel      *partNumber;
@property(nonatomic,retain)UILabel      *desc;
@property(nonatomic,retain)UILabel      *barCode;
//@property(nonatomic,retain)UILabel      *requiredQty;
@property(nonatomic,retain)UILabel      *consumedQty;
@property(nonatomic,retain)UILabel      *inStock;
@property(nonatomic,retain)UITextField      *addOrRemoveQty;
@property(nonatomic,retain)UIView     *cellSubView;

@property(nonatomic,retain)UIButton   *checkInButton;
@property(nonatomic,retain)UIButton   *checkOutButton;


@property(nonatomic,retain)UIButton   *actionButton;

// check in or check out subview


@property(nonatomic,retain)UILabel      *reqQtyValueLabel;
@property(nonatomic,retain)UILabel      *consumedQtyValueLabel;
@property(nonatomic,retain)UILabel      *chekInOrCheckOutFieldLabel;
@property(nonatomic,retain)UITextField  *checkInOrCheckOutValue;
@property(nonatomic,retain)UIButton     *cancelBtn;
@property(nonatomic,retain)UIButton     *checkInOrCheckOutBtn;
@property(nonatomic,retain)UILabel        *subViewPartNum;
@property(nonatomic,retain)UILabel     *subViewBomNotes;
@property(nonatomic,retain)UIButton       *scanBarCodeCheckInOrCheckOutBtn;
@property(nonatomic,retain)UIView *documentsListView;


//@property(nonatomic,retain)UILabel        *subViewBarCodeNum;
//@property(nonatomic,retain)UILabel        *subViewBomNotes;


@property(nonatomic,retain)UIButton      *getRAActionBtn;

@end
