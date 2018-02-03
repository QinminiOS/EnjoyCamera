//
//  RTAlbumTableViewCell.h
//  RTImagePicker
//
//  Created by 叔 陈 on 2/19/16.
//  Copyright © 2016 叔 陈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Geometry.h"

@interface RTAlbumTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView   *imageView1;
@property (nonatomic, strong) UIImageView   *imageView2;
@property (nonatomic, strong) UIImageView   *imageView3;
@property (nonatomic, strong) UIImageView   *imageView4;

@property (nonatomic, strong) UILabel       *titleLabel;
@property (nonatomic, strong) UILabel       *countLabel;

@end
