//
//  KKConnectViewController.h
//  MultipeerDemo
//
//  Created by mikewang on 14/10/22.
//  Copyright (c) 2014年 xiyou. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kServiceType = @"KKNearbyDemo";

#import <MultipeerConnectivity/MultipeerConnectivity.h>

@protocol  KKConnectViewControllerDelegate;

@interface KKConnectViewController : UIViewController

@property (nonatomic, strong) MCPeerID *peerID;

@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;

@property (nonatomic, strong) MCSession *session;

@property (nonatomic, assign) BOOL browsing;

@property (nonatomic, assign) id <KKConnectViewControllerDelegate> delegate;
@end

@protocol KKConnectViewControllerDelegate <NSObject>

@optional

- (void)dismissConnectViewController;

@end