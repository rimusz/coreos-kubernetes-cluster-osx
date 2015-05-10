//
//  AppDelegate.m
//  CoreOS Kubernetes Cluster for OS X
//
//  Created by Rimantas on 01/12/2014.
//  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setImage: [NSImage imageNamed:@"icon"]];
    [self.statusItem setHighlightMode:YES];
    
    // get the App's main bundle path
    _resoucesPathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@""];
    NSLog(@"applicationDirectory: '%@'", _resoucesPathFromApp);

    NSString *home_folder = [NSHomeDirectory() stringByAppendingPathComponent:@"coreos-k8s-cluster"];
    
    BOOL isDir;
    if([[NSFileManager defaultManager] fileExistsAtPath:home_folder isDirectory:&isDir] && isDir)
    // if coreos-k8s-cluster folder exists
    {
        // set resouces_path
        NSString *resources_content = _resoucesPathFromApp;
        NSData *fileContents1 = [resources_content dataUsingEncoding:NSUTF8StringEncoding];
        [[NSFileManager defaultManager] createFileAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"coreos-k8s-cluster/.env/resouces_path"]
                                                contents:fileContents1
                                              attributes:nil];

        // write to file App version
        NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSData *app_version = [version dataUsingEncoding:NSUTF8StringEncoding];
        [[NSFileManager defaultManager] createFileAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"coreos-k8s-cluster/.env/version"]
                                                contents:app_version
                                              attributes:nil];
        [self checkVMStatus];
        
/*
        if([[NSFileManager defaultManager] fileExistsAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"coreos-k8s-cluster/.env/version"]] )
        // if coreos-k8s-cluster/.env/version file exists
        {
            
            // check and set App verion
            // read version from file
            NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"coreos-k8s-cluster/.env/version"];
            NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
            NSLog(@"version file: '%@'", content);
            
            // get App version
            NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
            
            // compare versions
            if([content isEqualToString:version])
            {
                // the same version
                NSLog(@"the same App version");
            }
            else
            {
                // different version
                NSLog(@"not the same App version");
                
            }
            
            // write to file
            //        NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
            //        NSString *app_version = [NSString stringWithFormat:@"%@", version];
            //        [self runScript:scriptName = @"set_version" arguments:arguments = app_version ];
            
            // App was updated
            NSString *update_content = @"yes";
            NSData *fileContents = [update_content dataUsingEncoding:NSUTF8StringEncoding];
            [[NSFileManager defaultManager] createFileAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"coreos-k8s-cluster/.env/update"]
                                                    contents:fileContents
                                                  attributes:nil];

            [self checkVMStatus];
        }
        else
        {
            // write to file
            NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
            NSData *app_version = [version dataUsingEncoding:NSUTF8StringEncoding];
            [[NSFileManager defaultManager] createFileAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"coreos-k8s-cluster/.env/version"]
                                                    contents:app_version
                                                  attributes:nil];
            [self checkVMStatus];
        }
*/
            
            
    }
    else
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert setMessageText:@"CoreOS-Vagrant k8s Cluster was not set."];
        [alert setInformativeText:@"Do you want to set it up?"];
        [alert setAlertStyle:NSWarningAlertStyle];
        
        if ([alert runModal] == NSAlertFirstButtonReturn) {
            // OK clicked
            [self initialInstall:self];
        }
        else
        {
            // Cancel clicked
            NSString *msg = [NSString stringWithFormat:@"%@ ", @" 'Initial setup of CoreOS-Vagrant k8s Cluster' at any time later one !!! "];
            [self displayWithMessage:@"You can set Kubernetes Cluster from menu 'Setup':" infoText:msg];
        }
    }
}


- (IBAction)Start:(id)sender {
    
    NSString *home_folder = [NSHomeDirectory() stringByAppendingPathComponent:@"coreos-k8s-cluster"];
    
    BOOL isDir;
    if([[NSFileManager defaultManager]
        fileExistsAtPath:home_folder isDirectory:&isDir] && isDir)
    {
        // send a notification on to the screen
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = @"CoreOS-Vagrant k8s Cluster will be up shortly";
        notification.informativeText = @"and OS shell will be opened";
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        
        NSString *appName = [[NSString alloc] init];
        NSString *arguments = [[NSString alloc] init];
        [self runApp:appName = @"iTerm" arguments:arguments = [_resoucesPathFromApp stringByAppendingPathComponent:@"vagrant_up.command"]];
    }
    else
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert setMessageText:@"CoreOS-Vagrant k8s Cluster was not set."];
        [alert setInformativeText:@"Do you want to set it up?"];
        [alert setAlertStyle:NSWarningAlertStyle];
        
        if ([alert runModal] == NSAlertFirstButtonReturn) {
            // OK clicked
            [self initialInstall:self];
        }
        else
        {
            // Cancel clicked
            NSString *msg = [NSString stringWithFormat:@"%@ ", @" 'Initial setup of CoreOS-Vagrant k8s Cluster' at any time later one !!! "];
            [self displayWithMessage:@"You can set Kubernetes Cluster from menu 'Setup':" infoText:msg];
        }
    }
}

