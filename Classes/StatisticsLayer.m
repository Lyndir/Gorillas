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
#import "BuildingLayer.h"
#define gBarSize 25


@implementation StatisticsLayer


-(id) init {
    
    if(!(self = [super init]))
        return self;
    
    // Back.
    MenuItem *back     = [MenuItemFont itemFromString:@"<"
                                               target: self
                                             selector: @selector(back:)];
    
    menu = [[Menu menuWithItems:back, nil] retain];
    [menu setPosition:cpv([[GorillasConfig get] fontSize], [[GorillasConfig get] fontSize])];
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

    NSString **tDates = malloc(sizeof(NSString *) * [topScores count]);
    NSNumber **tScores = malloc(sizeof(NSNumber *) * [topScores count]);
    [topScores getObjects:tScores andKeys:tDates];

    // Convert their keys from NSStrings into NSDates for sorting.
    int topScore = 0;
    NSDateFormatter *defaultDateFormatter = [[NSDateFormatter alloc] init];
    [defaultDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
    for(NSUInteger i = 0; i < [topScores count]; ++i) {
        [dates addObject:[defaultDateFormatter dateFromString:tDates[i]]];
        [scores addObject:tScores[i]];
        if(topScore < [tScores[i] intValue])
            topScore = [tScores[i] intValue];
    }
    [defaultDateFormatter release];
    free(tDates);
    free(tScores);
    NSDictionary *history = [[NSDictionary alloc] initWithObjects:scores forKeys:dates];
    
    // Iterate over sorted data and add them as Labels.
    CGSize winSize = [[Director sharedDirector] winSize].size;
    int pad = [[GorillasConfig get] fontSize] * 1.5f;
    int x = pad;
    
    // Formatter for our score dates.
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d"];
    
    stats = [[NSMutableArray alloc] initWithCapacity:[topScores count]];
    NSEnumerator *datesEnumerator = [[[history allKeys] sortedArrayUsingSelector:@selector(compare:)] reverseObjectEnumerator];
    for(NSDate *date in [datesEnumerator allObjects]) {
        int score = [(NSNumber *) [history objectForKey:date] floatValue];
        float scoreRatio = (float) score / topScore;
        
        BuildingLayer *scoreTower = [[BuildingLayer alloc] initWithWidth:gBarSize heightRatio:scoreRatio];
        Label *scoreLabel = [[Label alloc] initWithString:[NSString stringWithFormat:@"%d", score]
                                               dimensions:CGSizeMake(gBarSize * 2, [[GorillasConfig get] smallFontSize] / 2)
                                                alignment:UITextAlignmentCenter
                                                 fontName:[[GorillasConfig get] fixedFontName]
                                                 fontSize:[[GorillasConfig get] smallFontSize] / 2];
        NSString *dateString = [dateFormatter stringFromDate:date];
        Label *dateLabel = [[Label alloc] initWithString:[Utility appendOrdinalPrefixFor:[dateString intValue] to:dateString]
                                               dimensions:CGSizeMake(gBarSize * 2, [[GorillasConfig get] smallFontSize] / 2)
                                                alignment:UITextAlignmentCenter
                                                 fontName:[[GorillasConfig get] fixedFontName]
                                                 fontSize:[[GorillasConfig get] smallFontSize] / 2];
        [scoreTower setPosition:cpv(x, pad + [dateLabel contentSize].height)];
        [scoreLabel setPosition:cpv([scoreTower position].x + [scoreTower contentSize].width / 2,
                                    [scoreTower position].y + [scoreTower contentSize].height + [scoreLabel contentSize].height)];
        [dateLabel setPosition:cpv([scoreTower position].x + [scoreTower contentSize].width / 2,
                                   [scoreTower position].y - [dateLabel contentSize].height)];
        //[stat setRGB:(int) (0xcc * scoreRatio) :(int) (0xcc * (1 - scoreRatio)) :0x00];
        [scoreTower do:[FadeIn actionWithDuration:[[GorillasConfig get] transitionDuration]]];
        [scoreLabel do:[FadeIn actionWithDuration:[[GorillasConfig get] transitionDuration]]];
        [dateLabel do:[FadeIn actionWithDuration:[[GorillasConfig get] transitionDuration]]];

        [stats addObject:scoreTower];
        [self add:scoreTower];
        [self add:scoreLabel];
        [self add:dateLabel];
        
        x += [scoreTower contentSize].width + 1;
        [scoreTower release];
        [scoreLabel release];
        [dateLabel release];
        
        if(x >= winSize.width - pad)
            break;
    }
    
    [dateFormatter release];
    dateFormatter = nil;
}


-(void) gone {
    
    [stats removeAllObjects];
    [stats release];
    stats = nil;
}


-(void) back: (id) sender {
    
    [[GorillasAppDelegate get] showInformation];
}


-(void) dealloc {
    
    [self gone];
    
    [super dealloc];
}


@end
