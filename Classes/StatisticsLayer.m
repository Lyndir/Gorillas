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
//  StatisticsLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "StatisticsLayer.h"
#import "GorillasAppDelegate.h"
#import "BuildingsLayer.h"
#define gBarSize 25


@implementation StatisticsLayer


-(id) init {
    
    if(!(self = [super init]))
        return self;
    
    // Back.
    [MenuItemFont setFontSize:[[GorillasConfig get] largeFontSize]];
    MenuItem *back     = [MenuItemFont itemFromString:@"   <   "
                                               target: self
                                             selector: @selector(back:)];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    
    menu = [[Menu menuWithItems:back, nil] retain];
    [menu setPosition:ccp([[GorillasConfig get] fontSize], [[GorillasConfig get] fontSize])];
    [menu alignItemsHorizontally];
    [self addChild:menu];
    
    return self;
}


-(void) onEnter {
    
    [self reset];

    [super onEnter];
}


-(void) reset {
    
    // Get the top scores.
    NSDictionary *topScores = [GorillasConfig get].topScoreHistory;
    NSLog(@"%@", topScores);
    NSMutableArray *dates = [[NSMutableArray alloc] initWithCapacity:[topScores count]];
    NSMutableArray *scores = [[NSMutableArray alloc] initWithCapacity:[topScores count]];
    
    NSString **tDates = malloc(sizeof(NSString *) * [topScores count]);
    NSNumber **tScores = malloc(sizeof(NSNumber *) * [topScores count]);
    [topScores getObjects:tScores andKeys:tDates];
    
    // Convert their keys from NSStrings into NSDates for sorting.
    NSInteger topScore = 0;
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
    Label *topScoreLabel            = [[Label alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"entries.score.top", @"Top Score: %04d"), topScore]
                                                         dimensions:CGSizeMake(200, [[GorillasConfig get] fontSize])
                                                          alignment:UITextAlignmentCenter
                                                           fontName:[GorillasConfig get].fixedFontName
                                                           fontSize:[GorillasConfig get].smallFontSize];
    topScoreLabel.position          = ccp(self.contentSize.width / 2, self.contentSize.height - padding + [GorillasConfig get].smallFontSize);
    [self addChild:topScoreLabel];
    [topScoreLabel release];
    
    
    // Formatter for our score dates.
    NSDateFormatter *dateFormatter  = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d"];
    
    // Prepare for looping.
    NSDictionary *history           = [[NSDictionary alloc] initWithObjects:scores forKeys:dates];
    [dates release];
    [scores release];
    dates                           = nil;
    scores                          = nil;

    free(scorePoints);
    free(scoreColors);
    scoreCount                      = [history count];
    scorePoints                     = malloc(sizeof(CGPoint) * scoreCount);
    scoreColors                     = malloc(sizeof(ccColor4B) * scoreCount);
    
    CGFloat step                    = (self.contentSize.width - padding * 2.0f) / scoreCount;
    CGFloat x                       = padding;
    NSUInteger s                    = 0;
    
    // Iterate the scores in reverse date order (recent to last).
    NSEnumerator *datesEnumerator = [[[history allKeys] sortedArrayUsingSelector:@selector(compare:)] reverseObjectEnumerator];
    for(NSDate *date in [datesEnumerator allObjects]) {
        NSInteger score             = [(NSNumber *) [history objectForKey:date] integerValue];
        
        // Score label.
        Label *scoreLabel           = [[Label alloc] initWithString:[NSString stringWithFormat:@"%d", score]
                                                         dimensions:CGSizeMake(gBarSize * 2, [GorillasConfig get].smallFontSize / 2)
                                                          alignment:UITextAlignmentCenter
                                                           fontName:[GorillasConfig get].fixedFontName
                                                           fontSize:[GorillasConfig get].smallFontSize / 2];
        scoreLabel.position         = ccp(x, padding + [GorillasConfig get].smallFontSize * (s % 2));
        
        // Score's date label.
        NSString *dateString        = [dateFormatter stringFromDate:date];
        Label *dateLabel            = [[Label alloc] initWithString:AppendOrdinalPrefix([dateString intValue], dateString)
                                                         dimensions:CGSizeMake(gBarSize * 2, [GorillasConfig get].smallFontSize / 2)
                                                          alignment:UITextAlignmentCenter
                                                           fontName:[GorillasConfig get].fixedFontName
                                                           fontSize:[GorillasConfig get].smallFontSize / 2];
        dateLabel.position          = ccp(x, padding + scoreLabel.contentSize.height + [GorillasConfig get].smallFontSize * (s % 2));

        // Score graph point.
        float scoreHeight           = ((float) score / topScore);
        float padGraph              = padding + scoreLabel.contentSize.height * 2 + dateLabel.contentSize.height * 2;
        scoreHeight                 *= (contentSize.height - padGraph * 2);
        
        scorePoints[s]              = ccp(x, scoreHeight + padGraph);
        scoreColors[s].r            = (float)0xff * s / (scoreCount - 1);
        scoreColors[s].g            = 0xff - (float)0xff * s / (scoreCount - 1);
        scoreColors[s].b            = 0x99;
        scoreColors[s].a            = 0xff;
        
        // Add labels to the scene.
        [self addChild:dateLabel];
        [self addChild:scoreLabel];
        
        // End iteration.
        ++s;
        x += step;
        [scoreLabel release];
        [dateLabel release];
    }
    
    [dateFormatter release];
    dateFormatter = nil;
    [history release];
    history = nil;
}


- (void)draw {
    
    [super draw];
    
    if (scoreCount > 1)
        DrawLines(scorePoints, scoreColors, scoreCount, 2.0f);
    glPointSize(3.0f);
    DrawPoints(scorePoints, scoreColors, scoreCount);
    glPointSize(1.0f);
}


-(void) dismissAsPush:(BOOL)_pushed {
    
    [super dismissAsPush:_pushed];
}


-(void) back: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    [[GorillasAppDelegate get] popLayer];
}


-(void) dealloc {
    
    [menu release];
    menu = nil;
    
    [super dealloc];
}


@end
