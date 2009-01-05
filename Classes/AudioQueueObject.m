/*
File: AudioQueueObject.m
Abstract: The superclass for the recording and playback classes.

Version: 1.2

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
("Apple") in consideration of your agreement to the following terms, and your
use, installation, modification or redistribution of this Apple software
constitutes acceptance of these terms.  If you do not agree with these terms,
please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject
to these terms, Apple grants you a personal, non-exclusive license, under
Apple's copyrights in this original Apple software (the "Apple Software"), to
use, reproduce, modify and redistribute the Apple Software, with or without
modifications, in source and/or binary forms; provided that if you redistribute
the Apple Software in its entirety and without modifications, you must retain
this notice and the following text and disclaimers in all such redistributions
of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may be used
to endorse or promote products derived from the Apple Software without specific
prior written permission from Apple.  Except as expressly stated in this notice,
no other rights or licenses, express or implied, are granted by Apple herein,
including but not limited to any patent rights that may be infringed by your
derivative works or by other works in which the Apple Software may be
incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2008 Apple Inc. All Rights Reserved.

*/


#include <AudioToolbox/AudioToolbox.h>
#import "AudioQueueObject.h"


@implementation AudioQueueObject

@synthesize queueObject;
@synthesize audioFileID;
@synthesize audioFileURL;
@synthesize hardwareSampleRate;
@synthesize audioFormat;
@synthesize audioLevels;
@synthesize startingPacketNumber;
@synthesize notificationDelegate;

- (void) incrementStartingPacketNumberBy: (UInt32) inNumPackets {

	startingPacketNumber += inNumPackets;
}

- (void) setNotificationDelegate: (id) inDelegate {

    notificationDelegate = inDelegate;
}

- (BOOL) isRunning {

	UInt32		isRunning;
	UInt32		propertySize = sizeof (UInt32);
	OSStatus	result;
	
	 result =	AudioQueueGetProperty(
					queueObject,
					kAudioQueueProperty_IsRunning,
					&isRunning,
					&propertySize
				);

	if (result != noErr) {
		return false;
	} else {
		return isRunning;
	}
}


// an audio queue object doesn't provide audio level information unless you 
// enable it to do so
- (void) enableLevelMetering {

	// allocate the memory needed to store audio level information
	self.audioLevels = (AudioQueueLevelMeterState *) calloc (sizeof (AudioQueueLevelMeterState), audioFormat.mChannelsPerFrame);

	UInt32 trueValue = true;

	AudioQueueSetProperty(
		self.queueObject,
		kAudioQueueProperty_EnableLevelMetering,
		&trueValue,
		sizeof (UInt32)
	);
}


// gets audio levels from the audio queue object, to 
// display using the bar graph in the application UI
- (void) getAudioLevels: (Float32 *) levels peakLevels: (Float32 *) peakLevels {

	UInt32 propertySize = audioFormat.mChannelsPerFrame * sizeof (AudioQueueLevelMeterState);
	
	AudioQueueGetProperty(
		self.queueObject,
		(AudioQueuePropertyID) kAudioQueueProperty_CurrentLevelMeter,
		self.audioLevels,
		&propertySize
	);
	
	levels[0]		= self.audioLevels[0].mAveragePower;
	peakLevels[0]	= self.audioLevels[0].mPeakPower;
}

- (void) dealloc {
    
	[super dealloc];
}

@end
