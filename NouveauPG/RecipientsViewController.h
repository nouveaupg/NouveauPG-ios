//
//  RecipientsViewController.h
//  NouveauPG
//
//  Created by John Hill on 5/4/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenPGPPublicKey.h"

@interface RecipientsViewController : UITableViewController {
    NSString *m_selectedEmailAddress;
    OpenPGPPublicKey *m_selectedEncryptionKey;
}

-(IBAction)addRecipient:(id)sender;

@end
