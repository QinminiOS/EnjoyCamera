//
//  QMUImageFilter.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/8/21.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "QMImageFilter.h"

#define kDefaultImageFilterAlpha    0.5

@interface QMImageFilter ()
@property (nonatomic, strong) NSMutableArray *textureUniforms;
@property (nonatomic, strong) QMFilterModel *filterModel;

@end

@implementation QMImageFilter

#pragma mark -
#pragma mark Initialization and teardown
- (instancetype)initWithFilterModel:(QMFilterModel *)model
{
    _filterModel = model;
    NSString *filter = [NSString stringWithContentsOfFile:model.fragmentShader encoding:NSUTF8StringEncoding error:nil];
    
    if (!(self = [super initWithFragmentShaderFromString:filter])) {
        return nil;
    }
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [self bindQMTexture];
    });
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)bindQMTexture
{
    _textureUniforms = [NSMutableArray array];
    
    for (int i = 0; i < _filterModel.textureImages.count; i++) {
        // uniform
        NSString *uniformName = [NSString stringWithFormat:@"inputImageTexture_%d", (i + 1)];
        NSUInteger inputImageTextureID = [filterProgram uniformIndex:uniformName];
        [_textureUniforms addObject:@(inputImageTextureID)];
        
        // load image
        NSString *imagePath = _filterModel.textureImages[i];
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
        GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:image];
        GPUImageFramebuffer *frameBuffer =  [picture framebufferForOutput];
        
        // lock
        [frameBuffer lock];
        [frameBuffer activateFramebuffer];
        
        // Texture
        int startTextureIndex = 3;
        glActiveTexture(GL_TEXTURE0 + i + startTextureIndex);
        glBindTexture(GL_TEXTURE_2D, [frameBuffer texture]);
        glUniform1i([_textureUniforms[i] intValue], i + startTextureIndex);
        
        // unlock
        [frameBuffer unlock];
    }
    
    [self setFloat:kDefaultImageFilterAlpha forUniformName:@"alpha"];
}

- (void)setAlpha:(CGFloat)alpha
{
    [self setFloat:alpha forUniformName:@"alpha"];
}

@end
