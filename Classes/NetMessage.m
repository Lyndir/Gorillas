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
@synthesize vote, playerVotes, host, hostID;

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if (!(self = [self init]))
        return self;
    
    self.vote = [aDecoder decodeIntegerForKey:@"vote"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeInteger:self.vote forKey:@"vote"];
}

- (id)initWithPlayers:(NSArray *)aPlayerIDs {
    
    if (!(self = [super init]))
        return self;
    
    self.vote = arc4random();
    self.playerVotes = [NSMutableDictionary dictionaryWithCapacity:[aPlayerIDs count]];
    for (NSString *playerID in aPlayerIDs)
        [self.playerVotes setObject:[NSNull null] forKey:playerID];

    // We've got a retain cycle while we're sitting in playerVotes.
    [self.playerVotes setObject:self forKey:[GKLocalPlayer localPlayer].playerID];
    
    return self;
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
    self.hostID = [[[self.playerVotes allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:voteCount % [self.playerVotes count]];
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
