//
//  Crashlytics.h
//  Crashlytics
//
//  Created by Jeff Seibert on 3/5/11.
//  Copyright 2011 Crashlytics, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CLDelegate;
@class CLSettings;
@class CLCrashReport;

@interface Crashlytics : NSObject {
	NSString *_apiKey;
	id <CLDelegate> _delegate;
	
	NSString *_dataDirectory;
	NSString *_bundleIdentifier;
	
	NSMutableArray *_reports;
	BOOL _installed;
	BOOL _debugMode;
	
	NSMutableDictionary *_customAttributes;
	id _user;
	
	NSInteger _sendButtonIndex;
	NSInteger _alwaysSendButtonIndex;
	
	CLSettings *settings;
}

@property (readonly) NSString *apiKey;
@property (readonly) NSString *version;

@property (assign) id <CLDelegate> delegate;
@property (assign) BOOL debugMode;
@property (readonly) NSArray *reports;
@property (readonly) NSDictionary *customAttributes;

/**
 *
 * The recommended way to install Crashlytics into your application is to place a call
 * to +startWithAPIKey: in your -application:didFinishLaunchingWithOptions: method.
 *
 * If you desire additional control, you may pass in a delegate object that will be
 * notified when crash reports will be sent, or control the precise time delay it will
 * wait before processing reports.
 *
 * This delay defaults to 1 second in order to generally give the application time to 
 * fully finish launching.
 *
 **/

+ (Crashlytics *)startWithAPIKey:(NSString *)apiKey;
+ (Crashlytics *)startWithAPIKey:(NSString *)apiKey delegate:(id <CLDelegate>)delegate;
+ (Crashlytics *)startWithAPIKey:(NSString *)apiKey delegate:(id <CLDelegate>)delegate afterDelay:(NSTimeInterval)delay;

/**
 *
 * Access the singleton Crashlytics instance.
 *
 **/

+ (Crashlytics *)sharedInstance;

/**
 *
 * Those who require more precise control of when crash reports are sent may do the following:
 * 
 * [[Crashlytics sharedInstance] initializeWithAPIKey:<APIKEY> delegate:self];
 *
 * Followed, at a later time, by:
 *
 * [[Crashlytics sharedInstance] processCrashesInBackground];
 *
 **/

- (id)initializeWithAPIKey:(NSString *)apiKey delegate:(id <CLDelegate>)delegate;

/**
 *
 * Waits the specified delay and then begins processing cached crash reports in the background.
 *
 **/

- (id)processCrashesAfterDelay:(NSTimeInterval)delay;

/**
 *
 * Immediately begins processing any cached crash reports asyncronously.
 *
 **/

- (void)processCrashesInBackground;

/**
 *
 * The easiest way to cause a crash - great for testing!
 *
 **/

- (void)crash;

- (void)setUserIdentifier:(id)user;
- (void)addCustomAttributes:(NSDictionary *)attributes;
- (void)addCustomAttribute:(id)attribute forKey:(NSString *)key;
- (id)customAttributeForKey:(NSString *)key;

@end



@protocol CLReport

@property (readonly) NSString *path;
@property (readonly) NSDate *date;

@end


@protocol CLDelegate <NSObject>

// CAUTION: These are not necessarily called from the main thread.

@optional
- (BOOL)crashlytics:(Crashlytics *)crashlytics shouldSendCrashReport:(id <CLReport>)report;
- (void)crashlytics:(Crashlytics *)crashlytics willSendCrashReport:(id <CLReport>)report;
- (void)crashlytics:(Crashlytics *)crashlytics didSendCrashReport:(id <CLReport>)report;

- (void)crashlyticsWillDisplayAlert:(Crashlytics *)crashlytics;
- (void)crashlyticsDidDismissAlert:(Crashlytics *)crashlytics;

@end

extern NSString *CrashlyticsException;
