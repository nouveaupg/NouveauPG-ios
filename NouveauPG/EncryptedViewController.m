//
//  EncryptedViewController.m
//  NouveauPG
//
//  Created by John Hill on 6/22/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import "EncryptedViewController.h"
#import "MessageUI/MFMailComposeViewController.h"

@interface EncryptedViewController ()

@end

@implementation EncryptedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated {
    [m_encryptedMessage selectAll:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [m_encryptedMessage setText:m_armouredMessage];
    
    UINavigationController *nav = self.navigationController;
    nav.toolbarHidden = NO;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)copyMessage:(id)sender {
    [m_encryptedMessage copy:sender];
}

-(IBAction)saveMessage:(id)sender {
    
}

-(IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(IBAction)email:(id)sender {
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc]init];
    [mailComposer setSubject:@"Encrypted PGP Message"];
    [mailComposer setToRecipients:[NSArray arrayWithObject:m_recipientEmail]];
    [mailComposer setMessageBody:m_armouredMessage isHTML:FALSE];
    mailComposer.mailComposeDelegate = self;
    [self presentViewController:mailComposer animated:YES completion:NULL];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissModalViewControllerAnimated:YES];
}

-(void)setEncryptedMessage: (NSString *)message recipientEmail: (NSString *)email {
    
    m_armouredMessage = [[NSString alloc]initWithString:message];
    m_recipientEmail = [[NSString alloc]initWithString:email];
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
