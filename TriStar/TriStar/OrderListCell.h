//
//  OrderListCell.h
//  TriStar
//
//  Created by Manulogix on 18/12/13.
//  Copyright (c) 2013 Manulogix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderListCell : UITableViewCell{
    IBOutlet UILabel *lineNumber;
    IBOutlet UILabel *partNumber;
    IBOutlet UILabel *orderedQty;
    IBOutlet UILabel *recivedQty;
    IBOutlet UILabel *statusValue;
    IBOutlet UILabel *priceValue;
    IBOutlet UILabel *totalValue;
    IBOutlet UIButton *getPOActionBtn;
}

@property(nonatomic,retain)UILabel *lineNumber;
@property(nonatomic,retain)UILabel *partNumber;
@property(nonatomic,retain)UILabel *orderedQty;
@property(nonatomic,retain)UILabel *recivedQty;
@property(nonatomic,retain)UILabel *statusValue;
@property(nonatomic,retain)UILabel *priceValue;
@property(nonatomic,retain)UILabel *totalValue;
@property(nonatomic,retain)UIButton *getPOActionBtn;

@end






















































