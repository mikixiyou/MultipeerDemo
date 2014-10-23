//
//  FirstViewController.m
//  MultipeerDemo
//
//  Created by mikewang on 14/10/17.
//  Copyright (c) 2014年 xiyou. All rights reserved.
//

#import "FirstViewController.h"

#import <sys/utsname.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>



@interface FirstViewController () <UITextFieldDelegate,MCNearbyServiceAdvertiserDelegate>
{
    void (^advertiserInvitationHandler)(BOOL accept, MCSession *session);
}

// @property (nonatomic, strong) void (^advertiserInvitationHandler)(BOOL accept, MCSession *session);


@property (nonatomic, strong) MCPeerID *peerID;

@property (nonatomic, strong) MCSession *session;
//一个 session可以对应多个 目标 peerID.

@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;

@property (nonatomic, assign) BOOL advertising;


@property (nonatomic, assign) UIToolbar *barGridFooter;

@property (nonatomic, assign) UIBarButtonItem *barItemTalking;

@property (nonatomic, strong) MCPeerID *remotePeerID;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    self.advertising=YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}








@end
