//
//  ExportViewController.m
//  NouveauPG
//
//  Created by John Hill on 6/19/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import "ExportViewController.h"

@interface ExportViewController ()

@end

@implementation ExportViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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

-(IBAction)dismissButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(IBAction)copyButton:(id)sender {
    
}

-(IBAction)saveButton:(id)sender {
    
}

-(IBAction)emailButton:(id)sender{
    
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
