//
//  FAUtilities.m
//  FormsiPadApp
//
//  Created by NagaMalleswar on 05/02/13.
//  Copyright (c) 2013 NagaMalleswar. All rights reserved.
//

#import "FAUtilities.h"
#import <mach/mach.h>
#import <QuartzCore/QuartzCore.h>
@implementation FAUtilities

+ (void)setBorderWithColor:(UIColor *)color toView:(UIView *)view withRadius:(CGFloat)radius{
    CALayer * layer = [view layer];
    [layer setMasksToBounds:YES];
    [layer setBorderWidth:1.0];
    [layer setBorderColor:[color CGColor]];
    [layer setCornerRadius:radius];
}
+ (UIBarButtonItem *)customButtonWithTitle:(NSString*)title style:(UIButtonType)buttonStyle target:(id)target action:(SEL)sel width:(CGFloat)width{
    UIButton *buttonView = [UIButton buttonWithType:buttonStyle];
    [buttonView setFrame:CGRectMake(0, 0, width, 30)];
	[buttonView setTitle:title forState:UIControlStateNormal];
	buttonView.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    buttonView.titleEdgeInsets = UIEdgeInsetsMake(0, 7, 3, 0);
    buttonView.titleLabel.textAlignment = NSTextAlignmentCenter;
	[buttonView addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    [buttonView setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
	UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
	return barButton  ;
}
+ (UIBarButtonItem *)customButtonWithImage:(NSString*)bgImage target:(id)target action:(SEL)sel width:(CGFloat)width{
    UIButton *buttonView = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonView setFrame:CGRectMake(0, 0, width, 30)];
    
	buttonView.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    buttonView.titleEdgeInsets = UIEdgeInsetsMake(0, 7, 3, 0);
    buttonView.titleLabel.textAlignment = NSTextAlignmentCenter;
	[buttonView addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    [buttonView setBackgroundImage:[UIImage imageNamed:bgImage] forState:UIControlStateNormal];
    //buttonView.imageView.layer.cornerRadius = 7.0f;
    buttonView.layer.shadowRadius = 5.0f;
    buttonView.layer.shadowColor = [[UIColor colorWithRed:248.0f/255.0f green:249.0f/255.0f blue:250.0f/255.0f alpha:1] CGColor];
    buttonView.layer.shadowOffset = CGSizeMake(-4.0f, 1.0f);
    buttonView.layer.shadowOpacity = 0.5f;
    buttonView.layer.masksToBounds = NO;
//    [buttonView.layer setCornerRadius: 4.0];
//    [buttonView.layer setBorderWidth:1.0];
    [buttonView.layer setBorderColor:[[UIColor colorWithRed:171.0f/255.0f green:171.0f/255.0f blue:171.0f/255.0f alpha:1] CGColor]];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
	return barButton  ;
}


+ (UIBarButtonItem *)customBackButtonWithtarget:(id)target action:(SEL)sel width:(CGFloat)width{
    UIButton *backButtonView = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, width, 20)];
    backButtonView.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    backButtonView.titleLabel.textAlignment = NSTextAlignmentCenter;
    backButtonView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	[backButtonView addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    [backButtonView setBackgroundImage:[UIImage imageNamed:@"backhome"] forState:UIControlStateNormal];
	UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButtonView];
	return backBarButton  ;
}
+ (UIBarButtonItem *)customBackButtonWithtarget:(id)target action:(SEL)sel width:(CGFloat)width title:(NSString *)title{
    UIButton *backButtonView = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, width, 30)];
    backButtonView.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    backButtonView.titleLabel.textAlignment = NSTextAlignmentCenter;
    backButtonView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	[backButtonView addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    [backButtonView setBackgroundImage:[UIImage imageNamed:@"button_black_1.png"] forState:UIControlStateNormal];
    [backButtonView setBackgroundImage:[UIImage imageNamed:@"button_black_2.png"] forState:UIControlStateHighlighted];

    [backButtonView setTitle:title forState:UIControlStateNormal];
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButtonView];
	return backBarButton  ;
}
+ (UIBarButtonItem *)customInfoButtonWithtarget:(id)target action:(SEL)sel width:(CGFloat)width{
    UIButton *infoButtonView = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, width, 20)];
    infoButtonView.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    infoButtonView.titleLabel.textAlignment = NSTextAlignmentCenter;
    infoButtonView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	[infoButtonView addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    [infoButtonView setBackgroundImage:[UIImage imageNamed:@"Info"] forState:UIControlStateNormal];
	UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:infoButtonView];
	return backBarButton  ;
}
+ (NSData*)getImageDataFromView:(UIView*)view{
    UIGraphicsBeginImageContext([view bounds].size);
    [[view layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    NSData *data = UIImageJPEGRepresentation(image, 1);
    UIGraphicsEndImageContext();
    return data;
}

+ (CGFloat)convertBytesToMB:(CGFloat)bytes{
    CGFloat mbData = ((bytes/1024)/1024);
    return mbData;
}

+ (CGFloat)getTotalDiskspace{
    CGFloat totalSpace = 0.0f;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        totalSpace = [fileSystemSizeInBytes floatValue];
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %d", [error domain], [error code]);
    }
     return totalSpace;
}

+ (CGFloat)getFreeDiskspace {
    CGFloat totalSpace = 0.0f;
    CGFloat totalFreeSpace = 0.0f;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes floatValue];
        totalFreeSpace = [freeFileSystemSizeInBytes floatValue];
        NSLog(@"Memory Capacity of %.2f MiB with %.2f MiB Free memory available.", ((totalSpace/1024)/1024), ((totalFreeSpace/1024)/1024));
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %d", [error domain], [error code]);
    }
    return totalFreeSpace;
}

