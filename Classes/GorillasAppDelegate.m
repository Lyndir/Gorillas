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
#import "RootViewController.h"
#import "Splash.h"
#import "Resettable.h"
#import "DebugLayer.h"
#import "CityTheme.h"
#import "ccMacros.h"


static NSString *PHContextNotifier  = @"PH.notifier";
static NSString *PHContextCharts    = @"PH.charts";
//static NSString *PHContextCommunity = @"PH.community";

@interface CCDirector (Reveal)

-(void) startAnimation;

@end

@interface GorillasAppDelegate ()

@property (nonatomic, readwrite, retain) GameLayer                      *gameLayer;
@property (nonatomic, readwrite, retain) NewGameLayer                   *newGameLayer;
@property (nonatomic, readwrite, retain) ConfigurationSectionLayer      *configLayer;
@property (nonatomic, readwrite, retain) GameConfigurationLayer         *gameConfigLayer;
@property (nonatomic, readwrite, retain) AVConfigurationLayer           *avConfigLayer;
@property (nonatomic, readwrite, retain) ModelsConfigurationLayer       *modelsConfigLayer;
@property (nonatomic, readwrite, retain) InformationLayer               *infoLayer;
@property (nonatomic, readwrite, retain) GuideLayer                     *guideLayer;
@property (nonatomic, readwrite, retain) FullGameLayer                  *fullLayer;

@property (nonatomic, readwrite, retain) NetController                  *netController;
@property (nonatomic, readwrite, retain) UIView                         *notifierView;

@end

@implementation GorillasAppDelegate
@synthesize gameLayer = _gameLayer;
@synthesize newGameLayer = _newGameLayer;
@synthesize configLayer = _configLayer, gameConfigLayer = _gameConfigLayer, avConfigLayer = _avConfigLayer, modelsConfigLayer = _modelsConfigLayer;
@synthesize infoLayer = _infoLayer, guideLayer = _guideLayer, fullLayer = _fullLayer;
@synthesize netController = _netController;
@synthesize notifierView = _notifierView;

+ (void)initialize {
    
    [[Logger get] setAutoprintLevel:LogLevelDebug];
    [GorillasConfig get];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [super application:application didFinishLaunchingWithOptions:launchOptions];
    [((RootViewController *) self.window.rootViewController) supportInterfaceOrientation:UIInterfaceOrientationLandscapeRight];
    [((RootViewController *) self.window.rootViewController) supportInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
    
    // Game Center setup.
    self.netController = [[NetController new] autorelease];
    [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error){
        if (error)
            wrn(@"Game Center unavailable: %@", error);
        
        [self.newGameLayer reset];
    }];
    [GKMatchmaker sharedMatchmaker].inviteHandler = ^(GKInvite *acceptedInvite, NSArray *playersToInvite) {
        [self.gameLayer performSelectorOnMainThread:@selector(stopGame) withObject:nil waitUntilDone:YES];
        
        if (acceptedInvite)
            [self.netController performSelectorOnMainThread:@selector(beginInvite:) withObject:acceptedInvite waitUntilDone:NO];
        
        else if(playersToInvite)
            [self performSelectorOnMainThread:@selector(showMainMenuForPlayers:) withObject:playersToInvite waitUntilDone:NO];
    };
    
	// Build the splash scene.
    CCScene *splashScene = [CCScene node];
    CCSprite *splash = [Splash node];
    [splashScene addChild:splash];
    
    // Build the game scene.
	self.gameLayer = [GameLayer node];
    CCSprite *frame = [CCSprite spriteWithFile:@"frame.png"];
    frame.anchorPoint = CGPointZero;
    [self.uiLayer addChild:frame z:1];
    [self.uiLayer addChild:self.gameLayer];
	
    // Show the splash screen, this starts the main loop in the current thread.
    [[CCDirector sharedDirector] pushScene:splashScene];
    [self showMainMenu];
    
    // PlayHaven setup.
    @try {
        [PlayHaven preloadWithDelegate:self];
        [PlayHaven loadChartsNotifierWithDelegate:self context:PHContextNotifier];
    }
    @catch (NSException *exception) {
        err(@"PlayHaven exception: %@", exception);
    }
    
    do {
#if ! TARGET_IPHONE_SIMULATOR
        @try {
#endif
            [[CCDirector sharedDirector] startAnimation];
#if ! TARGET_IPHONE_SIMULATOR
        }
        @catch (NSException * e) {
            NSLog(@"=== Exception Occurred! ===");
            NSLog(@"Name: %@; Reason: %@; Context: %@.\n", [e name], [e reason], [e userInfo]);
            [self.hudLayer message:[e reason] duration:5 isImportant:YES];
        }
#endif
    } while ([[CCDirector sharedDirector] runningScene]);
    
    return NO;
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
    
    if(!self.newGameLayer)
        self.newGameLayer = [NewGameLayer node];

    [self pushLayer:self.newGameLayer];
}


