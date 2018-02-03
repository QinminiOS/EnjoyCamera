//
//  RTImagePickerUtils.m
//  RTImagePicker
//
//  Created by 叔 陈 on 2/23/16.
//  Copyright © 2016 叔 陈. All rights reserved.
//

#import "RTImagePickerUtils.h"

@implementation NSIndexSet (Convenience)

- (NSArray *)rt_indexPathsFromIndexesWithSection:(NSUInteger)section
{
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:section]];
    }];
    return indexPaths;
}

@end

@implementation UICollectionView (Convenience)

- (NSArray *)rt_indexPathsForElementsInRect:(CGRect)rect
{
    NSArray *allLayoutAttributes = [self.collectionViewLayout layoutAttributesForElementsInRect:rect];
    if (allLayoutAttributes.count == 0) { return nil; }
    
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:allLayoutAttributes.count];
    for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes) {
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        [indexPaths addObject:indexPath];
    }
    return indexPaths;
}

@end

@implementation RTImagePickerUtils

+ (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect addedHandler:(void (^)(CGRect addedRect))addedHandler removedHandler:(void (^)(CGRect removedRect))removedHandler
{
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

+ (UIImage *)placeholderImageWithSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *backgroundColor = [UIColor colorWithRed:(239.0 / 255.0) green:(239.0 / 255.0) blue:(244.0 / 255.0) alpha:1.0];
    UIColor *iconColor = [UIColor colorWithRed:(179.0 / 255.0) green:(179.0 / 255.0) blue:(182.0 / 255.0) alpha:1.0];
    
    // Background
    CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    
    // Icon (back)
    CGRect backIconRect = CGRectMake(size.width * (16.0 / 68.0),
                                     size.height * (20.0 / 68.0),
                                     size.width * (32.0 / 68.0),
                                     size.height * (24.0 / 68.0));
    
    CGContextSetFillColorWithColor(context, [iconColor CGColor]);
    CGContextFillRect(context, backIconRect);
    
    CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
    CGContextFillRect(context, CGRectInset(backIconRect, 1.0, 1.0));
    
    // Icon (front)
    CGRect frontIconRect = CGRectMake(size.width * (20.0 / 68.0),
                                      size.height * (24.0 / 68.0),
                                      size.width * (32.0 / 68.0),
                                      size.height * (24.0 / 68.0));
    
    CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
    CGContextFillRect(context, CGRectInset(frontIconRect, -1.0, -1.0));
    
    CGContextSetFillColorWithColor(context, [iconColor CGColor]);
    CGContextFillRect(context, frontIconRect);
    
    CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
    CGContextFillRect(context, CGRectInset(frontIconRect, 1.0, 1.0));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


@end
