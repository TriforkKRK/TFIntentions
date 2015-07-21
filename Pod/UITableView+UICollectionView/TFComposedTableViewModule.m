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
    
    for (NSObject * ds in submodules) {
        [ds setCompositionDelegate:self];
    }
    _submodules = submodules;
}
#pragma mark TFDataSourceComposing

- (NSInteger)numberOfSectionsBeforeDataSource:(id)dataSource inView:(id)view
{
    NSInteger previousSections = 0;
    for (id<UITableViewDataSource, UICollectionViewDataSource> ds in self.submodules) {
        if (ds == dataSource) break;
        
        NSInteger sections = 1;
        if ([ds respondsToSelector:@selector(numberOfSectionsInTableView:)]) sections = [ds numberOfSectionsInTableView:view];
        if ([ds respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) sections = [ds numberOfSectionsInCollectionView:view];
        
        previousSections += sections;
    }
    
    return previousSections;
}

- (id<TFTableViewModule>)submoduleAtIndexPath:(NSIndexPath *)indexPath view:(id)view outIndexPath:(out NSIndexPath *__autoreleasing *)outIndexPath
{
    NSParameterAssert(view == nil || [view isKindOfClass:UITableView.class] || [view isKindOfClass:UICollectionView.class]);
    
    NSInteger previousSections = 0;
    for (id<TFTableViewModule> module in self.submodules) {
        NSInteger sections = 1;
        if ([module respondsToSelector:@selector(numberOfSectionsInTableView:)]) sections = [module numberOfSectionsInTableView:view];
        
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
#warning nil?
    id ds = [self submoduleAtIndexPath:indexPath view:nil outIndexPath:&outIndexPath];
    SEL sel = @selector(itemAtIndexPath:);
    if ([ds respondsToSelector:sel] == NO) {
        [NSException raise:NSInternalInconsistencyException format:@"Underlying dataSource: %@ doesn't implement %@", ds, NSStringFromSelector(sel)];
        return nil;
    }
    
    return [ds itemAtIndexPath:outIndexPath];
}



#warning TODO move to category

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self view:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self view:tableView cellAtIndexPath:indexPath];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self numberOfSectionsInView:tableView];
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
    id ds = [self submoduleAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] view:tableView outIndexPath:&shiftedIndexPath];
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
    id ds = [self submoduleAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] view:tableView outIndexPath:&shiftedIndexPath];
    NSAssert(ds != nil && shiftedIndexPath != nil, @"Underlying data source nor indexPath can't be unknown at this point");
    
    if (![ds respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        if (![ds respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
            return CGFLOAT_MIN; // no header
        }
        
        return 20.0f; // default height
    }
    
    return [ds tableView:tableView heightForHeaderInSection:shiftedIndexPath.section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath * shiftedIndexPath = nil;
    id ds = [self submoduleAtIndexPath:indexPath view:tableView outIndexPath:&shiftedIndexPath];
    NSAssert(ds != nil && shiftedIndexPath != nil, @"Underlying data source nor indexPath can't be unknown at this point");
    
    NSAssert([ds respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)], @"Whenever CompositeDataSource is set as tableView.delegate it will handle cell heights, but for this feature to work, all the child submodules need to implement this method");
    
    return [ds tableView:tableView heightForRowAtIndexPath:shiftedIndexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath * shiftedIndexPath = nil;
    id ds = [self submoduleAtIndexPath:indexPath view:tableView outIndexPath:&shiftedIndexPath];
    NSAssert(ds != nil && shiftedIndexPath != nil, @"Underlying data source nor indexPath can't be unknown at this point");
    
    if (![ds respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)]) {
        return;
    }
    
    [ds tableView:tableView willDisplayCell:cell forRowAtIndexPath:shiftedIndexPath];
}




#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self numberOfSectionsInView:collectionView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self view:collectionView numberOfRowsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self view:collectionView cellAtIndexPath:indexPath];
}


#pragma mark - Private Methods

- (id)view:(id)view cellAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath * shiftedIndexPath = nil;
    id ds = [self submoduleAtIndexPath:indexPath view:view outIndexPath:&shiftedIndexPath];
    NSAssert(ds != nil && shiftedIndexPath != nil, @"Underlying data source nor indexPath can't be unknown at this point");
    
    if ([ds conformsToProtocol:@protocol(UITableViewDataSource)]) {
        return [ds tableView:view cellForRowAtIndexPath:shiftedIndexPath];
    }
    if ([ds conformsToProtocol:@protocol(UICollectionViewDataSource)]) {
        return [ds collectionView:view cellForItemAtIndexPath:shiftedIndexPath];
    }
    
    NSAssert(NO, @"Data source has to be either UITableViewDataSource or UICollectionViewDataSource");
    return nil;
}

- (NSInteger)numberOfSectionsInView:(id)view
{
    NSInteger numSections = 0;
    for (id<UITableViewDataSource, UICollectionViewDataSource> ds in self.submodules) {
        NSInteger sections = 1;
        if ([ds respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            sections = [ds numberOfSectionsInTableView:view];
        }
        if ([ds respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
            sections = [ds numberOfSectionsInCollectionView:view];
        }
        numSections += sections;
    }
    
    return numSections;
}

- (NSInteger)view:(id)view numberOfRowsInSection:(NSInteger)section
{
    NSInteger previousSections = 0;
    for (id<UITableViewDataSource, UICollectionViewDataSource> ds in self.submodules) {
        NSInteger sections = 1;
        if ([ds respondsToSelector:@selector(numberOfSectionsInTableView:)]) sections = [ds numberOfSectionsInTableView:view];
        if ([ds respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) sections = [ds numberOfSectionsInCollectionView:view];
        
        if (section >= previousSections + sections)  {
            previousSections += sections;
            continue;
        }
        
        NSInteger rows = NSNotFound;
        if ([ds conformsToProtocol:@protocol(UITableViewDataSource)]){
            rows = [ds tableView:view numberOfRowsInSection:section-previousSections];
        }
        if ([ds conformsToProtocol:@protocol(UICollectionViewDataSource)]) {
            rows = [ds collectionView:view numberOfItemsInSection:section-previousSections];
        }
        
        return rows;
    }
    
    NSAssert(NO, @"Should never happen");
    return 0;
}

@end

#pragma clang diagnostic pop



@implementation NSObject (TFDataSourceComposing)

static void * compositionDelegateKey = &compositionDelegateKey;

- (void)setCompositionDelegate:(TFComposedTableViewModule *)compositionDelegate
{
    objc_setAssociatedObject(self, compositionDelegateKey, compositionDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (TFComposedTableViewModule *)compositionDelegate
{
    return objc_getAssociatedObject(self, compositionDelegateKey);
}

@end


