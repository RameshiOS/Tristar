//
//  LoginDetails.h
//  DDMForms
//
//  Created by manulogix on 7/19/13.
//  Copyright (c) 2013 Manulogix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginDetails : NSObject
{
    NSString *type;
    NSMutableArray *loginArray;
}
@property (nonatomic,retain)  NSString *type;
@property (nonatomic,retain)  NSMutableArray *loginArray;
@end
