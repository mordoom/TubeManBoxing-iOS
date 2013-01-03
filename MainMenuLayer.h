//
//  MainMenuLayer.h
//  Tube Man Boxing
//
//  Created by Alex Mordue on 23/07/12.
//  Copyright 2012. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameplayLayer.h"
typedef enum
{
    MainMenuLayerLogoTag = 1,
}MainMenuLayerTags;

@interface MainMenuLayer : CCLayer
{
    GameTypes game;
}
+(id)scene;
@end
