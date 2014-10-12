//
//  RecipientsViewController.m
//  NouveauPG
//
//  Created by John Hill on 5/4/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import "RecipientsViewController.h"
#import "AppDelegate.h"

#import "OpenPGPMessage.h"
#import "OpenPGPPacket.h"
#import "OpenPGPPublicKey.h"
#import "ComposeViewController.h"
#import "Recipient.h"
#import "RecipientDetails.h"
#import "RecipientCell.h"
#import "OpenPGPSignature.h"
#import "UserIDPacket.h"

@interface RecipientsViewController ()

@end

@implementation RecipientsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated {
    [[self tableView]reloadData];
}

-(IBAction)addRecipient:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *pasteboardContents = pasteboard.string;
    OpenPGPMessage *message = [[OpenPGPMessage alloc]initWithArmouredText:pasteboardContents];
    NSInteger warning = 0;
    if ([message validChecksum]) {
        OpenPGPPublicKey *found = nil;
        OpenPGPPublicKey *subkey = nil;
        OpenPGPSignature *userIdSig = nil;
        OpenPGPSignature *subkeySig = nil;
        UserIDPacket *userIdPkt = nil;
        
        for (OpenPGPPacket *eachPacket in [OpenPGPPacket packetsFromMessage:message]) {
            if ([eachPacket packetTag] == 6) {
                found = [[OpenPGPPublicKey alloc]initWithPacket:eachPacket];
            }
            else if( [eachPacket packetTag] == 13 ) {
                userIdPkt = [[UserIDPacket alloc]initWithPacket:eachPacket];
            }
            else if([eachPacket packetTag] == 14) {
                subkey = [[OpenPGPPublicKey alloc]initWithPacket:eachPacket];
            }
            else if([eachPacket packetTag] == 2) {
                OpenPGPSignature *sig = [[OpenPGPSignature alloc]initWithPacket:eachPacket];
                if (sig.signatureType >= 0x10 && sig.signatureType <= 0x13) {
                    userIdSig = sig;
                }
                else if(sig.signatureType == 0x18 ) {
                    subkeySig = sig;
                }
            }
        }
        
        // check the public key algo
        
        bool correctAlgo = [found publicKeyType] == 1 && [subkey publicKeyType] == 1;
        if (correctAlgo) {
            // check user id sig
            bool valid = [userIdSig validateWithPublicKey:found userId:[userIdPkt stringValue]];
            if (valid) {
                // check the subkey sig
                valid = [subkeySig validateSubkey:subkey withSigningKey:found];
                if (!valid) {
                    warning = -3;
                }
            }
            else {
                warning = -2;
            }
        }
        else {
            warning = -1;
        }
        
        if (found) {
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            bool collision = false;
            for (Recipient *eachRecipient in app.recipients) {
                if ([eachRecipient.details.keyId isEqualToString:found.keyId]) {
                    collision = true;
                }
            }
            
            if (!collision) {
                [app addRecipientWithCertificate:pasteboardContents];
                Recipient *lastRecipient = [app.recipients lastObject];
                lastRecipient.warning = warning;
                
                int row = [app.recipients count]-1;
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                
                [[self tableView]insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Public key exists" message:[NSString stringWithFormat:@"A public key with Key ID: %@ already exists on the recipients list.",found.keyId] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                [alert show];
            }
            
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Public key not found" message:@"A public key was not found in the OpenPGP message, make sure you have a PUBLIC KEY BLOCK message on your clipboard." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [alert show];
        }
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Not found" message:@"A valid OpenPGP message was not found on your clipboard." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (app.recipients) {
        return [app.recipients count];
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RecipientCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recipientCell" forIndexPath:indexPath];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    Recipient *current = [app.recipients objectAtIndex:[indexPath row]];
    
    [cell setName:current.details.userName];
    [cell setEmail:current.details.email];
    
    if (current.warning < 0) {
        switch (current.warning) {
            case -1:
                [cell showWarning:@"Unsupported public key algorithm"];
                break;
            case -2:
                [cell showWarning:@"Invalid UserId signature"];
                break;
            case -3:
                [cell showWarning:@"Invalid subkey signature"];
                break;
                
            default:
                [cell showWarning:@"Public key certificate error"];
                break;
        }
    }
    else {
        [cell setKeyId:[NSString stringWithFormat:@"%@ (%@)",current.details.keyId,current.details.publicKeyAlgo]];
        
        
        //[cell setPublicKeyAlgo:current.details.publicKeyAlgo];
        
        NSInteger newIdenticonCode = 0;
        
        NSString *keyId = current.details.keyId;
        for (int i = 0; i < 8; i++) {
            unichar c = [keyId characterAtIndex:i];
            if ((int)c < 58) {
                newIdenticonCode |=  ((int)c-48);
            }
            else {
                newIdenticonCode |= ((int)c-55);
            }
            if (i < 7) {
                newIdenticonCode <<= 4;
            }
        }
        
        [cell setIdenticonCode:newIdenticonCode];
    }
    
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
#pragma mark Public Key Selection
    // Very crucial logic; it's where we choose which public key to encrypt with by examining the certificate
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    Recipient *object = [app.recipients objectAtIndex:[indexPath row]];
    RecipientDetails *details = object.details;
    
    if(object.warning < 0) {
        UIAlertView *alert;
        switch (object.warning) {
            case -1:
                alert = [[UIAlertView alloc]initWithTitle:@"Certificate Problem" message:@"NouveauPG only supports RSA encryption and signing certificates." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                break;
                
            default:
                alert = [[UIAlertView alloc]initWithTitle:@"Certificate Problem" message:@"There is a problem with this certificate. Either it has been tampered with or was generated with unsupported options." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                break;
        }
        [alert show];
        return;
    }
    
    OpenPGPMessage *certificate = [[OpenPGPMessage alloc]initWithArmouredText:object.certificate];
    if ([certificate validChecksum]) {
        OpenPGPPublicKey *keyToUse = nil;
        NSArray *packets = [OpenPGPPacket packetsFromMessage:certificate];
        for ( OpenPGPPacket *eachPacket in packets ) {
            if ([eachPacket packetTag] == 6 ) {
                keyToUse = [[OpenPGPPublicKey alloc]initWithPacket:eachPacket];
            }
            else if([eachPacket packetTag] == 14) {
                keyToUse = [[OpenPGPPublicKey alloc]initWithPacket:eachPacket];
            }
        }
        if (keyToUse) {
            m_selectedEncryptionKey = keyToUse;
            if (details.email) {
                m_selectedEmailAddress = [[NSString alloc]initWithString:details.email];
            }
            else {
                m_selectedEmailAddress = @"";
            }
            NSLog(@"Selected KeyId: %@ email: %@",[keyToUse keyId],m_selectedEmailAddress);
            
            [self performSegueWithIdentifier:@"composeNewMessage" sender:self];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Certificate Error" message:@"Could not find suitable public key in certificate" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [alert show];
        }
        
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Certificate Error" message:@"Could not decode certificate" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    }
    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSMutableArray *editable = [[NSMutableArray alloc]initWithArray:app.recipients];
        
        Recipient *ptr = [app.recipients objectAtIndex:[indexPath row]];
        
        NSError *error;
        NSManagedObjectContext *context = [app managedObjectContext];
        [context deleteObject:ptr];
        [context save:&error];
        
        if (error) {
            NSLog(@"CoreData Error: %@",[error description]);
        }
        
        [editable removeObjectAtIndex:[indexPath row]];
        app.recipients = editable;
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    ComposeViewController *nextViewController = (ComposeViewController *)[segue destinationViewController];
    [nextViewController setEncryptionKey:m_selectedEncryptionKey recipient:m_selectedEmailAddress];
}

@end
