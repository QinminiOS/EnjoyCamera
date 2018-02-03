//
//  RTImagePickerUtils.h
//  RTImagePicker
//
//  Created by 叔 陈 on 2/23/16.
//  Copyright © 2016 叔 陈. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RTImagePickerViewController.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface RTImagePickerViewController (Private)

@property (nonatomic, strong) NSBundle *assetBundle;

@end

@interface NSIndexSet (Convenience)

- (NSArray *)rt_indexPathsFromIndexesWithSection:(NSUInteger)section;

@end

@interface UICollectionView (Convenience)

- (NSArray *)rt_indexPathsForElementsInRect:(CGRect)rect;

@end

@interface RTImagePickerUtils : NSObject

+ (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect addedHandler:(void (^)(CGRect addedRect))addedHandler removedHandler:(void (^)(CGRect removedRect))removedHandler;
+ (UIImage *)placeholderImageWithSize:(CGSize)size;

@end
