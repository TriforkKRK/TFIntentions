//
//  TFTableViewDataSource.m
//  TFIntentions
//
//  Created by Daniel Garbień on 30/10/14.
//  Copyright (c) 2014 krzysztof. All rights reserved.
//

#import "TFTableViewDataSource.h"
#import "TFTableViewCell.h"

@implementation TFTableViewDataSource

static NSString * const kCellIdentifier = @"cell";

#pragma mark - UITableViewDataSource

- (void)setTableView:(UITableView *)tableView
{
    [tableView registerClass:[TFTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TFTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSString *)itemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * titles = @[@"More than one line of text. It will take 2 or 3 lines depending on screen tableView width... lorem ipsum dolor ... lorem ipsum dolor ... lorem ipsum dolor ... lorem ipsum dolor ... lorem ipsum dolor ... lorem ipsum dolor ... 222 lorem ipsum dolor ... ",
                         @"One line text",
                         @"Two lines of text \nbecause there is a explicit newline char"
                         ];
    return titles[indexPath.row];
}

#pragma mark - TFUITableViewCellConfiguring

- (void)configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath
{
    ((TFTableViewCell *) cell).title = [self itemAtIndexPath:indexPath];
}

- (NSString *)reuseIdentifierAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellIdentifier;
}

@end
