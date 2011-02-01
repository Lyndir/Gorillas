//
//  NetMessage.h
//  Gorillas
//
//  Created by Maarten Billemont on 12/11/10.
//  Copyright 2010 lhunath (Maarten Billemont). All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NetMessage : NSObject <NSCoding> {

}

@end

@interface NetMessageElectHost : NetMessage
{
    NSUInteger                                      _vote;

    NSMutableDictionary                             *_playerVotes;
    NetMessageElectHost                             *_host;
    NSString                                        *_hostID;
    NSArray                                         *_orderedPlayerIDs;
}

@property (nonatomic, assign) NSUInteger            vote;

@property (nonatomic, retain) NSMutableDictionary   *playerVotes;
@property (nonatomic, retain) NetMessageElectHost   *host;
@property (nonatomic, retain) NSString              *hostID;
@property (nonatomic, retain) NSArray               *orderedPlayerIDs;

+ (NetMessageElectHost *)electHostWithPlayerIDs:(NSArray *)aPlayerIDs;

- (id)initWithPlayerIDs:(NSArray *)aPlayerIDs;

- (void)addVote:(NetMessageElectHost *)aVoteMessage fromPlayer:(NSString *)aPlayerID;
- (void)cleanup;

- (BOOL)isLocalHost;

@end

@interface NetMessageReady : NetMessage
{
}

+ (NetMessageReady *)ready;

@end

@interface NetMessageBecameReady : NetMessageReady
{
}

+ (NetMessageBecameReady *)ready;

@end

@interface NetMessageUpdateReady : NetMessageReady
{
}

+ (NetMessageUpdateReady *)ready;

@end

@interface NetMessageThrow : NetMessage
{
    CGPoint                                         _normalizedVelocity;
}

@property (nonatomic, assign) CGPoint               normalizedVelocity;

+ (NetMessageThrow *)throwWithNormalizedVelocity:(CGPoint)aNormalizedVelocity;

- (id)initWithNormalizedVelocity:(CGPoint)aNormalizedVelocity;

@end
