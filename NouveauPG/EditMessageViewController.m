//
//  EditMessageViewController.m
//  NouveauPG
//
//  Created by John Hill on 7/10/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import "EditMessageViewController.h"
#import "OpenPGPMessage.h"

@interface EditMessageViewController ()

@end

@implementation EditMessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)rightButton:(id)sender {
    if (m_mode == kModeEditing) {
        m_mode = 0;
        [m_textView setEditable:false];
        
        if (m_message) {
            [m_textView setText:m_originalMessage];
            
            [m_rightButton setTitle:@"Done"];
        }
        else {
            // save message
            
            NSLog(@"Saved message.");
            
            [m_rightButton setTitle:@"Edit"];
        }
    }
    else {
        m_mode = kModeEditing;
        if (m_message) {
            // attempt to decrypt
            
            [m_rightButton setTitle:@"Done"];
        }
        else {
            [m_textView setEditable:true];
            [m_textView becomeFirstResponder];
            
            [m_rightButton setTitle:@"Done"];
        }
    }
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [m_textView setText:m_originalMessage];
    
    m_message = [[OpenPGPMessage alloc]initWithArmouredText:m_originalMessage];
    if ([m_message validChecksum]) {
        [m_rightButton setTitle:@"Decrypt"];
    }
    else {
        [m_rightButton setTitle:@"Edit"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setText:(NSString *)newText {
    m_originalMessage = [[NSString alloc] initWithString:newText];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
