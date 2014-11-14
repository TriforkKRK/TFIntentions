//
//  TFSingleEntryDataSource.m
//  TFIntentions
//
//  Created by Krzysztof Profic on 06/11/14.
//  Copyright (c) 2014 krzysztof. All rights reserved.
//

#import "TFSingleEntryDataSource.h"
#import "TFTableViewCell.h"

static NSString * const kCellIdentifier = @"kSingleEntryTableViewCell";

@implementation TFSingleEntryDataSource

- (void)setTableView:(UITableView *)tableView
{
    [tableView registerClass:[TFTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TFTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (NSString *)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Single entry first cell";
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
