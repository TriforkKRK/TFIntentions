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
    TFTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - TFUITableViewCellConfiguring

- (void)configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSArray * titles = @[@"Intentions ... lorem ipsum dolor ... lorem ipsum dolor ... lorem ipsum dolor ... lorem ipsum dolor ... lorem ipsum dolor ... lorem ipsum dolor ... 222 lorem ipsum dolor ... lorem ipsum dolor ...  ",
                         @"\n\n\nbrougth to you by\n",
                         @"Krzysztof Profic"
                         ];
    
    ((TFTableViewCell *) cell).title = titles[indexPath.row];
}

- (NSString *)reuseIdentifierAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellIdentifier;
}

@end
