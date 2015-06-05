//
//  RADocumenmtsListTableViewCell.h
//  TriStar
//
//  Created by Manulogix on 20/10/14.
//  Copyright (c) 2014 Manulogix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RADocumenmtsListTableViewCell : UITableViewCell{
    IBOutlet UILabel *docNumber;
    IBOutlet UILabel *docTitle;
    IBOutlet UILabel *docFileName;
    IBOutlet UILabel *docUpdatedOn;
    
}

@property(nonatomic,retain)UILabel *docNumber;
@property(nonatomic,retain)UILabel *docTitle;
@property(nonatomic,retain)UILabel *docFileName;
@property(nonatomic,retain)UILabel *docUpdatedOn;

@end
