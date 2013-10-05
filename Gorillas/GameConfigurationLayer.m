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
//  ConfigurationLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "GameConfigurationLayer.h"
#import "GorillasAppDelegate.h"
#import "CityTheme.h"

@implementation GameConfigurationLayer

- (id)init {

    if (!(self = [super initWithDelegate:self logo:nil settings:
            @selector(gravity),
            @selector(level),
            @selector(replay),
            @selector(followThrow),
            @selector(cityTheme),
            nil]))
        return self;

    self.layout = PearlCCMenuLayoutColumns;

    return self;
}

- (NSString *)labelForSetting:(SEL)setting {

    if (setting == @selector(cityTheme))
        return PearlLocalize( @"menu.choose.theme" );
    if (setting == @selector(gravity))
        return PearlLocalize( @"menu.choose.gravity" );
    if (setting == @selector(level))
        return PearlLocalize( @"menu.choose.level" );
    if (setting == @selector(replay))
        return PearlLocalize( @"menu.choose.replays" );
    if (setting == @selector(followThrow))
        return PearlLocalize( @"menu.choose.follow" );

    return nil;
}

- (NSArray *)toggleItemsForSetting:(SEL)setting {

    if (setting == @selector(cityTheme))
        return [CityTheme getThemeNames];
    if (setting == @selector(gravity))
        return NumbersRanging( [[GorillasConfig get].minGravity doubleValue], [[GorillasConfig get].maxGravity doubleValue], 10,
                NSNumberFormatterDecimalStyle );
    if (setting == @selector(level))
        return [GorillasConfig get].levelNames;

    return nil;
}

- (NSUInteger)indexForSetting:(SEL)setting value:(id)value {

    dbg(@"Setting %@ is now %@.", NSStringFromSelector( setting ), value);
    if (setting == @selector(cityTheme))
        return [[CityTheme getThemeNames] indexOfObject:value];
    if (setting == @selector(gravity))
        return (NSUInteger)(([value doubleValue] - [[GorillasConfig get].minGravity doubleValue]) / 10);
    if (setting == @selector(level))
        return [[GorillasConfig get].levelNames indexOfObject:[GorillasConfig nameForLevel:value]];

    return NSUIntegerMax;
}

- (id)valueForSetting:(SEL)setting index:(NSUInteger)index {

    if (setting == @selector(cityTheme))
        return [CityTheme getThemeNames][index];
    if (setting == @selector(gravity))
        return @([[GorillasConfig get].minGravity doubleValue] + 10 * index);
    if (setting == @selector(level))
        return @(fminf( 0.9f, fmaxf( 0.1f, (float)index / [[GorillasConfig get].levelNames count] ) ));

    return nil;
}

- (void)back:(id)sender {

    [[GorillasAppDelegate get] popLayer];
}

@end
