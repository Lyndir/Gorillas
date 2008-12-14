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
#define gPadding 50


@implementation GuideLayer


-(id) init {

    if(!(self = [super init]))
        return self;

    // Guide Content.
    guidePages = [[NSArray arrayWithObjects:
                   [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"page1" ofType:@"guide"]],
                   [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"page2" ofType:@"guide"]],
                   [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"page3" ofType:@"guide"]],
                   [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"page4" ofType:@"guide"]],
                   [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"page5" ofType:@"guide"]],
                   [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"page6" ofType:@"guide"]],
                   [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"page7" ofType:@"guide"]],
                   nil] retain];
    
    // Controls.
    MenuItem *next  = [MenuItemFont itemFromString:@"Next"
                                            target:self
                                          selector:@selector(next:)];
    pageItem        = [[MenuItemFont itemFromString:[NSString stringWithFormat:@"%d / %d", [guidePages count], [guidePages count]]
                                            target:self
                                          selector:@selector(next:)] retain];
    MenuItem *back  = [MenuItemFont itemFromString:@"Back"
                                            target:self
                                          selector:@selector(back:)];
    
    menu = [[Menu menuWithItems:back, pageItem, next, nil] retain];
    [menu setPosition:cpv([menu position].x, [[GorillasConfig get] fontSize] / 2)];
    [menu alignItemsHorizontally];

    CGSize winSize = [[Director sharedDirector] winSize].size;
    cpVect s = cpv(winSize.width - gPadding, winSize.height - [[GorillasConfig get] fontSize] - gPadding);
    
    pageLabel = [[Label labelWithString:@"" dimensions:CGSizeMake(s.x, s.y) alignment:UITextAlignmentLeft fontName:[[GorillasConfig get] fontName] fontSize:[[GorillasConfig get] fontSize] * 2 / 3] retain];
    [pageLabel setPosition:cpv(winSize.width / 2, winSize.height / 2)];
    
    return self;
}


-(void) reveal {
    
    [super reveal];
    
    page = 0;
    [self flipPage];
    
    [menu do:[FadeIn actionWithDuration:[[GorillasConfig get] transitionDuration]]];
    [self add:menu];
}


-(void) flipPage {
    
    [[pageItem label] setString:[NSString stringWithFormat:@"%d / %d", page + 1, [guidePages count]]];
    
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
    
    [menu release];
    
    [super dealloc];
}


@end
