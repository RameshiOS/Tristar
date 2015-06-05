//
//  POLineReceiptListCell.h
//  TriStar
//
//  Created by Manulogix on 09/01/14.
//  Copyright (c) 2014 Manulogix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface POLineReceiptListCell : UITableViewCell{
    IBOutlet UILabel *lineReceiptQtyReceived;
    IBOutlet UILabel *lineReceiptQtyReceivedDate;
    IBOutlet UILabel *lineReceiptQtyReceivedBy;
    IBOutlet UILabel *lineReceiptQtyReceivedvendor;
    IBOutlet UILabel *lineReceiptQtyReceivedComments;
    IBOutlet UILabel *lineNumber;
    IBOutlet UIButton *lineAddReceiptSubviewEditBtn;

}

@property(nonatomic,retain)UILabel *lineReceiptQtyReceived;
@property(nonatomic,retain)UILabel *lineReceiptQtyReceivedDate;
@property(nonatomic,retain)UILabel *lineReceiptQtyReceivedBy;
@property(nonatomic,retain)UILabel *lineReceiptQtyReceivedvendor;
@property(nonatomic,retain)UILabel *lineReceiptQtyReceivedComments;
@property(nonatomic,retain)UILabel *lineNumber;
@property(nonatomic,retain)UIButton *lineAddReceiptSubviewEditBtn;

@end
