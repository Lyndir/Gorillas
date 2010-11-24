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
    
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Implement Me" userInfo:nil];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Implement Me" userInfo:nil];
}

@end

@implementation NetMessageElectHost
@synthesize vote, playerVotes, host, hostID, orderedPlayerIDs;

+ (NetMessageElectHost *)electHostWithPlayerIDs:(NSArray *)aPlayerIDs {
    
    return [[self alloc] initWithPlayerIDs:aPlayerIDs];
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

@end

@implementation NetMessageThrow
@synthesize playerID, velocity;

+ (NetMessageThrow *)throwWithPlayerID:(NSString *)aPlayerID velocity:(CGPoint)aVelocity {
    
    return [[[self alloc] initWithPlayerID:aPlayerID velocity:aVelocity] autorelease];
}

- (id)initWithPlayerID:(NSString *)aPlayerID velocity:(CGPoint)aVelocity {
    
    if (!(self = [super init]))
        return self;
    
    self.playerID = aPlayerID;
    self.velocity = aVelocity;
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if (!(self = [self init]))
        return self;
    
    self.playerID = [aDecoder decodeObjectForKey:@"playerID"];
    self.velocity = CGPointMake([aDecoder decodeFloatForKey:@"velocity.x"], [aDecoder decodeFloatForKey:@"velocity.y"]);
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.playerID forKey:@"playerID"];
    [aCoder encodeFloat:self.velocity.x forKey:@"velocity.x"];
    [aCoder encodeFloat:self.velocity.y forKey:@"velocity.y"];
}

@end

