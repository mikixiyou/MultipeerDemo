//
//  KKNearbyPeer.m
//  MultipeerDemo
//
//  Created by mikewang on 14/10/31.
//  Copyright (c) 2014年 xiyou. All rights reserved.
//

#import "KKNearbyPeer.h"

@implementation KKNearbyPeer

- (id)initWithPeerID:(MCPeerID*)peerID discoveryInfo:(NSDictionary *)discoveryInfo status:(NSString *)status
{
    if (self = [super init]) {
        
        self.peerID=peerID;
        self.peerName=peerID.displayName;
        self.discoveryInfo=discoveryInfo;
        self.accountOwner=[discoveryInfo objectForKey:@"accountOwner"];
        
        self.status=status;
        self.date=[NSDate date];
        
    }
    
    return self;
}

-(KKNearbyPeer *)equalDisplayNamePeerFrom:(NSMutableArray *)peers
{

    KKNearbyPeer *sameNamePeer;
    
    for (KKNearbyPeer *peer in peers) {
        
        NSString *tempName=peer.peerName;
        
        if ([self.peerName isEqualToString:tempName]) {
            sameNamePeer=peer;
            break;
        }
    }
    
    return sameNamePeer;
}


@end
