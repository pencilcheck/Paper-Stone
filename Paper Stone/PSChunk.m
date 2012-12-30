//
//  PSCube.m
//  Paper Stone
//
//  Created by Penn Su on 12/29/12.
//  Copyright (c) 2012 Light Years. All rights reserved.
//

#import "PSChunk.h"
#import "CZGPerlinGenerator.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))
#define M_TAU (2*M_PI)

GLfloat gBlockVertexData[216] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    // Facing +x
    0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          1.0f, 0.0f, 0.0f,

    // Facing +y
    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,
    
    // Facing -x
    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,

    // Facing -y
    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,

    // Facing +z
    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,

    // Facing -z
    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f
};

@interface PSChunk() {
    CZGPerlinGenerator *perlinGenerator;
    float _rotation;
    
    int activeBlockCount;
    
    int chunkVertexDataSize;
    GLfloat *gChunkVertexData;
    GLuint _vertexArray;
    GLuint _vertexBuffer;
}
@property (strong) GLKBaseEffect *effect;
@property BlockDef*** blockData;
@end

@implementation PSChunk

- (id)initWithPosition:(GLKVector3)position Size:(int)size Effect:(GLKBaseEffect *)effect {
    if ((self = [super init])) {
        self.effect = effect;
        
        perlinGenerator = [[CZGPerlinGenerator alloc] init];
        perlinGenerator.octaves = 1;
        perlinGenerator.zoom = 50;
        perlinGenerator.persistence = 0.5; //0.00001;
        
        self.size = size;
        self.position = position;

        self.blockData = (BlockDef***)malloc(sizeof(BlockDef**) * self.size);
        for (int i=0; i<self.size; ++i) {
            self.blockData[i] = (BlockDef**)malloc(sizeof(BlockDef*) * self.size);
            for (int j=0; j<self.size; ++j) {
                self.blockData[i][j] = (BlockDef*)malloc(sizeof(BlockDef) * self.size);
                for (int k=0; k<self.size; ++k) {
                    BlockDef def = {NO, BLOCK_DEFAULT};
                    self.blockData[i][j][k] = def;
                    activeBlockCount++;
                }
            }
        }
        chunkVertexDataSize = sizeof(GLfloat) * 216 * self.size * self.size * self.size;
        gChunkVertexData = (GLfloat*)malloc(chunkVertexDataSize);
        
        self.need_rebuild = true;
        self.need_render = false;
        self.will_render = false;
    }
    return self;
}

- (void)dealloc
{
    for (int i=0; i<self.size; ++i) {
        for (int j=0; j<self.size; ++j) {
            free(self.blockData[i][j]);
            self.blockData[i][j] = NULL;
        }
        self.blockData[i] = NULL;
    }
    free(gChunkVertexData);
}

- (GLKMatrix4)modelMatrix
{
    GLKMatrix4 modelMatrix = GLKMatrix4MakeTranslation(self.position.x, self.position.y, self.position.z);
    modelMatrix = GLKMatrix4Multiply(modelMatrix, GLKMatrix4MakeTranslation(0, 0, -self.size));
    return modelMatrix;
}

- (void)setupGL
{
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, chunkVertexDataSize, gChunkVertexData, GL_STATIC_DRAW);
    //glBufferData(GL_ARRAY_BUFFER, sizeof(gBlockVertexData), gBlockVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
    
    glBindVertexArrayOES(0);
}

- (void)setup
{
    //[self setupSphere];
    [self setupNoise];
}

- (void)setupNoise
{
    NSLog(@"setupNoise");
    for (int x=0; x<self.size; ++x) {
        for (int z=0; z<self.size; ++z) {
            float height = ABS([perlinGenerator perlinNoiseX:x y:0 z:z t:0]) * self.size;
            if (height > self.size)
                height = self.size;
            for (int y=0; y<height; ++y) {
                self.blockData[x][y][z].active = true;
            }
        }
    }
}

- (void)setupSphere
{
    for (int x=0; x<self.size; ++x) {
        for (int y=0; y<self.size; ++y) {
            for (int z=0; z<self.size; ++z) {
                if (sqrt((float) (x-self.size/2)*(x-self.size/2) + (y-self.size/2)*(y-self.size/2) + (z-self.size/2)*(z-self.size/2)) <= self.size/2) {
                    self.blockData[x][y][z].active = true;
                }
            }
        }
    }
}

- (void)buildMesh
{
    NSLog(@"buildMesh");
    memset(gChunkVertexData, 0, chunkVertexDataSize);
    for (int x=0; x<self.size; ++x) {
        for (int y=0; y<self.size; ++y) {
            for (int z=0; z<self.size; ++z) {
                if (self.blockData[x][y][z].active) {
                    Boolean activeNX = NO;
                    Boolean activeX = NO;
                    Boolean activeNY = NO;
                    Boolean activeY = NO;
                    Boolean activeNZ = NO;
                    Boolean activeZ = NO;

                    if (x > 0)
                        activeNX = self.blockData[x-1][y][z].active;
                    
                    if (x < self.size - 1)
                        activeX = self.blockData[x+1][y][z].active;

                    if (y > 0)
                        activeNY = self.blockData[x][y-1][z].active;

                    if (y < self.size - 1)
                        activeY = self.blockData[x][y+1][z].active;

                    if (z > 0)
                        activeNZ = self.blockData[x][y][z-1].active;

                    if (z < self.size - 1)
                        activeZ = self.blockData[x][y][z+1].active;


                    [self buildBlockMeshAtIndex:GLKVector3Make(x, y, z) ActiveX:activeX ActiveNX:activeNX ActiveY:activeY ActiveNY:activeNY ActiveZ:activeZ ActiveNZ:activeNZ];
                }
            }
        }
    }
    
    [self setupGL];
}

