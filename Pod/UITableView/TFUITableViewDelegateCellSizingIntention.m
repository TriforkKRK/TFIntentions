/*
 * Created by Krzysztof Profic on 17/10/14.
 * Copyright (c) 2014 Trifork A/S.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "TFUITableViewDelegateCellSizingIntention.h"

@interface TFUITableViewDelegateCellSizingIntention()
@end

@implementation TFUITableViewDelegateCellSizingIntention

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat separatorHeight = (self.tableView.separatorStyle != UITableViewCellSeparatorStyleNone) ? (1.0f / [[UIScreen mainScreen] scale]) : 0.f;
    CGFloat height = [self heightForBasicCellAtIndexPath:indexPath] + separatorHeight;
    return height;
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(self.tableView, @"TableView can not be nil");
    NSAssert([self.tableViewDataSource conformsToProtocol:@protocol(UITableViewDataSource)], @"dataSource needs to conform to UITableViewDataSource protocol");
    NSAssert([self.tableViewDataSource conformsToProtocol:@protocol(TFUITableViewCellConfiguring)], @"dataSource needs to conform to TFUITableViewCellSizing protocol");
    
    static id sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableViewDataSource tableView:self.tableView cellForRowAtIndexPath:indexPath];
    });
    
    [self.tableViewDataSource configureCell:sizingCell atIndexPath:indexPath];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell
{
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}

@end
