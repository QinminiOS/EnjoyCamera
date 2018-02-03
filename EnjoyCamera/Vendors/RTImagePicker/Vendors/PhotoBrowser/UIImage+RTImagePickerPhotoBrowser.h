//
//  UIImage+RTImagePickerPhotoBrowser.h
//  RTImagePicker
//
//  Created by 叔 陈 on 2/23/16.
//  Copyright © 2016 叔 陈. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage (RTImagePickerPhotoBrowser)

+ (UIImage *)imageForResourcePath:(NSString *)path ofType:(NSString *)type inBundle:(NSBundle *)bundle;
+ (UIImage *)clearImageWithSize:(CGSize)size;

@end
