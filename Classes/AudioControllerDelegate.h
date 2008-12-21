//
//  AudioControllerDelegate.h
//  Gorillas
//
//  Created by Maarten Billemont on 20/12/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol AudioControllerDelegate

-(void) audioStarted:(AudioPlayer *)player;
-(void) audioStopped:(AudioPlayer *)player;

@end