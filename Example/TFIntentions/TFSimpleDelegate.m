//
//  TFSimpleDataSource.m
//  TFIntentions
//
//  Created by Krzysztof Profic on 06/11/14.
//  Copyright (c) 2014 krzysztof. All rights reserved.
//

#import "TFSimpleDelegate.h"
#import "TFTableViewDataSource.h"
#import <TFIntentions/TFDataSourceCompositeIntention.h>

@implementation TFSimpleDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id model = [(TFDataSourceCompositeIntention *)tableView.dataSource itemAtIndexPath:indexPath];
    NSLog(@"selected %@", model);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

@end
