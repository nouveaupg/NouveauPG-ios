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
    NSString *m_userId;
    NSString *m_emailAddress;
    IBOutlet UILabel *m_promptLabel;
    IBOutlet UITextField *m_passwordField;
    IBOutlet UITextField *m_repeatPasswordField;
    IBOutlet UIButton *m_rightButton;
    IBOutlet UISwitch *m_keychainSwitch;
    IBOutlet UILabel *m_keychainLabel;
    NSString *m_password;
    
    bool m_changePassword;
    bool m_importKeystore;
    
    OpenPGPPublicKey *m_primary;
    OpenPGPPublicKey *m_subkey;
}

-(void)setKeystore:(NSString *)asciiArmouredData;
-(void)setPrimaryKey: (OpenPGPPublicKey *)primary subkey:(OpenPGPPublicKey *)encryptionSubkey;
-(void)setChangePassword: (bool)change;
-(void)setUserId:(NSString *)userId;
-(IBAction)unlockKeystore:(id)sender;

@end
