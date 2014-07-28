//
//  UnlockKeystoreViewController.h
//  NouveauPG
//
//  Created by John Hill on 6/22/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OpenPGPPublicKey.h"

@interface UnlockKeystoreViewController : UIViewController {
    NSString *m_keystoreData;
    IBOutlet UITextField *m_passwordField;
    
    OpenPGPPublicKey *m_primary;
    OpenPGPPublicKey *m_subkey;
}

-(void)setKeystore:(NSString *)asciiArmouredData;
-(void)setPrimaryKey: (OpenPGPPublicKey *)primary subkey:(OpenPGPPublicKey *)encryptionSubkey;
-(IBAction)unlockKeystore:(id)sender;

@end
