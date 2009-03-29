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
//  GorillasAudioController.m
//  Gorillas
//
//  Created by Maarten Billemont on 29/03/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "GorillasAudioController.h"

@implementation GorillasAudioController


-(void) clickEffect {
    
    static SystemSoundID clicky = 0;
    
    if([[GorillasConfig get] soundFx]) {
        if(clicky == 0)
            clicky = [GorillasAudioController loadEffectWithName:@"click.wav"];
        
        [GorillasAudioController playEffect:clicky];
    }
    
    else {
        [GorillasAudioController disposeEffect:clicky];
        clicky = 0;
    }
}


-(void) playTrack:(NSString *)track {
    
    if(![track length])
        track = nil;
    
    nextTrack = track;
    [self startNextTrack];
}


-(void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)success {
    
    if(player != audioPlayer)
        return;
    
    if(nextTrack == nil)
        [[GorillasConfig get] setCurrentTrack:nil];
    
    [self startNextTrack];
}

-(void) startNextTrack {
    
    if([audioPlayer isPlaying]) {
        [audioPlayer stop];
        [self audioPlayerDidFinishPlaying:audioPlayer successfully:NO];
    } else if(nextTrack) {
        NSString *track = nextTrack;
        if([track isEqualToString:@"random"])
            track = [GorillasConfig get].randomTrack;
        NSURL *nextUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:track ofType:nil]];
        
        if(audioPlayer != nil && ![audioPlayer.url isEqual:nextUrl]) {
            [audioPlayer release];
            audioPlayer = nil;
        }
        
        if(audioPlayer == nil)
            audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:nextUrl error:nil];
        
        [audioPlayer setDelegate:self];
        [audioPlayer play];
        
        [[GorillasConfig get] setCurrentTrack:nextTrack];
    }
}

-(void) dealloc {
    
    [audioPlayer release];
    audioPlayer = nil;
    
    [nextTrack release];
    nextTrack = nil;
    
    [super dealloc];
}


+(void) vibrate {
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}


+(void) playEffect:(SystemSoundID)soundFileObject {
    
    AudioServicesPlaySystemSound(soundFileObject);
}


+(SystemSoundID) loadEffectWithName:(NSString *)bundleRef {
    
    // Get the URL to the sound file to play
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    CFURLRef soundFileURLRef = CFBundleCopyResourceURL(mainBundle, (CFStringRef) bundleRef, NULL, NULL);
    
    // Create a system sound object representing the sound file
    SystemSoundID soundFileObject;
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundFileObject);
    CFRelease(soundFileURLRef);
    
    return soundFileObject;
}


+(void) disposeEffect:(SystemSoundID)soundFileObject {
    
    AudioServicesDisposeSystemSoundID(soundFileObject);
}

+(GorillasAudioController *) get {
    
    static GorillasAudioController *sharedAudioController = nil;
    if(sharedAudioController == nil)
        sharedAudioController = [[GorillasAudioController alloc] init];
    
    return sharedAudioController;
}

@end
