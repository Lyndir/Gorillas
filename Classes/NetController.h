//
//  NetController.h
//  Gorillas
//
//  Created by Maarten Billemont on 13/11/10.
//  Copyright 2010 lhunath (Maarten Billemont). All rights reserved.
//

#import <GameKit/GameKit.h>
#import "NetMessage.h"


@interface NetController : NSObject <GKMatchmakerViewControllerDelegate, GKMatchDelegate> {

    GKMatch                                                     *_match;
    NetMessageElectHost                                         *_hostElection;

    BOOL                                                        started;
}

@property (nonatomic, readonly, retain) GKMatch                 *match;
@property (nonatomic, readonly, retain) NetMessageElectHost     *hostElection;

- (void)beginRequest:(GKMatchRequest *)aMatchRequest;
- (void)beginInvite:(GKInvite *)anInvite;

- (void)endMatch;

@end
