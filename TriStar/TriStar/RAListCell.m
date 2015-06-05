//
//  RAListCell.m
//  TriStar
//
//  Created by Manulogix on 18/12/13.
//  Copyright (c) 2013 Manulogix. All rights reserved.
//

#import "RAListCell.h"

@implementation RAListCell
@synthesize raNumber;
@synthesize customerName;
@synthesize customerRefId;
@synthesize createdOn;
@synthesize customerPoNum;
@synthesize status;

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
