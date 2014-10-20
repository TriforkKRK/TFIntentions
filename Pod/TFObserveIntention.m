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

#import "TFObserveIntention.h"

@interface TFObserveIntention ()
@end

@implementation TFObserveIntention

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self updateValue];
    [self.sourceObject addObserver:self forKeyPath:self.sourceKeyPath options:0 context:nil];
}

- (void)updateValue
{
    id value = [self.sourceObject valueForKeyPath:self.sourceKeyPath];
    if (self.targetKeyPath) {
        [self.target setValue:value forKeyPath:self.targetKeyPath];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:self.sourceKeyPath]) {
        [self updateValue];
    }
}

- (void)dealloc
{
    [_sourceObject removeObserver:self forKeyPath:_sourceKeyPath context:nil];
}
@end
