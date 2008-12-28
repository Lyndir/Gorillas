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
    
    // Top score label.
    Label *topScoreLabel = [[Label alloc] initWithString:[NSString stringWithFormat:@"Top Score: %04d", topScore]
                                              dimensions:CGSizeMake(200, [[GorillasConfig get] fontSize])
                                               alignment:UITextAlignmentCenter
                                                fontName:[[GorillasConfig get] fixedFontName]
                                                fontSize:[[GorillasConfig get] smallFontSize]];
    [topScoreLabel setPosition:cpv(contentSize.width / 2, contentSize.height - padding + [[GorillasConfig get] smallFontSize])];
    [self add:topScoreLabel];
    [topScoreLabel release];
    
    // Iterate over sorted data and add them as Labels.
    int x = padding;
    
    // Formatter for our score dates.
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d"];
    
    int i = 0;
    NSDictionary *history = [[NSDictionary alloc] initWithObjects:scores forKeys:dates];
    NSEnumerator *datesEnumerator = [[[history allKeys] sortedArrayUsingSelector:@selector(compare:)] reverseObjectEnumerator];
    for(NSDate *date in [datesEnumerator allObjects]) {
        
        // Height ratio of score tower.
        //  - Adjust ratio for top and bottom tower padding.
        //  - Adjust ratio to undo theme's max building height.
        int score = [(NSNumber *) [history objectForKey:date] floatValue];
        float scoreRatio = ((float) score / topScore);
        scoreRatio *= ((contentSize.height - padding * 2) / contentSize.height);
        scoreRatio /= [[GorillasConfig get] buildingMax];

        // Score tower.
        BuildingLayer *scoreTower = [[BuildingLayer alloc] initWithWidth:gBarSize heightRatio:scoreRatio];

        // Score label.
        Label *scoreLabel = [[Label alloc] initWithString:[NSString stringWithFormat:@"%d", score]
                                               dimensions:CGSizeMake(gBarSize * 2, [[GorillasConfig get] smallFontSize] / 2)
                                                alignment:UITextAlignmentCenter
                                                 fontName:[[GorillasConfig get] fixedFontName]
                                                 fontSize:[[GorillasConfig get] smallFontSize] / 2];
        [scoreLabel setPosition:cpv([scoreTower contentSize].width / 2,
                                    [scoreTower contentSize].height + [scoreLabel contentSize].height)];
        
        // Score's date label.
        NSString *dateString = [dateFormatter stringFromDate:date];
        Label *dateLabel = [[Label alloc] initWithString:[Utility appendOrdinalPrefixFor:[dateString intValue] to:dateString]
                                              dimensions:CGSizeMake(gBarSize * 2, [[GorillasConfig get] smallFontSize] / 2)
                                               alignment:UITextAlignmentCenter
                                                fontName:[[GorillasConfig get] fixedFontName]
                                                fontSize:[[GorillasConfig get] smallFontSize] / 2];
        [dateLabel setPosition:cpv([scoreTower contentSize].width / 2,
                                   -[dateLabel contentSize].height)];
        
        [scoreTower do:[Sequence actions:
                        [Sequence actionWithDuration:0.1f * i],
                        [MoveTo actionWithDuration:[[GorillasConfig get] transitionDuration] position:cpv(x, padding)],
                        nil]];
        [scoreLabel do:[Sequence actions:
                        [Sequence actionWithDuration:0.1f * i],
                        [FadeIn actionWithDuration:[[GorillasConfig get] transitionDuration]],
                        nil]];
        [dateLabel do:[Sequence actions:
                       [Sequence actionWithDuration:0.1f * i],
                       [FadeIn actionWithDuration:[[GorillasConfig get] transitionDuration]],
                       nil]];

        [scoreTower setPosition:cpv(x, -[scoreTower contentSize].height - [scoreLabel contentSize].height)];
        [scoreTower add:scoreLabel];
        [scoreTower add:dateLabel];
        [self add:scoreTower];
        
        ++i;
        x += [scoreTower contentSize].width + 1;
        [scoreTower release];
        [scoreLabel release];
        [dateLabel release];
        
        if(x >= contentSize.width - padding)
            break;
    }
    
    [dateFormatter release];
    dateFormatter = nil;
}


-(void) gone {
    
}


-(void) back: (id) sender {
    
    [[GorillasAppDelegate get] showInformation];
}


-(void) dealloc {
    
    [super dealloc];
}


@end