/** 
 * Build sides of a block mesh only when the neighbor blocks touching the side is inactive
 */
- (void)buildBlockMeshAtIndex:(GLKVector3)position ActiveX:(Boolean)activeX ActiveNX:(Boolean)activeNX
               ActiveY:(Boolean)activeY ActiveNY:(Boolean)activeNY ActiveZ:(Boolean)activeZ ActiveNZ:(Boolean)activeNZ
{
    GLfloat *chunkVertexData;
    int index = position.x * 216 + position.y * self.size * 216 + position.z * self.size * self.size * 216;

    // Convert local position to global coordinates, center of the chunk is the origin
    GLKVector3 final_position = GLKVector3Subtract(position, GLKVector3Make(self.size/2, self.size/2, self.size/2));
    
    for (int i=0; i<216; i+=36) {
        if (!activeX && (i / 36 == 0)) {
            // +x side
            chunkVertexData = gChunkVertexData+index+i;
            [self buildOneSideOfChunkVertexData:chunkVertexData WithBlockVertexDataOffset:i AndPosition:final_position];
        }

        if (!activeY && (i / 36 == 1)) {
            // +y side
            chunkVertexData = gChunkVertexData+index+i;
            [self buildOneSideOfChunkVertexData:chunkVertexData WithBlockVertexDataOffset:i AndPosition:final_position];
        }
        
        if (!activeNX && (i / 36 == 2)) {
            // -x side
            chunkVertexData = gChunkVertexData+index+i;
            [self buildOneSideOfChunkVertexData:chunkVertexData WithBlockVertexDataOffset:i AndPosition:final_position];
        }

        if (!activeNY && (i / 36 == 3)) {
            // -y side
            chunkVertexData = gChunkVertexData+index+i;
            [self buildOneSideOfChunkVertexData:chunkVertexData WithBlockVertexDataOffset:i AndPosition:final_position];
        }

        if (!activeZ && (i / 36 == 4)) {
            // +z side
            chunkVertexData = gChunkVertexData+index+i;
            [self buildOneSideOfChunkVertexData:chunkVertexData WithBlockVertexDataOffset:i AndPosition:final_position];
        }

        if (!activeNZ && (i / 36 == 5)) {
            // -z side
            chunkVertexData = gChunkVertexData+index+i;
            [self buildOneSideOfChunkVertexData:chunkVertexData WithBlockVertexDataOffset:i AndPosition:final_position];
        }
    }
}

- (void)buildOneSideOfChunkVertexData:(GLfloat*)chunkVertexData WithBlockVertexDataOffset:(int)offset AndPosition:(GLKVector3)position
{
    for (int i=0; i<36; i+=6) {
        // Vertex
        chunkVertexData[i] = gBlockVertexData[offset+i] + position.x;
        chunkVertexData[i+1] = gBlockVertexData[offset+i+1] + position.y;
        chunkVertexData[i+2] = gBlockVertexData[offset+i+2] + position.z;
        
        // Normal
        chunkVertexData[i+3] = gBlockVertexData[offset+i+3];
        chunkVertexData[i+4] = gBlockVertexData[offset+i+4];
        chunkVertexData[i+5] = gBlockVertexData[offset+i+5];
    }
}

- (void)activateBlockAt:(GLKVector3)position
{
    if (!self.blockData[(int)position.x][(int)position.y][(int)position.z].active) {
        self.blockData[(int)position.x][(int)position.y][(int)position.z].active = true;
        activeBlockCount++;
    }
}

- (void)deactivateBlockAt:(GLKVector3)position
{
    if (self.blockData[(int)position.x][(int)position.y][(int)position.z].active) {
        self.blockData[(int)position.x][(int)position.y][(int)position.z].active = false;
        activeBlockCount--;
    }
}

- (Boolean)isEmptyChunk
{
    return activeBlockCount == 0;
}

- (void)update:(float)timeSinceLastUpdate
{
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 0.0f/*-self.size*/);
    //baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);
    
    // Compute the model view matrix for the object rendered with GLKit
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 0.0f);
    //modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    self.effect.transform.modelviewMatrix = GLKMatrix4Multiply(self.effect.transform.modelviewMatrix, modelViewMatrix);
    
    _rotation += timeSinceLastUpdate * 0.5f;
}

- (void)render
{
    glBindVertexArrayOES(_vertexArray);
    
    // Render the object with GLKit
    [self.effect prepareToDraw];
    
    glDrawArrays(GL_TRIANGLES, 0, self.size*self.size*self.size*36);
}

@end
