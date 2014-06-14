//
//  RecipientsViewController.m
//  NouveauPG
//
//  Created by John Hill on 5/4/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import "RecipientsViewController.h"
#import "AppDelegate.h"

#import "Recipient.h"
#import "RecipientDetails.h"
#import "RecipientCell.h"

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
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    [cell setKeyId:current.details.keyId];
    [cell setPublicKeyAlgo:current.details.publicKeyAlgo];
    
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
    
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
