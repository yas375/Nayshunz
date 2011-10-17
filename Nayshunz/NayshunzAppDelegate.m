//
//  NayshunzAppDelegate.m
//  Nayshunz
//
//  Created by Viktar Ilyukevich on 13.10.11.
//  Copyright 2011 EPAM Systems. All rights reserved.
//

#import "NayshunzAppDelegate.h"
#import "NationsController.h"
@implementation NayshunzAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application
                didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NationsController *nationsController = [[NationsController alloc] init];

    UINavigationController *navigationController =
                        [[UINavigationController alloc]
                                initWithRootViewController:nationsController];
    [nationsController release];

    self.window.rootViewController = navigationController;
    [navigationController release];

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)dealloc {
    [_window release];
    [super dealloc];
}

@end
