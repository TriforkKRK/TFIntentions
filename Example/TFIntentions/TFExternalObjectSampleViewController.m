//
//  TFExternalObjectSampleViewController.m
//  TFIntentions
//
//  Created by Krzysztof Profic on 05/11/14.
//  Copyright (c) 2014 krzysztof. All rights reserved.
//

#import "TFExternalObjectSampleViewController.h"
#import <TFIntentions/UIViewController+tf_NibExternalObjects.h>

@interface TFExternalObjectSampleViewController ()
@property (strong, nonatomic) id<UITableViewDataSource> dataSource;
@end

@implementation TFExternalObjectSampleViewController

- (id)initWithDataSource:(id<UITableViewDataSource>)dataSource
{
    self = [super init];
    if (self) {
        _dataSource = dataSource;
    }
    
    return self;
}

- (void)loadView
{
    [self tf_loadViewFromNibInjectingObjects:@{@"externalDataSource": self.dataSource}];
}

- (IBAction)closeButtonClicked:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
