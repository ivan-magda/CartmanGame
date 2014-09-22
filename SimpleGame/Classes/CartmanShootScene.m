//
//  HelloWorldScene.m
//  SimpleGame
//
//  Created by Ivan Magda on 21.09.14.
//  Copyright Ivan Magda 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import "CartmanShootScene.h"
#import "IntroScene.h"

// -----------------------------------------------------------------------
#pragma mark - HelloWorldScene
// -----------------------------------------------------------------------

@interface CartmanShootScene () <CCPhysicsCollisionDelegate>

@end

@implementation CartmanShootScene
{
    CCSprite *_player;
    
    CCPhysicsNode *_physicsWorld;
    
    CCLabelTTF *_scoreLabel;
    
    int _score;
}

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (CartmanShootScene *)scene
{
    return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init {
    self = [super init];
    if (!self) return(nil);
    
    _score = 0;
    
    // Enable touch handling on scene node
    self.userInteractionEnabled = YES;
    
    [self addBackgroundMusic];
    
    [self createBackground];
    
    [self createScoreLabel];
    
    [self createPhysicsWorld];
    
    [self createPlayer];
    
    [self addBackButton];
    
	return self;
}

- (void)addBackgroundMusic {
    [[OALSimpleAudio sharedInstance] playBg:@"Wild-Wild-West.mp3" loop:YES];
}

- (void)createBackground {
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor whiteColor]];
    [self addChild:background];
    
    CCSprite *backgroundImage = [CCSprite spriteWithImageNamed:@"southParkTown.jpg"];
    CGRect textureRect = [[UIScreen mainScreen]bounds];
    textureRect.origin.y = 80;
    [backgroundImage setTextureRect:textureRect];
    backgroundImage.anchorPoint = CGPointZero;
    backgroundImage.position = CGPointZero;
    [self addChild:backgroundImage];
}

- (void)createScoreLabel {
    _scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Score: %d", _score] fontName:@"Chalkduster" fontSize:18];
    _scoreLabel.positionType = CCPositionTypeNormalized;
    _scoreLabel.position     = ccp(0.1, 0.95);
    [self addChild:_scoreLabel];
}

- (void)createPhysicsWorld {
    _physicsWorld = [CCPhysicsNode node];
    _physicsWorld.gravity = ccp(0, 0);
    _physicsWorld.collisionDelegate = self;
    [self addChild:_physicsWorld];
}

- (void)createPlayer {
    _player = [CCSprite spriteWithImageNamed:@"cartman-player.png"];
    _player.position    = ccp(self.contentSize.width/8,self.contentSize.height/2);
    _player.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, _player.contentSize} cornerRadius:0];
    _player.physicsBody.collisionGroup = @"playerGroup";
    _player.physicsBody.collisionType  = @"playerCollision";
    [_physicsWorld addChild:_player];
}

- (void)addBackButton {
    CCButton *backButton = [CCButton buttonWithTitle:@"[ Menu ]" fontName:@"Chalkduster" fontSize:18.0f];
    backButton.positionType = CCPositionTypeNormalized;
    backButton.position = ccp(0.9f, 0.95f); // Top Right of screen
    [backButton setTarget:self selector:@selector(onBackClicked:)];
    [self addChild:backButton];
}

- (void)addSatan:(CCTime)dt {
    CCSprite *satan = [CCSprite spriteWithImageNamed:@"Satan.png"];
    
    int minY    = satan.contentSize.height / 2;
    int maxY    = self.contentSize.height - satan.contentSize.height;
    int rangeY  = maxY - minY;
    int randomY = (arc4random() % rangeY) + minY;
    
    satan.position = CGPointMake(self.contentSize.width + satan.contentSize.width/2, randomY);
    satan.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, satan.contentSize} cornerRadius:0];
    satan.physicsBody.collisionGroup = @"satanGroup";
    satan.physicsBody.collisionType  = @"satanCollision";
    [_physicsWorld addChild:satan];
    
    int minDuration    = 2;
    int maxDuration    = 5;
    int rangeDuration  = maxDuration - minDuration;
    int randomDuration = (arc4random() % rangeDuration) + minDuration;
    
    CCAction *action = [CCActionMoveTo actionWithDuration:randomDuration
                                                 position:CGPointMake(-satan.contentSize.width/2, randomY)];
    CCActionRemove *actionRemove = [CCActionRemove action];
    [satan runAction:[CCActionSequence actionWithArray:@[action, actionRemove]]];
}

