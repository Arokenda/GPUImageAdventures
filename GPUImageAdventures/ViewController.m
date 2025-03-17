//
//  ViewController.m
//  GPUImageAdventures
//
//  Created by wangxinjie on 2025/3/12.
//

#import "ViewController.h"

#import <GPUImage/GPUImage.h>
#import <GPUImage/GPUImageFramework.h>
#import <Masonry/Masonry.h>

#import "FishEyeFilter.h"

@interface FilterInfo : NSObject
@property (nonatomic, strong) NSString *filterName;
@property (nonatomic, strong) NSString *filterDescription;
@property (nonatomic, strong) Class cls;

@property (nonatomic, strong) NSString *displayString;
@end

@implementation FilterInfo

- (NSString *)displayString
{
    return [NSString stringWithFormat:@"%@\n%@", self.filterDescription, NSStringFromClass(self.cls)];
}

@end

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *filterCollectionView;

@property (nonatomic, strong) NSArray<FilterInfo *> *filterList;
@property (nonatomic, strong) NSMutableArray<FilterInfo *> *selectedFilters;

@property (nonatomic, strong) UIImageView *sourceImageView;
@property (nonatomic, strong) UIImageView *filteredImageView;
@property (nonatomic, strong) UILabel *filterLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupSubview];
}

- (void)setupSubview
{
    self.filterList = [self createFilterList];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal; // Set scroll direction to horizontal
    self.filterCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.filterCollectionView.delegate = self;
    self.filterCollectionView.dataSource = self;
    [self.view addSubview:self.filterCollectionView];
    [self.filterCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.filterCollectionView.allowsSelection = YES;
    self.filterCollectionView.allowsMultipleSelection = YES;
    
    [self.filterCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).mas_offset(50);
        make.height.mas_equalTo(200);
    }];
    
    self.sourceImageView = [[UIImageView alloc] init];
    self.sourceImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.sourceImageView.image = [UIImage imageNamed:@"llf"];
    [self.view addSubview:self.sourceImageView];
    [self.sourceImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.top.mas_equalTo(self.filterCollectionView.mas_bottom).mas_offset(10);
        make.bottom.mas_equalTo(self.view.mas_centerY);
    }];
    
    self.filteredImageView = [[UIImageView alloc] init];
    self.filteredImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.filteredImageView];
    [self.filteredImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.sourceImageView);
        make.top.mas_equalTo(self.sourceImageView.mas_bottom);
        make.bottom.mas_equalTo(self.view);
    }];
    
    self.filterLabel = [[UILabel alloc] init];
    self.filterLabel.text = @"Filter";
    self.filterLabel.numberOfLines = 0;
    self.filterLabel.textAlignment = NSTextAlignmentLeft;
    self.filterLabel.textColor = [UIColor purpleColor];
    [self.view addSubview:self.filterLabel];
    [self.filterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.view).mas_offset(10);
        make.top.mas_equalTo(self.sourceImageView).mas_offset(10);
    }];
    
    UIButton *clearBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [clearBtn setTitle:@"Clear" forState:UIControlStateNormal];
    [clearBtn addTarget:self action:@selector(clearFilter) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clearBtn];
    [clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.view).mas_offset(-10);
        make.top.mas_equalTo(self.filterLabel);
        make.size.mas_equalTo(CGSizeMake(60, 30));
    }];
}

