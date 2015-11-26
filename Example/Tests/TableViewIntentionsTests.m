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
#import <TFIntentions/TFComposedTableViewModule.h>


SpecBegin(TFUITableViewDataSourceComposite);

describe(@"Composite data source", ^{
    UITableView * tableView = mock([UITableView class]);
    
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
    
    describe(@"with two data sources", ^{ // first: 0->2 second: 0->1, 1->2

        __block TFDataSourceCompositeIntention * compositeOfTwoDataSources;
        beforeAll(^{
            compositeOfTwoDataSources = [[TFDataSourceCompositeIntention alloc] init];
            compositeOfTwoDataSources.dataSources = @[ds1, ds2];
            [given([tableView dataSource]) willReturn:compositeOfTwoDataSources];
        });
        
        context(@"in default mode", ^{
            beforeAll(^{
                compositeOfTwoDataSources.mode = kTFDataSourceModeMerge;
            });
            
            it(@"should have number of sections equal to max number of sections", ^{
                expect([tableView.dataSource numberOfSectionsInTableView:tableView]).to.equal(MAX([ds1 numberOfSectionsInTableView:tableView], [ds2 numberOfSectionsInTableView:tableView]));
            });
            
            it(@"should sum numberOfRowsInSection together", ^{
                expect([tableView.dataSource tableView:tableView numberOfRowsInSection:0]).to.equal([ds1 tableView:tableView numberOfRowsInSection:0] + [ds2 tableView:tableView numberOfRowsInSection:0]);
                expect([tableView.dataSource tableView:tableView numberOfRowsInSection:1]).to.equal([ds2 tableView:tableView numberOfRowsInSection:1]);
            });
            
            it(@"should return the very first cells from first dataSource", ^{
                expect([tableView.dataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).to.equal(ds1c00);
                expect([tableView.dataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]).to.equal(ds1c01);
            });
            
            it(@"should then return a merged cell from second data source", ^{
                expect([tableView.dataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]]).to.equal(ds2c00);
            });
            
            it(@"should then return cells from second datasource when asked for section nr 2", ^{
                expect([tableView.dataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]]).to.equal(ds2c10);
                expect([tableView.dataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]]).to.equal(ds2c11);
            });
        });

        context(@"in join mode", ^{
            beforeAll(^{
                compositeOfTwoDataSources.mode = kTFDataSourceModeJoin;
            });
            
            it(@"should have number of sections to be a sum of available sections from all underlying data sources", ^{
                expect([tableView.dataSource numberOfSectionsInTableView:tableView]).to.equal([ds1 numberOfSectionsInTableView:tableView] + [ds2 numberOfSectionsInTableView:tableView]);
            });

            it(@"has a number of rows in sections that corresponds to the underlying values in child data sources", ^{
                expect([tableView.dataSource tableView:tableView numberOfRowsInSection:0]).to.equal([ds1 tableView:tableView numberOfRowsInSection:0]);
                expect([tableView.dataSource tableView:tableView numberOfRowsInSection:1]).to.equal([ds2 tableView:tableView numberOfRowsInSection:0]);
                expect([tableView.dataSource tableView:tableView numberOfRowsInSection:2]).to.equal([ds2 tableView:tableView numberOfRowsInSection:1]);
            });
            
            it(@"should return for the first section all the cells from first section of the first underlying dataSource", ^{
                expect([tableView.dataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).to.equal([ds1 tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]);
                expect([tableView.dataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]).to.equal([ds1 tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]);
            });
            
            it(@"should then return cells from first section of the second underlyind data source when asked for cells from section nr 2", ^{
                expect([tableView.dataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]]).to.equal([ds2 tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]);
            });
            
            it(@"should finally return cells from second section of the second underlying datasource when asked for cells from section nr 3", ^{
                expect([tableView.dataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]]).to.equal([ds2 tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]]);
                expect([tableView.dataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]]).to.equal([ds2 tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]]);
            });
        });
    });
    
    
    
    describe(@"with three data sources", ^{ // first: 0->2 second: 0->1, 1->2, third 0->1, 1->0, 2->3
        
        id<UITableViewDataSource> ds3 = mockProtocol(@protocol(UITableViewDataSource)); // 2 sections, 0 => 1, 1 => 2
        [given([ds3 numberOfSectionsInTableView:tableView]) willReturn:@3];
        [given([ds3 tableView:tableView numberOfRowsInSection:0]) willReturn:@1];
        [given([ds3 tableView:tableView numberOfRowsInSection:1]) willReturn:@0];
        [given([ds3 tableView:tableView numberOfRowsInSection:2]) willReturn:@3];
        UITableViewCell * ds3c00 = mock([UITableViewCell class]);
        UITableViewCell * ds3c20 = mock([UITableViewCell class]);
        UITableViewCell * ds3c21 = mock([UITableViewCell class]);
        UITableViewCell * ds3c22 = mock([UITableViewCell class]);
        [given([ds3 tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]) willReturn:ds3c00];
        [given([ds3 tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]]) willReturn:ds3c20];
        [given([ds3 tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]]) willReturn:ds3c21];
        [given([ds3 tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:2]]) willReturn:ds3c22];
        
        __block TFDataSourceCompositeIntention * compositeOfThreeDataSources;
        beforeAll(^{
            compositeOfThreeDataSources = [[TFDataSourceCompositeIntention alloc] init];
            compositeOfThreeDataSources.dataSources = @[ds1, ds2, ds3];
            [given([tableView dataSource]) willReturn:compositeOfThreeDataSources];
        });
        
        context(@"in default mode", ^{
            beforeAll(^{
                compositeOfThreeDataSources.mode = kTFDataSourceModeMerge;
            });
            
            it(@"should have number of sections equal to max number of sections", ^{
                expect([tableView.dataSource numberOfSectionsInTableView:tableView]).to.equal(MAX(MAX([ds1 numberOfSectionsInTableView:tableView], [ds2 numberOfSectionsInTableView:tableView]), [ds3 numberOfSectionsInTableView:tableView]));
            });
            
            it(@"should sum numberOfRowsInSection together", ^{
                expect([tableView.dataSource tableView:tableView numberOfRowsInSection:0]).to.equal([ds1 tableView:tableView numberOfRowsInSection:0] + [ds2 tableView:tableView numberOfRowsInSection:0] + [ds3 tableView:tableView numberOfRowsInSection:0]);
                expect([tableView.dataSource tableView:tableView numberOfRowsInSection:1]).to.equal([ds2 tableView:tableView numberOfRowsInSection:1] + [ds3 tableView:tableView numberOfRowsInSection:1]);
                expect([tableView.dataSource tableView:tableView numberOfRowsInSection:2]).to.equal([ds2 tableView:tableView numberOfRowsInSection:2] + [ds3 tableView:tableView numberOfRowsInSection:2]);
            });
            
            it(@"should return the very first cells from first dataSource", ^{
                expect([tableView.dataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).to.equal(ds1c00);
                expect([tableView.dataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]).to.equal(ds1c01);
            });
            
            it(@"should then return a merged cell from second data source", ^{
                expect([tableView.dataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]]).to.equal(ds2c00);
            });
            
            it(@"should then return a merged cell from third data source", ^{
                expect([tableView.dataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]]).to.equal(ds3c00);
            });
            
            it(@"should then return cells from second datasource when asked for section nr 2", ^{
                expect([tableView.dataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]]).to.equal(ds2c10);
                expect([tableView.dataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]]).to.equal(ds2c11);
            });
            
            it(@"should then return cells from second datasource when asked for section nr 3", ^{
                expect([tableView.dataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]]).to.equal(ds3c20);
                expect([tableView.dataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]]).to.equal(ds3c21);
                expect([tableView.dataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:2]]).to.equal(ds3c22);
            });
        });
        
        context(@"in join mode", ^{ // 2, 1, 2, 1, 0, 3
            beforeAll(^{
                compositeOfThreeDataSources.mode = kTFDataSourceModeJoin;
            });
            
            it(@"should have number of sections to be a sum of available sections from all underlying data sources", ^{
                expect([tableView.dataSource numberOfSectionsInTableView:tableView]).to.equal([ds1 numberOfSectionsInTableView:tableView] + [ds2 numberOfSectionsInTableView:tableView] + [ds3 numberOfSectionsInTableView:tableView]);
            });
            
            it(@"has a number of rows in sections that corresponds to the underlying values in child data sources", ^{
                expect([tableView.dataSource tableView:tableView numberOfRowsInSection:0]).to.equal([ds1 tableView:tableView numberOfRowsInSection:0]);
                expect([tableView.dataSource tableView:tableView numberOfRowsInSection:1]).to.equal([ds2 tableView:tableView numberOfRowsInSection:0]);
                expect([tableView.dataSource tableView:tableView numberOfRowsInSection:2]).to.equal([ds2 tableView:tableView numberOfRowsInSection:1]);
                expect([tableView.dataSource tableView:tableView numberOfRowsInSection:3]).to.equal([ds3 tableView:tableView numberOfRowsInSection:0]);
                expect([tableView.dataSource tableView:tableView numberOfRowsInSection:4]).to.equal([ds3 tableView:tableView numberOfRowsInSection:1]);
                expect([tableView.dataSource tableView:tableView numberOfRowsInSection:5]).to.equal([ds3 tableView:tableView numberOfRowsInSection:2]);
            });
            
            it(@"should return for the first section all the cells from first section of the first underlying dataSource", ^{
                expect([tableView.dataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).to.equal([ds1 tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]);
                expect([tableView.dataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]).to.equal([ds1 tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]);
            });
            
            it(@"should then return cells from first section of the second underlyind data source when asked for cells from section nr 2", ^{
                expect([tableView.dataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]]).to.equal([ds2 tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]);
            });
            
            it(@"should then return cells from second section of the second underlying datasource when asked for cells from section nr 3", ^{
                expect([tableView.dataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]]).to.equal([ds2 tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]]);
                expect([tableView.dataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]]).to.equal([ds2 tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]]);
            });
            
            it(@"should then return cells from first section of the third underlying datasource when asked for cells from section nr 4", ^{
                expect([tableView.dataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]]).to.equal([ds3 tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]);
            });
            
            it(@"should then return cells from first section of the third underlying datasource when asked for cells from section nr 6", ^{
                expect([tableView.dataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:5]]).to.equal([ds3 tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]]);
                expect([tableView.dataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:5]]).to.equal([ds3 tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]]);
                expect([tableView.dataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:5]]).to.equal([ds3 tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:2]]);
            });
        });
    });
});


SpecEnd;