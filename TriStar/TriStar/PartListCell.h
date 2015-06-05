//
//  PartListCell.h
//  TriStar
//
//  Created by Manulogix on 26/04/14.
//  Copyright (c) 2014 Manulogix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PartListCell : UITableViewCell{
    IBOutlet UILabel *partNumber;
    IBOutlet UILabel *barcode;
    IBOutlet UILabel *inStock;
    IBOutlet UILabel *location;
}

@property(nonatomic,retain)UILabel *partNumber;
@property(nonatomic,retain)UILabel *barcode;
@property(nonatomic,retain)UILabel *inStock;
@property(nonatomic,retain)UILabel *location;


@end
