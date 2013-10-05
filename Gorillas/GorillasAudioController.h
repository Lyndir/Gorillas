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
//  GorillasAudioController.h
//  Gorillas
//
//  Created by Maarten Billemont on 29/03/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface GorillasAudioController : NSObject<AVAudioPlayerDelegate>

- (void)clickEffect;
- (void)playTrack:(NSString *)track;
- (void)startNextTrack;
- (void)playEffectNamed:(NSString *)bundleName;

+ (SystemSoundID)loadEffectWithName:(NSString *)bundleRef;
+ (void)vibrate;
+ (void)playEffect:(SystemSoundID)soundFileObject;
+ (void)disposeEffect:(SystemSoundID)soundFileObject;

+ (GorillasAudioController *)get;

@end
