//
//  KKNearbyPeer.h
//  MultipeerDemo
//
//  Created by mikewang on 14/10/31.
//  Copyright (c) 2014年 xiyou. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface KKNearbyPeer : NSObject

@property (nonatomic, strong) MCPeerID *peerID;

@property (nonatomic, strong) NSString *peerName;

@property (nonatomic, strong) NSDictionary *discoveryInfo;

@property (nonatomic, strong) NSString *accountOwner;

@property (nonatomic, strong) NSString *status;

@property (nonatomic, strong) NSString *source;

@property (nonatomic, strong) NSDate *date;

- (id)initWithPeerID:(MCPeerID*)peerID discoveryInfo:(NSDictionary *)discoveryInfo status:(NSString *)status;

//-(KKNearbyPeer *)equalDisplayNamePeerFrom:(NSMutableArray *)peers;

@end