-(void) showMainMenuForPlayers:(NSArray *)aPlayersToInvite {
    
    if(!self.newGameLayer)
        self.newGameLayer = [NewGameLayer node];
    self.newGameLayer.playersToInvite = aPlayersToInvite;
    
    [self pushLayer:self.newGameLayer];
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


-(void) showModelsConfiguration {
    
    if(!self.modelsConfigLayer)
        self.modelsConfigLayer = [ModelsConfigurationLayer node];
    
    [self pushLayer:self.modelsConfigLayer];
}


-(void) showInformation {
    
    if(!self.infoLayer)
        self.infoLayer = [InformationLayer node];
    
    [self pushLayer:self.infoLayer];
}


-(void) showGuide {
    
    if(!self.guideLayer)
        self.guideLayer = [GuideLayer node];
    
    [self pushLayer:self.guideLayer];
}


-(void) showFullGame {
    
    if(!self.fullLayer)
        self.fullLayer = [FullGameLayer node];
    
    [self pushLayer:self.fullLayer];
}

- (void)moreGames {
    
    [PlayHaven loadChartsWithDelegate:self context:PHContextCharts];
}


- (void)pushLayer: (ShadeLayer *)layer hidden:(BOOL)hidden {
    
    [self.gameLayer setPaused:YES];
    
    [super pushLayer:layer hidden:hidden];
}

- (void)didUpdateConfigForKey:(SEL)configKey {
    
    [super didUpdateConfigForKey:configKey];
    
    if (configKey == @selector(cityTheme)) {
        dbg(@"City Theme changed to: %@", [GorillasConfig get].cityTheme);
        [[[CityTheme getThemes] objectForKey:[GorillasConfig get].cityTheme] apply];
    }
    
    if (configKey == @selector(playerModel)) {
        dbg(@"Model changed");
        [self.gameLayer reset];
    }
}

- (void)didPushLayer:(ShadeLayer *)layer hidden:(BOOL)hidden {
    
    self.gameLayer.paused = YES;

    if (self.notifierView.superview && layer != self.newGameLayer)
        [self.notifierView removeFromSuperview];
    
    else if (self.notifierView) {
        if (layer == self.newGameLayer) {
            self.notifierView.center = ccp(100, 325);
            [[CCDirector sharedDirector].openGLView addSubview:self.notifierView];
        }
    }

    [super didPushLayer:layer hidden:hidden];
}

- (void)didPopLayer:(ShadeLayer *)layer anyLeft:(BOOL)anyLeft {
     
    if (self.notifierView.superview && layer == self.newGameLayer)
        [self.notifierView removeFromSuperview];
     
    else if (self.notifierView) {
        if ([self isLayerShowing:self.newGameLayer]) {
            self.notifierView.center = ccp(100, 330);
            [[CCDirector sharedDirector].openGLView addSubview:self.notifierView];
        }
    }
 
    if (!anyLeft)
        self.gameLayer.paused = NO;
    
    [super didPopLayer:layer anyLeft:anyLeft];
}


#pragma mark - PHPreloadDelegate

-(NSString *)playhavenPublisherToken {
    
    return [[NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"PlayHaven" withExtension:@"plist"]] valueForKeyPath:@"Token"];
}

-(BOOL)shouldTestPlayHaven {
    
#ifdef DEBUG
    return YES;
#else
    return NO;
#endif
}

-(void)playhavenDidFinishPreloading {
    
}

-(void)playhavenPreloadDidFailWithError:(NSString *)message {
    
    err(@"Playhaven preload failed with error: %@", message);
}

-(PHLogLevel *)playhavenDebugLogLevel {
    
    return [self shouldTestPlayHaven]? [PHLogLevel logLevelDebug]: [PHLogLevel logLevelWarn];
}


#pragma mark - PHRequestDelegate

- (void)playhaven:(UIView *)view didLoadWithContext:(id)contextValue {
    
    if (contextValue == PHContextNotifier) {
        [self.notifierView removeFromSuperview];
        self.notifierView = view;
        
        if ([self isLayerShowing:self.newGameLayer])
            [[CCDirector sharedDirector].openGLView addSubview:view];
    }
    
    if (contextValue == PHContextCharts) {
        [[CCDirector sharedDirector].openGLView addSubview:view];
        [[CCDirector sharedDirector] pause];
    }
}

- (void)playhaven:(UIView *)view didFailWithError:(NSString *)message context:(id)contextValue {
    
    err(@"Playhaven context: %@, failed with error: %@", contextValue, message);
    
    [view removeFromSuperview];
    [[CCDirector sharedDirector] resume];
}

- (void)playhaven:(UIView *)view wasDismissedWithContext:(id)contextValue {
    
    [view removeFromSuperview];
    [[CCDirector sharedDirector] resume];
}


-(void) applicationWillResignActive:(UIApplication *)application {

    if(!self.gameLayer.paused)
        [self showMainMenu];

    [super applicationWillResignActive:application];
}


- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    
    [super applicationDidReceiveMemoryWarning:application];
    
    if(self.newGameLayer && ![self.newGameLayer parent]) {
        [self.newGameLayer stopAllActions];
        self.newGameLayer = nil;
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
    if(self.modelsConfigLayer && ![self.modelsConfigLayer parent]) {
        [self.modelsConfigLayer stopAllActions];
        self.modelsConfigLayer = nil;
    }
    if(self.infoLayer && ![self.infoLayer parent]) {
        [self.infoLayer stopAllActions];
        self.infoLayer = nil;
    }
    if(self.guideLayer && ![self.guideLayer parent]) {
        [self.guideLayer stopAllActions];
        self.guideLayer = nil;
    }
    if(self.fullLayer && ![self.fullLayer parent]) {
        [self.fullLayer stopAllActions];
        self.fullLayer = nil;
    }
}


- (void)dealloc {
    
    self.gameLayer          = nil;
    self.newGameLayer       = nil;
    self.configLayer        = nil;
    self.gameConfigLayer    = nil;
    self.avConfigLayer      = nil;
    self.modelsConfigLayer  = nil;
    self.infoLayer          = nil;
    self.guideLayer         = nil;
    self.fullLayer          = nil;
    
    [super dealloc];
}


+(GorillasAppDelegate *) get {
    
    return (GorillasAppDelegate *) [UIApplication sharedApplication].delegate;
}


@end
