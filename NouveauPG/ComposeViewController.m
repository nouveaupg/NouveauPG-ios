//
//  ComposeViewController.m
//  NouveauPG
//
//  Created by John Hill on 6/22/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import "ComposeViewController.h"
#import "EncryptedViewController.h"
#import "EncryptedEnvelope.h"
#import "LiteralPacket.h"

@interface ComposeViewController ()

@end

@implementation ComposeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated {
    self.navigationController.toolbarHidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setEncryptionKey:(OpenPGPPublicKey *)encryptionKey recipient:(NSString *)recipientEmail {
    m_encryptionKey = encryptionKey;
    m_recipientEmail = [[NSString alloc]initWithString:recipientEmail];
}

-(IBAction)encryptMessage:(id)sender
{
    if ([[m_composedMessage text] length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Empty message" message:@"This message may be perplexing to the recipient. Do you wish to continue?" delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alert show];
    }
    else {
        [self performSegueWithIdentifier:@"exportEncryptedData" sender:self];
    }
}

-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self performSegueWithIdentifier:@"exportEncryptedData" sender:self];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"exportEncryptedData"]) {
        NSString *composedText = [NSString stringWithString:[m_composedMessage text]];
        LiteralPacket *plaintextPacket = [[LiteralPacket alloc]initWithUTF8String:composedText];
        EncryptedEnvelope *encryptedMessage = [[EncryptedEnvelope alloc]initWithLiteralPacket:plaintextPacket publicKey:m_encryptionKey];
        NSString *message = [encryptedMessage armouredMessage];
        // Clear the text after it has been encrypted.
        [m_composedMessage setText:@""];
        
        EncryptedViewController *newController = (EncryptedViewController *)[segue destinationViewController];
        [newController setEncryptedMessage:message recipientEmail:m_recipientEmail];

    }
}


@end
