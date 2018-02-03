//
//  QMSettingTableViewCell.m
//  EnjoyCamera
//
//  Created by qinmin on 2017/10/3.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "QMSettingTableViewCell.h"

@implementation QMSettingTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.switcher.transform = CGAffineTransformMakeScale(0.9, 0.9);
}

- (void)setSettingModelType:(QMSettingType)type
{
    if (type == QMSettingTypeLink) {
        self.switcher.hidden = YES;
    }else if (type == QMSettingTypeSwitch) {
        self.switcher.hidden = NO;
    }
}

@end
