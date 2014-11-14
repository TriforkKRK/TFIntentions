//
//  TFSingleEntryDataSource.h
//  TFIntentions
//
//  Created by Krzysztof Profic on 06/11/14.
//  Copyright (c) 2014 krzysztof. All rights reserved.
//

#import "TFOwnerableObject.h"
#import <TFIntentions/TFUITableViewDelegateCellSizingIntention.h>

@interface TFSingleEntryDataSource : NSObject<UITableViewDataSource, TFUITableViewCellConfiguring>

@property (nonatomic, weak) IBOutlet UITableView * tableView;

- (NSString *)itemAtIndexPath:(NSIndexPath *)indexPath;

@end
