//
//  GenerateKeyViewController.h
//  NouveauPG
//
//  Created by John Hill on 6/15/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBProgressHUD.h"

@interface GenerateKeyViewController : UIViewController {
    IBOutlet UITextField *m_nameField;
    IBOutlet UITextField *m_emailField;
    IBOutlet UITextField *m_passwordField;
    IBOutlet UITextField *m_passwordRepeatField;
    IBOutlet UIButton *m_generateButton;
    
    MBProgressHUD *m_progressIndicator;
    
    bool m_threadDone;
    bool m_threadStarted;
}

-(IBAction)generateKey:(id)sender;
-(void)checkThread:(id)sender;
-(void)generateKeypair;

@end
