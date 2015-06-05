//
//  POListCell.h
//  TriStar
//
//  Created by Manulogix on 18/12/13.
//  Copyright (c) 2013 Manulogix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface POListCell : UITableViewCell{
    IBOutlet UILabel *poNumber;
    IBOutlet UILabel *VendorName;
    IBOutlet UILabel *createdOn;
    IBOutlet UILabel *amount;
}

@property(nonatomic,retain)UILabel *poNumber;
@property(nonatomic,retain)UILabel *VendorName;
@property(nonatomic,retain)UILabel *createdOn;
@property(nonatomic,retain)UILabel *amount;

@end
