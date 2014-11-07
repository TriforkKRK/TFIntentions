//
//  TFIntentionsTests.m
//  TFIntentionsTests
//
//  Created by krzysztof on 10/17/2014.
//  Copyright (c) 2014 krzysztof. All rights reserved.
//

#import <Specta/Specta.h>
#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>
#import <UIKit/UIKit.h>
#import <TFIntentions/TFUITableViewDataSourceComposite.h>


SpecBegin(ddd);

describe(@"Composite data source", ^{
    UITableView * tableView = mock([UITableView class]);
    
    describe(@"with two data sources, first: 0->2 second: 0->1, 1->2", ^{
    
        id<UITableViewDataSource> ds1 = mockProtocol(@protocol(UITableViewDataSource)); // 1 section, 2 rows
        [given([ds1 numberOfSectionsInTableView:tableView]) willReturn:@1];
        [given([ds1 tableView:tableView numberOfRowsInSection:0]) willReturn:@2];
        id<UITableViewDataSource> ds2 = mockProtocol(@protocol(UITableViewDataSource)); // 2 sections, 0 => 1, 1 => 2
        [given([ds2 numberOfSectionsInTableView:tableView]) willReturn:@2];
        [given([ds2 tableView:tableView numberOfRowsInSection:0]) willReturn:@1];
        [given([ds2 tableView:tableView numberOfRowsInSection:1]) willReturn:@2];
        
        TFUITableViewDataSourceComposite * compositeDataSource = [[TFUITableViewDataSourceComposite alloc] init];
        compositeDataSource.dataSources = @[ds1, ds2];
        
        context(@"in default mode ", ^{
            it(@"should have number of sections equal to max number of sections", ^{
                expect([compositeDataSource numberOfSectionsInTableView:tableView]).to.equal(2);
            });
            
            it(@"should sum numberOfRowsInSection together", ^{
                expect([compositeDataSource tableView:tableView numberOfRowsInSection:0]).to.equal(3);
                expect([compositeDataSource tableView:tableView numberOfRowsInSection:1]).to.equal(2);
            });
            
            it(@"should return cells from proper underlying dataSources", ^{
                // TODO
            });
        });
        
        
        context(@"in join mode ", ^{
            // before mode
        });
        
    });
});


SpecEnd;