//
//  FishEyeFilter.m
//  GPUImageAdventures
//
//  Created by wangxinjie on 2025/3/13.
//

#import "FishEyeFilter.h"

@implementation FishEyeFilter

// Invert the colorspace for a sketch
NSString *const kGPUImageFishEyeFragmentShaderString = SHADER_STRING
(
 precision mediump float;
 
 varying vec2 textureCoordinate;

 uniform sampler2D inputImageTexture;

 // 放大镜的中心
 vec2 magnifyCenter = vec2(0.5, 0.2);
 // 放大镜的大小
 float magnifySize = 0.35;
 // 放大的倍数
 float magnifyRate = 2.0;

 void main() {
   vec2 uv = textureCoordinate;
   
   vec2 vecFromCenter = uv - magnifyCenter;
   float distFromCenter = length(vecFromCenter);
   
   // 如果在放大镜的范围内
   if (distFromCenter < magnifySize) {
       uv = magnifyCenter + vecFromCenter / magnifyRate;
   }
   
   vec4 color = texture2D(inputImageTexture, uv);
   gl_FragColor = color;
 }
);

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [self initWithFragmentShaderFromString:kGPUImageFishEyeFragmentShaderString]))
    {
        return nil;
    }
    
    return self;
}


@end
