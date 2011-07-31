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
@synthesize vote = _vote, playerVotes = _playerVotes, host = _host, hostID = _hostID, orderedPlayerIDs = _orderedPlayerIDs;

+ (NetMessageElectHost *)electHostWithPlayerIDs:(NSArray *)aPlayerIDs {
    
    return [[[self alloc] initWithPlayerIDs:aPlayerIDs] autorelease];
}

- (id)initWithPlayerIDs:(NSArray *)aPlayerIDs {
    
    if (!(self = [super init]))
        return self;
    
    self.vote = arc4random();
    self.playerVotes = [NSMutableDictionary dictionaryWithCapacity:[aPlayerIDs count]];
    for (NSString *playerID in aPlayerIDs)
        [self.playerVotes setObject:[NSNull null] forKey:playerID];
    
    // We've got a retain cycle while we're sitting in playerVotes.
    [self.playerVotes setObject:self forKey:[GKLocalPlayer localPlayer].playerID];
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
    
    [aCoder encodeInteger:self.vote forKey:@"vote"];
}

- (void)addVote:(NetMessageElectHost *)aVoteMessage fromPlayer:(NSString *)aPlayerID {
    
    [self.playerVotes setObject:aVoteMessage forKey:aPlayerID];
    
    NSUInteger voteCount = 0;
    for (NSString *anotherPlayerID in [self.playerVotes allKeys]) {
        NetMessageElectHost *voteMessage = [self.playerVotes objectForKey:anotherPlayerID];
        if ((id)voteMessage == [NSNull null]) {
            dbg(@"Missing vote from: %@", anotherPlayerID);
            return;
        }
        
        voteCount += voteMessage.vote;
    }
    self.orderedPlayerIDs = [[self.playerVotes allKeys] sortedArrayUsingComparator:^(id a, id b) {
        NSUInteger voteA = [[self.playerVotes objectForKey:a] vote];
        NSUInteger voteB = [[self.playerVotes objectForKey:b] vote];
        if (voteA > voteB)
            return NSOrderedAscending;
        else if (voteA == voteB)
            return NSOrderedSame;
        else
            return NSOrderedDescending;
    }];
    self.hostID = [self.orderedPlayerIDs objectAtIndex:voteCount % [self.playerVotes count]];
    self.host = [self.playerVotes objectForKey:self.hostID];
    
    // Necessary to break the retain cycle.
    [self cleanup];
}

- (void)cleanup {
    
    self.playerVotes = nil;
}

- (BOOL)isLocalHost {
    
    return [self.hostID isEqualToString:[GKLocalPlayer localPlayer].playerID];
}

- (void)dealloc {
    
    self.playerVotes        = nil;
    self.host               = nil;
    self.hostID             = nil;
    self.orderedPlayerIDs   = nil;
    
    [super dealloc];
}

@end

@implementation NetMessageReady

+ (NetMessageReady *)ready {
    
    return [[[self alloc] init] autorelease];
}

@end

@implementation NetMessageBecameReady

+ (NetMessageBecameReady *)ready {
    
    return [[[self alloc] init] autorelease];
}

@end

@implementation NetMessageUpdateReady

+ (NetMessageUpdateReady *)ready {
    
    return [[[self alloc] init] autorelease];
}

@end

@implementation NetMessageThrow
@synthesize normalizedVelocity = _normalizedVelocity;

+ (NetMessageThrow *)throwWithNormalizedVelocity:(CGPoint)aNormalizedVelocity {
    
    return [[[self alloc] initWithNormalizedVelocity:aNormalizedVelocity] autorelease];
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
    
    self.normalizedVelocity = CGPointMake([aDecoder decodeFloatForKey:@"normalizedVelocity.x"],
                                          [aDecoder decodeFloatForKey:@"normalizedVelocity.y"]);
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeFloat:self.normalizedVelocity.x forKey:@"normalizedVelocity.x"];
    [aCoder encodeFloat:self.normalizedVelocity.y forKey:@"normalizedVelocity.y"];
}

- (void)dealloc {
    
    [super dealloc];
}

@end

