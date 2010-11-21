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
}

@property (nonatomic, assign) NSUInteger            vote;

@property (nonatomic, retain) NSMutableDictionary   *playerVotes;
@property (nonatomic, retain) NetMessageElectHost   *host;
@property (nonatomic, retain) NSString              *hostID;

- (id)initWithPlayers:(NSArray *)aPlayerIDs;

- (void)addVote:(NetMessageElectHost *)aVoteMessage fromPlayer:(NSString *)aPlayerID;
- (void)cleanup;

- (BOOL)isLocalHost;

@end
