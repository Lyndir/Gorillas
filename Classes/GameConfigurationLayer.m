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
#import "StringUtils.h"


@interface GameConfigurationLayer ()

- (void)cityTheme:(id)sender;
- (void)gravity:(id)sender;
- (void)level:(id)sender;
- (void)replay:(id)sender;
- (void)followThrow:(id)sender;
- (void)back:(id)selector;

@end



@implementation GameConfigurationLayer


-(id) init {
    
    if (!(self = [super initWithDelegate:self logo:nil settings:
                  @selector(cityTheme),
                  @selector(gravity),
                  @selector(level),
                  @selector(replay),
                  @selector(followThrow),
                  nil]))
        return self;
    
    self.layout = MenuLayoutColumns;
    
    return self;
}


-(void) reset {
    
    NSUInteger theme = 0;
    NSArray *cityThemes = [[CityTheme getThemes] allKeys];
    if ([cityThemes containsObject:[GorillasConfig get].cityTheme])
        theme = [cityThemes indexOfObject:[GorillasConfig get].cityTheme];
    [themeI setSelectedIndex:theme];
    gravityI.label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", [[GorillasConfig get].gravity unsignedIntValue]]
                                        fontName:[GorillasConfig get].fontName fontSize:[[GorillasConfig get].fontSize intValue]];
    [levelI setSelectedIndex:[[GorillasConfig get].levelNames indexOfObject:[GorillasConfig get].levelName]];
    [replayI setSelectedIndex:[[GorillasConfig get].replay boolValue]? 1: 0];
    [followI setSelectedIndex:[[GorillasConfig get].followThrow boolValue]? 1: 0];
    
    themeI.isEnabled = ![[GorillasAppDelegate get].gameLayer checkGameStillOn];
}


-(void) onEnter {
    
    [self reset];
    
    [super onEnter];
}

- (NSString *)labelForSetting:(SEL)setting {
    
    if (setting == @selector(cityTheme))
        return l(@"entries.choose.theme");
    if (setting == @selector(gravity))
        return l(@"entries.choose.gravity");
    if (setting == @selector(level))
        return l(@"entries.choose.level");
    if (setting == @selector(replay))
        return l(@"entries.choose.replays");
    if (setting == @selector(followThrow))
        return l(@"entries.choose.follow");
    
    return nil;
}

- (NSArray *)toggleItemsForSetting:(SEL)setting {
    
    if (setting == @selector(cityTheme))
        return [[CityTheme getThemes] allKeys];
    if (setting == @selector(gravity))
        return NumbersRanging([[GorillasConfig get].minGravity doubleValue], [[GorillasConfig get].maxGravity doubleValue], 10,
                              NSNumberFormatterDecimalStyle);
    if (setting == @selector(level))
        return [GorillasConfig get].levelNames;
    
    return nil;
}

- (NSUInteger)indexForSetting:(SEL)setting value:(id)value {
    
    dbg(@"setting %s is now %@", setting, value);
    if (setting == @selector(cityTheme))
        return [[[CityTheme getThemes] allKeys] indexOfObject:value];
    if (setting == @selector(gravity))
        return (NSUInteger) (([value doubleValue] - [[GorillasConfig get].minGravity doubleValue]) / 10);
    
    return [value unsignedIntValue];
}

-(void) level: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    
    NSUInteger curLevelInd = [[GorillasConfig get].levelNames indexOfObject:[GorillasConfig get].levelName];
    float newLevel = (float)((curLevelInd + 1) % [[GorillasConfig get].levelNames count]) / [[GorillasConfig get].levelNames count];
    [GorillasConfig get].level = [NSNumber numberWithFloat:fminf(0.9f, fmaxf(0.1f, newLevel))];
}


-(void) gravity: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    NSUInteger minGravity = [[GorillasConfig get].minGravity unsignedIntValue];
    NSUInteger maxGravity = [[GorillasConfig get].maxGravity unsignedIntValue];
    NSUInteger newGravity = [[GorillasConfig get].gravity unsignedIntValue] + 10;
    if (newGravity > maxGravity || newGravity < minGravity)
        newGravity = minGravity;
    
    [GorillasConfig get].gravity = [NSNumber numberWithUnsignedInt:newGravity];
}


-(void) cityTheme: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    
    NSArray *themes = [[CityTheme getThemes] allKeys];
    NSString *newTheme = [themes objectAtIndex:0];
    
    BOOL found = NO;
    for(NSString *theme in themes) {
        if(found) {
            newTheme = theme;
            break;
        }
        
        if([[GorillasConfig get].cityTheme isEqualToString:theme])
            found = YES;
    }
    
    [[[CityTheme getThemes] objectForKey:newTheme] apply];
    [GorillasConfig get].cityTheme = newTheme;
    
    [[GorillasAppDelegate get].gameLayer reset];
}


-(void) replay: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    [GorillasConfig get].replay = [NSNumber numberWithBool:![[GorillasConfig get].replay boolValue]];
}


-(void) followThrow: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    [GorillasConfig get].followThrow = [NSNumber numberWithBool:![[GorillasConfig get].followThrow boolValue]];
}


-(void) back: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    [[GorillasAppDelegate get] popLayer];
}


-(void) dealloc {
    
    [super dealloc];
}


@end
