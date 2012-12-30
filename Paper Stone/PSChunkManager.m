//
//  PSChunkManager.m
//  Paper Stone
//
//  Created by Penn Su on 12/29/12.
//  Copyright (c) 2012 Light Years. All rights reserved.
//

#import "PSChunkManager.h"
#import "PSChunk.h"

#define NUM_CHUNKS_PER_FRAME 64
#define CHUNK_WIDTH 64
#define WORLD_WIDTH 1
#define VISIBLE_RADIUS 512

@interface PSChunkManager () {
    GLKVector3 m_cameraPosition;
    GLKVector3 m_cameraView;
}
@property (strong) GLKBaseEffect *effect;

@property (strong) NSMutableArray *allChunks;

@end

@implementation PSChunkManager

- (id)initWithEffect:(GLKBaseEffect *)effect
{
    if ((self = [super init])) {
        self.effect = effect;
        
        self.allChunks = [NSMutableArray array];
        
        [self populateChunks];
    }
    return self;
}

/*
 * This position vector represents the array position, not the actual world position
 */
- (PSChunk *)getChunkAt:(GLKVector3)position
{
    if (position.x < 0 || position.x >= WORLD_WIDTH ||
        position.y < 0 || position.y >= WORLD_WIDTH ||
        position.z < 0 || position.z >= WORLD_WIDTH) {
        return NULL;
    }
    return [self.allChunks objectAtIndex:position.x + position.y * WORLD_WIDTH + position.z * WORLD_WIDTH * WORLD_WIDTH];
}

- (void)populateChunks
{
    for (int z=0; z<WORLD_WIDTH*CHUNK_WIDTH; z+=CHUNK_WIDTH) {
        for (int y=0; y<WORLD_WIDTH*CHUNK_WIDTH; y+=CHUNK_WIDTH) {
            for (int x=0; x<WORLD_WIDTH*CHUNK_WIDTH; x+=CHUNK_WIDTH) {
                [self.allChunks addObject:[[PSChunk alloc] initWithPosition:GLKVector3Make(x, y, z) Size:CHUNK_WIDTH Effect:self.effect]];
            }
        }
    }
}

- (void)setupChunks
{
    for (PSChunk *chunk in self.allChunks) {
        if (chunk != NULL && chunk.need_rebuild) {
            [chunk setup];
        }
    }
}

- (void)rebuildChunks
{
    int numberRebuildInFrame = 0;
    for (PSChunk *chunk in self.allChunks) {
        if (chunk != NULL && chunk.need_rebuild) {
            if (numberRebuildInFrame < NUM_CHUNKS_PER_FRAME) {
                //NSLog(@"rebuilding mesh");
                [chunk buildMesh];
                
                PSChunk *chunkNX = [self getChunkAt:GLKVector3Make([chunk position].x-1, [chunk position].y, [chunk position].z)];
                PSChunk *chunkX = [self getChunkAt:GLKVector3Make([chunk position].x+1, [chunk position].y, [chunk position].z)];
                PSChunk *chunkNY = [self getChunkAt:GLKVector3Make([chunk position].x, [chunk position].y-1, [chunk position].z)];
                PSChunk *chunkY = [self getChunkAt:GLKVector3Make([chunk position].x, [chunk position].y+1, [chunk position].z)];
                PSChunk *chunkNZ = [self getChunkAt:GLKVector3Make([chunk position].x, [chunk position].y, [chunk position].z-1)];
                PSChunk *chunkZ = [self getChunkAt:GLKVector3Make([chunk position].x, [chunk position].y, [chunk position].z+1)];
                
                if (chunkNX != NULL)
                    chunkNX.need_rebuild = true;
                if (chunkX != NULL)
                    chunkX.need_rebuild = true;

                if (chunkNY != NULL)
                    chunkNY.need_rebuild = true;
                if (chunkY != NULL)
                    chunkY.need_rebuild = true;

                if (chunkNZ != NULL)
                    chunkNZ.need_rebuild = true;
                if (chunkZ != NULL)
                    chunkZ.need_rebuild = true;
                
                numberRebuildInFrame++;
                chunk.need_rebuild = false;
            }
        }
    }
}


- (void)updateVisibilityChunksWithCameraPosition:(GLKVector3)position
{
    for (PSChunk *chunk in self.allChunks) {
        if (chunk != NULL && !chunk.need_rebuild) {
            GLKVector3 chunkPosition = [chunk position];
            //NSLog(@"distance: %f", GLKVector3Distance(chunkPosition, position));
            if (GLKVector3Distance(chunkPosition, position) < VISIBLE_RADIUS) {
                chunk.need_render = true;
            } else {
                chunk.need_render = false;
            }
        }
    }
}

- (void)updateRenderChunks
{
    for (PSChunk *chunk in self.allChunks) {
        if (chunk != NULL && !chunk.need_rebuild && chunk.need_render) {
            //NSLog(@"render chunks");
            // TODO:We don't have frustum culling, nor Octree yet, we render everything!
            chunk.will_render = true;
        }
    }
}

- (void)update:(float)timeSinceLastUpdate WithCameraPosition:
    (GLKVector3)cameraPosition CameraView:(GLKVector3)cameraView;
{
    [self setupChunks];
    [self rebuildChunks];
    [self updateVisibilityChunksWithCameraPosition:cameraPosition];
    [self updateRenderChunks];
    
    m_cameraPosition = cameraPosition;
    m_cameraView = cameraView;
}

- (void)render
{
    for (PSChunk *chunk in self.allChunks) {
        //NSLog(@"rendering chunk");
        if (chunk.will_render) {
            [chunk render];
            chunk.will_render = false;
        }
    }
}

@end
