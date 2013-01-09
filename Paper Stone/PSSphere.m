//
//  PSSphere.m
//  Paper Stone
//
//  Created by Penn Su on 12/31/12.
//  Copyright (c) 2012 Light Years. All rights reserved.
//

#import "PSSphere.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))
#define M_TAU (2*M_PI)

@interface PSSphere () {
    float _rotation;
    
    float parallels;
    
    int chunkSphereDataSize;
    GLfloat *gSphereVertexData;
    GLuint _vertexArray;
    GLuint _vertexBuffer;
}
@property (strong) GLKBaseEffect *effect;
@end

@implementation PSSphere

- (id)initAtPosition:(GLKVector3)position Radius:(int)radius Effect:(GLKBaseEffect *)effect
{
    if ((self = [super init])) {
        self.effect = effect;
        self.position = position;
        self.radius = radius;
        
        parallels = 30;
        
        chunkSphereDataSize =  sizeof(GLfloat) * parallels * parallels * 6 * 2;
        gSphereVertexData = (GLfloat*)malloc(chunkSphereDataSize);
        
        [self buildMesh];
    }
    return self;
}

- (void)setup
{
    
}

- (void)setupGL
{
    glEnable(GL_CULL_FACE);

    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, chunkSphereDataSize, gSphereVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
    
    glBindVertexArrayOES(0);
}

- (void)buildMesh
{
    [self buildSphereCenter:self.position Radius:self.radius Parallels:parallels];
    [self setupGL];
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

// https://gist.github.com/1076642
- (void)buildSphereCenter:(GLKVector3)center Radius:(float)r Parallels:(int)p
{
    float theta1 = 0.0, theta2 = 0.0, theta3 = 0.0;
    float ex = 0.0f, ey = 0.0f, ez = 0.0f;
    float px = 0.0f, py = 0.0f, pz = 0.0f;
    GLfloat vertices[p*6+6], normals[p*6+6], texCoords[p*4+4];
    
    if( r < 0 )
        r = -r;
    
    if( p < 0 )
        p = -p;
    
    for(int i = 0; i < p/2; ++i)
    {
        theta1 = i * (M_PI*2) / p - M_PI_2;
        theta2 = (i + 1) * (M_PI*2) / p - M_PI_2;
        
        for(int j = 0; j <= p; ++j)
        {
            theta3 = j * (M_PI*2) / p;
            
            ex = cosf(theta2) * cosf(theta3);
            ey = sinf(theta2);
            ez = cosf(theta2) * sinf(theta3);
            px = center.x + r * ex;
            py = center.y + r * ey;
            pz = center.z + r * ez;
            
            vertices[(6*j)+(0%6)] = px;
            vertices[(6*j)+(1%6)] = py;
            vertices[(6*j)+(2%6)] = pz;
            
            normals[(6*j)+(0%6)] = ex;
            normals[(6*j)+(1%6)] = ey;
            normals[(6*j)+(2%6)] = ez;
            
            texCoords[(4*j)+(0%4)] = -(j/(float)p);
            texCoords[(4*j)+(1%4)] = 2*(i+1)/(float)p;
            
            int k = (i*p) + j*2;
            
            gSphereVertexData[(6*k)+0] = px;
            gSphereVertexData[(6*k)+1] = py;
            gSphereVertexData[(6*k)+2] = pz;
            
            gSphereVertexData[(6*k)+3] = ex;
            gSphereVertexData[(6*k)+4] = ey;
            gSphereVertexData[(6*k)+5] = ez;
            
            //NSLog(@"px py pz %f %f %f", px, py, pz);
            
            
            ex = cosf(theta1) * cosf(theta3);
            ey = sinf(theta1);
            ez = cosf(theta1) * sinf(theta3);
            px = center.x + r * ex;
            py = center.y + r * ey;
            pz = center.z + r * ez;
            
            vertices[(6*j)+(3%6)] = px;
            vertices[(6*j)+(4%6)] = py;
            vertices[(6*j)+(5%6)] = pz;
            
            normals[(6*j)+(3%6)] = ex;
            normals[(6*j)+(4%6)] = ey;
            normals[(6*j)+(5%6)] = ez;
            
            texCoords[(4*j)+(2%4)] = -(j/(float)p);
            texCoords[(4*j)+(3%4)] = 2*i/(float)p;
            
            gSphereVertexData[(6*(k+1))+0] = px;
            gSphereVertexData[(6*(k+1))+1] = py;
            gSphereVertexData[(6*(k+1))+2] = pz;
            
            gSphereVertexData[(6*(k+1))+3] = ex;
            gSphereVertexData[(6*(k+1))+4] = ey;
            gSphereVertexData[(6*(k+1))+5] = ez;
        }
    }
}

- (void)render
{
    glBindVertexArrayOES(_vertexArray);
    
    // Render the object with GLKit
    [self.effect prepareToDraw];
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 2 * parallels * parallels);
}

@end
