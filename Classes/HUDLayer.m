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
#import "Remove.h"


@implementation HUDLayer


-(id) init {
    
    if(!(self = [super init]))
        return self;

    CGSize winSize = [[Director sharedDirector] winSize];

    width = winSize.width;
    height =[[GorillasConfig get] smallFontSize] + 10;
    position = cpv(0, -height);
    
    menuButton = [[MenuItemAtlasFont itemFromString:@"Menu "
                                        charMapFile:@"bonk.png" itemWidth:13 itemHeight:26 startCharMap:' '
                                             target:self selector:@selector(menuButton:)] retain];

    menuMenu = [[Menu menuWithItems:menuButton, nil] retain];
    [menuMenu setPosition:cpv(width - [menuButton contentSize].width / 2, [menuButton contentSize].height / 2)];
    [menuMenu alignItemsHorizontally];
    [self add:menuMenu];
    
    // Score.
    infoLabel = [[LabelAtlas alloc] initWithString:@""
                                       charMapFile:@"bonk.png" itemWidth:13 itemHeight:26 startCharMap:' '];
    [infoLabel setPosition:cpvzero];
    [self add:infoLabel];
    
    // Lives.
    livesLayer = [[Layer alloc] init];
    [livesLayer setVisible:NO];
    infiniteLives = [Sprite spriteWithFile:@"infinite-shape.png"];
    [infiniteLives setPosition:cpv([infiniteLives contentSize].width / 2, height / 2)];
    [infiniteLives setVisible:NO];
    [self add:livesLayer];
    [livesLayer add:infiniteLives];
    
    return self;
}


-(void) updateHudWithScore:(int)score skill: (float)throwSkill {
    
    int lives = [GorillasAppDelegate get].gameLayer.activeGorilla.lives;
    NSMutableString *infoString = [[NSMutableString alloc] initWithCapacity:20];
    
    // Make sure there are enough life sprites on the livesLayer.
    NSUInteger l = [[livesLayer children] count] - 1;
    while((int)[[livesLayer children] count] - 1 < lives) {
        Sprite *life = [Sprite spriteWithFile:@"gorilla-shape.png"];
        [life setPosition:cpv(l++ * [life contentSize].width + [life contentSize].width / 2, height / 2)];
        
        [livesLayer add:life];
    }
    
    // Toggle the visibility of the lives depending on how many are left.
    for(int l = 1; l < (int)[[livesLayer children] count]; ++l)
        [[[livesLayer children] objectAtIndex:l] setVisible:l - 1 < lives];
    [infiniteLives setVisible:lives < 0];

    // Boot Camp message.
    if ([[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureCheat]) {
        if([infoString length])
            [infoString appendString:@"  "];
        
        [infoString appendString:@"Boot Camp"];
        [infoLabel setRGB:0xff :0xff :0x99];
    }
    
    // Put score on HUD.
    if ([[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureScore]) {
        if([infoString length])
            [infoString appendString:@"  "];
        
        [infoString appendFormat:@"Score:%03d", [[GorillasConfig get] score]];
    }

    // Put skill on HUD.
    if ([[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureSkill]) {
        if([infoString length])
            [infoString appendString:@"  "];
    
        float skill = [[GorillasConfig get] skill];
        if(throwSkill)
            skill = [[GorillasConfig get] skill] / 2 + throwSkill;
        
        [infoString appendFormat:@"Skill:%02d%%", (int) (fminf(0.99f, skill) * 100)];
    }
    
    // Put name and lives on HUD.
    if([GorillasAppDelegate get].gameLayer.activeGorilla.name) {
        if([infoString length])
            [infoString appendString:@"  "];
    
        [infoString appendString:[GorillasAppDelegate get].gameLayer.activeGorilla.name];
    }
    if ([[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureLivesPl]) {
        if([infoString length])
            [infoString appendString:@":"];
        [livesLayer setVisible:YES];
    } else
        [livesLayer setVisible:NO];

    [self setInfoString:infoString];
    [infoString release];

    if(score) {
        long scoreColor;
        if(score > 0)
            scoreColor = 0x99FF99ff;
        else if(score < 0)
            scoreColor = 0xFF9999ff;
        
        [infoLabel do:[Sequence actions:
                       [ShadeTo actionWithDuration:0.5f color:scoreColor],
                       [ShadeTo actionWithDuration:0.5f color:0xFFFFFFff],
                       nil]];
    }
}


-(void) setInfoString: (NSString *)string {
    
    [infoLabel setString:[NSString stringWithFormat:@" %@", string]];
    [livesLayer setPosition:cpv([infoLabel position].x + 13 * ([string length] + 1), [infoLabel position].y)];
}


-(void) onEnter {
    
    [super onEnter];
    
    [self stopAllActions];
    [self do:[MoveTo actionWithDuration:[[GorillasConfig get] transitionDuration] position:cpv(0, 0)]];
    
    [self updateHudWithScore:0 skill:0];
}


-(void) dismiss {
    
    [self stopAllActions];
    [self do:[Sequence actions:
              [MoveTo actionWithDuration:[[GorillasConfig get] transitionDuration] position:cpv(0, -height)],
              [Remove action],
              nil]];
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
    drawBoxFrom(cpvzero, to, 0x000000FF, 0x666666FF);
    drawLinesTo(cpv(0, height), &to, 1, 0x999999FF, 1);
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
