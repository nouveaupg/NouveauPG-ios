//
//  SettingsViewController.m
//  NouveauPG
//
//  Created by John Hill on 9/24/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController () {
    IBOutlet UISegmentedControl *m_hashAlgoControl;
    IBOutlet UISegmentedControl *m_rsaKeySizeControl;
    IBOutlet UISwitch *m_enableKeychainSwitch;
    IBOutlet UISwitch *m_enableTouchIdSwitch;
    IBOutlet UISwitch *m_enableiCloudSync;
}

- (IBAction)changeSetting:(id)sender;

@end

@implementation SettingsViewController

- (IBAction)changeSetting:(id)sender {
    if (sender == m_enableKeychainSwitch) {
        [[NSUserDefaults standardUserDefaults] setBool:m_enableKeychainSwitch.on forKey:@"enableKeychain"];
    }
    else if( sender == m_enableTouchIdSwitch ) {
        [[NSUserDefaults standardUserDefaults] setBool:m_enableTouchIdSwitch.on forKey:@"enableTouchId"];
    }
    else if( sender == m_hashAlgoControl ) {
        [[NSUserDefaults standardUserDefaults] setInteger:m_hashAlgoControl.selectedSegmentIndex forKey:@"hashAlgo"];
    }
    else if( sender == m_rsaKeySizeControl ) {
        [[NSUserDefaults standardUserDefaults] setInteger:m_rsaKeySizeControl.selectedSegmentIndex forKey:@"rsaKeySize"];
    }
    else if( sender == m_enableiCloudSync ) {
        [[NSUserDefaults standardUserDefaults] setBool:m_enableiCloudSync.on forKey:@"iCloudSyncEnabled"];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    m_enableKeychainSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"enableKeychain"];
    m_enableTouchIdSwitch.on = [[NSUserDefaults standardUserDefaults]boolForKey:@"enableTouchId"];
    m_hashAlgoControl.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults]integerForKey:@"hashAlgo"];
    m_rsaKeySizeControl.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults]integerForKey:@"rsaKeySize"];
    m_enableiCloudSync.on = [[NSUserDefaults standardUserDefaults]boolForKey:@"iCloudSyncEnabled"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
