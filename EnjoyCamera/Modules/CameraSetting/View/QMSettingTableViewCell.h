//
//  QMSettingTableViewCell.h
//  EnjoyCamera
//
//  Created by qinmin on 2017/10/3.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMSettingModel.h"

@interface QMSettingTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UISwitch *switcher;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

- (void)setSettingModelType:(QMSettingType)type;
@end
