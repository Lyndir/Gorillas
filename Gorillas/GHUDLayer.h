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
//  GHUDLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 10/11/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "PearlCCHUDLayer.h"


@interface GHUDLayer : PearlCCHUDLayer {

@private
    CCLabelAtlas                                        *_skillSprite;
    CCLabelAtlas                                        *_skillCount;
    CCLayer                                             *_livesLayer;
    CCSprite                                            *_infiniteLives;
    float                                               _throwSkill;
}

@property (nonatomic, readonly, retain) CCLabelAtlas    *skillSprite;
@property (nonatomic, readonly, retain) CCLabelAtlas    *skillCount;
@property (nonatomic, readonly, retain) CCLayer         *livesLayer;
@property (nonatomic, readonly, retain) CCSprite        *infiniteLives;
@property (nonatomic, readwrite, assign) float          throwSkill;

@end