- (IBAction)Pause:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.informativeText = @"CoreOS-Vagrant k8s Cluster will be suspended";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *scriptName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runScript:scriptName = @"coreos-vagrant" arguments:arguments = @"suspend"];
    
    [self checkVMStatus];
}

- (IBAction)Stop:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.informativeText = @"CoreOS-Vagrant k8s Cluster will be stopped";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *scriptName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runScript:scriptName = @"coreos-vagrant" arguments:arguments = @"halt"];
    
    [self checkVMStatus];
}

- (IBAction)Restart:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.informativeText = @"CoreOS-Vagrant k8s Cluster will be reloaded";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *appName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runApp:appName = @"iTerm" arguments:arguments = [_resoucesPathFromApp stringByAppendingPathComponent:@"vagrant_reload.command"]];
    
    [self checkVMStatus];
}


// Updates menu
- (IBAction)update_k8s:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"Kubernetes cluster and";
    notification.informativeText = @"OS X kubectl will be updated";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *appName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runApp:appName = @"iTerm" arguments:arguments = [_resoucesPathFromApp stringByAppendingPathComponent:@"update_k8s.command"]];
    //     NSLog(@"Apps arguments: '%@'", [_resoucesPathFromApp stringByAppendingPathComponent:@"update.command"]);
}

- (IBAction)updates:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"OS X etcdclt, fleetctl and";
    notification.informativeText = @"fleet units will be updated";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *appName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runApp:appName = @"iTerm" arguments:arguments = [_resoucesPathFromApp stringByAppendingPathComponent:@"update.command"]];
    //     NSLog(@"Apps arguments: '%@'", [_resoucesPathFromApp stringByAppendingPathComponent:@"update.command"]);
}

- (IBAction)updateVbox:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"CoreOS vbox";
    notification.informativeText = @"will be updated";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *appName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runApp:appName = @"iTerm" arguments:arguments = [_resoucesPathFromApp stringByAppendingPathComponent:@"update_vbox.command"]];
    //     NSLog(@"Apps arguments: '%@'", [_resoucesPathFromApp stringByAppendingPathComponent:@"update.command"]);
}


- (IBAction)force_coreos_update:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"CoreOS VMs will be forced to be updated !!!";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *appName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runApp:appName = @"iTerm" arguments:arguments = [_resoucesPathFromApp stringByAppendingPathComponent:@"force_coreos_update.command"]];
}
// Updates menu


// Setup menu
- (IBAction)changeReleaseChannel:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.informativeText = @"CoreOS-Vagrant k8s Cluster release channel change";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *appName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runApp:appName = @"iTerm" arguments:arguments = [_resoucesPathFromApp stringByAppendingPathComponent:@"change_release_channel.command"]];
    
    [self checkVMStatus];
}

- (IBAction)destroy:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.informativeText = @"CoreOS-Vagrant k8s Cluster will be destroyed";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *appName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runApp:appName = @"iTerm" arguments:arguments = [_resoucesPathFromApp stringByAppendingPathComponent:@"vagrant_destroy.command"]];
    
    [self checkVMStatus];
}

