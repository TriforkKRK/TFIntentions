//
//  TFSimpleDataSource.m
//  TFIntentions
//
//  Created by Krzysztof Profic on 06/11/14.
//  Copyright (c) 2014 krzysztof. All rights reserved.
//

#import "TFSimpleDelegate.h"

@implementation TFSimpleDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

@end
