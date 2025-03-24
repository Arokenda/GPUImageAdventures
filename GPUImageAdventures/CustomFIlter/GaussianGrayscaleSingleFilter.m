//
//  GPUImageGrayscaleBlurFilter.m
//  GPUImageAdventures
//
//  Created by wangxinjie on 2025/3/24.
//

#import "GaussianGrayscaleSingleFilter.h"
#import "GaussianGrayscaleSingleFilter.h"

@implementation GaussianGrayscaleSingleFilter {
    GLint texelWidthOffsetUniform, texelHeightOffsetUniform;
}

NSString *const kGaussianGrayscaleSingleFragmentShader = SHADER_STRING(
   precision highp float;

   varying highp vec2 textureCoordinate;
   uniform sampler2D inputImageTexture;
   uniform highp float texelWidthOffset;
   uniform highp float texelHeightOffset;

   void main()
   {
       vec4 sum = vec4(0.0);
       vec2 singleStepOffset = vec2(texelWidthOffset, texelHeightOffset);

       sum += texture2D(inputImageTexture, textureCoordinate + singleStepOffset * vec2(-1.0, -1.0)) * 0.0625;
       sum += texture2D(inputImageTexture, textureCoordinate.xy + vec2(0.0, texelHeightOffset)) * 0.125;
       sum += texture2D(inputImageTexture, textureCoordinate + vec2(singleStepOffset.x, singleStepOffset.y)) * 0.0625;
       sum += texture2D(inputImageTexture, textureCoordinate + vec2(-singleStepOffset.x, singleStepOffset.y)) * 0.0625;
       sum += texture2D(inputImageTexture, textureCoordinate + vec2(singleStepOffset.x, -singleStepOffset.y)) * 0.0625;
       sum += texture2D(inputImageTexture, textureCoordinate + vec2(-singleStepOffset.x, -singleStepOffset.y)) * 0.0625;
       sum += texture2D(inputImageTexture, textureCoordinate + vec2(0.0, singleStepOffset.y)) * 0.125;
       sum += texture2D(inputImageTexture, textureCoordinate + vec2(0.0, -singleStepOffset.y)) * 0.125;
       sum += texture2D(inputImageTexture, textureCoordinate + vec2(singleStepOffset.x, 0.0)) * 0.125;
       sum += texture2D(inputImageTexture, textureCoordinate + vec2(-singleStepOffset.x, 0.0)) * 0.125;
       sum += texture2D(inputImageTexture, textureCoordinate) * 0.25;

       float gray = dot(sum.rgb, vec3(0.2125, 0.7154, 0.0721));
       gl_FragColor = vec4(vec3(gray), 1.0);
   }
);


- (id)init {
    if (self = [super initWithFragmentShaderFromString:kGaussianGrayscaleSingleFragmentShader]) {
        self.blurRadiusInPixels = 5.0;
        texelWidthOffsetUniform = [filterProgram uniformIndex:@"texelWidthOffset"];
        texelHeightOffsetUniform = [filterProgram uniformIndex:@"texelHeightOffset"];
    }
    return self;
}

- (void)setBlurRadiusInPixels:(CGFloat)newValue {
    _blurRadiusInPixels = newValue;
    [self setupFilterForSize:inputTextureSize];
}

- (void)setupFilterForSize:(CGSize)filterFrameSize {
    [super setupFilterForSize:filterFrameSize];

    if (!CGSizeEqualToSize(filterFrameSize, CGSizeZero)) {
        [self setFloat:_blurRadiusInPixels / filterFrameSize.width forUniform:texelWidthOffsetUniform program:filterProgram];
        [self setFloat:_blurRadiusInPixels / filterFrameSize.height forUniform:texelHeightOffsetUniform program:filterProgram];
    }
}

- (void)setUniformsForProgramAtIndex:(NSUInteger)programIndex {
    [super setUniformsForProgramAtIndex:programIndex];

    texelWidthOffsetUniform = [filterProgram uniformIndex:@"texelWidthOffset"];
    texelHeightOffsetUniform = [filterProgram uniformIndex:@"texelHeightOffset"];

    [self setFloat:_blurRadiusInPixels/inputTextureSize.width forUniform:texelWidthOffsetUniform program:filterProgram];
    [self setFloat:_blurRadiusInPixels/inputTextureSize.height forUniform:texelHeightOffsetUniform program:filterProgram];
}

@end
