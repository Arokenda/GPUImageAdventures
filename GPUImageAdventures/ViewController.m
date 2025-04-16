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
#import "GaussianGrayscaleSingleFilter.h"

typedef GPUImageFilter *(^FilterInitBlock)(void);

@interface FilterInfo : NSObject
@property (nonatomic, strong) NSString *filterName;
@property (nonatomic, strong) NSString *filterDescription;
@property (nonatomic, copy) FilterInitBlock filterInitBlock;

@property (nonatomic, strong) NSString *displayString;
@end

@implementation FilterInfo

- (NSString *)displayString
{
    return [NSString stringWithFormat:@"%@\n%@", self.filterDescription, self.filterName];
}

@end

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *filterCollectionView;

@property (nonatomic, strong) NSArray<FilterInfo *> *filterList;
@property (nonatomic, strong) NSMutableArray<FilterInfo *> *selectedFilters;

@property (nonatomic, strong) UIImageView *sourceImageView;
@property (nonatomic, strong) GPUImageView *filteredImageView;
@property (nonatomic, strong) UILabel *filterLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupSubview];
    
    //官方使用示例
//    UIImage *inputImage = [UIImage imageNamed:@"llf.jpg"];
//
//    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:inputImage];
//    GPUImageSepiaFilter *stillImageFilter = [[GPUImageSepiaFilter alloc] init];
//
//    [stillImageSource addTarget:stillImageFilter];
//    [stillImageFilter useNextFrameForImageCapture];
//    [stillImageSource processImage];
//
//    UIImage *currentFilteredVideoFrame = [stillImageFilter imageFromCurrentFramebuffer];
//    
//    UIImageView *sourceImageView = [[UIImageView alloc] initWithImage:currentFilteredVideoFrame];
//    sourceImageView.frame = self.view.bounds;
//    [self.view addSubview:sourceImageView];
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
    
    self.filteredImageView = [[GPUImageView alloc] init];
    self.filteredImageView.fillMode = kGPUImageFillModePreserveAspectRatio;
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
//    [self.filteredImageView stop];
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
        GPUImageFilter *filter = info.filterInitBlock();
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
    
    [currentFilter addTarget:self.filteredImageView];

    // 确保最后一个滤镜调用 useNextFrameForImageCapture
//    [currentFilter useNextFrameForImageCapture];
    // 处理图像
    [picture processImage];

    // 获取处理后的图像
//    UIImage *outputImage = [currentFilter imageFromCurrentFramebuffer];
//    self.filteredImageView.image = outputImage;
}


#pragma mark - FilterList

