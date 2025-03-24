//
//  GPUImageGrayscaleBlurFilter.h
//  GPUImageAdventures
//
//  Created by wangxinjie on 2025/3/24.
//

#import "GPUImageFilter.h"
#import <GPUImage/GPUImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface GaussianGrayscaleSingleFilter : GPUImageFilter

@property (nonatomic, assign) CGFloat blurRadiusInPixels;

@end

NS_ASSUME_NONNULL_END
