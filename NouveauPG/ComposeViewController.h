//
//  ComposeViewController.h
//  NouveauPG
//
//  Created by John Hill on 6/22/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenPGPPublicKey.h"

@interface ComposeViewController : UIViewController <UIAlertViewDelegate> {
    IBOutlet UITextView *m_composedMessage;
    NSString *m_recipientEmail;
    OpenPGPPublicKey *m_encryptionKey;
}

-(void)setEncryptionKey:(OpenPGPPublicKey *)encryptionKey recipient:(NSString *)recipientEmail;

-(IBAction)encryptMessage:(id)sender;

@end
