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

#import "TFUITableViewDataSourceComposite.h"

NSString * const kTFDataSourceModeMerge = @"merge";
NSString * const kTFDataSourceModeJoin = @"join";

@interface TFUITableViewDataSourceComposite()
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

@implementation TFUITableViewDataSourceComposite

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

// TODO CollectionView
@implementation TFCompositeDataSourceMergeSectionsImpl

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger maxNumSections = 0;
    for (id<UITableViewDataSource> ds in self.dataSources) {
        NSInteger sections = 1;
        if ([ds respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            sections = [ds numberOfSectionsInTableView:tableView];
        }
        maxNumSections = MAX(maxNumSections, sections);
    }
    
    return maxNumSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger sum = 0;
    for (id<UITableViewDataSource> ds in self.dataSources) {
        NSInteger sections = 1;
        if ([ds respondsToSelector:@selector(numberOfSectionsInTableView:)]) sections = [ds numberOfSectionsInTableView:tableView];
        
        if (section >= sections) continue;
        
        sum += [ds tableView:tableView numberOfRowsInSection:section];
    }

    return sum;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger previousObjectsCount = 0;
    for (id<UITableViewDataSource> ds in self.dataSources) {
        NSInteger rows = [ds tableView:tableView numberOfRowsInSection:indexPath.section];
        if (indexPath.row < previousObjectsCount + rows) {
            NSIndexPath * shiftedIndexPath = [NSIndexPath indexPathForRow:indexPath.row-previousObjectsCount inSection:indexPath.section];
            return [ds tableView:tableView cellForRowAtIndexPath:shiftedIndexPath];
        }
        
        previousObjectsCount += rows;
    }
    
    NSAssert(NO, @"Data source not found!!!, this should never happen!");
    return nil;
}

@end


@implementation TFCompositeDataSourceJoinSectionsImpl

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numSections = 0;
    for (id<UITableViewDataSource> ds in self.dataSources) {
        NSInteger sections = 1;
        if ([ds respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            sections = [ds numberOfSectionsInTableView:tableView];
        }
        numSections += sections;
    }
    
    return numSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger previousSections = 0;
    for (id<UITableViewDataSource> ds in self.dataSources) {
        NSInteger sections = 1;
        if ([ds respondsToSelector:@selector(numberOfSectionsInTableView:)]) sections = [ds numberOfSectionsInTableView:tableView];
        
        if (section >= previousSections + sections)  {
            previousSections += sections;
            continue;
        }
        
        return [ds tableView:tableView numberOfRowsInSection:section-previousSections];
    }
    
    NSAssert(NO, @"Should never happen");
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger previousSections = 0;
    for (id<UITableViewDataSource> ds in self.dataSources) {
        NSInteger sections = 1;
        if ([ds respondsToSelector:@selector(numberOfSectionsInTableView:)]) sections = [ds numberOfSectionsInTableView:tableView];
        
        if (indexPath.section >= previousSections + sections)  {
            previousSections += sections;
            continue;
        }
        
        NSIndexPath * shiftedIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-previousSections];
        return [ds tableView:tableView cellForRowAtIndexPath:shiftedIndexPath];
    }
    
    NSAssert(NO, @"Should never happen");
    return nil;
}
@end

