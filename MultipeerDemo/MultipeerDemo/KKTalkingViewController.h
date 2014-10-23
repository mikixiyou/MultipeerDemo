//
//  KKTalkingViewController.h
//  MultipeerDemo
//
//  Created by mikewang on 14/10/22.
//  Copyright (c) 2014年 xiyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  KKTalkingViewControllerDelegate;

@interface KKTalkingViewController : UIViewController


@property (nonatomic, assign) id <KKTalkingViewControllerDelegate> delegate;
@end

@protocol KKTalkingViewControllerDelegate <NSObject>

@optional

- (void)dismissTalkingViewController;

@end