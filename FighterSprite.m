//
//  FighterSprite.m
//  Tube Man Boxing
//
//  Created by Alex Mordue on 27/06/12.
//  Copyright 2012
//

#import "FighterSprite.h"
#import "GameplayLayer.h"
#import "CCAnimationHelper.h"
#import "HUDLayer.h"
#import "QueueAdditions.h"
#import "SimpleAudioEngine.h"

@interface FighterSprite(PrivateMethods)
-(id) initWithFighterImage:(NSString*)type player:(BOOL)player;
-(void) changeStance;
@end

@implementation FighterSprite
@synthesize health, state, enemy;
static const int MAX_HEALTH = 100;
static const int MAX_SPEC = 100;

+(id) fighter:(NSString*) type player:(BOOL)player difficulty:(int)difficulty
{
	return [[[self alloc] initWithFighterImage:type player:player difficulty:difficulty] autorelease];
}

-(id) initWithFighterImage:(NSString*)spriteType player:(BOOL)player difficulty:(int)difficulty
{
    //Set up
    NSString* frameName = [NSString stringWithFormat:@"%@-idle0.png", spriteType];
    NSString* resourceName = [NSString stringWithFormat:@"%@-art.plist", spriteType];
    CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    [frameCache addSpriteFramesWithFile:resourceName];

    if ((self = [super initWithSpriteFrameName:frameName]))
	{
        //Transparency settings
        [self setBlendFunc: (ccBlendFunc) { GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA }];
        [self setOpacityModifyRGB:NO];
        
        type = spriteType;
        health = MAX_HEALTH;
        special = 0;
        playerCharacter = player;
        combo = [[NSMutableArray alloc] init];
        stances = [[NSMutableDictionary alloc] init];
        aiDifficulty = difficulty;
        state = COUNTIN;
        
        //Set up sound effects
        punchSoundList = [NSArray arrayWithObjects:@"punch.mp3", @"punch.mp3", nil];
        
        //Load in fight stances
        NSString* path = [[NSBundle mainBundle] pathForResource:type ofType:@"txt"];
        NSString* content = [NSString stringWithContentsOfFile:path
                                                      encoding:NSUTF8StringEncoding
                                                         error:NULL];
        NSArray* fightStancesData = [content componentsSeparatedByString:@"\n"];
        NSEnumerator *e = [fightStancesData objectEnumerator];
        NSString* str;
        
        //Enumerate through data
        while (str = [e nextObject])
        {
            //Split on commas
            NSArray* stanceData = [str componentsSeparatedByString:@","];
            
            NSString* key = [stanceData objectAtIndex:0];
            int frames = [[stanceData objectAtIndex:1] intValue];
            float duration = [[stanceData objectAtIndex:2] floatValue];
            NSString* highAttack = [stanceData objectAtIndex:3];
            NSString* lowAttack = [stanceData objectAtIndex:4];
            int damage = [[stanceData objectAtIndex:5] intValue];
            float ht = [[stanceData objectAtIndex:6] floatValue];
            
            FightStance* temp = [FightStance stanceWithNoOfFrames:frames
                                                         duration:duration
                                                       highAttack:highAttack
                                                        lowAttack:lowAttack
                                                           damage:damage
                                                            hitTime:ht];
            
            //Add stance object to stances
            [stances setObject:temp forKey:key];
        }
        if (!player && aiDifficulty > 0)
            //schedule AI updates
            [self scheduleUpdate];
        
        if (player)
            //Flip image
            self.scaleX = -1;
	}
	return self;
}

-(void) pause
{
    //Stop actions
    [self pauseSchedulerAndActions];
}

-(void) unpause
{
    //resume actions
    [self resumeSchedulerAndActions];
    
    //Match has just started
    if (state == COUNTIN || state == DEAD)
        [self changeStance];
}

-(void) updateSpecialBy:(int)amount
{    
    //Check if spec full
    if (special < 100 || amount < 0)
    {
        //Update specialbar
        HUDLayer* hud = (HUDLayer*)[[GameplayLayer sharedGameScene] getChildByTag:GameSceneLayerTagHUD];
        special += amount;
            if (special < 0)
                special = 0;
        float specCoefficient = (float)special/MAX_SPEC;
        [hud updateSpecial:specCoefficient player:playerCharacter];
    }
}

