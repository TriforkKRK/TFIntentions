/*
 * Created by Krzysztof Profic on 29/10/14.
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

#import "UIViewController+tf_NibExternalObjects.h"


@interface UINib (tf_NibExternalObjects)

- (UIView *)tf_unarchiveTopLevelViewWithOwner:(id)owner injectingObjects:(NSDictionary *)externalObjects;

@end


@implementation UIViewController (tf_NibExternalObjects)

- (void)tf_loadViewFromNibInjectingObjects:(NSDictionary *)externalObjects
{
    return [self tf_loadViewFromNibNamed:nil injectingObjects:externalObjects];
}

- (void)tf_loadViewFromNibNamed:(NSString *)nibNameOrNil injectingObjects:(NSDictionary *)externalObjects
{
    NSString *nibName = nibNameOrNil == nil ? NSStringFromClass(self.class) : nibNameOrNil;
    
    UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
    self.view = [nib tf_unarchiveTopLevelViewWithOwner:self injectingObjects:externalObjects];
}

@end


@implementation UINib (tf_NibExternalObjects)

- (UIView *)tf_unarchiveTopLevelViewWithOwner:(id)owner injectingObjects:(NSDictionary *)externalObjects
{
    NSDictionary *nibOptions = [NSDictionary dictionaryWithObject:externalObjects forKey:UINibExternalObjects];
    NSArray *toplevelObjects =  [self instantiateWithOwner:owner options:nibOptions];
    
    return [toplevelObjects firstObject];
}

@end
