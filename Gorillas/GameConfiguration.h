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
//  GameConfiguration.h
//  Gorillas
//
//  Created by Maarten Billemont on 28/02/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//



@interface GameConfiguration : NSObject

@property(nonatomic, copy, readonly) NSString *name;
@property(nonatomic, copy, readonly) NSString *description;
@property(nonatomic, assign, readonly) GorillasMode mode;
@property(nonatomic, assign, readonly) NSUInteger singleplayerAICount;
@property(nonatomic, assign, readonly) NSUInteger multiplayerAICount;
@property(nonatomic, assign, readonly) NSUInteger multiplayerHumanCount;

+ (GameConfiguration *)configurationWithName:(NSString *)aName description:(NSString *)aDescription mode:(GorillasMode)aMode
                         singleplayerAICount:(NSUInteger)aSingleplayerAICount
                          multiplayerAICount:(NSUInteger)aMultiplayerAICount multiplayerHumanCount:(NSUInteger)aMultiplayerHumanCount;

- (GameConfiguration *)initWithName:(NSString *)aName description:(NSString *)aDescription mode:(GorillasMode)aMode
                singleplayerAICount:(NSUInteger)aSingleplayerAICount
                 multiplayerAICount:(NSUInteger)aMultiplayerAICount multiplayerHumanCount:(NSUInteger)aMultiplayerHumanCount;

@end
