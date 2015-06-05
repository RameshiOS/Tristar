//
//  PartListCell.m
//  TriStar
//
//  Created by Manulogix on 26/04/14.
//  Copyright (c) 2014 Manulogix. All rights reserved.
//

#import "PartListCell.h"

@implementation PartListCell
@synthesize partNumber;
@synthesize barcode;
@synthesize inStock;
@synthesize location;

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
