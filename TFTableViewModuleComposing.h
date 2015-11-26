/*
 * Created by Krzysztof Profic on 22/07/15.
 * Copyright (c) 2015 Trifork A/S.
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


@protocol TFTableViewModuleComposing;

/**
 *  Declaration of an interface that is used as a type of the submodules @see in TFTableViewModuleComposing.
 *  It has to implement all @required methods from datasources, and it can also implement delegation methods
 *  There are certain scenarios that require all the underlying elements to implement a method (like heightForRowAtIndexPath) or none.
 *
 *  Important:
 *  @see dequeueReusableCellWithIdentifier:kCellIdentifier must be used instead of @see dequeueReusableCellWithIdentifier:forIndexPath:
 *  when implementing modules, the later method is not supported yet.
 */
@protocol TFTableViewModule <UITableViewDataSource, UITableViewDelegate>
/**
 *  A reference to parent module which is @see TFTableViewModuleComposing
 *  It needs to be automatically set when being composed by parent module, and it has to be weakly stored
 */
- (id<TFTableViewModuleComposing>)supermodule;
- (void)setSupermodule:(id<TFTableViewModuleComposing>)supermodule;
@end



/**
 *  Declaration of protocol that is able to compose a set of @see TFTableViewModule objects.
 *  This protocol is also TFTableViewModule by its nature and may be used to as a module in another composition.
 *
 *  TODOs
 *  revice which methods should be really exposed, maybe just for subclassing purposes ?
 *  itemAtIndexPath will have to go somewhere else, it's origin is around MVVM architecture
 */
@protocol TFTableViewModuleComposing <TFTableViewModule>
@required
- (NSArray *)submodules;   /**< list of TFTableViewModule objects, TODO: http://drekka.ghost.io/objective-c-generics/ */
- (id<TFTableViewModule>)submoduleAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView outIndexPath:(out NSIndexPath **)outIndexPath;
- (NSInteger)numberOfSubmodulesBefore:(id<TFTableViewModule>)submodule inTableView:(UITableView *)tableView;

@optional
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;
@end

