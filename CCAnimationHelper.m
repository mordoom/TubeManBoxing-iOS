//
//  CCAnimationHelper.h
//  Tube Man Boxing
//
//  Created by Alex Mordue on 20/01/12.
//  Copyright 2012
//

#import "CCAnimationHelper.h"


@implementation CCAnimation (Helper)

//Creates an animation from single files
+(CCAnimation*) animationWithFile:(NSString *)name frameCount:(int)frameCount delay:(float)delay
{
    //Load animation frames as textures and create the sprite frames
    NSMutableArray* frames = [NSMutableArray arrayWithCapacity:frameCount];
    for (int i = 0; i < frameCount; i++)
    {
        //Assuming all animation files are named "nameX".png
        NSString* file = [NSString stringWithFormat:@"%@%i.png", name, i];
        CCTexture2D* texture = [[CCTextureCache sharedTextureCache] addImage:file];
        
        //Assuming that image file animations always use the whole image
        CGSize texSize = texture.contentSize;
        CGRect texRect = CGRectMake(0, 0, texSize.width, texSize.height);
        CCSpriteFrame* frame = [CCSpriteFrame frameWithTexture:texture rect:texRect];
        
        [frames addObject:frame];
    }
    
    //Return an animation object from all the sprite animation frames
    return [CCAnimation animationWithFrames:frames delay:delay];
}

//Load an animation from sprite frames
+(CCAnimation*) animationWithFrame:(NSString *)frame frameCount:(int)frameCount delay:(float)delay
{
    //Load the ship's animation frames as textures and create a sprite frame
    NSMutableArray* frames = [NSMutableArray arrayWithCapacity:frameCount];
    for (int i = 0; i < frameCount; i++)
    {
        NSString* file =  [NSString stringWithFormat:@"%@%i.png", frame, i];
        CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        CCSpriteFrame* frame = [frameCache spriteFrameByName:file];
        [frames addObject:frame];
    }
    
    //return an animation object from all the sprite animation frames
    return [CCAnimation animationWithFrames:frames delay:delay];
}

@end
