//
//  TFSingleEntryDataSource.m
//  TFIntentions
//
//  Created by Krzysztof Profic on 06/11/14.
//  Copyright (c) 2014 krzysztof. All rights reserved.
//

#import "TFSingleEntryDataSource.h"

@implementation TFSingleEntryDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = @"Single entry first cell";
}

@end
