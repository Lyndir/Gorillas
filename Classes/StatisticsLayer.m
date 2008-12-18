/*
 * This file is part of Gorillas.
 *
 *  Gorillas is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Gorillas is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Gorillas in the file named 'COPYING'.
 *  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  StatisticsLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008, lhunath (Maarten Billemont). All rights reserved.
//

#import "StatisticsLayer.h"
#import "GorillasAppDelegate.h"
#import "Utility.h"
#define gBarSize 10


@implementation StatisticsLayer


-(id) init {
    
    if(!(self = [super init]))
        return self;
    
    MenuItem *back  = [MenuItemFont itemFromString:@"Back"
                                            target:self
                                          selector:@selector(back:)];
    
    menu = [[Menu menuWithItems:back, nil] retain];
    [menu setPosition:cpv([menu position].x, [[GorillasConfig get] fontSize] / 2)];
    [menu alignItemsHorizontally];

    return self;
}


-(void) reveal {
    
    [super reveal];
    
    [menu do:[FadeIn actionWithDuration:[[GorillasConfig get] transitionDuration]]];
    [self add:menu];
    
    // Get the top scores.
    NSDictionary *topScores = [[GorillasConfig get] topScoreHistory];
    NSMutableArray *dates = [NSMutableArray arrayWithCapacity:[topScores count]];
    NSMutableArray *scores = [NSMutableArray arrayWithCapacity:[topScores count]];

    NSLog(@"%d", [topScores count]);
    NSString *tDates[[topScores count]];
    NSNumber *tScores[[topScores count]];
    [topScores getObjects:tScores andKeys:tDates];

    // Convert their keys from NSStrings into NSDates.
    topScore = 0;
    for(int i = 0; i < [topScores count]; ++i) {
        [dates addObject:[NSDate dateWithString:tDates[i]]];
        [scores addObject:tScores[i]];
        if(topScore < [tScores[i] intValue])
            topScore = [tScores[i] intValue];
    }
    history = [[NSDictionary alloc] initWithObjects:scores forKeys:dates];
}


-(void) gone {
    
    [history release];
    history = nil;
}


-(void) draw {
    
    [super draw];
    
    int padding = [[GorillasConfig get] fontSize] * 1.5;
    
    CGSize winSize = [[Director sharedDirector] winSize].size;
    int y = winSize.height - padding;
    
    for(NSDate *date in [[history allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
        int score = [(NSNumber *) [history objectForKey:date] floatValue];
        float scoreRatio = (float) score / topScore;
        long c  = (int) (0xcc * scoreRatio)         << 24
                | (int) (0xcc * (1 - scoreRatio))   << 16
                | 0x00                              << 8
                | [self opacity]                    << 0;
        long bc = (int) (0xff * scoreRatio)         << 24
                | (int) (0xff * (1 - scoreRatio))   << 16
                | 0x33                              << 8
                | [self opacity]                    << 0;
        
        [Utility drawBoxFrom:cpv(padding, y) size:cpv((winSize.width - padding * 2) * scoreRatio, -gBarSize) color:c];
        [Utility drawBorderFrom:cpv(padding, y) size:cpv((winSize.width - padding * 2) * scoreRatio, -gBarSize) color:bc width:1];
        
        y -= gBarSize * 1.5;
    }
}


-(void) back: (id) sender {
    
    [[GorillasAppDelegate get] showInformation];
}


-(void) dealloc {
    
    [history release];
    history = nil;
    
    [super dealloc];
}


@end
