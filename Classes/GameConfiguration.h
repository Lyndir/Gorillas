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



@interface GameConfiguration : NSObject {

@private
    NSString *name;
    NSString *description;
    
    GorillasMode mode;
    NSUInteger sHumans, mHumans, sAis, mAis;
}

+(id) configurationWithName:(NSString *)_name description:(NSString *)_description
                       mode:(GorillasMode)_mode
                    sHumans:(NSUInteger)_sHumans mHumans:(NSUInteger)_mHumans
                       sAis:(NSUInteger)_sAis mAis:(NSUInteger)_mAis;

-(id) initWithName:(NSString *)_name description:(NSString *)_description
              mode:(GorillasMode)_mode
           sHumans:(NSUInteger)_sHumans mHumans:(NSUInteger)_mHumans
              sAis:(NSUInteger)_sAis mAis:(NSUInteger)_mAis;

@property (nonatomic, readonly) NSString       *name;
@property (nonatomic, readonly) NSString       *description;
@property (nonatomic, readonly) GorillasMode   mode;
@property (nonatomic, readonly) NSUInteger     sHumans;
@property (nonatomic, readonly) NSUInteger     mHumans;
@property (nonatomic, readonly) NSUInteger     sAis;
@property (nonatomic, readonly) NSUInteger     mAis;

@end
