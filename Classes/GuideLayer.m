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
//  GuideLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "GuideLayer.h"
#import "GorillasAppDelegate.h"


@interface GuideLayer ()

- (void)flipPage;
- (void)next:(id)sender;
- (void)back:(id)sender;
- (void)skip:(id)sender;
- (void)swiped:(BOOL)forward;

@end

@implementation GuideLayer


-(id) init {

    if(!(self = [super init]))
        return self;

    // Guide Content.
    id error = nil;
    NSString *guideData = [NSString stringWithContentsOfFile:
                           [[NSBundle mainBundle] pathForResource:@"guide"
                                                           ofType:@"txt"]
                                                    encoding:NSUTF8StringEncoding
                                                       error:&error];
    if(error != nil)
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"Guide text could not be read: %@", error] userInfo:nil];
    
    NSArray *pages = [guideData componentsSeparatedByString:@"\n\n===== NEXT PAGE =====\n"];

#ifdef LITE
    BOOL isLite = YES;
#else
    BOOL isLite = NO;
#endif
    
    guidePages = [[NSMutableArray alloc] initWithCapacity:[pages count]];
    guideTitles = [[NSMutableArray alloc] initWithCapacity:[pages count]];
    for(NSString *guidePage in pages) {
        unichar pageType = [guidePage characterAtIndex:0];
        guidePage = [guidePage substringFromIndex:1];
        
        if (!(isLite && pageType == '+')) {
            NSUInteger firstLineEnd = [guidePage rangeOfString:@"\n"].location;
            [guideTitles addObject:[guidePage substringToIndex:firstLineEnd]];
            [guidePages addObject:[guidePage substringFromIndex:firstLineEnd + 1]];
        }
    }
    
    
    // Controls.
    [CCMenuItemFont setFontSize:15];
    chapterNext = [[CCMenuItemFont itemFromString:@"                              " target:self selector:@selector(next:)] retain];
    chapterSkip = [[CCMenuItemFont itemFromString:@"                              " target:self selector:@selector(skip:)] retain];
    [CCMenuItemFont setFontSize:26];
    chapterCurr = [[CCMenuItemFont itemFromString:@"                              "] retain];
    [chapterCurr setIsEnabled:NO];

    CCMenu *chapterMenu = [CCMenu menuWithItems:chapterCurr, chapterNext, chapterSkip, nil];
    [chapterMenu alignItemsHorizontally];
    [chapterMenu setPosition:ccp([chapterMenu position].x, self.contentSize.height - self.padding.top + 10)];
    [self addChild:chapterMenu];
    [CCMenuItemFont setFontSize:[[GorillasConfig get].fontSize intValue]];
    
    CGPoint s = ccp(self.contentSize.width - self.padding.left - self.padding.right,
                    self.contentSize.height - [[GorillasConfig get].fontSize intValue] - self.padding.top);
    
    UITextAlignment alignment = UITextAlignmentLeft;
    if ([NSLocalizedString(@"config.direction", "ltr") isEqualToString:@"rtl"]) {
        alignment = UITextAlignmentRight;
    }
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    prevPageLabel = [[CCLabelTTF alloc] initWithString:@""
                             dimensions:CGSizeMake(s.x, s.y)
                              alignment:alignment
                               fontName:[GorillasConfig get].fixedFontName
                               fontSize:[[GorillasConfig get].smallFontSize intValue]];
    [prevPageLabel setPosition:ccp(self.contentSize.width / 2 - winSize.width,
                                   self.contentSize.height / 2)];
    [prevPageLabel runAction:[CCFadeIn actionWithDuration:[[GorillasConfig get].transitionDuration floatValue]]];
    currPageLabel = [[CCLabelTTF alloc] initWithString:@""
                                   dimensions:CGSizeMake(s.x, s.y)
                                    alignment:alignment
                                     fontName:[GorillasConfig get].fixedFontName
                                     fontSize:[[GorillasConfig get].smallFontSize intValue]];
    [currPageLabel setPosition:ccp(self.contentSize.width / 2,
                                   self.contentSize.height / 2)];
    [currPageLabel runAction:[CCFadeIn actionWithDuration:[[GorillasConfig get].transitionDuration floatValue]]];
    nextPageLabel = [[CCLabelTTF alloc] initWithString:@""
                                   dimensions:CGSizeMake(s.x, s.y)
                                    alignment:alignment
                                     fontName:[GorillasConfig get].fixedFontName
                                     fontSize:[[GorillasConfig get].smallFontSize intValue]];
    [nextPageLabel setPosition:ccp(self.contentSize.width / 2 + winSize.width,
                                   self.contentSize.height / 2)];
    [nextPageLabel runAction:[CCFadeIn actionWithDuration:[[GorillasConfig get].transitionDuration floatValue]]];
    
    swipeLayer = [[SwipeLayer alloc] initWithTarget:self selector:@selector(swiped:)];
    [self addChild:swipeLayer];
    [swipeLayer addChild:prevPageLabel];
    [swipeLayer addChild:currPageLabel];
    [swipeLayer addChild:nextPageLabel];
    CGPoint swipeAreaHalf = ccp([currPageLabel contentSize].width / 2,
                               [currPageLabel contentSize].height / 2 - [[GorillasConfig get].fontSize intValue] / 2);
    [swipeLayer setSwipeAreaFrom:ccpSub([currPageLabel position], swipeAreaHalf)
                              to:ccpAdd([currPageLabel position], swipeAreaHalf)];
    
    pageNumberLabel = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"%d / %d", [guidePages count], [guidePages count]]
                                         dimensions:CGSizeMake(150, [[GorillasConfig get].smallFontSize intValue])
                                          alignment:UITextAlignmentCenter
                                           fontName:[GorillasConfig get].fontName
                                           fontSize:[[GorillasConfig get].smallFontSize intValue]];
    [pageNumberLabel setPosition:ccp(self.contentSize.width - [[GorillasConfig get].smallFontSize intValue] * 3,
                                     self.padding.top + self.padding.bottom - [[GorillasConfig get].fontSize intValue] / 2)];
    [self addChild:pageNumberLabel];
    
    return self;
}


