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
//  HUDLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 10/11/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "BarLayer.h"


@interface HUDLayer : BarLayer {

    Sprite              *scoreSprite, *skillSprite;
    LabelAtlas          *scoreCount, *skillCount;
    Layer               *livesLayer;
    Sprite              *infiniteLives;
    BarLayer            *messageBar;
}

-(void) updateHudWithScore:(int)score skill: (float)throwSkill;

-(BOOL) hitsHud: (CGPoint)pos;

@end
