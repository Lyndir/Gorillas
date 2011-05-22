//
//  PlayHaven.h
//  PlayHaven
//
//  Created by Kurtiss Hare on 2/16/10.
//  Copyright 2010 Medium Entertainment, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma GCC visibility push(default)

#pragma mark Constants
extern NSString *const PHPromotionRedeemedKey;
extern NSString *const PHPromotionRedirectURLKey;
extern NSString *const PHPromotionRedirectURLStringKey;

#pragma mark Interfaces and Protocols
@interface PHLogLevel : NSObject {
	int intValue;
}

+(id)logLevelDebug;
+(id)logLevelInfo;
+(id)logLevelWarn;
+(id)logLevelError;

@property (nonatomic, readonly) int intValue;

@end

@interface PHConfiguration : NSObject {
	PHLogLevel *logLevel;
}

+(id)configuration;
@property (nonatomic, retain) PHLogLevel *logLevel;

@end

@protocol PHRequestDelegate<NSObject>
@required
-(void)playhaven:(UIView *)view didLoadWithContext:(id)contextValue;
-(void)playhaven:(UIView *)view didFailWithError:(NSString *)message context:(id)contextValue;
-(void)playhaven:(UIView *)view wasDismissedWithContext:(id)contextValue;
@end

@protocol PHDataRequestDelegate<NSObject>
-(void)playhavenRequestDidLoadData:(NSDictionary *)data context:(id)contextValue;
-(void)playhavenRequestDidFailWithError:(NSString *)message context:(id)contextValue;
@end

@protocol PHPreloadDelegate<NSObject>
@required
-(NSString *)playhavenPublisherToken;
@optional
-(BOOL)shouldTestPlayHaven;
-(void)playhavenDidFinishPreloading;
-(void)playhavenPreloadDidFailWithError:(NSString *)message;
-(PHLogLevel *)playhavenDebugLogLevel;
@end

@interface PlayHaven : NSObject

+(void)preloadWithDelegate:(id<PHPreloadDelegate>)theDelegate;

// NOTE: the following preload methods will become deprecated soon, you should use the method above.
+(void)preloadWithPublisherToken:(NSString *)publisherToken testing:(BOOL)shouldTest __attribute__ ((deprecated));

// NOTE: configuration only used in conjunction with the debug version of libPlayHaven-Debug.a
+(void)preloadWithPublisherToken:(NSString *)publisherToken testing:(BOOL)shouldTest configuration:(PHConfiguration *)configuration __attribute__ ((deprecated));

+(void)loadChartsNotifierWithDelegate:(id<PHRequestDelegate>)delegate context:(id)contextValue;
+(void)loadChartsWithDelegate:(id<PHRequestDelegate>)delegate context:(id)contextValue;
+(void)loadCommunityWithDelegate:(id<PHRequestDelegate>)delegate context:(id)contextValue __attribute__((unavailable));
+(void)loadService:(NSString *)service withDelegate:(id<PHRequestDelegate>)delegate params:(NSDictionary *)dictionary context:(id)contextValue;


#pragma mark PlayHaven Data Requests
+(void)requestPromotion:(NSString *)promoToken delegate:(id)delegate context:(id)context;

+(NSString *)version;

@end

#pragma GCC visibility pop