// -----------------------------------------------------------------------

- (void)dealloc
{
    // clean up code goes here
}

// -----------------------------------------------------------------------
#pragma mark - Enter & Exit
// -----------------------------------------------------------------------

- (void)onEnter
{
    // always call super onEnter first
    [super onEnter];
    
    [self schedule:@selector(addSatan:) interval:1.0];
}

// -----------------------------------------------------------------------

- (void)onExit
{
    // always call super onExit last
    [super onExit];
}

// -----------------------------------------------------------------------
#pragma mark - Touch Handler
- (void)shootBullet:(UITouch *)touch {
    CGPoint touchLocation = [touch locationInNode:self];
    
    CGPoint offset = ccpSub(touchLocation, _player.position);
    float ratio    = offset.y / offset.x;
    int targetX    = _player.contentSize.width/2 + self.contentSize.width;
    int targetY    = (targetX * ratio) + _player.position.y;
    CGPoint targetPosition = ccp(targetX, targetY);
    
    CCSprite *bullet = [CCSprite spriteWithImageNamed:@"bullet.png"];
    CGPoint bulletPosition = _player.position;
    bulletPosition.x += 45;
    bulletPosition.y += 30;
    bullet.position = bulletPosition;
    bullet.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, bullet.contentSize} cornerRadius:0];
    bullet.physicsBody.collisionGroup = @"playerGroup";
    bullet.physicsBody.collisionType  = @"bulletCollision";
    [_physicsWorld addChild:bullet];
    
    CCActionMoveTo *actionMoveTo = [CCActionMoveTo actionWithDuration:1.5
                                                             position:targetPosition];
    CCActionRemove *removeAction = [CCActionRemove action];
    [bullet runAction:[CCActionSequence actionWithArray:@[actionMoveTo, removeAction]]];
    
    [[OALSimpleAudio sharedInstance] playEffect:@"pew-pew-lei.caf"];
}

// -----------------------------------------------------------------------

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    [self shootBullet:touch];
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair satanCollision:(CCNode *)satan bulletCollision:(CCNode *)bullet
{
    [satan removeFromParent];
    [bullet removeFromParent];
    
    ++_score;
    _scoreLabel.string = [NSString stringWithFormat:@"Score: %d", _score];
    
    return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair playerCollision:(CCNode *)player satanCollision:(CCNode *)satan
{
    [player removeFromParent];
    
    [self createDeadCartman];
    
    [self addLoseSound];
    [self addLoseLabel];
    
    return YES;
}

- (void)createDeadCartman {
    _player = [CCSprite spriteWithImageNamed:@"Dead_Cartman.png"];
    _player.position    = ccp(self.contentSize.width/8,self.contentSize.height/2);
    [_physicsWorld addChild:_player];
}

- (void)addLoseSound {
    [[OALSimpleAudio sharedInstance]stopAllEffects];
    
    [[OALSimpleAudio sharedInstance]playBg:@"UNCLE_FUCKER.mp3" loop:YES];
}

- (void)addLoseLabel {
    CCLabelTTF *loseLabel = [CCLabelTTF labelWithString:@"You Lose" fontName:@"Chalkduster" fontSize:80];
    loseLabel.fontColor = [CCColor blackColor];
    loseLabel.positionType = CCPositionTypeNormalized;
    loseLabel.position     = CGPointMake(0.5, 0.5);
    [self addChild:loseLabel];
}


// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
- (void)presentMenu
{
    [[CCDirector sharedDirector] replaceScene:[IntroScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:1.0f]];
}

// -----------------------------------------------------------------------

- (void)onBackClicked:(id)sender
{
    [self presentMenu];
}

// -----------------------------------------------------------------------
@end
