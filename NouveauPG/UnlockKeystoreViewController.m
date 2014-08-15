//
//  UnlockKeystoreViewController.m
//  NouveauPG
//
//  Created by John Hill on 6/22/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import "UnlockKeystoreViewController.h"
#import "OpenPGPMessage.h"
#import "OpenPGPPacket.h"
#import "OpenPGPPublicKey.h"
#import "ExportViewController.h"

@interface UnlockKeystoreViewController ()

@end

@implementation UnlockKeystoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [m_passwordField setText:@""];
    [m_repeatPasswordField setText:@""];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [m_passwordField becomeFirstResponder];
    
    if (m_changePassword) {
        [m_promptLabel setText:@"Enter a password to encrypt your keystore. You will need to enter this password every time you use this key."];
        [m_repeatPasswordField setHidden:NO];
        [m_rightButton setTitle:@"Export Keystore" forState:UIControlStateNormal];
    }
    else {
        [m_promptLabel setText:@"Enter a password to decrypt and unlock your keystore."];
        [m_repeatPasswordField setHidden:YES];
        [m_rightButton setTitle:@"Unlock Keystore" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setKeystore:(NSString *)asciiArmouredData {
    m_keystoreData = [[NSString alloc]initWithString:asciiArmouredData];
}

-(void)setPrimaryKey: (OpenPGPPublicKey *)primary subkey:(OpenPGPPublicKey *)encryptionSubkey {
    m_primary = primary;
    m_subkey = encryptionSubkey;
}

-(void)setChangePassword: (bool)change {
    m_changePassword = change;
    if (change) {
        [m_promptLabel setText:@"Enter a password to encrypt your keystore. You will need to enter this password every time you use this key."];
        [m_repeatPasswordField setHidden:NO];
        [m_rightButton setTitle:@"Export Keystore" forState:UIControlStateNormal];
    }
    else {
        [m_promptLabel setText:@"Enter a password to decrypt and unlock your keystore."];
        [m_repeatPasswordField setHidden:YES];
        [m_rightButton setTitle:@"Unlock Keystore" forState:UIControlStateNormal];
    }
}

-(IBAction)unlockKeystore:(id)sender {
    NSString *password = [m_passwordField text];
    
    if (m_changePassword) {
        if ([[m_passwordField text] isEqualToString:[m_repeatPasswordField text]]) {
            m_password = [m_passwordField text];
            [self performSegueWithIdentifier:@"exportKeystore" sender:self];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Passwords didn't match" message:@"You must enter the same password in each field" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [alert show];
        }
    }
    else {
        if ([m_primary decryptKey:password]) {
            if (! [m_subkey decryptKey:password] ) {
                NSLog(@"Could not decrypt subkey with primary key passphrase.");
            }
            
            [self.navigationController popToRootViewControllerAnimated:TRUE];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Wrong password" message:@"The password you entered will not encrypt the keystore." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [alert show];
        }
    }
    
    

    
    /*
    OpenPGPMessage *keystoreMessage = [[OpenPGPMessage alloc]initWithArmouredText:m_keystoreData];
    if (keystoreMessage && [keystoreMessage validChecksum]) {
        NSArray *packets = [OpenPGPPacket packetsFromMessage:keystoreMessage];
        for (OpenPGPPacket *eachPacket in packets) {
            NSLog(@"Packet tag: %ld",(long)[eachPacket packetTag]);
            if ([eachPacket packetTag] == 5) {
                OpenPGPPublicKey *key = [[OpenPGPPublicKey alloc]initWithEncryptedPacket:eachPacket];
                if ([key decryptKey:password]) {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Change password?" message:@"Would you like to export the keystore protected by a different password than you just entered?" delegate:nil cancelButtonTitle:@"No" otherButtonTitles: @"Yes",nil];
                    [alert show];
                    break;
                }
                else {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Wrong password" message:@"The password you entered will not encrypt the keystore." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                    [alert show];
                    break;
                }
            }
        }
    }
    else {
        NSLog(@"Invalid keystore OpenPGP message.");
    }
    */
}

-(void)setUserId:(NSString *)userId
{
    m_userId = userId;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"exportKeystore"]) {
        NSMutableArray *packets = [[NSMutableArray alloc]initWithCapacity:3];
        
        [packets addObject:[m_primary exportPrivateKey:m_password]];
        NSData *userIdData = [NSData dataWithBytes:[m_userId UTF8String] length:[m_userId length]];
        OpenPGPPacket *userIdPacket = [[OpenPGPPacket alloc]initWithPacketBody:userIdData tag:13 oldFormat:YES];
        [packets addObject:userIdPacket];
        [packets addObject:[m_subkey exportPrivateKey:m_password]];
        
        NSString *asciiArmouredData = [OpenPGPMessage privateKeystoreFromPacketChain:packets];
        
        ExportViewController *viewController = (ExportViewController *)[segue destinationViewController];
        [viewController setText:asciiArmouredData];
    }
    
    
}

@end
