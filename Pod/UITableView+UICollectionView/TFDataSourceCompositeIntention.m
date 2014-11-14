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

#import "TFDataSourceCompositeIntention.h"

NSString * const kTFDataSourceModeMerge = @"merge";
NSString * const kTFDataSourceModeJoin = @"join";

@interface TFDataSourceCompositeIntention()
@property (nonatomic, strong) NSObject<TFDataSourceComposing> *implementation;
@end


@interface TFCompositeDataSourceMergeSectionsImpl : NSObject<TFDataSourceComposing>
@property (strong, nonatomic) NSArray * dataSources;
@end

@interface TFCompositeDataSourceJoinSectionsImpl : NSObject<TFDataSourceComposing>
@property (strong, nonatomic) NSArray * dataSources;
@end


#pragma clang push
#pragma clang diagnostic ignored "-Wprotocol"

@implementation TFDataSourceCompositeIntention

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath * outIndexPath = nil;
    id ds = [self dataSourceAtIndexPath:indexPath view:nil outIndexPath:&outIndexPath];
    SEL sel = @selector(itemAtIndexPath:);
    if ([ds respondsToSelector:sel] == NO) {
        [NSException raise:NSInternalInconsistencyException format:@"Underlying dataSource: %@ doesn't implement %@", ds, NSStringFromSelector(sel)];
        return nil;
    }
    
    return [ds itemAtIndexPath:outIndexPath];
}

#pragma mark - Interface Methods

- (void)setMode:(NSString *)mode
{
    NSParameterAssert([mode isEqualToString:kTFDataSourceModeMerge] || [mode isEqualToString:kTFDataSourceModeJoin]);
    
    if (mode == _mode) return;

    _mode = mode;
    _implementation = [self createImplementationForMode:mode];
}

- (void)setDataSources:(NSArray *)dataSources
{
    if (dataSources == _dataSources) return;
    
    _dataSources = dataSources;
    _implementation.dataSources = dataSources;
}

#pragma mark - Overriden

- (instancetype)init
{
    self = [super init];
    if  (self) {
        [self setMode:kTFDataSourceModeMerge];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setMode:kTFDataSourceModeMerge];
    }
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    NSMethodSignature *sig = [super methodSignatureForSelector:sel];
    if (sig) return sig;
    
    return [self.implementation methodSignatureForSelector:sel];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector]) return YES;

    return [self.implementation respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    [anInvocation invokeWithTarget:self.implementation];
}

#pragma mark - Private Methods

- (id<TFDataSourceComposing>)createImplementationForMode:(NSString *)mode
{
    Class implClass = [mode isEqualToString:kTFDataSourceModeMerge] ? TFCompositeDataSourceMergeSectionsImpl.class : TFCompositeDataSourceJoinSectionsImpl.class;
    
    NSObject<TFDataSourceComposing> * impl = [[implClass alloc] init];
    impl.dataSources = self.dataSources;
    return impl;
}

@end

#pragma clang diagnostic pop



#pragma mark - Concrete Implementations

@implementation TFCompositeDataSourceMergeSectionsImpl

- (id<UITableViewDataSource, UICollectionViewDataSource>)dataSourceAtIndexPath:(NSIndexPath *)indexPath view:(id)view outIndexPath:(out NSIndexPath *__autoreleasing *)outIndexPath
{
#warning TODO
    // param assert ds protocol + view type
    NSInteger previousObjectsCount = 0;
    for (id<UITableViewDataSource, UICollectionViewDataSource> ds in self.dataSources) {
        NSInteger rows = 0;
        if ([ds conformsToProtocol:@protocol(UITableViewDataSource)]) {
            rows = [ds tableView:view numberOfRowsInSection:indexPath.section];
        }
        if ([ds conformsToProtocol:@protocol(UICollectionViewDataSource)]) {
            rows = [ds collectionView:view numberOfItemsInSection:indexPath.section];
        }
        
        if (indexPath.row < previousObjectsCount + rows) {
            NSIndexPath * shiftedIndexPath = [NSIndexPath indexPathForRow:indexPath.row-previousObjectsCount inSection:indexPath.section];
            if (outIndexPath != NULL) {
                *outIndexPath = shiftedIndexPath;
            }
            return ds;
        }
        
        previousObjectsCount += rows;
    }
    
#warning - what about this assertion here?
    NSAssert(NO, @"Data source not found!!!, this should never happen!");
    return nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self numberOfSectionsInView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self view:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self view:tableView cellAtIndexPath:indexPath];
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

