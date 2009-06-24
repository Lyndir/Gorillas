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
//  GorillasAudioController.h
//  Gorillas
//
//  Created by Maarten Billemont on 29/03/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>


@interface GorillasAudioController : NSObject <AVAudioPlayerDelegate> {
    
    AVAudioPlayer               *audioPlayer;
    NSString                    *nextTrack;
    
    NSMutableDictionary         *effects;
}

-(void) clickEffect;
-(void) playTrack:(NSString *)track;
-(void) startNextTrack;
- (void)playEffectNamed:(NSString *)bundleName;

+(SystemSoundID) loadEffectWithName:(NSString *)bundleRef;
+(void) vibrate;
+(void) playEffect:(SystemSoundID)soundFileObject;
+(void) disposeEffect:(SystemSoundID)soundFileObject;

+(GorillasAudioController *) get;

@end
