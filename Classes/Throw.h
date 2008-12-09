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
//  Throw.h
//  Gorillas
//
//  Created by Maarten Billemont on 22/11/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"


@interface Throw : IntervalAction {

    @private
    BOOL running;
    cpVect v;
    cpVect r0;
}

+(Throw *) actionWithVelocity: (cpVect)velocity startPos: (cpVect)startPos;
-(Throw *) initWithVelocity: (cpVect)velocity startPos: (cpVect)startPos;

@end
