//
//  PSChunkManager.h
//  Paper Stone
//
//  Created by Penn Su on 12/29/12.
//  Copyright (c) 2012 Light Years. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface PSChunkManager : NSObject

- (id)initWithEffect:(GLKBaseEffect *)effect;
- (void)update:(float)timeSinceLastUpdate WithCameraPosition:(GLKVector3)cameraPosition CameraView:(GLKVector3)cameraView;
- (void)render;

@end
