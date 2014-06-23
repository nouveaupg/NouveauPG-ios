//
//  EncryptedViewController.h
//  NouveauPG
//
//  Created by John Hill on 6/22/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageUI/MFMailComposeViewController.h"

@interface EncryptedViewController : UIViewController <MFMailComposeViewControllerDelegate> {
    IBOutlet UITextView *m_encryptedMessage;
    
    NSString *m_armouredMessage;
    NSString *m_recipientEmail;
}

-(void)setEncryptedMessage: (NSString *)message recipientEmail: (NSString *)email;


-(IBAction)dismiss:(id)sender;
-(IBAction)email:(id)sender;

@end
