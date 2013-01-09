//
//  PSSphere.h
//  Paper Stone
//
//  Created by Penn Su on 12/31/12.
//  Copyright (c) 2012 Light Years. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef enum {
    SPHERE_DEFAULT
} SphereType;

typedef struct {
    SphereType type;
} SphereDef;

@interface PSSphere : NSObject
@property (assign) GLKVector3 position;
@property (assign) int radius;

- (id)initAtPosition:(GLKVector3)position Radius:(int)radius Effect:(GLKBaseEffect *)effect;
- (void)setup;
- (void)buildMesh;
- (void)setupGL;
- (void)update:(float)timeSinceLastUpdate;
- (void)render;
@end
