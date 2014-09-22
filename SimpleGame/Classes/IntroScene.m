//
//  IntroScene.m
//  SimpleGame
//
//  Created by Ivan Magda on 21.09.14.
//  Copyright Ivan Magda 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "IntroScene.h"
#import "CartmanShootScene.h"

// -----------------------------------------------------------------------
#pragma mark - IntroScene
// -----------------------------------------------------------------------

@implementation IntroScene

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (IntroScene *)scene
{
	return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    [[OALSimpleAudio sharedInstance] playBg:@"south-park-main-theme.mp3" loop:YES];
    
    CCSprite *backgroundImage = [CCSprite spriteWithImageNamed:@"menu.jpg"];
    CGRect textureRect = [[UIScreen mainScreen]bounds];
    textureRect.origin.x = -50;
    textureRect.origin.y = 25;
    [backgroundImage setTextureRect:textureRect];
    backgroundImage.anchorPoint = CGPointZero;
    backgroundImage.position = CGPointZero;
    [self addChild:backgroundImage];
    
    // Helloworld scene button
    CCButton *helloWorldButton = [CCButton buttonWithTitle:@"[ Start Game ]" fontName:@"Chalkduster" fontSize:28.0f];
    helloWorldButton.color = [CCColor blackColor];
    [helloWorldButton setLabelColor:[CCColor lightGrayColor]
                           forState:CCControlStateHighlighted];
    helloWorldButton.positionType = CCPositionTypeNormalized;
    helloWorldButton.position = ccp(0.5f, 0.10f);
    [helloWorldButton setTarget:self selector:@selector(onSpinningClicked:)];
    [self addChild:helloWorldButton];

	return self;
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onSpinningClicked:(id)sender
{
    // start spinning scene with transition
    [[CCDirector sharedDirector] replaceScene:[CartmanShootScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:1.0f]];
}

// -----------------------------------------------------------------------
@end
