//
//  RTAlbumTableViewCell.m
//  RTImagePicker
//
//  Created by 叔 陈 on 2/19/16.
//  Copyright © 2016 叔 陈. All rights reserved.
//

#import "RTAlbumTableViewCell.h"

@interface RTAlbumTableViewCell()
{
    UIImageView *disclosureIndicatorView;
    UIView *imageBackView1;
    UIView *imageBackView2;
    UIView *imageBackView3;
    UIView *imageBackView4;
}
@end

@implementation RTAlbumTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews
{
    imageBackView1 = [self shadowView];
    imageBackView2 = [self shadowView];
    imageBackView3 = [self shadowView];
    imageBackView4 = [self shadowView];
    
    self.imageView1 = [[UIImageView alloc] initWithFrame:CGRectZero];
    _imageView1.contentMode = UIViewContentModeScaleAspectFill;
    _imageView1.clipsToBounds = YES;
    [imageBackView1 addSubview:_imageView1];

    self.imageView2 = [[UIImageView alloc] initWithFrame:CGRectZero];
    _imageView2.contentMode = UIViewContentModeScaleAspectFill;
    _imageView2.clipsToBounds = YES;
    [imageBackView2 addSubview:_imageView2];
    
    self.imageView3 = [[UIImageView alloc] initWithFrame:CGRectZero];
    _imageView3.contentMode = UIViewContentModeScaleAspectFill;
    _imageView3.clipsToBounds = YES;
    [imageBackView3 addSubview:_imageView3];
    
    self.imageView4 = [[UIImageView alloc] initWithFrame:CGRectZero];
    _imageView4.contentMode = UIViewContentModeScaleAspectFill;
    _imageView4.clipsToBounds = YES;
    [imageBackView4 addSubview:_imageView4];
    
    [self.contentView addSubview:imageBackView4];
    [self.contentView addSubview:imageBackView3];
    [self.contentView addSubview:imageBackView2];
    [self.contentView addSubview:imageBackView1];
    
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont systemFontOfSize:17.0f];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _titleLabel.numberOfLines = 1;
    [self.contentView addSubview:_titleLabel];
    
    self.countLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    _countLabel.textAlignment = NSTextAlignmentLeft;
    _countLabel.font = [UIFont systemFontOfSize:12.0f];
    _countLabel.textColor = [UIColor whiteColor];
    _countLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _countLabel.numberOfLines = 1;
    [self.contentView addSubview:_countLabel];
    
    disclosureIndicatorView = [[UIImageView alloc]initWithFrame:CGRectZero];
    disclosureIndicatorView.image = [UIImage imageNamed:@"rtimagepicker_indicator"];
    [self.contentView addSubview:disclosureIndicatorView];
}

- (void)layoutSubviews
{
    CGFloat imageWidth = self.width/5.0f;
    imageBackView1.frame = CGRectMake(30.0f, (self.height - imageWidth)/2.0f, imageWidth, imageWidth);
    [imageBackView1.layer setShadowPath:[UIBezierPath bezierPathWithRect:[self shadowPathWithRect:imageBackView1.bounds]].CGPath];
    self.imageView1.frame = CGRectMake(0.0, 0.0, imageWidth, imageWidth);
    
    imageWidth = imageWidth - 10.0f;
    imageBackView2.frame = CGRectMake(imageBackView1.right - self.width/12.0f, (self.height - imageWidth)/2.0f, imageWidth, imageWidth);
    [imageBackView2.layer setShadowPath:[UIBezierPath bezierPathWithRect:[self shadowPathWithRect:imageBackView2.bounds]].CGPath];
    self.imageView2.frame = CGRectMake(0.0f, 0.0f, imageWidth, imageWidth);
    
    imageWidth = imageWidth - 10.0f;
    imageBackView3.frame = CGRectMake(imageBackView2.right - self.width/10.0f, (self.height - imageWidth)/2.0f, imageWidth, imageWidth);
    [imageBackView3.layer setShadowPath:[UIBezierPath bezierPathWithRect:[self shadowPathWithRect:imageBackView3.bounds]].CGPath];
    self.imageView3.frame = CGRectMake(0.0f, 0.0f, imageWidth, imageWidth);
    
    imageWidth = imageWidth - 10.0f;
    imageBackView4.frame = CGRectMake(imageBackView3.right - self.width/10.0f, (self.height - imageWidth)/2.0f, imageWidth, imageWidth);
    [imageBackView4.layer setShadowPath:[UIBezierPath bezierPathWithRect:[self shadowPathWithRect:imageBackView4.bounds]].CGPath];
    self.imageView4.frame = CGRectMake(0.0f, 0.0f, imageWidth, imageWidth);
    
    self.titleLabel.frame = CGRectMake(imageBackView4.right + 30.0f, (self.height - 50.0f)/2.0f, ScreenWidth - imageBackView4.right - 80.0f, 20.0f);
    self.countLabel.frame = CGRectMake(imageBackView4.right + 30.0f, _titleLabel.bottom + 15.0f, _titleLabel.width, 15.0f);
    disclosureIndicatorView.frame = CGRectMake(self.width - 46.0f, (self.height - 46.0f)/2.0f, 46.0f, 46.0f);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (CGRect)shadowPathWithRect:(CGRect)rect
{
    CGRect frame = rect;
    frame.origin.x += 5.0f;
    return frame;
}

- (UIView *)shadowView
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    view.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOpacity = 0.6f;
    view.layer.shadowRadius = 5.0f;
    return view;
}
@end
