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

#import "GameConfiguration.h"


@implementation GameConfiguration

@synthesize name, description;
@synthesize mode, sHumans, mHumans, sAis, mAis;


+(id) configurationWithName:(NSString *)_name description:(NSString *)_description
                       mode:(GorillasMode)_mode
                    sHumans:(NSUInteger)_sHumans mHumans:(NSUInteger)_mHumans
                       sAis:(NSUInteger)_sAis mAis:(NSUInteger)_mAis {
    
    return [[[GameConfiguration alloc] initWithName:_name description:_description mode:_mode
                                            sHumans:_sHumans mHumans:_mHumans
                                               sAis:_sAis mAis:_mAis] autorelease];
}


-(id) initWithName:(NSString *)_name description:(NSString *)_description
              mode:(GorillasMode)_mode
           sHumans:(NSUInteger)_sHumans mHumans:(NSUInteger)_mHumans
              sAis:(NSUInteger)_sAis mAis:(NSUInteger)_mAis {

    if(!(self = [super init]))
        return self;
    
    name        = [_name copy];
    description = [_description copy];
    
    mode        = _mode;
    sHumans     = _sHumans;
    mHumans     = _mHumans;
    sAis        = _sAis;
    mAis        = _mAis;
    
    return self;
}


-(void) dealloc {
    
    [name release];
    name = nil;
    
    [description release];
    description = nil;
    
    [super dealloc];
}


@end
