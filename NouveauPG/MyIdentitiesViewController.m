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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    
    NSString *keyId = identityData.keyId;
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
    [cell setKeyMetadata:[identityData.keyId uppercaseString]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    m_identityData = [app.identities objectAtIndex:[indexPath row]];
    
    UIActionSheet *privateKeyStoreOptions = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"Dismiss" destructiveButtonTitle:nil otherButtonTitles:@"Export public certificate", @"Export private keystore", nil];
    [privateKeyStoreOptions setDelegate:self];
    [privateKeyStoreOptions showFromTabBar:[[self tabBarController] tabBar]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self performSegueWithIdentifier:@"exportPublicKey" sender:self];
    }
    else if( buttonIndex == 1 ) {
        [self performSegueWithIdentifier:@"unlockKeystore" sender:self];
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"exportPublicKey"]) {
        ExportViewController *nextViewController = (ExportViewController *)[segue destinationViewController];
        
        [nextViewController setText:[m_identityData publicCertificate]];
    }
    else if( [[segue identifier] isEqualToString:@"unlockKeystore"]) {
        UnlockKeystoreViewController *nextViewController = (UnlockKeystoreViewController *)[segue destinationViewController];
        
        [nextViewController setKeystore: [m_identityData privateKeystore]];
    }
}


@end
