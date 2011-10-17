//
//  NationDetailsController.h
//  Nayshunz
//
//  Created by Viktar Ilyukevich on 13.10.11.
//  Copyright 2011 EPAM Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Nation;

@interface NationDetailsController : UIViewController {
    IBOutlet UILabel *name;
    IBOutlet UILabel *code;
}

@property (nonatomic, retain) Nation *nation;

- (void)releaseVariables;

@end
