/*******************************************************************************
 * The MIT License (MIT)
 * 
 * Copyright (c) 2015 Jean-David Gadina - www.digidna.net
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

#import "MainWindowController.h"

@interface MainWindowController()

@property( atomic, readwrite, assign ) BOOL       running;
@property( atomic, readwrite, strong ) NSImage  * icon;
@property( atomic, readwrite, strong ) NSString * appName;
@property( atomic, readwrite, strong ) NSString * appVersion;
@property( atomic, readwrite, strong ) NSString * fixButtonTitle;
@property( atomic, readwrite, strong ) NSString * launchButtonTitle;

- ( IBAction )fix: ( id )sender;
- ( IBAction )launch: ( id )sender;
- ( IBAction )help: ( id )sender;
- ( void )displayError;
- ( BOOL )rebuildLaunchServicesDatabase;
- ( BOOL )clearExtendedAttributes;

@end

@implementation MainWindowController

- ( instancetype )init
{
    if( ( self = [ self initWithWindowNibName: NSStringFromClass( [ self class ] ) ] ) )
    {
        [ self addObserver: self forKeyPath: @"url" options: NSKeyValueObservingOptionNew context: NULL ];
    }
    
    return self;
}

- ( void )dealloc
{
    [ self removeObserver: self forKeyPath: @"url" context: NULL ];
}

- ( void )windowDidLoad
{
    NSString * title;
    
    [ super windowDidLoad ];
    
    title = [ [ [ NSBundle mainBundle ] infoDictionary ] objectForKey: @"CFBundleName" ];
    
    self.window.title = ( title ) ? title : @"";
}

- ( void )observeValueForKeyPath: ( NSString * )keyPath ofObject: ( id )object change: ( NSDictionary * )change context: ( void * )context
{
    NSString * path;
    NSBundle * bundle;
    
    if( object == self && [ keyPath isEqualToString: @"url" ] )
    {
        path = self.url.path;
        
        if( path )
        {
            bundle = [ NSBundle bundleWithPath: path ];
            
            self.icon               = [ [ NSWorkspace sharedWorkspace ] iconForFile: path ];
            self.appName            = bundle.infoDictionary[ @"CFBundleName" ];
            self.appVersion         = bundle.infoDictionary[ @"CFBundleShortVersionString" ];
            self.fixButtonTitle     = [ NSString stringWithFormat: @"Repair %@", self.appName ];
            self.launchButtonTitle  = [ NSString stringWithFormat: @"Start %@", self.appName ];
        }
        else
        {
            self.icon               = nil;
            self.appName            = @"";
            self.appVersion         = @"";
            self.fixButtonTitle     = @"";
            self.launchButtonTitle  = @"";
        }
    }
    else
    {
        [ super observeValueForKeyPath: keyPath ofObject: object change: change context: context ];
    }
}

- ( IBAction )fix: ( id )sender
{
    ( void )sender;
    
    if( self.url == nil )
    {
        return;
    }
    
    self.running = YES;
    
    dispatch_async
    (
        dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ),
        ^( void )
        {
            if( [ self clearExtendedAttributes ] == NO )
            {
                [ self displayError ];
                
                return;
            }
            
            if( [ self rebuildLaunchServicesDatabase ] == NO )
            {
                [ self displayError ];
                
                return;
            }
            
            dispatch_async
            (
                dispatch_get_main_queue(),
                ^( void )
                {
                    NSAlert  * alert;
                    NSWindow * window;
                    
                    self.running = NO;
                    
                    alert                 = [ NSAlert new ];
                    alert.messageText     = @"Application Repaired";
                    alert.informativeText = [ NSString stringWithFormat: @"%@ has been successfully repaired and you should now be able to start it.", self.appName ];
                    alert.alertStyle      = NSInformationalAlertStyle;
                    
                    [ alert addButtonWithTitle: @"OK" ];
                    
                    window = self.window;
                    
                    if( window )
                    {
                        [ alert beginSheetModalForWindow: window completionHandler: NULL ];
                    }
                    else
                    {
                        [ alert runModal ];
                    }
                }
            );
        }
    );
}

- ( IBAction )launch: ( id )sender
{
    NSURL * url;
    
    ( void )sender;
    
    url = self.url;
    
    if( url )
    {
        [ [ NSWorkspace sharedWorkspace ] openURL: url ];
    }
}

- ( IBAction )help: ( id )sender
{
    NSURL * url;
    
    ( void )sender;
    
    url = [ NSURL URLWithString: @"https://github.com/DigiDNA/iMazingAppFixer" ];
    
    [ [ NSWorkspace sharedWorkspace ] openURL: url ];
}

- ( void )displayError
{
    dispatch_async
    (
        dispatch_get_main_queue(),
        ^( void )
        {
            NSAlert  * alert;
            NSWindow * window;
            
            self.running = NO;
            
            alert                 = [ NSAlert new ];
            alert.messageText     = @"Repaired Failed";
            alert.informativeText = [ NSString stringWithFormat: @"Errors were unfortunately encountered while trying to repair %@.", self.appName ];
            alert.alertStyle      = NSInformationalAlertStyle;
            
            [ alert addButtonWithTitle: @"OK" ];
            
            window = self.window;
                    
            if( window )
            {
                [ alert beginSheetModalForWindow: window completionHandler: NULL ];
            }
            else
            {
                [ alert runModal ];
            }
        }
    );
}

- ( BOOL )rebuildLaunchServicesDatabase
{
    NSTask * task;
    
    task            = [ NSTask new ];
    task.launchPath = @"/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister";
    task.arguments  = @[ @"-kill", @"-r", @"-domain", @"local", @"-domain", @"system", @"-domain", @"user" ];
    
    [ task launch ];
    [ task waitUntilExit ];
    
    return task.terminationStatus == 0;
}

- ( BOOL )clearExtendedAttributes
{
    NSTask   * task;
    NSString * path = self.url.path;
    
    if( path == nil )
    {
        return NO;
    }
    
    task            = [ NSTask new ];
    task.launchPath = @"/usr/bin/xattr";
    task.arguments  = @[ @"-c", @"-r", path ];
    
    [ task launch ];
    [ task waitUntilExit ];
    
    return task.terminationStatus == 0;
}

@end
