//
//  HUDLayer.m
//  Tube Man Boxing
//
//  Created by Alex Mordue on 3/07/12.
//  Copyright 2012
//

#import "HUDLayer.h"
#import "CCAnimationHelper.h"
#import "GameplayLayer.h"
#import "SimpleAudioEngine.h"
#import "PauseLayer.h"

@interface HUDLayer(PrivateMethods)
-(void) removeCountIn;
@end

@implementation HUDLayer
-(id) init
{
    if (self = [super init])
    {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        //Timer
        timeLabel = [CCLabelBMFont labelWithString:@"00" fntFile:@"bitmapfont.fnt"];
		timeLabel.position = CGPointMake(screenSize.width/2, screenSize.height-32);
        [self addChild:timeLabel z:2 tag:HUDLayerTagTimeLabel];
        
        //Character names
        playerLabel = [CCLabelBMFont labelWithString:@"Player1" fntFile:@"bitmapfont.fnt"];
		playerLabel.position = CGPointMake(screenSize.width/4, screenSize.height-32);
        [self addChild:playerLabel z:5 tag:HUDLayerTagTimeLabel];
        
        //Hit marker
        CCSprite* hitMarkerSprite = [CCSprite spriteWithSpriteFrameName:@"hit.png"];
        hitMarkerSprite.visible = NO;
        [self addChild:hitMarkerSprite z:2 tag:HUDLayerTagHitMarker];
        
        //Create the healthbars
        CCSprite* rightHPOutline = [CCSprite spriteWithSpriteFrameName:@"health-outline.png"];
        CCSprite* leftHPOutline = [CCSprite spriteWithSpriteFrameName:@"health-outline.png"];
        CCSprite* rightHPBack = [CCSprite spriteWithSpriteFrameName:@"health-back.png"];
        CCSprite* leftHPBack = [CCSprite spriteWithSpriteFrameName:@"health-back.png"];
        CCSprite* rightHPFilled = [CCSprite spriteWithSpriteFrameName:@"health-filled.png"];
        CCSprite* leftHPFilled = [CCSprite spriteWithSpriteFrameName:@"health-filled.png"];
        
        //Create specialbars
        CCSprite* rightSpecialOutline = [CCSprite spriteWithSpriteFrameName:@"special-outline.png"];
        CCSprite* leftSpecialOutline = [CCSprite spriteWithSpriteFrameName:@"special-outline.png"];
        CCSprite* rightSpecialFilled = [CCSprite spriteWithSpriteFrameName:@"special-filled.png"];
        CCSprite* leftSpecialFilled = [CCSprite spriteWithSpriteFrameName:@"special-filled.png"];
        
        //Rotate
        rightHPOutline.scaleX = -1;
        rightSpecialOutline.scaleX = -1;
        rightSpecialFilled.scaleX = 0;
        leftSpecialFilled.scaleX = 0;
        rightHPBack.scaleX = rightHPOutline.scaleX;
        rightHPFilled.scaleX = rightHPOutline.scaleX;
        
        //Change anchor points for ease of scaling X later
        rightHPOutline.anchorPoint = CGPointMake(0, 0.5f);
        rightHPBack.anchorPoint = rightHPOutline.anchorPoint;
        rightHPFilled.anchorPoint = rightHPOutline.anchorPoint;
        rightSpecialOutline.anchorPoint = rightHPOutline.anchorPoint;
        rightSpecialFilled.anchorPoint = rightHPOutline.anchorPoint;
        
        leftHPOutline.anchorPoint = CGPointMake(0, 0.5f);
        leftHPBack.anchorPoint = leftHPOutline.anchorPoint;
        leftHPFilled.anchorPoint = leftHPOutline.anchorPoint;
        leftSpecialOutline.anchorPoint = leftHPOutline.anchorPoint;
        leftSpecialFilled.anchorPoint = leftHPOutline.anchorPoint;
        
        //Position them
        rightHPOutline.position = CGPointMake(screenSize.width-rightHPOutline.textureRect.size.width/6,
                                              screenSize.height-rightHPOutline.textureRect.size.height);
        leftHPOutline.position = CGPointMake(leftHPOutline.textureRect.size.width/6,
                                             rightHPOutline.position.y);
        rightHPBack.position = rightHPOutline.position;
        leftHPBack.position = leftHPOutline.position;
        rightHPFilled.position = rightHPOutline.position;
        leftHPFilled.position = leftHPOutline.position;
        
        //Special pos
        rightSpecialOutline.position = CGPointMake(rightHPOutline.position.x, rightHPOutline.position.y-16);
        rightSpecialFilled.position = rightSpecialOutline.position;
        leftSpecialOutline.position = CGPointMake(leftHPOutline.position.x, leftHPOutline.position.y-16);
        leftSpecialFilled.position = leftSpecialOutline.position;
        
        //Add them
        [self addChild:rightHPOutline z:2];
        [self addChild:leftHPOutline z:2];
        [self addChild:rightSpecialOutline z:2];
        [self addChild:leftSpecialOutline z:2];
        [self addChild:rightHPBack z:0];
        [self addChild:leftHPBack z:0];
        [self addChild:rightHPFilled z:1 tag:HUDLayerTagPlayerHealth];
        [self addChild:leftHPFilled z:1 tag:HUDLayerTagOpponentHealth];
        [self addChild:rightSpecialFilled z:1 tag:HUDLayerTagPlayerSpecial];
        [self addChild:leftSpecialFilled z:1 tag:HUDLayerTagOpponentSpecial];
        
        //Count in the fight
        [self countIn];
    }
    
    return self;
}

