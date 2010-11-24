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
    NSUInteger                                      vote;

    NSMutableDictionary                             *playerVotes;
    NetMessageElectHost                             *host;
    NSString                                        *hostID;
    NSArray                                         *orderedPlayerIDs;
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

@interface NetMessageThrow : NetMessage
{
    NSString                                        *playerID;
    CGPoint                                         velocity;
}

@property (nonatomic, retain) NSString              *playerID;
@property (nonatomic, assign) CGPoint               velocity;

+ (NetMessageThrow *)throwWithPlayerID:(NSString *)aPlayerID velocity:(CGPoint)aVelocity;

- (id)initWithPlayerID:(NSString *)aPlayerID velocity:(CGPoint)aVelocity;

@end
