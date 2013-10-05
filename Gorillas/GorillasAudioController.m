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
//  GorillasAudioController.m
//  Gorillas
//
//  Created by Maarten Billemont on 29/03/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "GorillasAudioController.h"

@implementation GorillasAudioController {
    AVAudioPlayer *audioPlayer;
    NSString *nextTrack;
    NSMutableDictionary *effects;
}

- (void)clickEffect {

    static SystemSoundID clicky = 0;

    if ([[GorillasConfig get].soundFx boolValue]) {
        if (clicky == 0)
            clicky = [GorillasAudioController loadEffectWithName:@"snapclick.caf"];

        [GorillasAudioController playEffect:clicky];
    }

    else {
        [GorillasAudioController disposeEffect:clicky];
        clicky = 0;
    }
}

- (void)playTrack:(NSString *)track {

    if (![track length])
        track = nil;

    nextTrack = track;
    [self startNextTrack];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)success {

    if (player != audioPlayer)
        return;

    if (nextTrack == nil)
        [[GorillasConfig get] setCurrentTrack:nil];

    [self startNextTrack];
}

- (void)startNextTrack {

    if ([audioPlayer isPlaying]) {
        [audioPlayer stop];
        [self audioPlayerDidFinishPlaying:audioPlayer successfully:NO];
    }
    else if (nextTrack) {
        NSString *track = nextTrack;
        if ([track isEqualToString:@"random"])
            track = [GorillasConfig get].randomTrack;
        NSURL *nextUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:track ofType:nil]];

        if (audioPlayer != nil && ![audioPlayer.url isEqual:nextUrl]) {
            audioPlayer = nil;
        }

        if (audioPlayer == nil)
            audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:nextUrl error:nil];

        [audioPlayer setDelegate:self];
        [audioPlayer play];

        [[GorillasConfig get] setCurrentTrack:nextTrack];
    }
}

- (void)playEffectNamed:(NSString *)bundleName {

    SystemSoundID effect = [(NSNumber *)effects[bundleName] unsignedIntValue];
    if (effect == 0) {
        effect = [GorillasAudioController loadEffectWithName:[NSString stringWithFormat:@"%@.caf", bundleName]];
        if (effect == 0)
            return;

        effects[bundleName] = [NSNumber numberWithUnsignedInt:effect];
    }

    [GorillasAudioController playEffect:effect];
}

+ (void)vibrate {

    AudioServicesPlaySystemSound( kSystemSoundID_Vibrate );
}

+ (void)playEffect:(SystemSoundID)soundFileObject {

    AudioServicesPlaySystemSound( soundFileObject );
}

+ (SystemSoundID)loadEffectWithName:(NSString *)bundleRef {

    // Get the URL to the sound file to play
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    CFURLRef soundFileURLRef = CFBundleCopyResourceURL( mainBundle, (__bridge CFStringRef)bundleRef, NULL, NULL );

    // Create a system sound object representing the sound file
    SystemSoundID soundFileObject;
    AudioServicesCreateSystemSoundID( soundFileURLRef, &soundFileObject );
    CFRelease( soundFileURLRef );

    return soundFileObject;
}

+ (void)disposeEffect:(SystemSoundID)soundFileObject {

    AudioServicesDisposeSystemSoundID( soundFileObject );
}

+ (GorillasAudioController *)get {

    static GorillasAudioController *sharedAudioController = nil;
    if (sharedAudioController == nil)
        sharedAudioController = [[GorillasAudioController alloc] init];

    return sharedAudioController;
}

@end
