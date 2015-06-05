//
//  RepairListCell.m
//  TriStar
//
//  Created by Manulogix on 18/12/13.
//  Copyright (c) 2013 Manulogix. All rights reserved.
//

#import "RepairListCell.h"

@implementation RepairListCell
@synthesize lineNumber;
@synthesize partNumber;
@synthesize desc;
@synthesize barCode;
//@synthesize requiredQty;
@synthesize consumedQty;
@synthesize inStock;
@synthesize addOrRemoveQty;
@synthesize getRAActionBtn;
@synthesize cellSubView;
@synthesize checkInButton;
@synthesize checkOutButton;
@synthesize reqQtyValueLabel;
@synthesize consumedQtyValueLabel;
@synthesize chekInOrCheckOutFieldLabel;
@synthesize checkInOrCheckOutValue;
@synthesize cancelBtn;
@synthesize checkInOrCheckOutBtn;
@synthesize subViewPartNum;
@synthesize subViewBomNotes;
@synthesize scanBarCodeCheckInOrCheckOutBtn;
@synthesize documentsListView;

// for actions menu

@synthesize actionButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
