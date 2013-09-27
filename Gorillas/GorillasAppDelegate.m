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
//  GorillasAppDelegate.m
//  Gorillas
//
//  Created by Maarten Billemont on 18/10/08.
//  Copyright, lhunath (Maarten Billemont) 2008. All rights reserved.
//

#import "GorillasAppDelegate.h"
#import "PearlRootViewController.h"
#import "PearlCCSplash.h"
#import "PearlResettable.h"
#import "PearlCCDebugLayer.h"
#import "CityTheme.h"
#import "ccMacros.h"
#import "LocalyticsSession.h"
#import "TestFlight.h"
#import <Crashlytics/Crashlytics.h>


@interface GorillasAppDelegate ()

@property (nonatomic, readwrite, retain) GameLayer                      *gameLayer;
@property (nonatomic, readwrite, retain) MainMenuLayer                   *mainMenuLayer;
@property (nonatomic, readwrite, retain) ConfigurationSectionLayer      *configLayer;
@property (nonatomic, readwrite, retain) GameConfigurationLayer         *gameConfigLayer;
@property (nonatomic, readwrite, retain) AVConfigurationLayer           *avConfigLayer;

@property (nonatomic, readwrite, retain) NetController                  *netController;

- (NSString *)testFlightInfo;
- (NSString *)testFlightToken;

- (NSString *)crashlyticsInfo;
- (NSString *)crashlyticsAPIKey;

- (NSString *)localyticsInfo;
- (NSString *)localyticsKey;

@end

@implementation GorillasAppDelegate
@synthesize gameLayer = _gameLayer;
@synthesize mainMenuLayer = _mainMenuLayer;
@synthesize configLayer = _configLayer, gameConfigLayer = _gameConfigLayer, avConfigLayer = _avConfigLayer;
@synthesize netController = _netController;

+ (void)initialize {
    
    [GorillasConfig get];
#ifdef DEBUG
    [[PearlLogger get] setPrintLevel:PearlLogLevelDebug];
#endif
}

- (void)preSetup {

    @try {
        NSString *apiKey = [self crashlyticsAPIKey];
        if ([apiKey length]) {
            dbg(@"Initializing Crashlytics");
#ifndef APPSTORE
            [Crashlytics sharedInstance].debugMode = YES;
#endif
            [Crashlytics startWithAPIKey:apiKey afterDelay:0];
            [[Crashlytics sharedInstance] setUserName:@"Anonymous"];
            [[PearlLogger get] registerListener:^BOOL(PearlLogMessage *message) {
#ifdef APPSTORE
                if (message.level >= PearlLogLevelInfo)
                    CLSLog(@"%@", message);
#else
                if (message.level >= PearlLogLevelDebug)
                    CLSLog( @"%@", message );
#endif

                return YES;
            }];
        }
    }
    @catch (id exception) {
        err(@"Crashlytics: %@", exception);
    }
    @try {
        NSString *token = [self testFlightToken];
        if ([token length]) {
            inf(@"Initializing TestFlight");
            [TestFlight addCustomEnvironmentInformation:@"Anonymous" forKey:@"username"];
            [TestFlight setOptions:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:NO],   @"logToConsole",
                                    [NSNumber numberWithBool:NO],   @"logToSTDERR",
                                    nil]];
            [TestFlight takeOff:token];
            [[PearlLogger get] registerListener:^BOOL(PearlLogMessage *message) {
#ifdef APPSTORE
                if (message.level >= PearlLogLevelInfo)
                    TFLog(@"%@", message);
#else
                if (message.level >= PearlLogLevelDebug)
                    TFLog(@"%@", message);
#endif
                
                return YES;
            }];
        }
    }
    @catch (id exception) {
        err(@"TestFlight: %@", exception);
    }
    @try {
        NSString *key = [self localyticsKey];
        if ([key length]) {
            dbg(@"Initializing Localytics");
            [[LocalyticsSession sharedLocalyticsSession] startSession:key];
            [[PearlLogger get] registerListener:^BOOL(PearlLogMessage *message) {
                if (message.level >= PearlLogLevelError)
                    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Problem" attributes:
                     [NSDictionary dictionaryWithObjectsAndKeys:
                      [[NSString alloc] initWithUTF8String:PearlLogLevelStr(message.level)], @"level",
                      message.message, @"message",
                      nil]];
                
                return YES;
            }];
        }
    }
    @catch (id exception) {
        err(@"Localytics exception: %@", exception);
    }

    [super preSetup];
    
    // Build the splash scene.
    CCScene *splashScene = [CCScene node];
    CCSprite *splash = [PearlCCSplash node];
    [splashScene addChild:splash];
    
    // Build the game scene.
    self.gameLayer = [GameLayer node];
    CCSprite *frame = [CCSprite spriteWithFile:@"frame.png"];
    frame.anchorPoint = CGPointZero;
    [self.uiLayer addChild:frame z:1];
    [self.uiLayer addChild:self.gameLayer];

    // Show the splash screen, this starts the main loop in the current thread.
    [[CCDirector sharedDirector] pushScene:splashScene];
    
    // Game Center setup.
    [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error){
        if (error)
            wrn(@"Game Center unavailable: %@", error);

        dbg(@"Local player alias: %@", [GKLocalPlayer localPlayer].alias);
        [TestFlight addCustomEnvironmentInformation:[GKLocalPlayer localPlayer].alias forKey:@"username"];
        [[Crashlytics sharedInstance] setUserName:[GKLocalPlayer localPlayer].alias];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainMenuLayer reset];
        });
    }];
