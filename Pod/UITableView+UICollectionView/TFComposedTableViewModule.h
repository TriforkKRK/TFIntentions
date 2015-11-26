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
#import "TFTableViewModuleComposing.h"


/**
 *  An implementation of @see TFTableViewModuleComposing. It's a subclass of @see TFIntention
 *  which makes it possible to create and configure it directly from Inmterface Builder, both xib and storyboard.
 *
 *  TODO:
 *  Consider being a subclass of @see TFTargetMultiplexerIntention
 */
@interface TFComposedTableViewModule : TFIntention<TFTableViewModuleComposing>
@property (nonatomic, weak) IBOutlet UITableView * tableView;
@property (nonatomic, strong) IBOutletCollection(id) NSArray * submodules;
@end


/**
 *  Extension that adds a relationship to supermodule (opposite to "submodule) which is a @see TFComposedTableViewModule that composes this module.
 *
 *  TODO: When having better language possibilities this would be an extension on NSObject<TFTableViewModule>
 */
@interface NSObject (TFTableViewModule)
@property (nonatomic, weak) id<TFTableViewModuleComposing> supermodule;
@end
