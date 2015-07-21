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

#import "TFIntention.h"


/**
 *  Declaration of an interface that is used as a type of the submodules @see in TFTableViewModuleComposing.
 *  It has to implement all @required methods from datasources, and it can also implement delegation methods
 *  There are certain scenarios that require all the underlying elements to implement a method (like heightForRowAtIndexPath) or none.
 *
 *  Important:
 *  @see dequeueReusableCellWithIdentifier:kCellIdentifier must be used instead of @see dequeueReusableCellWithIdentifier:forIndexPath:
 *  when implementing modules, the later method is not supported yet.
 */
@protocol TFTableViewModule <UITableViewDataSource, UITableViewDelegate> @end
@protocol TFCollectionViewModule <UICollectionViewDataSource, UICollectionViewDelegate> @end



/**
 *  Declaration of protocol that is able to compose a set of @see TFTableViewModule objects.
 *  This protocol is also TFTableViewModule by its nature and may be used to as a module in another composition.
 */
@protocol TFTableViewModuleComposing <TFTableViewModule>
@required

- (NSArray *)submodules;   /**< list of TFTableViewModule objects */

#warning TODO: this shouldn't be really exposed, maybe just for subclassing purposes
- (id<TFTableViewModule>)submoduleAtIndexPath:(NSIndexPath *)indexPath view:(id)view outIndexPath:(out NSIndexPath **)outIndexPath;
- (NSInteger)numberOfSectionsBeforeDataSource:(id)dataSource inView:(id)view;

// TODO this will have to go somewhere else, it's origin is around MVVM architecture
@optional
/**
 *  This method is supported as long as all underlying @see dataSources also implement it
 *  IMPORTANT: it will pass nil as tableView / collectionView when talking to dataSources
 */
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;
@end



/**
 *  It's a subclass of TFIntention in order to allow creating and configuring this object from IB
 */
@interface TFComposedTableViewModule : TFIntention<TFTableViewModuleComposing>
@property (weak, nonatomic) IBOutlet UITableView * tableView;
@property (strong, nonatomic) IBOutletCollection(id) NSArray * submodules;
@end


/**
 *  Extension that adds a relationship to parent in this composition pattern
 */
@interface NSObject (TFComposedTableViewModule)
@property (nonatomic, weak) TFComposedTableViewModule * compositionDelegate;
@end
