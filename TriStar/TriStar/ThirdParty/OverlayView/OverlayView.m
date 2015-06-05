                                  //
//  OverlayView.m
//  OverlayViewTester
//
//  Created by Jason Job on 09-12-10.
//  Copyright 2009 Jason Job. All rights reserved.
//

#import "OverlayView.h"


@implementation OverlayView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		// Clear the background of the overlay:
		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];
		
		// Load the image to show in the overlay:
        
        UIImage *overlayGraphic1 = [UIImage imageNamed:@"newOverlay.png"];
        
        UIView *overlayGraphicView1 = [[UIView alloc] init];
        overlayGraphicView1.frame = CGRectMake(0, 0, 544, 300); // for small img with croped with

        UIImageView *overlayGraphicImgView = [[UIImageView alloc] initWithImage:overlayGraphic1];
        overlayGraphicImgView.frame = CGRectMake(0, 0, 544, 300); // for small img with croped with
        
  
        [overlayGraphicView1 addSubview:overlayGraphicImgView];
		[self addSubview:overlayGraphicView1];
    }
    return self;
}



- (void)clearLabel:(UILabel *)label {
	label.text = @"";
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
    [super dealloc];
}


@end
