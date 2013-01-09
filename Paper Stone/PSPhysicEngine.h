//
//  PSPhysicEngine.h
//  Paper Stone
//
//  Created by Penn Su on 12/31/12.
//  Copyright (c) 2012 Light Years. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef struct {
    GLKVector3 c; // center
    float r[3]; // halfwidths
} AABB;

@interface PSPhysicEngine : NSObject

- (Boolean)testAABB:(AABB)a andB:(AABB)b;
- (void)update:(float)timeSinceLastUpdate;

@end
