/*
 * This file is part of Gorillas.
 *
 *  Gorillas is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 2 of the License, or
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
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "GuideLayer.h"
#import "GorillasConfig.h"
#import "GorillasAppDelegate.h"


@implementation GuideLayer


-(id) init {

    if(!(self = [super init]))
        return self;

    // Guide Content.
    NSUInteger pageCount = 10;
    NSString** pageData = malloc(sizeof(NSString *) * pageCount);
    for(NSUInteger i = 0; i < pageCount; ++i)
        pageData[i] = [NSString stringWithContentsOfFile:
                       [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"page%d", i + 1]
                                                       ofType:@"guide"]];
    
    NSArray *pages = [[NSArray alloc] initWithObjects:pageData count:pageCount];
    free(pageData);
    
    guidePages = [[NSMutableArray alloc] initWithCapacity:[pages count]];
    guideTitles = [[NSMutableArray alloc] initWithCapacity:[pages count]];
    for(NSString *guidePage in pages) {
        NSUInteger firstLineEnd = [guidePage rangeOfString:@"\n"].location;
        
        [guideTitles addObject:[guidePage substringToIndex:firstLineEnd]];
        [guidePages addObject:[guidePage substringFromIndex:firstLineEnd + 1]];
    }
    [pages release];
    
    
    // Controls.
    MenuItem *back  = [MenuItemFont itemFromString:@"<"
                                               target: self
                                             selector: @selector(back:)];
    
    backMenu = [[Menu menuWithItems:back, nil] retain];
    [backMenu setPosition:cpv([[GorillasConfig get] fontSize], [[GorillasConfig get] fontSize])];
    [backMenu alignItemsHorizontally];
    [self add:backMenu];
    
    [MenuItemFont setFontSize:15];
    chapterNext = [[MenuItemFont itemFromString:@"                              " target:self selector:@selector(next:)] retain];
    chapterSkip = [[MenuItemFont itemFromString:@"                              " target:self selector:@selector(skip:)] retain];
    [MenuItemFont setFontSize:26];
    chapterCurr = [[MenuItemFont itemFromString:@"                              "] retain];
    [chapterCurr setIsEnabled:NO];
    chapterMenu = [[Menu menuWithItems:chapterCurr, chapterNext, chapterSkip, nil] retain];
    [chapterMenu alignItemsHorizontally];
    [chapterMenu setPosition:cpv([chapterMenu position].x, contentSize.height - padding + 10)];
    [self add:chapterMenu];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    
    cpVect s = cpv(contentSize.width - padding, contentSize.height - [[GorillasConfig get] fontSize] - padding);
    
    pageLabel = [[Label alloc] initWithString:@""
                             dimensions:CGSizeMake(s.x, s.y)
                              alignment:UITextAlignmentLeft
                               fontName:[[GorillasConfig get] fixedFontName]
                               fontSize:[[GorillasConfig get] smallFontSize]];
    [pageLabel setPosition:cpv(contentSize.width / 2, contentSize.height / 2)];
    
    pageNumberLabel = [[Label alloc] initWithString:[NSString stringWithFormat:@"%d / %d", [guidePages count], [guidePages count]]
                                         dimensions:CGSizeMake(150, [[GorillasConfig get] smallFontSize])
                                          alignment:UITextAlignmentCenter
                                           fontName:[[GorillasConfig get] fontName]
                                           fontSize:[[GorillasConfig get] smallFontSize]];
    [pageNumberLabel setPosition:cpv(contentSize.width - [[GorillasConfig get] smallFontSize] * 3,
                                     padding - [[GorillasConfig get] fontSize] / 2)];
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
    
    [chapterCurr setString:[guideTitles objectAtIndex:page - 0]];
    [chapterNext setString:[guideTitles objectAtIndex:(page + 1) % [guidePages count]]];
    [chapterSkip setString:[guideTitles objectAtIndex:(page + 2) % [guidePages count]]];
}


-(void) back: (id) sender {
    
    [[GorillasAppDelegate get] clickEffect];
    [[GorillasAppDelegate get] showInformation];
}


-(void) next: (id) sender {
    
    [[GorillasAppDelegate get] clickEffect];
    page = (page + 1) % [guidePages count];
    [self flipPage];
}


-(void) skip: (id) sender {
    
    [[GorillasAppDelegate get] clickEffect];
    page = (page + 2) % [guidePages count];
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
    
    [guideTitles release];
    guideTitles = nil;
    
    [guidePages release];
    guidePages = nil;

    [super dealloc];
}


@end