-(void) performAttackType:(FighterState)attackType
{
    //Get the last attack's appropriate combo if available
    NSString* lastStance = combo.lastObject;
    FightStance* stance;
    if (lastStance != nil)
    {
        stance = [stances objectForKey:lastStance];
        //Update specialbar - combo move
        [self updateSpecialBy:5];
    }
    else
    {
        //First move in combo
        stance = [stances objectForKey:currentStance];
    }
    
    //Determine which attack to append to the combo
    NSString* attackName;
    switch (attackType)
    {
        case HIGHATTACK:
            attackName = stance.highAttack;
            break;
        case LOWATTACK:
            attackName = stance.lowAttack;
            break;
        case DEFLATE:
            attackName = @"deflate";
            break;
        case SPECIAL:
            attackName = @"special";
            break;
        default:
            CCLOG(@"Unknown attack attempted!");
            break;
    }

    //Make sure the character is able to attack
    if (state == IDLE || state == HIGHATTACK || state == LOWATTACK || state == DEFLATE)
    {
        //change state
        state = attackType;
        
        //Idle is used as a sentinel
        if (![lastStance isEqualToString:@"idle"])
        {
            //Enqueue - combo is still going
            [combo enqueue:attackName];
            
            if ([currentStance isEqualToString:@"idle"])
                //Need to manually schedule to change stance
                [self changeStance];
        }
    }
}

//Public interfaces to attacks
-(void) performHighAttack
{
    [self performAttackType:HIGHATTACK];
}

-(void) performLowAttack
{
    [self performAttackType:LOWATTACK];
}

-(void) performDeflate
{
    if (state == IDLE)
    {
        //perform deflate
        [self performAttackType:DEFLATE];
        
        //Play whoosh
        [[SimpleAudioEngine sharedEngine] playEffect:@"whip.mp3"];
    }
}

-(void) performSpecialAttack
{
    //Could change it so you dont have to be idle, but your combo is cleared?
    if (special >= 100 && state == IDLE)
    {
        //Deplete special meter
        [self updateSpecialBy:-100];
        
        //Perform the attack
        [self performAttackType:SPECIAL];
        
        //Play special specific sound?
    }
    //else
    //play failed special sound
}

-(void) die
{
    state = DEAD;
    [self stopAllActions];
    
    //Update healthbar
    HUDLayer* hud = (HUDLayer*)[[GameplayLayer sharedGameScene] getChildByTag:GameSceneLayerTagHUD];
    [hud knockOut];
    NSString* frameName = [NSString stringWithFormat:@"%@-deflate0.png", type];
    [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName]];
}

-(void) stunned
{
    state = STUNNED;
    [self stopAllActions];
    [self clearCombo];
    [combo enqueue:@"stunned"];
    [self changeStance];
}

-(void) gotHit:(FightStance*)stance
{
    //Determine if the attack connected
    bool vulnerable = state != DEFLATE && state != DEAD;
    bool enemyStillAttacking = enemy.state == LOWATTACK || enemy.state == HIGHATTACK || enemy.state == SPECIAL;
    
    if (vulnerable && enemyStillAttacking)
    {
        //update state
        state = HIT;
        
        //Just to be sure - clear combo queue
        [combo removeAllObjects];
        
        //Take off health
        health -= stance.damage.intValue;
        
        //Update healthbar
        HUDLayer* hud = (HUDLayer*)[[GameplayLayer sharedGameScene] getChildByTag:GameSceneLayerTagHUD];
        float hpCoefficient = (float)health/MAX_HEALTH;
        [hud updateHealth:hpCoefficient player:playerCharacter];
        [hud hitMarker:self.position];
        
        //Update specialbar
        [self updateSpecialBy:3];
        
        //Play sound - randomise?
        [[SimpleAudioEngine sharedEngine] playEffect:@"punch.mp3"];
    
        //Check if dead
        if (hpCoefficient <= 0)
            [self die];
        
        if (health > 0)
        {
            //Clear actions
            [self stopAllActions];
            
            // create an animation object from all the sprite animation frames
            NSString* frameName;
            float delay = 0.5f;
            
            //Different frames based on low/high attacks
            switch (enemy.state) {
                case LOWATTACK:
                    frameName = [NSString stringWithFormat:@"%@-lowhit", type];
                    break;
                case SPECIAL:
                    delay = 1.1f;
                case HIGHATTACK:
                    frameName = [NSString stringWithFormat:@"%@-hit", type];
                    break;
                default:
                    //attack was interrupted
                    CCLOG(@"Error: unknown hit connected");
                    break;
            }
            
            //Re-order sprites
            [self.parent reorderChild:self z:1];
            
            //The duration of this animation decides the recovery time from damage
            CCAnimation* anim = [CCAnimation animationWithFrame:frameName frameCount:1 delay:delay];
            
            // run the animation by using the CCAnimate action
            CCAnimate* animate = [CCAnimate actionWithAnimation:anim restoreOriginalFrame:YES];
            [self runAction:[CCSequence actions:
                             animate,
                             [CCCallFuncN actionWithTarget:self selector:@selector(changeStance)],
                             nil]];
        }
    }
    if (!vulnerable)
    {
        //Attack missed - clear enemy's combo
        [enemy clearCombo];
    }
}