#ifndef LITE
    self.netController = [[NetController new] autorelease];
    [GKMatchmaker sharedMatchmaker].inviteHandler = ^(GKInvite *acceptedInvite, NSArray *playersToInvite) {
        
        if (acceptedInvite)
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.netController beginInvite:acceptedInvite];
            });
        
        else if(playersToInvite)
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showMainMenuForPlayers:playersToInvite];
            });
    };
#endif
}


-(GHUDLayer *) hudLayer {
    
    if(!_hudLayer)
        _hudLayer = [[GHUDLayer alloc] init];
    
    return (GHUDLayer *)super.hudLayer;
}


- (void)hudMenuPressed {
    
    [self showMainMenu];
}

-(void) showMainMenu {
    
    if(!self.mainMenuLayer)
        self.mainMenuLayer = [MainMenuLayer node];
    
    if (![self isLastLayerShowing] || ![self isLayerShowing:self.mainMenuLayer]) {
        [self popAllLayers];
        [self pushLayer:self.mainMenuLayer];
    }
}


-(void) showMainMenuForPlayers:(NSArray *)aPlayersToInvite {
    
    if(!self.mainMenuLayer)
        self.mainMenuLayer = [MainMenuLayer node];
    self.mainMenuLayer.playersToInvite = aPlayersToInvite;
    
    [self pushLayer:self.mainMenuLayer];
}


-(void) showConfiguration {
    
    if(!self.configLayer)
        self.configLayer = [ConfigurationSectionLayer node];
    
    [self pushLayer:self.configLayer];
}


-(void) showGameConfiguration {
    
    if(!self.gameConfigLayer)
        self.gameConfigLayer = [GameConfigurationLayer node];
    
    [self pushLayer:self.gameConfigLayer];
}


-(void) showAVConfiguration {
    
    if(!self.avConfigLayer)
        self.avConfigLayer = [AVConfigurationLayer node];
    
    [self pushLayer:self.avConfigLayer];
}


- (void)pushLayer: (PearlCCShadeLayer *)layer hidden:(BOOL)hidden {
    
    [self.gameLayer setPaused:YES];
    
    [super pushLayer:layer hidden:hidden];
}

- (void)didUpdateConfigForKey:(SEL)configKey fromValue:(id)value {
    
    [super didUpdateConfigForKey:configKey fromValue:value];
    
    if (configKey == @selector(cityTheme)) {
        dbg(@"City Theme changed to: %@", [GorillasConfig get].cityTheme);
        [[[CityTheme getThemes] objectForKey:[GorillasConfig get].cityTheme] apply];
    }
}

