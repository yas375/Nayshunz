//
//  Nation.m
//  Nayshunz
//
//  Created by Viktar Ilyukevich on 13.10.11.
//  Copyright 2011 EPAM Systems. All rights reserved.
//

#import "Nation.h"

@implementation Nation

@synthesize name = _name, code = _code;

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ (%@)", self.name, self.code];
}

- (void)dealloc {
    self.name = nil;
    self.code = nil;
    [super dealloc];
}

@end
