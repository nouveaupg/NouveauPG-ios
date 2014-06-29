//
//  UnlockKeystoreViewController.h
//  NouveauPG
//
//  Created by John Hill on 6/22/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnlockKeystoreViewController : UIViewController {
    NSString *m_keystoreData;
    IBOutlet UITextField *m_passwordField;
}

-(void)setKeystore:(NSString *)asciiArmouredData;
-(IBAction)unlockKeystore:(id)sender;

@end