- (void)didPushLayer:(PearlCCShadeLayer *)layer hidden:(BOOL)hidden {
    
    self.gameLayer.paused = YES;
    
    [super didPushLayer:layer hidden:hidden];
}

- (void)didPopLayer:(PearlCCShadeLayer *)layer anyLeft:(BOOL)anyLeft {
    
    if (!anyLeft)
        self.gameLayer.paused = NO;
    
    [super didPopLayer:layer anyLeft:anyLeft];
}


#pragma mark - TestFlight

- (NSDictionary *)testFlightInfo {
    
    static NSDictionary *testFlightInfo = nil;
    if (testFlightInfo == nil)
        testFlightInfo = [[NSDictionary alloc] initWithContentsOfURL:
                          [[NSBundle mainBundle] URLForResource:@"TestFlight" withExtension:@"plist"]];
    
    return testFlightInfo;
}

- (NSString *)testFlightToken {
    
    return NSNullToNil([[self testFlightInfo] valueForKeyPath:@"Team Token"]);
}


#pragma mark - Crashlytics

- (NSDictionary *)crashlyticsInfo {
    
    static NSDictionary *crashlyticsInfo = nil;
    if (crashlyticsInfo == nil)
        crashlyticsInfo = [[NSDictionary alloc] initWithContentsOfURL:
                           [[NSBundle mainBundle] URLForResource:@"Crashlytics" withExtension:@"plist"]];
    
    return crashlyticsInfo;
}

- (NSString *)crashlyticsAPIKey {
    
    return NSNullToNil([[self crashlyticsInfo] valueForKeyPath:@"API Key"]);
}



#pragma mark - Localytics

- (NSDictionary *)localyticsInfo {
    
    static NSDictionary *localyticsInfo = nil;
    if (localyticsInfo == nil)
        localyticsInfo = [[NSDictionary alloc] initWithContentsOfURL:
                          [[NSBundle mainBundle] URLForResource:@"Localytics" withExtension:@"plist"]];
    
    return localyticsInfo;
}

- (NSString *)localyticsKey {
    
#ifdef DEBUG
    return NSNullToNil([[self localyticsInfo] valueForKeyPath:@"Key.development"]);
#elif defined(LITE)
    return NSNullToNil([[self localyticsInfo] valueForKeyPath:@"Key.distribution.lite"]);
#else
    return NSNullToNil([[self localyticsInfo] valueForKeyPath:@"Key.distribution"]);
#endif
}



- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];
    
    [super applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    [[LocalyticsSession sharedLocalyticsSession] resume];
    [[LocalyticsSession sharedLocalyticsSession] upload];
    
    [super applicationWillEnterForeground:application];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];
    
    [super applicationWillTerminate:application];
}

-(void) applicationWillResignActive:(UIApplication *)application {
    
    if(!self.gameLayer.paused)
        [self showMainMenu];
    
    [super applicationWillResignActive:application];
}


- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    
    [super applicationDidReceiveMemoryWarning:application];
    
    if(self.mainMenuLayer && ![self.mainMenuLayer parent]) {
        [self.mainMenuLayer stopAllActions];
        self.mainMenuLayer = nil;
    }
    if(self.configLayer && ![self.configLayer parent]) {
        [self.configLayer stopAllActions];
        self.configLayer = nil;
    }
    if(self.gameConfigLayer && ![self.gameConfigLayer parent]) {
        [self.gameConfigLayer stopAllActions];
        self.gameConfigLayer = nil;
    }
    if(self.avConfigLayer && ![self.avConfigLayer parent]) {
        [self.avConfigLayer stopAllActions];
        self.avConfigLayer = nil;
    }
}


- (void)dealloc {
    
    self.gameLayer          = nil;
    self.mainMenuLayer      = nil;
    self.configLayer        = nil;
    self.gameConfigLayer    = nil;
    self.avConfigLayer      = nil;
    
    [super dealloc];
}


+(GorillasAppDelegate *) get {
    
    return (GorillasAppDelegate *) [UIApplication sharedApplication].delegate;
}


@end