- (NSArray<FilterInfo *> *)createFilterList
{
    NSMutableArray<FilterInfo *> *filters = [NSMutableArray array];
    
    //自定义滤镜
    [filters addObject:[self createFilterInfoWithName:@"FishEye" description:@"鱼眼效果(自定义)" initBlock:^GPUImageFilter *{
        FishEyeFilter *filter = [[FishEyeFilter alloc] init];
        return filter;
    }]];
    [filters addObject:[self createFilterInfoWithName:@"GaussianGrayscaleSingle" description:@"灰度模糊(自定义)" initBlock:^GPUImageFilter *{
        GaussianGrayscaleSingleFilter *filter = [[GaussianGrayscaleSingleFilter alloc] init];
        filter.blurRadiusInPixels = 5;
        return filter;
    }]];

    // Brightness
    [filters addObject:[self createFilterInfoWithName:@"Brightness"
                                         description:@"调整亮度"
                                           initBlock:^GPUImageFilter *{
        GPUImageBrightnessFilter *filter = [[GPUImageBrightnessFilter alloc] init];
        filter.brightness = 0.2;
        return filter;
    }]];

    // Contrast
    [filters addObject:[self createFilterInfoWithName:@"Contrast"
                                         description:@"调整对比度"
                                           initBlock:^GPUImageFilter *{
        GPUImageContrastFilter *filter = [[GPUImageContrastFilter alloc] init];
        filter.contrast = 1.5;
        return filter;
    }]];

    // Saturation
    [filters addObject:[self createFilterInfoWithName:@"Saturation"
                                         description:@"调整饱和度"
                                           initBlock:^GPUImageFilter *{
        GPUImageSaturationFilter *filter = [[GPUImageSaturationFilter alloc] init];
        filter.saturation = 1.5;
        return filter;
    }]];

    // Exposure
    [filters addObject:[self createFilterInfoWithName:@"Exposure"
                                         description:@"调整曝光"
                                           initBlock:^GPUImageFilter *{
        GPUImageExposureFilter *filter = [[GPUImageExposureFilter alloc] init];
        filter.exposure = 0.3;
        return filter;
    }]];

    // Gamma
    [filters addObject:[self createFilterInfoWithName:@"Gamma"
                                         description:@"伽马校正"
                                           initBlock:^GPUImageFilter *{
        GPUImageGammaFilter *filter = [[GPUImageGammaFilter alloc] init];
        filter.gamma = 2.0;
        return filter;
    }]];

    // Hue
    [filters addObject:[self createFilterInfoWithName:@"Hue"
                                         description:@"色调调整"
                                           initBlock:^GPUImageFilter *{
        GPUImageHueFilter *filter = [[GPUImageHueFilter alloc] init];
        filter.hue = 90.0;
        return filter;
    }]];

    // Sharpen
    [filters addObject:[self createFilterInfoWithName:@"Sharpen"
                                         description:@"锐化处理"
                                           initBlock:^GPUImageFilter *{
        GPUImageSharpenFilter *filter = [[GPUImageSharpenFilter alloc] init];
        filter.sharpness = 1.0;
        return filter;
    }]];

    // Gaussian Blur
    [filters addObject:[self createFilterInfoWithName:@"GaussianBlur"
                                         description:@"高斯模糊"
                                           initBlock:^GPUImageFilter *{
        GPUImageGaussianBlurFilter *filter = [[GPUImageGaussianBlurFilter alloc] init];
        filter.blurRadiusInPixels = 5.0;
        return filter;
    }]];

    // Pixellate
    [filters addObject:[self createFilterInfoWithName:@"Pixellate"
                                         description:@"像素化"
                                           initBlock:^GPUImageFilter *{
        GPUImagePixellateFilter *filter = [[GPUImagePixellateFilter alloc] init];
        filter.fractionalWidthOfAPixel = 0.02;
        return filter;
    }]];

    // Sepia
    [filters addObject:[self createFilterInfoWithName:@"Sepia"
                                         description:@"怀旧棕色(Sepia)"
                                           initBlock:^GPUImageFilter *{
        GPUImageSepiaFilter *filter = [[GPUImageSepiaFilter alloc] init];
        filter.intensity = 1.0;
        return filter;
    }]];

    // Grayscale
    [filters addObject:[self createFilterInfoWithName:@"Grayscale"
                                         description:@"灰度滤镜"
                                           initBlock:^GPUImageFilter *{
        return [[GPUImageGrayscaleFilter alloc] init];
    }]];

    // Sketch
    [filters addObject:[self createFilterInfoWithName:@"Sketch"
                                         description:@"素描"
                                           initBlock:^GPUImageFilter *{
        return [[GPUImageSketchFilter alloc] init];
    }]];

    // Emboss
    [filters addObject:[self createFilterInfoWithName:@"Emboss"
                                         description:@"浮雕"
                                           initBlock:^GPUImageFilter *{
        GPUImageEmbossFilter *filter = [[GPUImageEmbossFilter alloc] init];
        filter.intensity = 1.0;
        return filter;
    }]];

    // Vignette
    [filters addObject:[self createFilterInfoWithName:@"Vignette"
                                         description:@"暗角效果"
                                           initBlock:^GPUImageFilter *{
        GPUImageVignetteFilter *filter = [[GPUImageVignetteFilter alloc] init];
        filter.vignetteStart = 0.3;
        filter.vignetteEnd = 0.75;
        return filter;
    }]];

    // ColorInvert
    [filters addObject:[self createFilterInfoWithName:@"ColorInvert"
                                         description:@"颜色反转"
                                           initBlock:^GPUImageFilter *{
        return [[GPUImageColorInvertFilter alloc] init];
    }]];

    // Monochrome
    [filters addObject:[self createFilterInfoWithName:@"Monochrome"
                                         description:@"单色滤镜"
                                           initBlock:^GPUImageFilter *{
        GPUImageMonochromeFilter *filter = [[GPUImageMonochromeFilter alloc] init];
        filter.color = (GPUVector4){0.6, 0.45, 0.3, 1.0}; //棕色系
        filter.intensity = 1.0;
        return filter;
    }]];

    // Levels
    [filters addObject:[self createFilterInfoWithName:@"Levels"
                                         description:@"色阶调整"
                                           initBlock:^GPUImageFilter *{
        GPUImageLevelsFilter *filter = [[GPUImageLevelsFilter alloc] init];
        [filter setMin:0.0 gamma:1.0 max:0.8 minOut:0.1 maxOut:1.0];
        return filter;
    }]];

    // RGB
    [filters addObject:[self createFilterInfoWithName:@"RGB"
                                         description:@"RGB通道调整"
                                           initBlock:^GPUImageFilter *{
        GPUImageRGBFilter *filter = [[GPUImageRGBFilter alloc] init];
        filter.red = 1.0; filter.green = 0.8; filter.blue = 0.8;
        return filter;
    }]];

    return [filters copy];
}

- (FilterInfo *)createFilterInfoWithName:(NSString *)name
                             description:(NSString *)description
                            initBlock:(FilterInitBlock)initBlock
{
    FilterInfo *info = [[FilterInfo alloc] init];
    info.filterName = name;
    info.filterDescription = description;
    info.filterInitBlock = initBlock;
    return info;
}

@end
