//
//  NationDetailsController.m
//  Nayshunz
//
//  Created by Viktar Ilyukevich on 13.10.11.
//  Copyright 2011 EPAM Systems. All rights reserved.
//

#import "NationDetailsController.h"
#import "Nation.h"

@implementation NationDetailsController

@synthesize nation = _nation;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;

    NSLog(@"nation: %@", self.nation);
    name.text = self.nation.name;
    code.text = self.nation.code;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self releaseVariables];
}

- (void)dealloc {
    [self releaseVariables];
    [super dealloc];
}

- (void)releaseVariables {
    self.nation = nil;
    if (name) {
        [name release];
        name = nil;
    }
    if (code) {
        [code release];
        code = nil;
    }
}

@end
