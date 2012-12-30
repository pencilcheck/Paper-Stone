//
//  Shader.fsh
//  OpenGLGameExample
//
//  Created by Penn Su on 12/29/12.
//  Copyright (c) 2012 Light Years. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
