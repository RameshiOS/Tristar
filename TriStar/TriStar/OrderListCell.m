//
//  OrderListCell.m
//  TriStar
//
//  Created by Manulogix on 18/12/13.
//  Copyright (c) 2013 Manulogix. All rights reserved.
//

#import "OrderListCell.h"

@implementation OrderListCell
@synthesize lineNumber;
@synthesize partNumber;
@synthesize orderedQty;
@synthesize recivedQty;
@synthesize statusValue;
@synthesize priceValue;
@synthesize totalValue;
@synthesize getPOActionBtn;


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
