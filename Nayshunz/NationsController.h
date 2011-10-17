//
//  NationsController.h
//  Nayshunz
//
//  Created by Viktar Ilyukevich on 13.10.11.
//  Copyright 2011 EPAM Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@class NationDetailsController;

@interface NationsController : UIViewController
            <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *countryTable;
    IBOutlet UISearchBar *searchBar;

    // model
    NSMutableArray *continents;

    // database stuff
    sqlite3 *database;
    sqlite3_stmt *statement;

    NationDetailsController *detailsController;
}

- (void)releaseVariables;

@end
