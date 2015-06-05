//
//  RADocumentTableViewCell.m
//  TriStar
//
//  Created by Manulogix on 21/10/14.
//  Copyright (c) 2014 Manulogix. All rights reserved.
//

#import "RADocumentTableViewCell.h"

@implementation RADocumentTableViewCell

@synthesize docTitle;
@synthesize docFileName;
@synthesize docNotes;

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
