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
//  HUDLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 10/11/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "HUDLayer.h"
#import "GorillasAppDelegate.h"
#import "GorillasConfig.h"
#import "Utility.h"
#import "ShadeTo.h"


@implementation HUDLayer


-(id) init {
    
    if(!(self = [super init]))
        return self;

    CGSize winSize = [[Director sharedDirector] winSize];

    width = winSize.width;
    height =[[GorillasConfig get] smallFontSize] + 10;
    position = cpv(0, -height);
    
    [MenuItemFont setFontSize:[[GorillasConfig get] smallFontSize]];
    menuButton = [[MenuItemFont itemFromString:@"                              "
                                        target:self
                                      selector:@selector(menuButton:)] retain];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];

    menuMenu = [[Menu menuWithItems:menuButton, nil] retain];
    [menuMenu setPosition:cpv([menuMenu position].x, (height - 5) / 2)];
    [menuMenu alignItemsHorizontally];
    [self add:menuMenu];
    
    // Score.
    scoreLabel = [[Label alloc] initWithString:[NSString stringWithFormat:@"%04d", [[GorillasConfig get] score]]
                                    dimensions:CGSizeMake(80, [[GorillasConfig get] smallFontSize])
                                     alignment:UITextAlignmentRight
                                      fontName:[[GorillasConfig get] fixedFontName]
                                      fontSize:[[GorillasConfig get] smallFontSize]];
    [scoreLabel setPosition:cpv(winSize.width - [scoreLabel contentSize].width * 2 / 3, height / 2)];
    [self add:scoreLabel];
    
    return self;
}


-(void) updateScore: (int)nScore {
    
    long scoreColor = 0xFFFFFFff;
    
    if(nScore > 0)
        scoreColor = 0x66CC66ff;
    else if(nScore < 0)
        scoreColor = 0xCC6666ff;

    [scoreLabel setString:[NSString stringWithFormat:@"%04d", [[GorillasConfig get] score]]];
    [scoreLabel do:[Spawn actions:
                    [Sequence actions:
                     [ShadeTo actionWithColor:scoreColor duration:0.5f],
                     [ShadeTo actionWithColor:0xFFFFFFFF duration:0.5f],
                     nil],
                    [Sequence actions:
                     [ScaleTo actionWithDuration:0.5f scale:1.2f],
                     [ScaleTo actionWithDuration:0.5f scale:1],
                     nil],
                    nil]];
}



-(void) setMenuTitle: (NSString *)title {
    
    [menuButton setString:title];
}


-(void) onEnter {

    [super onEnter];
    
    [self stopAllActions];
    [self do:[MoveTo actionWithDuration:[[GorillasConfig get] transitionDuration] position:cpv(0, 0)]];
    [scoreLabel setVisible:[[[GorillasAppDelegate get] gameLayer] singlePlayer]];
}


-(void) dismiss {
    
    [self stopAllActions];
    [self do:[Sequence actions:
              [MoveTo actionWithDuration:[[GorillasConfig get] transitionDuration] position:cpv(0, -height)],
              [CallFunc actionWithTarget:self selector:@selector(gone)],
              nil]];
}


-(void) gone {
    
    [parent removeAndStop:self];
}


-(void) menuButton: (id) caller {
    
    [[GorillasAppDelegate get] clickEffect];
    [[GorillasAppDelegate get] showMainMenu];
}


-(BOOL) hitsHud: (cpVect)pos {
    
    return  pos.x >= position.x         &&
            pos.y >= position.y         &&
            pos.x <= position.x + width &&
            pos.y <= position.y + height;
}


-(void) draw {
    
    drawBoxFrom(cpvzero, cpv(width, height), [[GorillasConfig get] shadeColor], [[GorillasConfig get] shadeColor]);
}


-(void) dealloc {
    
    [menuButton release];
    menuButton = nil;
    
    [menuMenu release];
    menuMenu = nil;
    
    [scoreLabel release];
    scoreLabel = nil;
    
    [super dealloc];
}


@end
