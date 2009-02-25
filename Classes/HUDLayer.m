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
    
    menuButton = [[MenuItemAtlasFont itemFromString:@"Menu"
                                        charMapFile:@"bonk.png" itemWidth:13 itemHeight:26 startCharMap:' '
                                             target:self selector:@selector(menuButton:)] retain];

    menuMenu = [[Menu menuWithItems:menuButton, nil] retain];
    [menuMenu setPosition:cpv(width - [menuButton contentSize].width, height / 2)];
    [menuMenu alignItemsHorizontally];
    [self add:menuMenu];
    
    // Score.
    infoLabel = [[LabelAtlas alloc] initWithString:@""
                                       charMapFile:@"bonk.png" itemWidth:13 itemHeight:26 startCharMap:' '];
    [infoLabel setPosition:cpvzero];
    [self add:infoLabel];
    
    return self;
}


-(void) updateScore: (int)nScore skill: (float)throwSkill {

    if([[GorillasConfig get] training]) {
        [infoLabel setString:[NSString stringWithFormat:@" Training   | Skill: %02d%%",
                              (int) (fminf(0.99f, [[GorillasConfig get] skill] + throwSkill) * 100)]];
        [infoLabel setRGB:0xff :0xff :0x99];
        
        return;
    }
    
    [infoLabel setString:[NSString stringWithFormat:@" Score: %03d | Skill: %02d%%",
                          [[GorillasConfig get] score],
                          (int) (fminf(0.99f, [[GorillasConfig get] skill] + throwSkill) * 100)]];
    
    if(nScore) {
        long scoreColor = 0xFFFFFFff;
        
        if(nScore > 0)
            scoreColor = 0x66CC66ff;
        else if(nScore < 0)
            scoreColor = 0xCC6666ff;
        
        [infoLabel do:[Sequence actions:
                       [ShadeTo actionWithColor:scoreColor duration:0.5f],
                       [ShadeTo actionWithColor:0xFFFFFFFF duration:0.5f],
                       nil]];
    }
}



-(void) setInfoString: (NSString *)string {
    
    [infoLabel setString:string];
}


-(void) onEnter {

    [super onEnter];
    
    [self stopAllActions];
    [self do:[MoveTo actionWithDuration:[[GorillasConfig get] transitionDuration] position:cpv(0, 0)]];
    
    [infoLabel setVisible:[[[GorillasAppDelegate get] gameLayer] singlePlayer]];
    [self updateScore:0 skill:0];
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
    
    cpVect to = cpv(width, height);
    drawBoxFrom(cpvzero, to, 0x000000FF, 0x000000FF);
    drawLinesTo(cpv(0, height), &to, 1, 0xFFFFFFFF, 1);
}


-(void) dealloc {
    
    [menuButton release];
    menuButton = nil;
    
    [menuMenu release];
    menuMenu = nil;
    
    [infoLabel release];
    infoLabel = nil;
    
    [super dealloc];
}


@end
