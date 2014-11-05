//
//  TFTableViewCell.m
//  TFIntentions
//
//  Created by Daniel Garbień on 30/10/14.
//  Copyright (c) 2014 krzysztof. All rights reserved.
//

#import "TFTableViewCell.h"

@interface TFTableViewCell ()

@property (strong, nonatomic) UILabel * titleLabel;

@end

@implementation TFTableViewCell

#pragma mark - Public Properties

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (NSString *)title
{
    return self.titleLabel.text;
}

#pragma mark - Overridden

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.numberOfLines = 0;
        [self.contentView addSubview:_titleLabel];
        
        NSDictionary * views = NSDictionaryOfVariableBindings(_titleLabel);
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-1-[_titleLabel]-1-|" options:0 metrics:nil views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-1-[_titleLabel]-1-|" options:0 metrics:nil views:views]];
    }
    return self;
}

@end
