//
//  RTAssetCollectionViewCell.m
//  RTImagePicker
//
//  Created by 叔 陈 on 2/19/16.
//  Copyright © 2016 叔 陈. All rights reserved.
//

#import "RTAssetCollectionViewCell.h"

@interface RTAssetCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIView *overlayView;

@end

@implementation RTAssetCollectionViewCell

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    // Show/hide overlay view
    self.overlayView.backgroundColor = [UIColor darkGrayColor];
    self.overlayView.alpha = 0.6f;
    self.overlayView.hidden = !(selected && self.showsOverlayViewWhenSelected);
}
@end
