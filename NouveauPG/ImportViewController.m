//
//  ImportViewController.m
//  NouveauPG
//
//  Created by John Hill on 5/10/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import "ImportViewController.h"
#import "OpenPGPMessage.h"
#import "OpenPGPPacket.h"
#import "UserIDPacket.h"
#import "OpenPGPPublicKey.h"
#import "UnlockKeystoreViewController.h"
#import "AppDelegate.h"

#import "NSString+Base64.h"

@interface ImportViewController ()

@end

@implementation ImportViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    [m_clipboardButton setHidden:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [m_importText setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)importFromTextView:(id)sender {
    m_importData = [m_importText text];
    m_primary = nil;
    OpenPGPMessage *openPGPMessage = [[OpenPGPMessage alloc]initWithArmouredText:m_importData];
    if ([openPGPMessage validChecksum]) {
        NSLog(@"Valid PGP Message found.");
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSArray *packets = [OpenPGPPacket packetsFromMessage:openPGPMessage];
        for ( OpenPGPPacket *eachPacket in packets ) {
            NSLog(@"Packet tag: %ld, length: %ld", (long)[eachPacket packetTag], (unsigned long)[[eachPacket packetData] length]);
            if ([eachPacket packetTag] == 5) {
                m_primary = [[OpenPGPPublicKey alloc]initWithEncryptedPacket:eachPacket];
            }
            if ([eachPacket packetTag] == 6) {
                [appDelegate addRecipientWithCertificate:[openPGPMessage originalArmouredText]];
                // now show the recipients tab
                [[[self navigationController] tabBarController] setSelectedIndex:0];
            }
        }
        if (m_primary) {
            [self performSegueWithIdentifier:@"unlockImport" sender:self];
        }
    }
    [m_importText resignFirstResponder];
}

-(IBAction)clearTextView:(id)sender {
    [m_importText setText:@""];
    
    [m_importText resignFirstResponder];
    
    [m_clipboardButton setHidden:NO];
}

-(IBAction)pasteToTextView:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [m_importText insertText:pasteboard.string];
    
    [m_importText resignFirstResponder];
    
    [m_clipboardButton setHidden:YES];
    
    [self importFromTextView:sender];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    [self clearTextView:self];
    
    if ([[segue identifier]isEqualToString:@"unlockImport"]) {
         UnlockKeystoreViewController *newViewController = (UnlockKeystoreViewController *)[segue destinationViewController];
        [newViewController setPrimaryKey:m_primary subkey:nil];
        [newViewController setKeystore:m_importData];
    }
    
    
    
}

@end