- (NSInteger)numberOfSectionsInView:(id)view
{
    NSInteger maxNumSections = 0;
    for (id<UITableViewDataSource, UICollectionViewDataSource> ds in self.dataSources) {
        NSInteger sections = 1;
        if ([ds respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            sections = [ds numberOfSectionsInTableView:view];
        }
        if ([ds respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
            sections = [ds numberOfSectionsInCollectionView:view];
        }
        maxNumSections = MAX(maxNumSections, sections);
    }
    
    return maxNumSections;
}

- (NSInteger)view:(id)view numberOfRowsInSection:(NSInteger)section
{
    NSInteger sum = 0;
    for (id<UITableViewDataSource, UICollectionViewDataSource> ds in self.dataSources) {
        NSInteger sections = 1;
        if ([ds respondsToSelector:@selector(numberOfSectionsInTableView:)]) sections = [ds numberOfSectionsInTableView:view];
        if ([ds respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) sections = [ds numberOfSectionsInCollectionView:view];
        
        if (section >= sections) continue;
        
        if ([ds conformsToProtocol:@protocol(UITableViewDataSource)]) {
            sum += [ds tableView:view numberOfRowsInSection:section];
        }
        if ([ds conformsToProtocol:@protocol(UICollectionViewDataSource)]) {
            sum += [ds collectionView:view numberOfItemsInSection:section];
        }
    }

    return sum;
}

- (id)view:(id)view cellAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath * shiftedIndexPath = nil;
    id ds = [self dataSourceAtIndexPath:indexPath view:view outIndexPath:&shiftedIndexPath];
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

@end


@implementation TFCompositeDataSourceJoinSectionsImpl

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self numberOfSectionsInView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self view:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self view:tableView cellAtIndexPath:indexPath];
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

- (NSInteger)numberOfSectionsInView:(id)view
{
    NSInteger numSections = 0;
    for (id<UITableViewDataSource, UICollectionViewDataSource> ds in self.dataSources) {
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
    for (id<UITableViewDataSource, UICollectionViewDataSource> ds in self.dataSources) {
        NSInteger sections = 1;
        if ([ds respondsToSelector:@selector(numberOfSectionsInTableView:)]) sections = [ds numberOfSectionsInTableView:view];
        if ([ds respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) sections = [ds numberOfSectionsInCollectionView:view];
        
        if (section >= previousSections + sections)  {
            previousSections += sections;
            continue;
        }
        
        if ([ds conformsToProtocol:@protocol(UITableViewDataSource)]){
            return [ds tableView:view numberOfRowsInSection:section-previousSections];
        }
        if ([ds conformsToProtocol:@protocol(UICollectionViewDataSource)]) {
            return [ds collectionView:view numberOfItemsInSection:section-previousSections];
        }
    }
    
    NSAssert(NO, @"Should never happen");
    return 0;
}

- (id)view:(id)view cellAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger previousSections = 0;
    for (id<UITableViewDataSource, UICollectionViewDataSource> ds in self.dataSources) {
        NSInteger sections = 1;
        if ([ds respondsToSelector:@selector(numberOfSectionsInTableView:)]) sections = [ds numberOfSectionsInTableView:view];
        if ([ds respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) sections = [ds numberOfSectionsInCollectionView:view];
        
        if (indexPath.section >= previousSections + sections)  {
            previousSections += sections;
            continue;
        }
        
        NSIndexPath * shiftedIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-previousSections];
        if ([ds conformsToProtocol:@protocol(UITableViewDataSource)]){
            return [ds tableView:view cellForRowAtIndexPath:shiftedIndexPath];
        }
        if ([ds conformsToProtocol:@protocol(UICollectionViewDataSource)]) {
            return [ds collectionView:view cellForItemAtIndexPath:shiftedIndexPath];
        }
    }
    
    NSAssert(NO, @"Should never happen");
    return nil;
}

@end

