//
//  FighterSprite.h
//  Tube Man Boxing
//
//  Created by Alex Mordue on 27/06/12.
//  Copyright 2012
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "FightStance.h"

typedef enum
{
    IDLE = 1,
    HIGHATTACK,
    LOWATTACK,
    DEFLATE,
    COUNTIN,
    STUNNED,
    SPECIAL,
    HIT,
    DEAD,
}FighterState;

@interface FighterSprite : CCSprite
{
    int health;
    FighterState state;
    NSString* type;
    FighterSprite* enemy;
    NSString* currentStance;
    BOOL playerCharacter;
    //List of available stances
    NSMutableDictionary* stances;
    
    //Combo queue fills with each successful hit and has a cooldown calculation
    NSMutableArray* combo;
    
    //Special - bar fills when combo attacks land, or when hit by opponent
    int special;
    
    //AI intelligence
    int aiDifficulty;
    
    //Sounds
    NSArray* punchSoundList;
    
    ccTime totalTime;
    ccTime nextShotTime;
}

@property (readonly, nonatomic) int health;
@property (readwrite, retain) FighterSprite* enemy;
@property (readonly, nonatomic) FighterState state;
+(id) fighter:(NSString*)type player:(BOOL)player difficulty:(int)difficulty;
-(void) changeStance;
-(void) gotHit:(FightStance*)stance;
-(void) performSpecialAttack;
-(void) performHighAttack;
-(void) performLowAttack;
-(void) performDeflate;
-(void) unpause;
-(void) pause;
-(void) clearCombo;
-(void) reset;
@end