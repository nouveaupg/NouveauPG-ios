//
//  MyIdentitiesViewController.m
//  NouveauPG
//
//  Created by John Hill on 6/15/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import "MyIdentitiesViewController.h"
#import "IdentityCell.h"
#import "AppDelegate.h"
#import "Identity.h"
#import "ExportViewController.h"
#import "UnlockKeystoreViewController.h"
#import "OpenPGPPacket.h"
#import "OpenPGPMessage.h"
#import "OpenPGPPublicKey.h"

#import <Security/Security.h>

@interface MyIdentitiesViewController ()

@end

@implementation MyIdentitiesViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animate {
    [[self tableView] reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationController.toolbarHidden = YES;
}

-(void)viewDidAppear:(BOOL)animated {
    self.navigationController.toolbarHidden = YES;
    
    [[self tableView]reloadData];
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
    // Return the number of rows in the section.
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return [app.identities count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IdentityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IdentityCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    Identity *identityData = [app.identities objectAtIndex:[indexPath row]];
    
    NSInteger newIdenticonCode = 0;
    
    NSString *keyId = [identityData.keyId uppercaseString];
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
    [cell setName:identityData.name];
    [cell setEmail:identityData.email];
    [cell setKeyMetadata:[identityData.keyId uppercaseString]];
    
    if ([identityData.primaryKeystore isEncrypted]) {
        [cell setLocked:@"Locked"];
    }
    else {
        [cell setLocked:@"Unlocked"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    m_identityData = [app.identities objectAtIndex:[indexPath row]];
    
    if (![m_identityData.primaryKeystore isEncrypted]) {
        UIActionSheet *privateKeyStoreOptions = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"Dismiss" destructiveButtonTitle:@"Lock keystore" otherButtonTitles:@"Export public certificate", @"Export private keystore", nil];
        [privateKeyStoreOptions setDelegate:self];
        [privateKeyStoreOptions showFromTabBar:[[self tabBarController] tabBar]];
    }
    else {
        UIActionSheet *privateKeyStoreOptions = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"Dismiss" destructiveButtonTitle:nil otherButtonTitles:@"Export public certificate", @"Unlock keystore", nil];
        [privateKeyStoreOptions setDelegate:self];
        [privateKeyStoreOptions showFromTabBar:[[self tabBarController] tabBar]];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if ([m_identityData.primaryKeystore isEncrypted]) {
        if (buttonIndex == 0) {
            [self performSegueWithIdentifier:@"exportPublicKey" sender:self];
        }
        else if( buttonIndex == 1 ) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"enableKeychain"]) {
                NSMutableDictionary *genericPasswordQuery = [[NSMutableDictionary alloc]init];
                //NSMutableDictionary *keychainData;
                NSString *keychainItemIdentifier = [NSString stringWithFormat:@"com.nouveaupg.key.%@",m_identityData.primaryKeystore.keyId];
                NSLog(@"Searching for keychain item with identifier: %@",keychainItemIdentifier);
                OSStatus keychainErr = noErr;
                
                [genericPasswordQuery setObject:(__bridge id)kSecClassGenericPassword
                                         forKey:(__bridge id)kSecClass];
                // The kSecAttrGeneric attribute is used to store a unique string that is used
                // to easily identify and find this keychain item. The string is first
                // converted to an NSData object:
                NSData *keychainItemID = [NSData dataWithBytes:[keychainItemIdentifier UTF8String]
                                                        length:[keychainItemIdentifier length]];
                [genericPasswordQuery setObject:keychainItemID forKey:(__bridge id)kSecAttrGeneric];
                // Return the attributes of the first match only:
                [genericPasswordQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
                // Return the attributes of the keychain item (the password is
                //  acquired in the secItemFormatToDictionary: method):
                [genericPasswordQuery setObject:(__bridge id)kCFBooleanTrue
                                         forKey:(__bridge id)kSecReturnAttributes];
                
                //Initialize the dictionary used to hold return data from the keychain:
                CFMutableDictionaryRef outDictionary = nil;
                // If the keychain item exists, return the attributes of the item:
                keychainErr = SecItemCopyMatching((__bridge CFDictionaryRef)genericPasswordQuery,
                                                  (CFTypeRef *)&outDictionary);
                
                if (keychainErr == noErr) {
                    NSLog(@"Keychain item found!");
                    if (outDictionary) CFRelease(outDictionary);
                }
                else if (keychainErr == errSecItemNotFound) {
                    // Put default values into the keychain if no matching
                    // keychain item is found:
                    NSLog(@"Keychain item not found.");
                    if (outDictionary) CFRelease(outDictionary);
                } else {
                    // Any other error is unexpected.
                    NSAssert(NO, @"Serious error.\n");
                    if (outDictionary) CFRelease(outDictionary);
                }
                
            }
            
            [self performSegueWithIdentifier:@"unlockKeystore" sender:self];
        }
    }
    else {
        if ( buttonIndex == 0 ) {
            OpenPGPMessage *message = [[OpenPGPMessage alloc]initWithArmouredText:m_identityData.privateKeystore];
            if ([message validChecksum]) {
                for (OpenPGPPacket *eachPacket in [OpenPGPPacket packetsFromMessage:message] ) {
                    if ( [eachPacket packetTag] == 5 ) {
                        m_identityData.primaryKeystore = [[OpenPGPPublicKey alloc]initWithEncryptedPacket:eachPacket];
                    }
                    else if( [eachPacket packetTag] == 7 ) {
                        m_identityData.encryptionKeystore = [[OpenPGPPublicKey alloc]initWithEncryptedPacket:eachPacket];
                    }
                }
            }
            [[self tableView] reloadData];
        }
        else if( buttonIndex == 1 ) {
            [self performSegueWithIdentifier:@"exportPublicKey" sender:self];
        }
        else if( buttonIndex == 2 ) {
            [self performSegueWithIdentifier:@"choosePassword" sender:self];
        }
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
        NSMutableArray *editable = [[NSMutableArray alloc]initWithArray:app.identities];
        
        Identity *ptr = [app.identities objectAtIndex:[indexPath row]];
        
        NSError *error;
        NSManagedObjectContext *context = [app managedObjectContext];
        [context deleteObject:ptr];
        [context save:&error];
        
        if (error) {
            NSLog(@"CoreData Error: %@",[error description]);
        }
        
        [editable removeObjectAtIndex:[indexPath row]];
        app.identities = editable;
        
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

-(IBAction)addIdentity:(id)sender {
    NSString *certificateData = [[UIPasteboard generalPasteboard] string];
    OpenPGPMessage *message = [[OpenPGPMessage alloc]initWithArmouredText:certificateData];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([message validChecksum]) {
        for (OpenPGPPacket *eachPacket in [OpenPGPPacket packetsFromMessage:message] ) {
            if ([eachPacket packetTag] == 5) {
                m_primary = [[OpenPGPPublicKey alloc]initWithEncryptedPacket:eachPacket];
            }
        }
        
        if (m_primary) {
            m_clipboardData = [[NSString alloc]initWithString:certificateData];
            
            [self performSegueWithIdentifier:@"unlockKeystore" sender:self];
            return;
        }
    }
    [self performSegueWithIdentifier:@"generateIdentity" sender:self];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"exportPublicKey"]) {
        ExportViewController *nextViewController = (ExportViewController *)[segue destinationViewController];
        
        [nextViewController setText:[m_identityData publicCertificate]];
        [nextViewController setEmail:[m_identityData email]];
    }
    else if( [[segue identifier] isEqualToString:@"unlockKeystore"]) {
        UnlockKeystoreViewController *nextViewController = (UnlockKeystoreViewController *)[segue destinationViewController];
        
        if (m_primary) {
            [nextViewController setPrimaryKey:m_primary subkey:nil];
            [nextViewController setKeystore:m_clipboardData];
        }
        else {
            [nextViewController setPrimaryKey:m_identityData.primaryKeystore subkey:m_identityData.encryptionKeystore];
            [nextViewController setChangePassword:false];
        }
        //[nextViewController setKeystore: [m_identityData privateKeystore]];
    }
    else if( [[segue identifier] isEqualToString:@"choosePassword"]) {
        UnlockKeystoreViewController *nextViewController = (UnlockKeystoreViewController *)[segue destinationViewController];
        [nextViewController setPrimaryKey:m_identityData.primaryKeystore subkey:m_identityData.encryptionKeystore];
        NSString *userId;
        if (m_identityData.email) {
            userId = [NSString stringWithFormat:@"%@ <%@>",m_identityData.name,m_identityData.email];
        }
        else {
            userId = [NSString stringWithFormat:@"%@",m_identityData.name];
        }
        
        [nextViewController setUserId: userId];
        [nextViewController setChangePassword:true];
    }
}


@end
