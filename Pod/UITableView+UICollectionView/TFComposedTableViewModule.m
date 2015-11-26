/*
 * Created by Krzysztof Profic on 06/11/14.
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

#import "TFComposedTableViewModule.h"
#import <objc/runtime.h>


#pragma clang push
#pragma clang diagnostic ignored "-Wprotocol"

@implementation TFComposedTableViewModule

#pragma mark - Interface Methods

- (void)setSubmodules:(NSArray *)submodules
{
    if (submodules == _submodules) return;
    
    _submodules = submodules;
    [_submodules makeObjectsPerformSelector:@selector(setSupermodule:) withObject:self];
}

#pragma mark TFDataSourceComposing

- (NSInteger)numberOfSubmodulesBefore:(id<TFTableViewModule>)submodule inTableView:(UITableView *)tableView
{
    NSInteger previousSections = 0;
    for (id<TFTableViewModule> ds in self.submodules) {
        if (ds == submodule) break;
        
        NSInteger sections = 1;
        if ([ds respondsToSelector:@selector(numberOfSectionsInTableView:)]) sections = [ds numberOfSectionsInTableView:tableView];
        
        previousSections += sections;
    }
    
    return previousSections;
}

#warning TODO reimplement using the method above / extract logic for shiftedIndexPath
- (id<TFTableViewModule>)submoduleAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView outIndexPath:(out NSIndexPath *__autoreleasing *)outIndexPath
{
    NSParameterAssert(tableView == nil || [tableView isKindOfClass:UITableView.class]);
    
    NSInteger previousSections = 0;
    for (id<TFTableViewModule> module in self.submodules) {
        NSInteger sections = 1;
        if ([module respondsToSelector:@selector(numberOfSectionsInTableView:)]) sections = [module numberOfSectionsInTableView:tableView];
        
        if (indexPath.section >= previousSections + sections)  {
            previousSections += sections;
            continue;
        }
        
        NSIndexPath * shiftedIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-previousSections];
        if (outIndexPath != NULL) {
            *outIndexPath = shiftedIndexPath;
        }
        return module;
    }
    
    [NSException raise:NSInternalInconsistencyException format:@"Invalid indexPath: %@, can't locate underlying module", indexPath];
    return nil;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath * outIndexPath = nil;
    id ds = [self submoduleAtIndexPath:indexPath tableView:self.tableView outIndexPath:&outIndexPath];
    SEL sel = @selector(itemAtIndexPath:);
    if ([ds respondsToSelector:sel] == NO) {
        [NSException raise:NSInternalInconsistencyException format:@"Underlying dataSource: %@ doesn't implement %@", ds, NSStringFromSelector(sel)];
        return nil;
    }
    
    return [ds itemAtIndexPath:outIndexPath];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger previousSections = 0;
    for (id<UITableViewDataSource, UICollectionViewDataSource> ds in self.submodules) {
        NSInteger sections = 1;
        if ([ds respondsToSelector:@selector(numberOfSectionsInTableView:)]) sections = [ds numberOfSectionsInTableView:tableView];
        
        if (section >= previousSections + sections)  {
            previousSections += sections;
            continue;
        }
        
        NSInteger rows = [ds tableView:tableView numberOfRowsInSection:section-previousSections];
        
        return rows;
    }
    
    NSAssert(NO, @"Should never happen");
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath * shiftedIndexPath = nil;
    id ds = [self submoduleAtIndexPath:indexPath tableView:tableView outIndexPath:&shiftedIndexPath];
    NSAssert(ds != nil && shiftedIndexPath != nil, @"Underlying data source nor indexPath can't be unknown at this point");
    
    return [ds tableView:tableView cellForRowAtIndexPath:shiftedIndexPath];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numSections = 0;
    for (id<UITableViewDataSource, UICollectionViewDataSource> ds in self.submodules) {
        NSInteger sections = 1;
        if ([ds respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            sections = [ds numberOfSectionsInTableView:tableView];
        }
        numSections += sections;
    }
    
    return numSections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSInteger previousSections = 0;
    for (id<UITableViewDataSource, UICollectionViewDataSource> ds in self.submodules) {
        NSInteger sections = 1;
        if ([ds respondsToSelector:@selector(numberOfSectionsInTableView:)]) sections = [ds numberOfSectionsInTableView:tableView];
        
        if (section >= previousSections + sections)  {
            previousSections += sections;
            continue;
        }
        
        NSString * title = nil;
        if ([ds respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
            title = [ds tableView:tableView titleForHeaderInSection:section-previousSections];
        }
        
        return title;
    }
    
    NSAssert(NO, @"Should never happen");
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSInteger previousSections = 0;
    for (id<UITableViewDataSource, UICollectionViewDataSource> ds in self.submodules) {
        NSInteger sections = 1;
        if ([ds respondsToSelector:@selector(numberOfSectionsInTableView:)]) sections = [ds numberOfSectionsInTableView:tableView];
        
        if (section >= previousSections + sections)  {
            previousSections += sections;
            continue;
        }
        
        NSString * title = nil;
        if ([ds respondsToSelector:@selector(tableView:titleForFooterInSection:)]) {
            title = [ds tableView:tableView titleForHeaderInSection:section-previousSections];
        }
        
        return title;
    }
    
    NSAssert(NO, @"Should never happen");
    return nil;
}

#pragma mark - UITableViewDelegate


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSIndexPath * shiftedIndexPath = nil;
    id ds = [self submoduleAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] tableView:tableView outIndexPath:&shiftedIndexPath];
    NSAssert(ds != nil && shiftedIndexPath != nil, @"Underlying data source nor indexPath can't be unknown at this point");
    
    if (![ds respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        if (![ds respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
            return nil; // no header
        }
        
        UITableViewHeaderFooterView * view = [[UITableViewHeaderFooterView alloc] init];  // try a default header
        view.textLabel.text = [ds tableView:tableView titleForHeaderInSection:section];
        return view;
    }
    
    return [ds tableView:tableView viewForHeaderInSection:shiftedIndexPath.section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSIndexPath * shiftedIndexPath = nil;
    id ds = [self submoduleAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] tableView:tableView outIndexPath:&shiftedIndexPath];
    NSAssert(ds != nil && shiftedIndexPath != nil, @"Underlying data source nor indexPath can't be unknown at this point");
    
    if (![ds respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        if (![ds respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
            return CGFLOAT_MIN; // no header
        }
        
        return 20.0f; // default height
    }
    
    return [ds tableView:tableView heightForHeaderInSection:shiftedIndexPath.section];
}

// footers

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath * shiftedIndexPath = nil;
    id ds = [self submoduleAtIndexPath:indexPath tableView:tableView outIndexPath:&shiftedIndexPath];
    NSAssert(ds != nil && shiftedIndexPath != nil, @"Underlying data source nor indexPath can't be unknown at this point");
    
    NSAssert([ds respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)], @"Whenever CompositeDataSource is set as tableView.delegate it will handle cell heights, but for this feature to work, all the child submodules need to implement this method");
    
    return [ds tableView:tableView heightForRowAtIndexPath:shiftedIndexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath * shiftedIndexPath = nil;
    id ds = [self submoduleAtIndexPath:indexPath tableView:tableView outIndexPath:&shiftedIndexPath];
    NSAssert(ds != nil && shiftedIndexPath != nil, @"Underlying data source nor indexPath can't be unknown at this point");
    
    if (![ds respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)]) {
        return;
    }
    
    [ds tableView:tableView willDisplayCell:cell forRowAtIndexPath:shiftedIndexPath];
}

@end

#pragma clang diagnostic pop



@implementation NSObject (TFTableViewModule)

static void * supermoduleKey = &supermoduleKey;

- (void)setSupermodule:(id<TFTableViewModuleComposing>)supermodule
{
    objc_setAssociatedObject(self, supermoduleKey, supermodule, OBJC_ASSOCIATION_ASSIGN);
}

- (TFComposedTableViewModule *)supermodule
{
    return objc_getAssociatedObject(self, supermoduleKey);
}

@end