-(void) clearCombo
{
    CCLOG(@"Combo broken!");
    [combo removeAllObjects];
    
    //Sentinel - perhaps keep this encapsulated better by just calling changeStance?
    [combo enqueue:@"idle"];
}

-(void) update:(ccTime)delta
{
    //Do AI stuff here
    totalTime += delta;
    
    if (totalTime > nextShotTime && enemy.state != DEAD)
    {
        if (special < 100)
        {
            //Get the current stance object
            //FightStance* stance = [stances objectForKey:currentStance];
        
            int decision = (arc4random() % aiDifficulty);
            
            switch (decision) {
                case 0:
                    //if (![stance.highAttack isEqualToString:@"idle"])
                        [self performHighAttack];
                    break;
                case 1:
                    //if (![stance.lowAttack isEqualToString:@"idle"])
                        [self performLowAttack];
                    break;
                case 2:
                    [self performDeflate];
                    break;
                default:
                    break;
            }
        }
        else
        {
            //Try to special
            if (enemy.state == IDLE)
            {
                [self performSpecialAttack];
            }
            else
            {
                [self performDeflate];
            }
        }
        nextShotTime = totalTime + 0.25f;
    }
}

//Methods for the new combo system
-(void) changeStance
{
    //Avoid double scheduling
    //[self unschedule:_cmd];
    
    //Dequeue next stance from combo queue
    currentStance = [combo dequeue];
    
    //Change to idle stance if there is no attack queued
    if (currentStance == nil)
        currentStance = @"idle";
    
    // create an animation object from all the sprite animation frames
    NSString* frameName = [NSString stringWithFormat:@"%@-%@", type, currentStance];
    FightStance* stance = [stances objectForKey:currentStance];
    CCAnimation* anim = [CCAnimation animationWithFrame:frameName 
                                     frameCount:stance.frames.intValue 
                                     delay:stance.duration.floatValue];
    
    // run the animation by using the CCAnimate action
    CCAnimate* animate = [CCAnimate actionWithAnimation:anim restoreOriginalFrame:YES];
    
    //Change from attacking to IDLE state
    if ([currentStance isEqualToString:@"idle"])
    {
        state = IDLE;
        
        //Repeat animation
        CCRepeatForever* repeat = [CCRepeatForever actionWithAction:animate];
        [self runAction:repeat];
    }
    //Otherwise, attack
    else
    {
        //Re-order sprites
        [self.parent reorderChild:self z:2];
        
        //Schedule to change stance after attack completes
        [self runAction:[CCSequence actions:
                         animate,
                         [CCCallFuncN actionWithTarget:self selector:@selector(changeStance)],
                         nil]];
        //Damage enemy if possible
        [enemy performSelector:@selector(gotHit:) withObject:stance afterDelay:stance.hitTime.doubleValue];
    }
}

-(void) reset
{
    health = MAX_HEALTH;
    
    //Show the idle frame
    NSString* frameName = [NSString stringWithFormat:@"%@-idle0.png", type];
    [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName]];
}

-(void) dealloc
{
    [combo release];
    [stances release];
    [enemy release];
    [super dealloc];
}

@end
