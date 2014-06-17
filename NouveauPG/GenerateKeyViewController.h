//
//  GenerateKeyViewController.h
//  NouveauPG
//
//  Created by John Hill on 6/15/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GenerateKeyViewController : UIViewController {
    IBOutlet UITextField *m_nameField;
    IBOutlet UITextField *m_emailField;
    IBOutlet UITextField *m_passwordField;
    IBOutlet UITextField *m_passwordRepeatField;
}

-(IBAction)generateKey:(id)sender;

@end