-(void) bellSound
{
    SimpleAudioEngine* audio = [SimpleAudioEngine sharedEngine];
    [audio playEffect:@"bell.mp3"];
}

-(void) countIn
{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    //Pause fighters
    GameplayLayer* game = [GameplayLayer sharedGameScene];
    [game pauseForCountIn];
    
    //Graphics
    CCSprite* count = [CCSprite spriteWithSpriteFrameName:@"count-in0.png"];
    count.position = CGPointMake(screenSize.width/2, screenSize.height/2);
    [self addChild:count z:3 tag:HUDLayerTagCountIn];
    CCAnimation* anim = [CCAnimation animationWithFrame:@"count-in" frameCount:5 delay:0.5f];
     
    // run the animation by using the CCAnimate action
    CCAnimate* animate = [CCAnimate actionWithAnimation:anim restoreOriginalFrame:NO];
    count = (CCSprite*)[self getChildByTag:HUDLayerTagCountIn];
    [count runAction:[CCSequence actions:
                     animate,
                     [CCCallFuncN actionWithTarget:self selector:@selector(bellSound)],
                     [CCCallFuncN actionWithTarget:game selector:@selector(unpause)],
                     [CCCallFuncN actionWithTarget:self selector:@selector(removeCountIn)],
                     nil]];
}

-(void) removeCountIn
{
    [self removeChildByTag:HUDLayerTagCountIn cleanup:YES];
}

-(void) updateSpecial:(float)coefficient player:(BOOL)player
{
    if (coefficient > 1)
        coefficient = 1;
    
    if (!player)
    {
        CCSprite* specialBar = (CCSprite*)[self getChildByTag:HUDLayerTagPlayerSpecial];
        coefficient *= -1;
        specialBar.scaleX = coefficient;
    }
    else
    {
        CCSprite* specialBar = (CCSprite*)[self getChildByTag:HUDLayerTagOpponentSpecial];
        specialBar.scaleX = coefficient;
    }

}

-(void) updateHealth:(float)coefficient player:(BOOL)player
{
    if (coefficient < 0)
        coefficient = 0;
    
    if (!player)
    {
        CCSprite* healthBar = (CCSprite*)[self getChildByTag:HUDLayerTagPlayerHealth];
        coefficient *= -1;
        healthBar.scaleX = coefficient;
    }
    else
    {
        CCSprite* healthBar = (CCSprite*)[self getChildByTag:HUDLayerTagOpponentHealth];
        healthBar.scaleX = coefficient;
    }
}

-(void) removeHitMarker:(ccTime)delta
{
    CCSprite* hitMarkerSprite = (CCSprite*)[self getChildByTag:HUDLayerTagHitMarker];
    hitMarkerSprite.visible = NO;
}

-(void) hitMarker:(CGPoint)pos
{
    [self stopAllActions];
    CCSprite* hitMarkerSprite = (CCSprite*)[self getChildByTag:HUDLayerTagHitMarker];
    hitMarkerSprite.visible = YES;
    hitMarkerSprite.position = pos;
    [self schedule:@selector(removeHitMarker:) interval:0.5f];
}

-(void) addRoundIndicator:(BOOL)player
{
    //Create sprite
    CCSprite* roundind = [CCSprite spriteWithSpriteFrameName:@"round-ind.png"];
    
    if (player)
    {
        CCSprite* sbar = (CCSprite*)[self getChildByTag:HUDLayerTagOpponentSpecial];
        roundind.position = CGPointMake(sbar.position.x, sbar.position.y-16);
    }
    else
    {
        CCSprite* sbar = (CCSprite*)[self getChildByTag:HUDLayerTagPlayerSpecial];
        roundind.position = CGPointMake(sbar.position.x, sbar.position.y-16);
    }
    
    [self addChild:roundind z:10];
}

-(void) knockOut
{
    //Text
    CCLabelBMFont* koText = [CCLabelBMFont labelWithString:@"K.O." fntFile:@"bitmapfont.fnt"];
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    koText.position = CGPointMake(screenSize.width/2, screenSize.height/2);
    [self addChild:koText z:2 tag:HUDLayerTagKO];
    GameplayLayer* game = [GameplayLayer sharedGameScene];
    [game schedule:@selector(reset:) interval:3];
}

-(void) reset:(BOOL)playerWon
{
    //Reset health bars
    [self updateHealth:1.0f player:YES];
    [self updateHealth:1.0f player:NO];
    
    //Show a round indicator
    [self addRoundIndicator:playerWon];
    
    //remove KO
    [self removeChildByTag:HUDLayerTagKO cleanup:NO];
}

-(void) showPauseLayer
{
    PauseLayer* pauseLayer = [PauseLayer node];
    [self addChild:pauseLayer z:10 tag:HUDLayerTagPauseScreen];
}

-(void) removePauseLayer
{
    [self removeChildByTag:HUDLayerTagPauseScreen cleanup:YES];
}

-(void)dealloc
{
    [super dealloc];
}

@end
