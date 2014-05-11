//
//  ImportViewController.h
//  NouveauPG
//
//  Created by John Hill on 5/10/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImportViewController : UIViewController {
    IBOutlet UITextView *m_importText;

}

-(IBAction)importFromTextView:(id)sender;

@end
