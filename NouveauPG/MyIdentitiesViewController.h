//
//  MyIdentitiesViewController.h
//  NouveauPG
//
//  Created by John Hill on 6/15/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Identity.h"

@interface MyIdentitiesViewController : UITableViewController <UIActionSheetDelegate> {
    Identity *m_identityData;
    
}

@end
