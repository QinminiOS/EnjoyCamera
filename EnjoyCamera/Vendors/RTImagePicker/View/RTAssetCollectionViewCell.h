//
//  RTAssetCollectionViewCell.h
//  RTImagePicker
//
//  Created by 叔 陈 on 2/19/16.
//  Copyright © 2016 叔 陈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTVideoIndicatorView.h"

@interface RTAssetCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView            *imageView;
@property (nonatomic, weak) IBOutlet RTVideoIndicatorView   *videoIndicatorView;
@property (nonatomic, assign) BOOL                          showsOverlayViewWhenSelected;

@end