-(void) onEnter {
    
    [super onEnter];
    
    page = 0;
    [self flipPage];
    
}


-(void) swiped:(BOOL)forward {
    
    page = (page + [guidePages count] + (forward? 1: -1)) % [guidePages count];
    
    [self flipPage];
}


-(void) flipPage {
    
    NSUInteger count = [guidePages count];
    NSUInteger prevPage = (page + count - 1) % count;
    NSUInteger currPage = page;
    NSUInteger nextPage = (page + 1) % count;
    NSUInteger skipPage = (page + 2) % count;
    
    [swipeLayer setPosition:CGPointZero];
    
    [pageNumberLabel setString:[NSString stringWithFormat:@"%d / %d", page + 1, count]];

    [prevPageLabel setString:[guidePages objectAtIndex:prevPage]];
    [currPageLabel setString:[guidePages objectAtIndex:currPage]];
    [nextPageLabel setString:[guidePages objectAtIndex:nextPage]];

    [chapterCurr setString:[guideTitles objectAtIndex:currPage]];
    [chapterNext setString:[guideTitles objectAtIndex:nextPage]];
    [chapterSkip setString:[guideTitles objectAtIndex:skipPage]];
}


-(void) next: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    page = (page + 1) % [guidePages count];
    [self flipPage];
}


-(void) skip: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    page = (page + 2) % [guidePages count];
    [self flipPage];
}


-(void) back: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    [[GorillasAppDelegate get] popLayer];
}


-(void) dealloc {
    
    [currPageLabel release];
    currPageLabel = nil;
    
    [pageNumberLabel release];
    pageNumberLabel = nil;
    
    [guideTitles release];
    guideTitles = nil;
    
    [guidePages release];
    guidePages = nil;

    [super dealloc];
}


@end
