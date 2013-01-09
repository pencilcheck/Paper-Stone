//
//  PSPhysicEngine.m
//  Paper Stone
//
//  Created by Penn Su on 12/31/12.
//  Copyright (c) 2012 Light Years. All rights reserved.
//

#import "PSPhysicEngine.h"


@interface PSPhysicEngine () {

}

@end

@implementation PSPhysicEngine

- (id)init {
    if ((self = [super init])) {
    }
    return self;
}

- (Boolean)testAABB:(AABB)a andB:(AABB)b
{
    if ( ABS(a.c.x - b.c.x) > (a.r[0] + b.r[0]) ) return false;
    if ( ABS(a.c.y - b.c.y) > (a.r[1] + b.r[1]) ) return false;
    if ( ABS(a.c.z - b.c.z) > (a.r[2] + b.r[2]) ) return false;
    // We have an overlap
    return true;
}

- (void)update:(float)timeSinceLastUpdate
{
}

@end
