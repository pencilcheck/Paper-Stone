//
//  PSCube.h
//  Paper Stone
//
//  Created by Penn Su on 12/29/12.
//  Copyright (c) 2012 Light Years. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef enum {
    BLOCK_DEFAULT,
    BLOCK_WATER,
    BLOCK_GRASS,
    BLOCK_ROCK,
    BLOCK_WOOD,
    BLOCK_SAND,
    BLOCK_DIRT
} BlockType;

typedef struct {
    Boolean active;
    BlockType type;
} BlockDef;

@interface PSChunk : NSObject
@property (assign) GLKVector3 position;
@property (assign) int size;

@property (assign) Boolean need_rebuild;
@property (assign) Boolean need_render;
@property (assign) Boolean will_render;

- (id)initWithPosition:(GLKVector3)position Size:(int)size Effect:(GLKBaseEffect *)effect;
- (void)setup;
- (void)buildMesh;
- (void)activateBlockAt:(GLKVector3)position;
- (void)deactivateBlockAt:(GLKVector3)position;
- (Boolean)isEmptyChunk;
- (void)setupGL;
- (void)update:(float)timeSinceLastUpdate;
- (void)render;
@end
