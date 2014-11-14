//
//  TFTableViewDataSource.h
//  TFIntentions
//
//  Created by Daniel Garbień on 30/10/14.
//  Copyright (c) 2014 krzysztof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TFUITableViewDelegateCellSizingIntention.h>

@interface TFTableViewDataSource : NSObject <UITableViewDataSource, TFUITableViewCellConfiguring>
@property (nonatomic, weak) IBOutlet UITableView * tableView;

- (NSString *)itemAtIndexPath:(NSIndexPath *)indexPath;
@end
