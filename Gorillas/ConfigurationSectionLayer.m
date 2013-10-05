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
//  ConfigurationSectionLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 02/01/09.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "ConfigurationSectionLayer.h"
#import "GorillasAppDelegate.h"

@interface ConfigurationSectionLayer()

- (void)game:(id)sender;
- (void)av:(id)sender;
- (void)back:(id)selector;

@end

@implementation ConfigurationSectionLayer

- (id)init {

    if (!(self = [super initWithDelegate:self logo:nil items:
            [CCMenuItemFont itemWithString:PearlLocalize( @"menu.gameplay" )
                                    target:self selector:@selector(game:)],
            [CCMenuItemFont itemWithString:PearlLocalize( @"menu.av" )
                                    target:self selector:@selector(av:)],
            nil]))
        return nil;

    return self;
}

- (void)reset {
}

- (void)onEnter {

    [self reset];

    [super onEnter];
}

- (void)game:(id)sender {

    [[GorillasAppDelegate get] showGameConfiguration];
}

- (void)av:(id)sender {

    [[GorillasAppDelegate get] showAVConfiguration];
}

- (void)back:(id)sender {

    [[GorillasAppDelegate get] popLayer];
}

@end
