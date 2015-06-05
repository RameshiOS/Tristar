//
//  RAListCell.h
//  TriStar
//
//  Created by Manulogix on 18/12/13.
//  Copyright (c) 2013 Manulogix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RAListCell : UITableViewCell{
    IBOutlet UILabel *raNumber;
    IBOutlet UILabel *customerName;
    IBOutlet UILabel *customerRefId;
    IBOutlet UILabel *createdOn;
    IBOutlet UILabel *customerPoNum;
    IBOutlet UILabel *status;
}

@property(nonatomic,retain)UILabel *raNumber;
@property(nonatomic,retain)UILabel *customerName;
@property(nonatomic,retain)UILabel *customerRefId;
@property(nonatomic,retain)UILabel *createdOn;
@property(nonatomic,retain)UILabel *customerPoNum;
@property(nonatomic,retain)UILabel *status;


@end