+ (CGFloat)getAppUsageSpace {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        NSLog(@"Memory in use (in bytes): %u", info.resident_size);
    } else {
        NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
    }
    return  info.resident_size;
}


+ (UIColor *)getUIColorObjectFromHexString:(NSString *)hexStr alpha:(CGFloat)alpha
{
    // Convert hex string to an integer
    unsigned int hexint = [self intFromHexString:hexStr];
    
    // Create color object, specifying alpha as well
    UIColor *color =
    [UIColor colorWithRed:((CGFloat) ((hexint & 0xFF0000) >> 16))/255
                    green:((CGFloat) ((hexint & 0xFF00) >> 8))/255
                     blue:((CGFloat) (hexint & 0xFF))/255
                    alpha:alpha];
    
    return color;
}

+ (unsigned int)intFromHexString:(NSString *)hexStr
{
    unsigned int hexInt = 0;
    
    // Create scanner
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    
    // Tell scanner to skip the # character
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    
    // Scan hex value
    [scanner scanHexInt:&hexInt];
    
    return hexInt;
}


+(BOOL) offlineCheck {
//    if(isOFFLINE) {
//        return YES;
//    }
//    return NO;
    return NO;
}


+(void)showAlert:(NSString*)msg withTitle:(NSString *)title{
    NSString *titleStr;
    
    if (title.length ==0) {
        titleStr = ALERT_MSG_TITLE;
    }else{
        titleStr = title;
    }
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:titleStr message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}

+(void)showToastMessageAlert:(NSString*)message{
//    NSString *titleString;
//    
//    if ([[[UIDevice currentDevice] systemVersion] doubleValue] < 7) {
//        titleString = [NSString stringWithFormat:@"\n\n%@",FORMS_PAGE_TITLE];
//    }else{
//        titleString = FORMS_PAGE_TITLE;
//    }
//
//    
//	UIAlertView *toastMsgAlert= [[UIAlertView alloc] initWithTitle:titleString
//                                                           message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
//	[toastMsgAlert setMessage:message];
//	[toastMsgAlert setDelegate:self];
//	[toastMsgAlert show];
//    
//  
//    
//    [self performSelector:@selector(dismiss:) withObject:toastMsgAlert afterDelay:1.5];
}

+(void)dismiss:(UIAlertView*)alertView
{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}






@end
