//
//  KKNearbyAlertView.m
//  MultipeerDemo
//
//  Created by mikewang on 14/10/28.
//  Copyright (c) 2014年 xiyou. All rights reserved.
//

#import "KKNearbyAlertView.h"

@implementation KKNearbyAlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
    
    if(self.dontDismiss)
        return;
    
    [super dismissWithClickedButtonIndex:buttonIndex animated:animated];
}

@end