- (IBAction)initialInstall:(id)sender
{
    NSString *home_folder = [NSHomeDirectory() stringByAppendingPathComponent:@"coreos-k8s-cluster"];
    
    BOOL isDir;
    if([[NSFileManager defaultManager]
        fileExistsAtPath:home_folder isDirectory:&isDir] && isDir){
        NSString *msg = [NSString stringWithFormat:@"%@ %@ %@", @"Folder", home_folder, @"exists, please delete or rename that folder !!!"];
        [self displayWithMessage:@"CoreOS-Vagrant k8s Cluster" infoText:msg];
    }
    else
    {
        NSLog(@"Folder does not exist: '%@'", home_folder);
        // create home folder and .env subfolder
        NSString *env_folder = [home_folder stringByAppendingPathComponent:@".env"];
        NSError * error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:env_folder
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        // write to file App version
        NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSData *app_version = [version dataUsingEncoding:NSUTF8StringEncoding];
        [[NSFileManager defaultManager] createFileAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"coreos-k8s-cluster/.env/version"]
                                                contents:app_version
                                              attributes:nil];
        // set resouces_path
        NSString *resources_content = _resoucesPathFromApp;
        NSData *fileContents1 = [resources_content dataUsingEncoding:NSUTF8StringEncoding];
        [[NSFileManager defaultManager] createFileAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"coreos-k8s-cluster/.env/resouces_path"]
                                                contents:fileContents1
                                              attributes:nil];
        
        // run install script
        NSString *scriptName = [[NSString alloc] init];
        NSString *arguments = [[NSString alloc] init];
        [self runScript:scriptName = @"coreos-vagrant-install" arguments:arguments = _resoucesPathFromApp ];
    }
}
// Setup menu

- (IBAction)About:(id)sender {
    
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
//    NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
//    NSString *app_version = [NSString stringWithFormat:@"%@.%@", version, build];
    NSString *app_version = [NSString stringWithFormat:@"%@", version];
    
    NSString *mText = [NSString stringWithFormat:@"%@ %@", @"CoreOS-Vagrant k8s Cluster for OS X", app_version];
    NSString *infoText = @"It is a simple wrapper around the CoreOS-Vagrant, which allows to control CoreOS-Vagrant k8s Cluster via Status Bar !!!";
    [self displayWithMessage:mText infoText:infoText];
}


// OS shell
- (IBAction)open_shell:(id)sender{
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.informativeText = @"OS X shell will be opened";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *appName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runApp:appName = @"iTerm" arguments:arguments = [_resoucesPathFromApp stringByAppendingPathComponent:@"os_shell.command"]];
}

// ssh to hosts
- (IBAction)runSsh1:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.informativeText = @"vagrant ssh shell to k8smaster-01 will be opened";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *appName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runApp:appName = @"iTerm" arguments:arguments = [_resoucesPathFromApp stringByAppendingPathComponent:@"vagrant_control1.command"]];
}

- (IBAction)runSsh2:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.informativeText = @"vagrant ssh shell to k8snode-01 will be opened";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *appName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runApp:appName = @"iTerm" arguments:arguments = [_resoucesPathFromApp stringByAppendingPathComponent:@"vagrant_node1.command"]];
}

- (IBAction)runSsh3:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.informativeText = @"vagrant ssh shell to k8snode-02 will be opened";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *appName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runApp:appName = @"iTerm" arguments:arguments = [_resoucesPathFromApp stringByAppendingPathComponent:@"vagrant_node2.command"]];
}
// ssh to hosts

// UI
- (IBAction)fleetUI:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://172.17.15.101:3000"]];
}


- (IBAction)KubernetesUI:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://172.17.15.101:8080/static/app/#/dashboard/"]];
}

- (IBAction)node1_cAdvisor:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://172.17.15.102:4194"]];
}

- (IBAction)node2_cAdvisor:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://172.17.15.103:4194"]];
}

// UI


- (void)runScript:(NSString*)scriptName arguments:(NSString*)arguments
{
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] pathForResource:scriptName ofType:@"command"]];
    task.arguments  = @[arguments];
    [task launch];
    [task waitUntilExit];
}


- (void)runApp:(NSString*)appName arguments:(NSString*)arguments
{
    // lunch an external App from the mainBundle
    [[NSWorkspace sharedWorkspace] openFile:arguments withApplication:appName];
}


- (void)checkVMStatus {
    // check vm status and and return the shell script output
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] pathForResource:@"coreos-vagrant" ofType:@"command"]];
    task.arguments  = @[@"status"];
    // task.arguments  = @[@"status | grep virtualbox | sed -e 's/  */ /g' -e 's/^ *\(.*\) *$/\1/' "];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    [task waitUntilExit];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    //    NSLog (@"Returned:\n%@", string);
    
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
//    notification.contentImage = [NSImage imageNamed:@"icon2"];
    notification.informativeText = string;
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}


- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}


-(void) displayWithMessage:(NSString *)mText infoText:(NSString*)infoText
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setAlertStyle:NSInformationalAlertStyle];
    // [alert setIcon:[NSImage imageNamed:@"icon2"]];
    [alert setMessageText:mText];
    [alert setInformativeText:infoText];
    [alert runModal];
}


@end
