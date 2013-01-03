//
//  OpponentSprite.m
//  Tube Man Boxing
//
//  Created by Cheebang on 27/06/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "OpponentSprite.h"
#import "CCAnimationHelper.h"
#import "GameplayLayer.h"
#import "HUDLayer.h"

@interface OpponentSprite(PrivateMethods)
-(id) initWithOpponentImage;
-(void) idle;
-(void) performLowAttack;
-(void) performHighAttack;
-(void) performDeflate;
@end

@implementation OpponentSprite
@synthesize inflated;
@synthesize health;
const int MAX_HEALTH = 100;

+(id) opponent
{
	return [[[self alloc] initWithOpponentImage] autorelease];
}

-(id) initWithOpponentImage
{
	if ((self = [super initWithSpriteFrameName:@"enemy-idle0.png"]))
	{
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        self.scaleX = -1;
        self.position = CGPointMake(screenSize.width/2 - self.textureRect.size.width/2.25, screenSize.height / 2.5);
        
        //Alive
        alive = YES;
        
        //Health
        health = MAX_HEALTH;
        
        [self idle];
        [self scheduleUpdate];
	}
	return self;
}

-(void) idle
{
    [self stopAllActions];
    //Inflated state
    inflated = YES;
    //state = IDLE;
    // create an animation object from all the sprite animation frames
    CCAnimation* anim = [CCAnimation animationWithFrame:@"enemy-idle" frameCount:3 delay:0.15f];
    // run the animation by using the CCAnimate action
    CCAnimate* animate = [CCAnimate actionWithAnimation:anim restoreOriginalFrame:YES];
    CCRepeatForever* repeat = [CCRepeatForever actionWithAction:animate];
    [self runAction:repeat];

}

-(void) die
{
    alive = NO;
    [self stopAllActions];
    [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"enemy-deflate0.png"]];
}

-(void) gotHit
{
    //state = HIT;
    
    //Take off health
    health -=3;
    
    //Update healthbar
    HUDLayer* hud = (HUDLayer*)[[GameplayLayer sharedGameScene] getChildByTag:GameSceneLayerTagHUD];
    float coefficient = (float)health/MAX_HEALTH;
    
    //Check if dead
    if (coefficient >= 0)
        [hud updateOpponentHealth:coefficient];
    else
        [self die];
    
    if (alive)
    {
        // create an animation object from all the sprite animation frames
        CCAnimation* anim = [CCAnimation animationWithFrame:@"enemy-hit" frameCount:1 delay:0.5f];
        
        // run the animation by using the CCAnimate action
        CCAnimate* animate = [CCAnimate actionWithAnimation:anim restoreOriginalFrame:YES];
        [self runAction:[CCSequence actions:
                         animate,
                         [CCCallFuncN actionWithTarget:self selector:@selector(idle)],
                         nil]];
    }

}

-(void) performHighAttack
{
    //state = HIGHATTACK;
    
    // create an animation object from all the sprite animation frames
    CCAnimation* anim = [CCAnimation animationWithFrame:@"enemy-highattack" frameCount:1 delay:0.5f];
    
    // run the animation by using the CCAnimate action
    CCAnimate* animate = [CCAnimate actionWithAnimation:anim restoreOriginalFrame:YES];
    
    [self runAction:[CCSequence actions:
                     animate,
                     [CCCallFuncN actionWithTarget:self selector:@selector(idle)],
                     nil]];
    
    //Damage enemy
    //OpponentSprite* enemy = [[GameplayLayer sharedGameScene] defaultFighter];
    //if (enemy.inflated)
    //{
    //    [enemy gotHit];
    //}
}

-(void) performLowAttack
{
    //state = LOWATTACK;
    
    // create an animation object from all the sprite animation frames
    CCAnimation* anim = [CCAnimation animationWithFrame:@"enemy-lowattack" frameCount:1 delay:0.5f];
    
    // run the animation by using the CCAnimate action
    CCAnimate* animate = [CCAnimate actionWithAnimation:anim restoreOriginalFrame:YES];
    [self runAction:[CCSequence actions:
                     animate,
                     [CCCallFuncN actionWithTarget:self selector:@selector(idle)],
                     nil]];
    
    //Enemy hit
    //OpponentSprite* enemy = [[GameplayLayer sharedGameScene] defaultFighter];
    //if (enemy.inflated)
    //{
    //    [enemy gotHit];
    //}
}


-(void) performDeflate
{
    //Inflated state
    inflated = NO;
    //state = DEFLATE;
    
    // create an animation object from all the sprite animation frames
    CCAnimation* anim = [CCAnimation animationWithFrame:@"enemy-deflate" frameCount:1 delay:0.5f];
    
    // run the animation by using the CCAnimate action
    CCAnimate* animate = [CCAnimate actionWithAnimation:anim restoreOriginalFrame:YES];
    [self runAction:[CCSequence actions:
                     animate,
                     [CCCallFuncN actionWithTarget:self selector:@selector(idle)],
                     nil]];
}


-(void) update:(ccTime)delta
{
    //Do AI stuff here
    totalTime += delta;
    
    if (totalTime > nextShotTime )
    {
        //Generate random number
        int num = (arc4random() % 4);
        
        switch (num) {
            case 0:
                [self performHighAttack];
                break;
            case 1:
                [self performLowAttack];
                break;
            case 2:
                [self performDeflate];
                break;
                
            default:
                break;
        }
        
        nextShotTime = totalTime + 0.75f;
    }
}

-(void) dealloc
{
    [super dealloc];
}

@end