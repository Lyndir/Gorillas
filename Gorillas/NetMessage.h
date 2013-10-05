//
//  NetMessage.h
//  Gorillas
//
//  Created by Maarten Billemont on 12/11/10.
//  Copyright 2010 lhunath (Maarten Billemont). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetMessage : NSObject<NSCoding>

@end

@interface NetMessageElectHost : NetMessage

@property(nonatomic, assign) NSUInteger vote;

@property(nonatomic, strong) NSMutableDictionary *playerVotes;
@property(nonatomic, strong) NetMessageElectHost *host;
@property(nonatomic, strong) NSString *hostID;
@property(nonatomic, strong) NSArray *orderedPlayerIDs;

+ (NetMessageElectHost *)electHostWithPlayerIDs:(NSArray *)aPlayerIDs;

- (id)initWithPlayerIDs:(NSArray *)aPlayerIDs;

- (void)addVote:(NetMessageElectHost *)aVoteMessage fromPlayer:(NSString *)aPlayerID;
- (void)cleanup;

- (BOOL)isLocalHost;

@end

@interface NetMessageReady : NetMessage

+ (NetMessageReady *)ready;

@end

@interface NetMessageBecameReady : NetMessageReady

+ (NetMessageBecameReady *)ready;

@end

@interface NetMessageUpdateReady : NetMessageReady

+ (NetMessageUpdateReady *)ready;

@end

@interface NetMessageThrow : NetMessage

@property(nonatomic, assign) CGPoint normalizedVelocity;

+ (NetMessageThrow *)throwWithNormalizedVelocity:(CGPoint)aNormalizedVelocity;

- (id)initWithNormalizedVelocity:(CGPoint)aNormalizedVelocity;

@end
