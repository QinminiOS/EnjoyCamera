//
//  SuspensionView.h
//  EnjoyCamera
//
//  Created by qinmin on 2017/10/9.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYModel.h>

@interface QMSuspensionModel : NSObject<YYModel>
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) CGFloat value;
+ (NSArray<QMSuspensionModel *> *)buildSuspensionModelsWithJson:(NSString *)jsonStr;
@end

@interface QMSuspensionView : UIView
@property (nonatomic, strong) NSArray<QMSuspensionModel *> *suspensionModels;
@property (nonatomic, copy) void (^suspensionItemClickBlock)(QMSuspensionModel *item);

- (UICollectionViewFlowLayout *)collectionViewForFlowLayout;

- (void)toggleBelowInView:(UIView *)view;
- (void)showBelowInView:(UIView *)view;
- (BOOL)hide;
@end
