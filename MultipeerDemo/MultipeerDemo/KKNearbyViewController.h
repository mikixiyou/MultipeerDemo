//
//  KKNearbyViewController.h
//  MultipeerDemo
//
//  Created by mikewang on 14/10/28.
//  Copyright (c) 2014年 xiyou. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GTMLogger.h"

@protocol  KKNearbyViewControllerDelegate;

@interface KKNearbyViewController : UIViewController

@property (nonatomic,strong) NSNumber *numDayid;

@property (nonatomic, assign) id <KKNearbyViewControllerDelegate> delegate;

@end

@protocol KKNearbyViewControllerDelegate <NSObject>

@optional

- (void)dismissNearbyViewController;

@end