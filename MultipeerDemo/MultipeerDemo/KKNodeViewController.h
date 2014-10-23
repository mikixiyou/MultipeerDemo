//
//  KKNodeViewController.h
//  MultipeerDemo
//
//  Created by mikewang on 14/10/21.
//  Copyright (c) 2014年 xiyou. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KKConnectViewController.h"

@interface KKNodeViewController : UIViewController <KKConnectViewControllerDelegate>

@property (nonatomic,strong) KKConnectViewController *connectViewController;

@end