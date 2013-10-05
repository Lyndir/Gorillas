//
//  NetController.h
//  Gorillas
//
//  Created by Maarten Billemont on 13/11/10.
//  Copyright 2010 lhunath (Maarten Billemont). All rights reserved.
//

#import <GameKit/GameKit.h>
#import "NetMessage.h"

@interface NetController : NSObject<GKMatchmakerViewControllerDelegate, GKMatchDelegate>

@property(nonatomic, readonly, strong) GKMatch *match;
@property(nonatomic, readonly, strong) NetMessageElectHost *hostElection;

- (void)beginRequest:(GKMatchRequest *)aMatchRequest;
- (void)beginInvite:(GKInvite *)anInvite;

- (void)endMatchForced:(BOOL)forced;

- (void)sendBecameReady;
- (void)sendThrowWithNormalizedVelocity:(CGPoint)velocity;

@end
