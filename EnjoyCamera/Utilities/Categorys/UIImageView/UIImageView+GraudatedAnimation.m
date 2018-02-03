//
//  UIImageView+DisplayFullScreen.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/4/13.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "UIImageView+GraudatedAnimation.h"

static NSMutableArray *reusableQueue;


@interface  GraudatedAnimationView: UIImageView

@end

@implementation GraudatedAnimationView

@end


@implementation UIImageView (GraudatedAnimation)

- (GraudatedAnimationView *)dequeue
{
    GraudatedAnimationView *tmpImgView = nil;

    @synchronized(self) {
        if (!reusableQueue) {
            reusableQueue = [[NSMutableArray alloc] init];
        }
        
        if (reusableQueue.count > 0) {
            tmpImgView = [reusableQueue firstObject];
            [reusableQueue removeObject:tmpImgView];
        }
    }
//    NSLog(@"dequeue=%d", reusableQueue.count);
    return tmpImgView;
}

- (void)enqueue:(GraudatedAnimationView *)view
{
    @synchronized(self) {
        if (!reusableQueue) {
            reusableQueue = [[NSMutableArray alloc] init];
        }
        
        if (view) {
            view.image = nil;
            
            [reusableQueue addObject:view];
        }
    }
//    NSLog(@"enqueue=%d", reusableQueue.count);

}


- (void)setImageWithGraudatedAnimation:(UIImage * )image {
    [self setImageWithGraudatedAnimation:image duration:0.5];
}

- (void)setImageWithGraudatedAnimation:(UIImage * )image duration:(NSTimeInterval)duration {
    
    dispatch_sync(dispatch_get_main_queue(), ^{
//        @autoreleasepool {
            GraudatedAnimationView *tmpImageView = [self dequeue];
            if (!tmpImageView) {
                tmpImageView = [[GraudatedAnimationView alloc] init];
            }
            
            tmpImageView.frame = self.bounds;
            tmpImageView.image = image ;
            tmpImageView.alpha = 0 ;
            
            [self insertSubview:tmpImageView atIndex:0];
            
            [UIView animateWithDuration:duration animations:^{
                tmpImageView.alpha = 1 ;
            }completion:^(BOOL isOk){
                self.image = image ;
                [self enqueue:tmpImageView];
                [tmpImageView removeFromSuperview];
            }];

//        }
    });
    
}

- (void)setImageWithGraudatedMainAnimation:(UIImage * )image graduatedView:(UIImageView *)graduatedView duration:(NSTimeInterval)duration {
    
    if (isnan(self.bounds.origin.x) || isnan(self.bounds.origin.y) || isnan(self.bounds.size.width) || isnan(self.bounds.size.height)) {
        graduatedView.frame = CGRectMake(0, 0, 0, 0);
    }else{
        graduatedView.frame = self.bounds;
    }
    graduatedView.image = image ;
    graduatedView.alpha = 0 ;
    
    [UIView setAnimationsEnabled:YES];
    [UIView animateWithDuration:duration animations:^{
        graduatedView.alpha = 1 ;
    } completion:^(BOOL isOk){
        self.image = image ;
        graduatedView.image = nil;
    }];
    
}

- (void)setImageWithGraudatedMainAnimation:(UIImage * )image duration:(NSTimeInterval)duration {
    
//        @autoreleasepool {
            GraudatedAnimationView *tmpImageView = [self dequeue];
            if (!tmpImageView) {
                tmpImageView = [[GraudatedAnimationView alloc] init];
            }
            
            tmpImageView.frame = self.bounds;
            tmpImageView.image = image ;
            tmpImageView.alpha = 0 ;
            
            [self insertSubview:tmpImageView atIndex:0];
            
            [UIView animateWithDuration:duration animations:^{
                tmpImageView.alpha = 1 ;
            } completion:^(BOOL isOk){
                self.image = image ;
                [self enqueue:tmpImageView];
                [tmpImageView removeFromSuperview];
            }];
//        }
    
}

- (void)setImageWithGraudatedMainAnimation:(UIImage * )image duration:(NSTimeInterval)duration completion:(void (^)())completion{
    
//    @autoreleasepool {
        GraudatedAnimationView *tmpImageView = [self dequeue];
        if (!tmpImageView) {
            tmpImageView = [[GraudatedAnimationView alloc] init];
        }
        
        tmpImageView.frame = self.bounds;
        tmpImageView.image = image ;
        tmpImageView.alpha = 0 ;
        
        [self insertSubview:tmpImageView atIndex:0];
        
        [UIView animateWithDuration:duration animations:^{
            tmpImageView.alpha = 1 ;
        } completion:^(BOOL isOk){
            self.image = image ;
            [self enqueue:tmpImageView];
            [tmpImageView removeFromSuperview];
            
            if (completion) {
                completion();
            }
        }];
        
//    }
    
}

- (void)setGraudatedAnimationViewTransform:(CGAffineTransform)transfrom
{
    for (GraudatedAnimationView *view in self.subviews) {
        if ([view isKindOfClass:[GraudatedAnimationView class]]) {
            view.transform = view.transform;
            
            break;
        }
    }
}


- (void)setGraudatedAnimationViewFrame:(CGRect)frame
{
    for (GraudatedAnimationView *view in self.subviews) {
        if ([view isKindOfClass:[GraudatedAnimationView class]]) {
            view.transform = view.transform;
            view.frame = frame;
            
            break;
        }
    }
}

+ (void)clearCatches
{
    reusableQueue = nil;
}


@end
