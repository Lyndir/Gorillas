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


@implementation AVConfigurationLayer


-(id) init {
    
    if(!(self = [super initWithDelegate:self logo:nil settings:
                 @selector(music),
                 @selector(soundFx),
                 @selector(voice),
                 @selector(visualFx),
                 @selector(vibrate),
                 nil]))
        return self;
    
    self.layout = MenuLayoutColumns;
    
    return self;
}

-(void) onEnter {
    
    [vibrationI setSelectedIndex:([[GorillasConfig get].vibration boolValue] && [DeviceUtils isIPhone])? 1: 0];
    
    [super onEnter];
}

- (NSString *)labelForSetting:(SEL)setting {

    if (setting == @selector(music))
        return l(@"menu.choose.fx.music");
    if (setting == @selector(soundFx))
        return l(@"menu.choose.fx.sound");
    if (setting == @selector(voice))
        return l(@"menu.choose.fx.voice");
    if (setting == @selector(visualFx))
        return l(@"menu.choose.fx.visual");
    if (setting == @selector(vibrate))
        return l(@"menu.choose.fx.vibration");
    
    return nil;
}

-(void) back: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    [[GorillasAppDelegate get] popLayer];
}


-(void) dealloc {
    
    [super dealloc];
}


@end
