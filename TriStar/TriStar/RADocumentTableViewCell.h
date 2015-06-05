//
//  RADocumentTableViewCell.h
//  TriStar
//
//  Created by Manulogix on 21/10/14.
//  Copyright (c) 2014 Manulogix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RADocumentTableViewCell : UITableViewCell{
    IBOutlet UILabel *docTitle;
    IBOutlet UILabel *docFileName;
    IBOutlet UILabel *docNotes;

}

@property(nonatomic,retain)UILabel *docTitle;
@property(nonatomic,retain)UILabel *docFileName;
@property(nonatomic,retain)UILabel *docNotes;


@end
