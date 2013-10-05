//
//  NetMessage.m
//  Gorillas
//
//  Created by Maarten Billemont on 12/11/10.
//  Copyright 2010 lhunath (Maarten Billemont). All rights reserved.
//

#import "NetMessage.h"
#import <GameKit/GameKit.h>

@implementation NetMessage

- (id)initWithCoder:(NSCoder *)aDecoder {

    if (!(self = [self init]))
        return self;

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
}

@end

@implementation NetMessageElectHost

+ (NetMessageElectHost *)electHostWithPlayerIDs:(NSArray *)aPlayerIDs {

    return [[self alloc] initWithPlayerIDs:aPlayerIDs];
}

- (id)initWithPlayerIDs:(NSArray *)aPlayerIDs {

    if (!(self = [super init]))
        return self;

    self.vote = arc4random();
    self.playerVotes = [NSMutableDictionary dictionaryWithCapacity:[aPlayerIDs count]];
    for (NSString *playerID in aPlayerIDs)
        (self.playerVotes)[playerID] = [NSNull null];

    // We've got a retain cycle while we're sitting in playerVotes.
    (self.playerVotes)[[GKLocalPlayer localPlayer].playerID] = self;
    dbg(@"init playerVotes: %@, from: %@", self.playerVotes, aPlayerIDs);

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {

    if (!(self = [self init]))
        return self;

    self.vote = [aDecoder decodeIntegerForKey:@"vote"];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {

    [aCoder encodeInteger:(signed)self.vote forKey:@"vote"];
}

- (void)addVote:(NetMessageElectHost *)aVoteMessage fromPlayer:(NSString *)aPlayerID {

    (self.playerVotes)[aPlayerID] = aVoteMessage;

    NSUInteger voteCount = 0;
    for (NSString *anotherPlayerID in [self.playerVotes allKeys]) {
        NetMessageElectHost *voteMessage = (self.playerVotes)[anotherPlayerID];
        if ((id)voteMessage == [NSNull null]) {
            dbg(@"Missing vote from: %@", anotherPlayerID);
            return;
        }

        voteCount += voteMessage.vote;
    }
    self.orderedPlayerIDs = [[self.playerVotes allKeys] sortedArrayUsingComparator:^(id a, id b) {
        NSUInteger voteA = [(self.playerVotes)[a] vote];
        NSUInteger voteB = [(self.playerVotes)[b] vote];
        if (voteA > voteB)
            return NSOrderedAscending;
        else if (voteA == voteB)
            return NSOrderedSame;
        else
            return NSOrderedDescending;
    }];
    self.hostID = (self.orderedPlayerIDs)[voteCount % [self.playerVotes count]];
    self.host = (self.playerVotes)[self.hostID];

    // Necessary to break the retain cycle.
    [self cleanup];
}

- (void)cleanup {

    self.playerVotes = nil;
}

- (BOOL)isLocalHost {

    return [self.hostID isEqualToString:[GKLocalPlayer localPlayer].playerID];
}

@end

@implementation NetMessageReady

+ (NetMessageReady *)ready {

    return [[self alloc] init];
}

@end

@implementation NetMessageBecameReady

+ (NetMessageBecameReady *)ready {

    return [[self alloc] init];
}

@end

@implementation NetMessageUpdateReady

+ (NetMessageUpdateReady *)ready {

    return [[self alloc] init];
}

@end

@implementation NetMessageThrow

+ (NetMessageThrow *)throwWithNormalizedVelocity:(CGPoint)aNormalizedVelocity {

    return [[self alloc] initWithNormalizedVelocity:aNormalizedVelocity];
}

- (id)initWithNormalizedVelocity:(CGPoint)aNormalizedVelocity {

    if (!(self = [super init]))
        return self;

    self.normalizedVelocity = aNormalizedVelocity;

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {

    if (!(self = [self init]))
        return self;

    self.normalizedVelocity = CGPointMake( [aDecoder decodeFloatForKey:@"normalizedVelocity.x"],
            [aDecoder decodeFloatForKey:@"normalizedVelocity.y"] );

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {

    [aCoder encodeFloat:self.normalizedVelocity.x forKey:@"normalizedVelocity.x"];
    [aCoder encodeFloat:self.normalizedVelocity.y forKey:@"normalizedVelocity.y"];
}

@end

