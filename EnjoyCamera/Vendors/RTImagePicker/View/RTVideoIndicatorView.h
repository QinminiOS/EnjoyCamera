//
//  RTVideoIndicatorView.h
//  RTImagePicker
//
//  Created by 叔 陈 on 2/19/16.
//  Copyright © 2016 叔 陈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTVideoIconView.h"
#import "UIView+Geometry.h"

@interface RTVideoIndicatorView : UIView

@property (nonatomic, weak) IBOutlet UILabel            *timeLabel;
@property (nonatomic, weak) IBOutlet RTVideoIconView    *videoIcon;

@end
