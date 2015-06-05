//
//  RADocumenmtsListTableViewCell.m
//  TriStar
//
//  Created by Manulogix on 20/10/14.
//  Copyright (c) 2014 Manulogix. All rights reserved.
//

#import "RADocumenmtsListTableViewCell.h"

@implementation RADocumenmtsListTableViewCell
@synthesize docNumber;
@synthesize docTitle;
@synthesize docFileName;
@synthesize docUpdatedOn;

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
