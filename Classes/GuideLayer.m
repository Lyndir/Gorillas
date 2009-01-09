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
//  GuideLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008, lhunath (Maarten Billemont). All rights reserved.
//

#import "GuideLayer.h"
#import "GorillasConfig.h"
#import "GorillasAppDelegate.h"


@implementation GuideLayer


-(id) init {

    if(!(self = [super init]))
        return self;

    // Guide Content.
    guidePages = [[NSArray alloc] initWithObjects:
                   [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"page1" ofType:@"guide"]],
                   [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"page2" ofType:@"guide"]],
                   [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"page3" ofType:@"guide"]],
                   [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"page4" ofType:@"guide"]],
                   [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"page5" ofType:@"guide"]],
                   [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"page6" ofType:@"guide"]],
                   [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"page7" ofType:@"guide"]],
                   [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"page8" ofType:@"guide"]],
                   [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"page9" ofType:@"guide"]],
                   nil];
    
    
    // Controls.
    MenuItem *next  = [MenuItemFont itemFromString:@">"
                                            target:self
                                          selector:@selector(next:)];
    MenuItem *back  = [MenuItemFont itemFromString:@"<"
                                               target: self
                                             selector: @selector(back:)];
    
    CGSize winSize = [[Director sharedDirector] winSize].size;
    nextMenu = [[Menu menuWithItems:next, nil] retain];
    [nextMenu setPosition:cpv(winSize.width - [[GorillasConfig get] fontSize], [[GorillasConfig get] fontSize])];
    [nextMenu alignItemsHorizontally];
    [self add:nextMenu];

    backMenu = [[Menu menuWithItems:back, nil] retain];
    [backMenu setPosition:cpv([[GorillasConfig get] fontSize], [[GorillasConfig get] fontSize])];
    [backMenu alignItemsHorizontally];
    [self add:backMenu];

    cpVect s = cpv(winSize.width - padding, winSize.height - [[GorillasConfig get] fontSize] - padding);
    
    pageLabel = [[Label alloc] initWithString:@""
                             dimensions:CGSizeMake(s.x, s.y)
                              alignment:UITextAlignmentLeft
                               fontName:[[GorillasConfig get] fixedFontName]
                               fontSize:[[GorillasConfig get] smallFontSize]];
    [pageLabel setPosition:cpv(winSize.width / 2, winSize.height / 2)];
    
    pageNumberLabel = [[Label alloc] initWithString:[NSString stringWithFormat:@"%d / %d", [guidePages count], [guidePages count]]
                                         dimensions:CGSizeMake(100, [[GorillasConfig get] fontSize])
                                          alignment:UITextAlignmentCenter
                                           fontName:[[GorillasConfig get] fontName]
                                           fontSize:[[GorillasConfig get] fontSize]];
    [pageNumberLabel setPosition:cpv(winSize.width / 2, padding - [[GorillasConfig get] fontSize] / 2)];
    [self add:pageNumberLabel];
    
    return self;
}


-(void) onEnter {
    
    [super onEnter];
    
    page = 0;
    [self flipPage];
    
}


-(void) flipPage {
    
    [pageNumberLabel setString:[NSString stringWithFormat:@"%d / %d", page + 1, [guidePages count]]];
    
    if([pageLabel parent] == nil) {
        [pageLabel setString:[guidePages objectAtIndex:page]];
        [pageLabel do:[FadeIn actionWithDuration:[[GorillasConfig get] transitionDuration]]];
        [self add:pageLabel];
    }
    
    else {
        [pageLabel do:[FadeOut actionWithDuration:[[GorillasConfig get] transitionDuration]]];
        [pageLabel setString:[guidePages objectAtIndex:page]];
        [pageLabel do:[FadeIn actionWithDuration:[[GorillasConfig get] transitionDuration]]];
    }
}


-(void) next: (id) sender {
    
    page = (page + 1) % [guidePages count];
    [self flipPage];
}


-(void) back: (id) sender {
    
    page--;
    
    if(page < 0)
        [[GorillasAppDelegate get] showInformation];
    
    else
        [self flipPage];
}


-(void) dealloc {
    
    [backMenu release];
    backMenu = nil;
    
    [nextMenu release];
    nextMenu = nil;
    
    [pageLabel release];
    pageLabel = nil;
    
    [pageNumberLabel release];
    pageNumberLabel = nil;
    
    [guidePages release];
    guidePages = nil;

    [super dealloc];
}


@end
