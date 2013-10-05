/*
 * This file is part of Gorillas.
 *
 *  Gorillas is open software: you can use or modify it under the
 *  terms of the Java Research License or optionally a more
 *  permissive Commercial License.
 *
 *  Gorillas is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 *  You should have received a copy of the Java Research License
 *  along with Gorillas in the file named 'COPYING'.
 *  If not, see <http://stuff.lhunath.com/COPYING>.
 */

//
//  GameConfiguration.m
//  Gorillas
//
//  Created by Maarten Billemont on 28/02/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

@interface GameConfiguration()

@property(nonatomic, copy, readwrite) NSString *name;
@property(nonatomic, copy, readwrite) NSString *description;
@property(nonatomic, assign, readwrite) GorillasMode mode;
@property(nonatomic, assign, readwrite) NSUInteger singleplayerAICount;
@property(nonatomic, assign, readwrite) NSUInteger multiplayerAICount;
@property(nonatomic, assign, readwrite) NSUInteger multiplayerHumanCount;

@end

@implementation GameConfiguration

+ (GameConfiguration *)configurationWithName:(NSString *)aName description:(NSString *)aDescription mode:(GorillasMode)aMode
                         singleplayerAICount:(NSUInteger)aSingleplayerAICount
                          multiplayerAICount:(NSUInteger)aMultiplayerAICount multiplayerHumanCount:(NSUInteger)aMultiplayerHumanCount {

    return [[GameConfiguration alloc] initWithName:aName description:aDescription mode:aMode
                               singleplayerAICount:aSingleplayerAICount
                                multiplayerAICount:aMultiplayerAICount multiplayerHumanCount:aMultiplayerHumanCount];
}

- (GameConfiguration *)initWithName:(NSString *)aName description:(NSString *)aDescription mode:(GorillasMode)aMode
                singleplayerAICount:(NSUInteger)aSingleplayerAICount
                 multiplayerAICount:(NSUInteger)aMultiplayerAICount multiplayerHumanCount:(NSUInteger)aMultiplayerHumanCount {

    if (!(self = [super init]))
        return self;

    self.name = aName;
    self.description = aDescription;
    self.mode = aMode;
    self.singleplayerAICount = aSingleplayerAICount;
    self.multiplayerAICount = aMultiplayerAICount;
    self.multiplayerHumanCount = aMultiplayerHumanCount;

    return self;
}

@end