- (void)clearFilter
{
    [self.selectedFilters removeAllObjects];
    NSArray *indexPaths = [self.filterCollectionView indexPathsForSelectedItems];
    for (NSIndexPath *indexPath in indexPaths) {
        [self.filterCollectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
    [self.filterCollectionView reloadData];
    self.filterLabel.text = @"Filter";
    self.filteredImageView.image = nil;
}

- (NSMutableArray<FilterInfo *> *)selectedFilters
{
    if (_selectedFilters == nil) {
        _selectedFilters = [NSMutableArray array];
    }
    return _selectedFilters;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.filterList.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = cell.selected ? [UIColor systemCyanColor] : [UIColor systemGroupedBackgroundColor];
    UILabel *titleLable = [cell.contentView viewWithTag:10086];
    if (titleLable == nil) {
        titleLable = [[UILabel alloc] init];
        titleLable.tag = 10086;
        titleLable.numberOfLines = 2;
        titleLable.lineBreakMode = NSLineBreakByWordWrapping;
        titleLable.font = [UIFont systemFontOfSize:16];
        titleLable.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:titleLable];
        [titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(cell.contentView);
        }];
    }
    FilterInfo *info = self.filterList[indexPath.row];
    [titleLable setText:info.displayString];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FilterInfo *info = self.filterList[indexPath.row];
    NSString *string = info.displayString;
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:16]};
    CGSize maxSize = CGSizeMake(CGFLOAT_MAX, 60);

    CGRect boundingBox = [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];

    CGFloat stringWidth = boundingBox.size.width;
//    CGFloat stringHeight = boundingBox.size.height;
    return CGSizeMake(stringWidth, 60);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor systemCyanColor]; // your highlight color
    FilterInfo *info = self.filterList[indexPath.row];
    if (![self.selectedFilters containsObject:info]) {
        [self.selectedFilters addObject:info];
    }
    NSLog(@"filter: %@", info.displayString);
    [self processFilter];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor systemGroupedBackgroundColor]; // your normal color
    
    FilterInfo *info = self.filterList[indexPath.row];
    if ([self.selectedFilters containsObject:info]) {
        [self.selectedFilters removeObject:info];
    }
    NSLog(@"filter: %@", info.displayString);
    [self processFilter];
}



#pragma mark - process

- (void)processFilter
{
    if (self.selectedFilters.count == 0) {
        return;
    }
    self.filterLabel.text = @"滤镜：";
    // 加载原始图像
    UIImage *inputImage = self.sourceImageView.image;

    // 创建 GPUImagePicture
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:inputImage];

    // 初始化第一个滤镜
    GPUImageFilter *currentFilter = nil;
    for (FilterInfo *info in self.selectedFilters) {
        GPUImageFilter *filter = [[info.cls alloc] init];
        if (currentFilter) {
            // 将当前滤镜连接到上一个滤镜
            [currentFilter addTarget:filter];
        } else {
            // 第一个滤镜直接连接到 picture
            [picture addTarget:filter];
        }
        // 更新当前滤镜
        currentFilter = filter;
        
        self.filterLabel.text = [NSString stringWithFormat:@"%@\n%@", self.filterLabel.text, info.filterName];
    }

    // 确保最后一个滤镜调用 useNextFrameForImageCapture
    [currentFilter useNextFrameForImageCapture];
    // 处理图像
    [picture processImage];

    // 获取处理后的图像
    UIImage *outputImage = [currentFilter imageFromCurrentFramebuffer];
    self.filteredImageView.image = outputImage;
}


#pragma mark - FilterList

