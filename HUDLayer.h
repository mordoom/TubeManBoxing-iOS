//
//  HUDLayer.m
//  Tube Man Boxing
//
//  Created by Alex Mordue on 3/07/12.
//  Copyright 2012
//


#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum
{
    HUDLayerTagPlayerHealth = 1,
    HUDLayerTagOpponentHealth,
    HUDLayerTagPlayerSpecial,
    HUDLayerTagOpponentSpecial,
    HUDLayerTagCountIn,
    HUDLayerTagTimeLabel,
    HUDLayerTagHitMarker,
    HUDLayerTagKO,
    HUDLayerTagPauseScreen,
}HUDLayerTags;

@interface HUDLayer : CCNode
{
    CCLabelBMFont* timeLabel;
    CCLabelBMFont* playerLabel;
}
-(void) updateHealth:(float)coefficient player:(BOOL)player;
-(void) updateSpecial:(float)coefficient player:(BOOL)player;
-(void) knockOut;
-(void) hitMarker:(CGPoint)pos;
-(void) countIn;
-(void) reset:(BOOL)playerWon;
-(void) showPauseLayer;
-(void) removePauseLayer;
@end
