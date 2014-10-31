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
@property (nonatomic, strong) NSMutableDictionary * sizingCells;
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
    
    id sizingCell = [self sizingCellAtIndexPath:indexPath];
    [self.tableViewDataSource configureCell:sizingCell atIndexPath:indexPath];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell
{
    // base layout system calculations on a contentView instead of a cell
    // this makes it independent of what UIKit does with table view cell (e.g. adds standard size constraints 320x44)
    [sizingCell.contentView setNeedsLayout];
    [sizingCell.contentView layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}

#pragma mark - Private Methods

- (NSMutableDictionary *)sizingCells
{
    if (_sizingCells == nil) {
        _sizingCells = [NSMutableDictionary dictionary];
    }
    
    return _sizingCells;
}

- (id)sizingCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * reuseId = [self.tableViewDataSource reuseIdentifierAtIndexPath:indexPath];
    id sizingCell = self.sizingCells[reuseId];
    if (sizingCell == nil) {
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:reuseId];
        // add constraints on the lowest level view possible
        [((UITableViewCell *)sizingCell).contentView addConstraint:[NSLayoutConstraint constraintWithItem:((UITableViewCell *)sizingCell).contentView
                                                                                                attribute:NSLayoutAttributeWidth
                                                                                                relatedBy:NSLayoutRelationEqual
                                                                                                   toItem:nil
                                                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                                                               multiplier:1.0
                                                                                                 constant:self.tableView.bounds.size.width]];
        // disregard constraints generated from mask
        ((UITableViewCell *)sizingCell).contentView.translatesAutoresizingMaskIntoConstraints = NO;
        NSAssert(sizingCell, @"Can' be nil");
        self.sizingCells[reuseId] = sizingCell;
    }
    
    return sizingCell;
}

#warning TODO memory warning

@end
