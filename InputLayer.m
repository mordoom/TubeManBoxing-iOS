//
//  InputLayer.h
//  TMB
//
//  Created by Alex Mordue on 12/01/12.
//  Copyright 2012
//

#import "InputLayer.h"
#import "GameplayLayer.h"
#import "FighterSprite.h"
#import "NetworkPackets.h"

@interface InputLayer(PrivateMethods)
-(void)addHighAttackButton;
-(void)addLowAttackButton;
-(void)addDeflateButton;
-(void)addSpecialAttackButton;
@end

@implementation InputLayer
static const float BUTTON_RADIUS = 100;
static const float PAUSEBUTTON_RADIUS = 16;
static const bool VISIBILITY = NO;
static const float SHOT_BREAK = 0.1f;
-(id) init
{
	if ((self = [super init]))
	{
		[self addHighAttackButton];
        [self addLowAttackButton];
        [self addDeflateButton];
        [self addSpecialAttackButton];
        [self addPauseButton];
		[self scheduleUpdate];
	}
	
	return self;
}

-(void) dealloc
{
	[super dealloc];
}

-(void) addPauseButton
{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    //Button
    //float halfRad = PAUSEBUTTON_RADIUS/1.5;
    pauseButton = [SneakyButton buttonAtPos:CGPointMake(screenSize.width-PAUSEBUTTON_RADIUS,
                                                        screenSize.height-PAUSEBUTTON_RADIUS)
                                          radius:PAUSEBUTTON_RADIUS];
    
    //Skin
    SneakyButtonSkinnedBase* pauseButtonSkin = [SneakyButtonSkinnedBase skinnedButton];
    pauseButtonSkin.defaultSprite = [CCSprite spriteWithSpriteFrameName:@"pause.png"];
    pauseButtonSkin.pressSprite = [CCSprite spriteWithSpriteFrameName:@"pause.png"];
    pauseButtonSkin.scale = 1.0f;
    pauseButtonSkin.position = pauseButton.position;
    
    [self addChild:pauseButton];
    [self addChild:pauseButtonSkin];
}

-(void) addHighAttackButton
{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    //Button
    highAttackButton = [SneakyButton buttonAtPos:CGPointMake(screenSize.width-BUTTON_RADIUS*1.2,
                                                             screenSize.height - BUTTON_RADIUS*0.5)
                                          radius:BUTTON_RADIUS];
    
    //Skin
    SneakyButtonSkinnedBase* highButtonSkin = [SneakyButtonSkinnedBase skinnedButtonWithVisibility:VISIBILITY];
    highButtonSkin.position = highAttackButton.position;
    
    [self addChild:highAttackButton];
    [self addChild:highButtonSkin];
}

-(void) addLowAttackButton
{
    //Button
    lowAttackButton = [SneakyButton buttonAtPos:CGPointMake(highAttackButton.position.x, BUTTON_RADIUS/2) radius:BUTTON_RADIUS];

    //Skin
    SneakyButtonSkinnedBase* lowButtonSkin = [SneakyButtonSkinnedBase skinnedButtonWithVisibility:VISIBILITY];
    lowButtonSkin.position = lowAttackButton.position;
    
    [self addChild:lowAttackButton];
    [self addChild:lowButtonSkin];
}

-(void) addDeflateButton
{
    //Button
    deflateButton = [SneakyButton buttonAtPos:CGPointMake(BUTTON_RADIUS, BUTTON_RADIUS*0.5) radius:BUTTON_RADIUS];
    
    //Skin
    SneakyButtonSkinnedBase* deflateButtonSkin = [SneakyButtonSkinnedBase skinnedButtonWithVisibility:VISIBILITY];
    deflateButtonSkin.position = deflateButton.position;
    
    [self addChild:deflateButton];
    [self addChild:deflateButtonSkin];

}

-(void) addSpecialAttackButton
{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    //Button
    specialAttackButton = [SneakyButton buttonAtPos:CGPointMake(BUTTON_RADIUS, screenSize.height - BUTTON_RADIUS*0.5) radius:BUTTON_RADIUS];
    
    //Skin
    SneakyButtonSkinnedBase* specialAttackButtonSkin = [SneakyButtonSkinnedBase skinnedButtonWithVisibility:VISIBILITY];
    specialAttackButtonSkin.position = specialAttackButton.position;
    
    [self addChild:specialAttackButton];
    [self addChild:specialAttackButtonSkin];
}

-(void) turnOnMultiplayer
{
    multiplayer = YES;
}

-(void) updateNextShotTime
{
    nextShotTime = totalTime + SHOT_BREAK;
}

-(void) update:(ccTime)delta
{
    totalTime += delta;
    
    //Get singletons
    GameplayLayer* game = [GameplayLayer sharedGameScene];
    FighterSprite* fighter = [game defaultFighter];
    
    if (totalTime > nextShotTime)
    {
        if (game.state == Playing)
        {
            //HighAttack
            if (highAttackButton.active)
            {
                [fighter performHighAttack];
                
                //if (multiplayer)
                  //  [game sendButtonPress:ButtonHighAttack];
                
                [self updateNextShotTime];
            }
            //LowAttack
            else if (lowAttackButton.active)
            {
                [fighter performLowAttack];
                
                //if (multiplayer)
                  //  [game sendButtonPress:ButtonLowAttack];
                
                [self updateNextShotTime];
            }
            //Deflate
            else if (deflateButton.active)
            {
                [fighter performDeflate];
                
                //if (multiplayer)
                  //  [game sendButtonPress:ButtonDeflate];
                
                [self updateNextShotTime];
            }
            //Special
            else if (specialAttackButton.active)
            {
                [fighter performSpecialAttack];
                
                //if (multiplayer)
                  //  [game sendButtonPress:ButtonSpecial];
                
                [self updateNextShotTime];
            }
            //Pause
            else if (pauseButton.active)
            {
                //Pause/unpause game
                [game pause];
                CCLOG(@"PAUSE PRESSED");
                [self updateNextShotTime];
            }
        }
        //Unpause
        else if (game.state == Paused)
        {
            if (pauseButton.active)
            {
                [game unpause];
                CCLOG(@"PAUSE UNPRESSED");
                [self updateNextShotTime];
            }
        }
    }

}
@end
