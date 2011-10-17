//
//  NationsController.m
//  Nayshunz
//
//  Created by Viktar Ilyukevich on 13.10.11.
//  Copyright 2011 EPAM Systems. All rights reserved.
//

#import "NationsController.h"
#import "Nation.h"
#import "NationDetailsController.h"

@implementation NationsController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        continents = [[NSMutableArray alloc] init];

        // where do the documents go?
        NSArray *paths =
        NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                            NSUserDomainMask,
                                            YES);
        NSString *path = [paths objectAtIndex:0];

        NSString *fullPath =
        [path stringByAppendingPathComponent:@"countries.db"];
        // get file manager for file operations
        NSFileManager *fileManager = [NSFileManager defaultManager];

        // does the file already exist?
        BOOL exists = [fileManager fileExistsAtPath:fullPath];
        if (exists) {
            NSLog(@"%@ exists - just opening", fullPath);
        } else {
            NSLog(@"%@ does not exist - copying and opening", fullPath);
            // Where is the starting database in the application wrapper?
            NSString *pathForStartingDB =
            [[NSBundle mainBundle] pathForResource:@"countries" ofType:@"db"];

            // copy it to the documents directory
            BOOL success = [fileManager copyItemAtPath:pathForStartingDB
                                                toPath:fullPath
                                                 error:NULL];
            if (!success) {
                NSLog(@"database copy failed");
            }
        }

        // open database
        const char *cFullPath =
                        [fullPath cStringUsingEncoding:NSUTF8StringEncoding];
        if (sqlite3_open(cFullPath, &database) != SQLITE_OK) {
            NSLog(@"unable to open database as %@", fullPath);
        }
    }
    return self;
}

- (void)dealloc {
    [self releaseVariables];

    sqlite3_close(database);
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [searchBar becomeFirstResponder];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self releaseVariables];
}

- (void)releaseVariables {
    if (countryTable) {
        [countryTable release];
        countryTable = nil;
    }
    if (searchBar) {
        [searchBar release];
        searchBar = nil;
    }
    if (continents) {
        [continents release];
        continents = nil;
    }
    if (detailsController) {
        [detailsController release];
        detailsController = nil;
    }
}

#pragma mark - SearchBar

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText {
    [continents removeAllObjects];

    if ([searchText length] > 0) {
        // does the statement need to be prepared?
        if (!statement) {
            // '?' is a placeholder for parameters
            char *cQuery = "SELECT Continent, Name, Code FROM Country "
            "WHERE Name LIKE ? ORDER BY Continent, Name";
            // prepare the query
            if (sqlite3_prepare_v2(database, cQuery, -1, &statement, NULL) !=
                SQLITE_OK) {
                NSLog(@"query error: %s", (char *)statement);
            }
        }

        // add % to the end of search text
        searchText = [searchText stringByAppendingString:@"%"];
        NSLog(@"searching for %@", searchText);

        // this C string will get cleaned up automatically
        const char *cSearchText =
        [searchText cStringUsingEncoding:NSUTF8StringEncoding];

        // replace the first (and only) parameter with the search text
        sqlite3_bind_text(statement, 1, cSearchText, -1, SQLITE_TRANSIENT);

        NSString *lastContinentName = nil;
        NSMutableArray *currentNationList;

        // Loop to get all the rows
        while (sqlite3_step(statement) == SQLITE_ROW) {
            // get the string in the first column
            const char *cContinentName =
                                (const char *)sqlite3_column_text(statement, 0);
            // convert C strings into an NSString
            NSString *continentName =
            [[[NSString alloc] initWithUTF8String:cContinentName] autorelease];

            // is this a new continent?
            if (!lastContinentName ||
                ![lastContinentName isEqualToString:continentName]) {
                // create an array for the nations of this new continent
                currentNationList = [[NSMutableArray alloc] init];

                // put the name and the array in a dictionary
                NSDictionary *continentalDictionary =
                [[NSDictionary alloc] initWithObjectsAndKeys:
                 continentName, @"name",
                 currentNationList, @"list", nil];

                // release array retained by the dictionary
                [currentNationList release];

                // add the new continent to the array of continents
                [continents addObject:continentalDictionary];

                // release the dictionary being retained by the array
                [continentalDictionary release];
            }
            lastContinentName = continentName;

            // get the string in the second column
            const char *cCountryName =
                                (const char *)sqlite3_column_text(statement, 1);
            // convert C strings into an NSString
            NSString *countryName =
            [[[NSString alloc] initWithUTF8String:cCountryName] autorelease];

            // get the string in the third column
            const char *cCountryCode =
                                (const char *)sqlite3_column_text(statement, 2);
            // convert C strings into an NSString
            NSString *countryCode =
            [[[NSString alloc] initWithUTF8String:cCountryCode] autorelease];

            // create a Nation object for this nation
            Nation *countryNation = [[Nation alloc] init];
            countryNation.name = countryName;
            countryNation.code = countryCode;

            // put the nation's dictionary in the list for the current continent
            [currentNationList addObject:countryNation];
            [countryNation release];
        }
        // clear the query results
        sqlite3_reset(statement);
    }

    [countryTable reloadData];
}

#pragma mark - TableView source

- (NSInteger)tableView:(UITableView *)tableView
                                numberOfRowsInSection:(NSInteger)section {
    NSDictionary *continentDictionary = [continents objectAtIndex:section];
    NSArray *nations = [continentDictionary objectForKey:@"list"];

    return [nations count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [continents count];
}

- (NSString *)tableView:(UITableView *)tableView
                            titleForHeaderInSection:(NSInteger)section {
    NSDictionary *continentDictionary = [continents objectAtIndex:section];
    return [continentDictionary objectForKey:@"name"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // get dictionary for the continent for this section
    NSDictionary *continentDictionary =
                                [continents objectAtIndex:indexPath.section];
    // get array of nations on this continent
    NSArray *nations = [continentDictionary objectForKey:@"list"];
    // get nation
    Nation *nation = [nations objectAtIndex:indexPath.row];
    // what is its name?
    NSString *nationName = nation.name;

    // try to reuse an existing cell
    UITableViewCell *cell =
                    [tableView dequeueReusableCellWithIdentifier:@"NationCell"];

    if (!cell) {
        cell =
        [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                               reuseIdentifier:@"NationCell"];
        [cell autorelease];
    }
    cell.textLabel.text = nationName;

    return cell;
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView
                    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // get dictionary for the continent for this section
    NSDictionary *continentDictionary =
                                [continents objectAtIndex:indexPath.section];
    // get array of nations on this continent
    NSArray *nations = [continentDictionary objectForKey:@"list"];
    // get nation
    Nation *nation = [nations objectAtIndex:indexPath.row];

    if (!detailsController) {
        detailsController = [[NationDetailsController alloc] init];
    }
    detailsController.nation = nation;
    [self.navigationController pushViewController:detailsController
                                         animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


@end