- (NSArray<FilterInfo *> *)createFilterList
{
    NSMutableArray<FilterInfo *> *filters = [NSMutableArray array];
    
    //自定义滤镜
    [filters addObject:[self createFilterInfoWithName:@"FishEye" description:@"鱼眼效果(自定义)" cls:[FishEyeFilter class]]];

    // 颜色调整滤镜
    [filters addObject:[self createFilterInfoWithName:@"Brightness" description:@"调整亮度" cls:[GPUImageBrightnessFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Contrast" description:@"调整对比度" cls:[GPUImageContrastFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Saturation" description:@"调整饱和度" cls:[GPUImageSaturationFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Exposure" description:@"调整曝光" cls:[GPUImageExposureFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Gamma" description:@"调整伽马值" cls:[GPUImageGammaFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Levels" description:@"调整色阶" cls:[GPUImageLevelsFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"RGB" description:@"调整红、绿、蓝通道的强度" cls:[GPUImageRGBFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Hue" description:@"调整色调" cls:[GPUImageHueFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"White Balance" description:@"调整白平衡" cls:[GPUImageWhiteBalanceFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Highlight Shadow" description:@"调整高光和阴影" cls:[GPUImageHighlightShadowFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Color Invert" description:@"反色滤镜" cls:[GPUImageColorInvertFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Grayscale" description:@"灰度滤镜" cls:[GPUImageGrayscaleFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Monochrome" description:@"单色滤镜" cls:[GPUImageMonochromeFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"False Color" description:@"双色调滤镜" cls:[GPUImageFalseColorFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Haze" description:@"雾化效果" cls:[GPUImageHazeFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Sepia" description:@"复古滤镜" cls:[GPUImageSepiaFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Opacity" description:@"调整透明度" cls:[GPUImageOpacityFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Solid Color" description:@"生成纯色图像" cls:[GPUImageSolidColorGenerator class]]];

    // 图像处理滤镜
    [filters addObject:[self createFilterInfoWithName:@"Box Blur" description:@"方框模糊" cls:[GPUImageBoxBlurFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Gaussian Blur" description:@"高斯模糊" cls:[GPUImageGaussianBlurFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Median" description:@"中值滤波" cls:[GPUImageMedianFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Bilateral" description:@"双边滤波" cls:[GPUImageBilateralFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Sharpen" description:@"锐化滤镜" cls:[GPUImageSharpenFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Unsharp Mask" description:@"反锐化掩模滤镜" cls:[GPUImageUnsharpMaskFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Sobel Edge Detection" description:@"Sobel 边缘检测" cls:[GPUImageSobelEdgeDetectionFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Canny Edge Detection" description:@"Canny 边缘检测" cls:[GPUImageCannyEdgeDetectionFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Prewitt Edge Detection" description:@"Prewitt 边缘检测" cls:[GPUImagePrewittEdgeDetectionFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"XY Derivative" description:@"XY 方向导数边缘检测" cls:[GPUImageXYDerivativeFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Harris Corner Detection" description:@"Harris 角点检测" cls:[GPUImageHarrisCornerDetectionFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Noble Corner Detection" description:@"Noble 角点检测" cls:[GPUImageNobleCornerDetectionFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Shi-Tomasi Feature Detection" description:@"Shi-Tomasi 角点检测" cls:[GPUImageShiTomasiFeatureDetectionFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Motion Blur" description:@"运动模糊" cls:[GPUImageMotionBlurFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Zoom Blur" description:@"缩放模糊" cls:[GPUImageZoomBlurFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Tilt Shift" description:@"移轴模糊" cls:[GPUImageTiltShiftFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Vignette" description:@"暗角效果" cls:[GPUImageVignetteFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Swirl" description:@"漩涡效果" cls:[GPUImageSwirlFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Bulge Distortion" description:@"凸起扭曲效果" cls:[GPUImageBulgeDistortionFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Pinch Distortion" description:@"收缩扭曲效果" cls:[GPUImagePinchDistortionFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Stretch Distortion" description:@"拉伸扭曲效果" cls:[GPUImageStretchDistortionFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Sphere Refraction" description:@"球形折射效果" cls:[GPUImageSphereRefractionFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Glass Sphere" description:@"玻璃球效果" cls:[GPUImageGlassSphereFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Toon" description:@"卡通效果" cls:[GPUImageToonFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Posterize" description:@"色调分离效果" cls:[GPUImagePosterizeFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Emboss" description:@"浮雕效果" cls:[GPUImageEmbossFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Halftone" description:@"半色调效果" cls:[GPUImageHalftoneFilter class]]];

    // 混合滤镜
    [filters addObject:[self createFilterInfoWithName:@"Alpha Blend" description:@"透明度混合" cls:[GPUImageAlphaBlendFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Dissolve Blend" description:@"溶解混合" cls:[GPUImageDissolveBlendFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Multiply Blend" description:@"正片叠底混合" cls:[GPUImageMultiplyBlendFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Add Blend" description:@"叠加混合" cls:[GPUImageAddBlendFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Subtract Blend" description:@"减去混合" cls:[GPUImageSubtractBlendFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Divide Blend" description:@"划分混合" cls:[GPUImageDivideBlendFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Overlay Blend" description:@"叠加混合" cls:[GPUImageOverlayBlendFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Darken Blend" description:@"变暗混合" cls:[GPUImageDarkenBlendFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Lighten Blend" description:@"变亮混合" cls:[GPUImageLightenBlendFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Screen Blend" description:@"屏幕混合" cls:[GPUImageScreenBlendFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Exclusion Blend" description:@"排除混合" cls:[GPUImageExclusionBlendFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Difference Blend" description:@"差异混合" cls:[GPUImageDifferenceBlendFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Hard Light Blend" description:@"强光混合" cls:[GPUImageHardLightBlendFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Soft Light Blend" description:@"柔光混合" cls:[GPUImageSoftLightBlendFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Chroma Key Blend" description:@"色度键混合" cls:[GPUImageChromaKeyBlendFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Mask" description:@"遮罩混合" cls:[GPUImageMaskFilter class]]];

    // 视觉效果滤镜
    [filters addObject:[self createFilterInfoWithName:@"Pixellate" description:@"像素化效果" cls:[GPUImagePixellateFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Polar Pixellate" description:@"极坐标像素化效果" cls:[GPUImagePolarPixellateFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Polka Dot" description:@"圆点效果" cls:[GPUImagePolkaDotFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Crosshatch" description:@"交叉线效果" cls:[GPUImageCrosshatchFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Sketch" description:@"素描效果" cls:[GPUImageSketchFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Threshold Sketch" description:@"阈值素描效果" cls:[GPUImageThresholdSketchFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Smooth Toon" description:@"平滑卡通效果" cls:[GPUImageSmoothToonFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Kuwahara" description:@"桑原滤波" cls:[GPUImageKuwaharaFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Mosaic" description:@"马赛克效果" cls:[GPUImageMosaicFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Local Binary Pattern" description:@"局部二值模式效果" cls:[GPUImageLocalBinaryPatternFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Perlin Noise" description:@"Perlin 噪声效果" cls:[GPUImagePerlinNoiseFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"JFA Voronoi" description:@"Voronoi 图效果" cls:[GPUImageJFAVoronoiFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Voronoi Consumer" description:@"Voronoi 图消费者效果" cls:[GPUImageVoronoiConsumerFilter class]]];

    // 其他滤镜
    [filters addObject:[self createFilterInfoWithName:@"Transform" description:@"图像变换" cls:[GPUImageTransformFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Crop" description:@"图像裁剪" cls:[GPUImageCropFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Lanczos Resampling" description:@"Lanczos 重采样" cls:[GPUImageLanczosResamplingFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Histogram" description:@"直方图生成" cls:[GPUImageHistogramFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Histogram Equalization" description:@"直方图均衡化" cls:[GPUImageHistogramEqualizationFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Adaptive Threshold" description:@"自适应阈值" cls:[GPUImageAdaptiveThresholdFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Average Luminance Threshold" description:@"平均亮度阈值" cls:[GPUImageAverageLuminanceThresholdFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"Low Pass" description:@"低通滤波" cls:[GPUImageLowPassFilter class]]];
    [filters addObject:[self createFilterInfoWithName:@"High Pass" description:@"高通滤波" cls:[GPUImageHighPassFilter class]]];

    return [filters copy];
}

- (FilterInfo *)createFilterInfoWithName:(NSString *)name description:(NSString *)description cls:(Class)cls
{
    FilterInfo *info = [[FilterInfo alloc] init];
    info.filterName = name;
    info.filterDescription = description;
    info.cls = cls;
    return info;
}

@end
