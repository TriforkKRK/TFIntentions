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


SpecBegin(TFUITableViewDataSourceComposite);

describe(@"Composite data source", ^{
    UITableView * tableView = mock([UITableView class]);
    
    describe(@"with two data sources", ^{ // first: 0->2 second: 0->1, 1->2
    
        id<UITableViewDataSource> ds1 = mockProtocol(@protocol(UITableViewDataSource)); // 1 section, 2 rows
        [given([ds1 numberOfSectionsInTableView:tableView]) willReturn:@1];
        [given([ds1 tableView:tableView numberOfRowsInSection:0]) willReturn:@2];
        UITableViewCell * ds1c00 = mock([UITableViewCell class]);
        UITableViewCell * ds1c01 = mock([UITableViewCell class]);
        [given([ds1 tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]) willReturn:ds1c00];
        [given([ds1 tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]) willReturn:ds1c01];
        
        id<UITableViewDataSource> ds2 = mockProtocol(@protocol(UITableViewDataSource)); // 2 sections, 0 => 1, 1 => 2
        [given([ds2 numberOfSectionsInTableView:tableView]) willReturn:@2];
        [given([ds2 tableView:tableView numberOfRowsInSection:0]) willReturn:@1];
        [given([ds2 tableView:tableView numberOfRowsInSection:1]) willReturn:@2];
        UITableViewCell * ds2c00 = mock([UITableViewCell class]);
        UITableViewCell * ds2c10 = mock([UITableViewCell class]);
        UITableViewCell * ds2c11 = mock([UITableViewCell class]);
        [given([ds2 tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]) willReturn:ds2c00];
        [given([ds2 tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]]) willReturn:ds2c10];
        [given([ds2 tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]]) willReturn:ds2c11];
        
        TFUITableViewDataSourceComposite * compositeDataSource = [[TFUITableViewDataSourceComposite alloc] init];
        compositeDataSource.dataSources = @[ds1, ds2];
        
        context(@"in default mode ", ^{
            beforeAll(^{
                compositeDataSource.mode = kTFDataSourceModeMerge;
            });
            
            it(@"should have number of sections equal to max number of sections", ^{
                expect([compositeDataSource numberOfSectionsInTableView:tableView]).to.equal(MAX([ds1 numberOfSectionsInTableView:tableView], [ds2 numberOfSectionsInTableView:tableView]));
            });
            
            it(@"should sum numberOfRowsInSection together", ^{
                expect([compositeDataSource tableView:tableView numberOfRowsInSection:0]).to.equal([ds1 tableView:tableView numberOfRowsInSection:0] + [ds2 tableView:tableView numberOfRowsInSection:0]);
                expect([compositeDataSource tableView:tableView numberOfRowsInSection:1]).to.equal([ds2 tableView:tableView numberOfRowsInSection:1]);
            });
            
            it(@"should return the very first cells from first dataSource", ^{
                expect([compositeDataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).to.equal(ds1c00);
                expect([compositeDataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]).to.equal(ds1c01);
            });
            
            it(@"should then return a merged cell from second data source", ^{
                expect([compositeDataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]]).to.equal(ds2c00);
            });
            
            it(@"should then return cells from second datasource when asked for section nr 2", ^{
                expect([compositeDataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]]).to.equal(ds2c10);
                expect([compositeDataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]]).to.equal(ds2c11);
            });
        });

        context(@"in join mode ", ^{
            beforeAll(^{
                compositeDataSource.mode = kTFDataSourceModeJoin;
            });
            
            it(@"should have number of sections to be a sum of available sections from all underlying data sources", ^{
                expect([compositeDataSource numberOfSectionsInTableView:tableView]).to.equal([ds1 numberOfSectionsInTableView:tableView] + [ds2 numberOfSectionsInTableView:tableView]);
            });

            it(@"has a number of rows in sections that corresponds to the underlying values in child data sources", ^{
                expect([compositeDataSource tableView:tableView numberOfRowsInSection:0]).to.equal([ds1 tableView:tableView numberOfRowsInSection:0]);
                expect([compositeDataSource tableView:tableView numberOfRowsInSection:1]).to.equal([ds2 tableView:tableView numberOfRowsInSection:0]);
                expect([compositeDataSource tableView:tableView numberOfRowsInSection:2]).to.equal([ds2 tableView:tableView numberOfRowsInSection:1]);
            });
            
            it(@"should return for the first section all the cells from first section of the first underlying dataSource", ^{
                expect([compositeDataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).to.equal([ds1 tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]);
                expect([compositeDataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]).to.equal([ds1 tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]);
            });
            
            it(@"should then return cells from first section of the second underlyind data source when asked for cells from section nr 2", ^{
                expect([compositeDataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]]).to.equal([ds2 tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]);
            });
            
            it(@"should finally return cells from second section of the second underlying datasource when asked for cells from section nr 3", ^{
                expect([compositeDataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]]).to.equal([ds2 tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]]);
                expect([compositeDataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]]).to.equal([ds2 tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]]);
            });
        });
    });
});


SpecEnd;