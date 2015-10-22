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

#import "ApplicationDelegate.h"
#import "MainWindowController.h"

@interface ApplicationDelegate()

@property( atomic, readwrite, strong ) MainWindowController * mainWindowController;

- ( void )openDocument: ( id )sender;

@end

@implementation ApplicationDelegate

- ( void )applicationDidFinishLaunching: ( NSNotification * )notification
{
    ( void )notification;
    
    self.mainWindowController = [ MainWindowController new ];
    
    [ self openDocument: nil ];
}

- ( BOOL )applicationShouldTerminateAfterLastWindowClosed: ( NSApplication * )sender
{
    ( void )sender;
    
    return YES;
}

- ( void )openDocument: ( id )sender
{
    NSOpenPanel * panel;
    
    ( void )sender;
    
    panel = [ NSOpenPanel new ];
    
    panel.canChooseDirectories      = NO;
    panel.canChooseFiles            = YES;
    panel.canCreateDirectories      = NO;
    panel.allowsMultipleSelection   = NO;
    panel.allowedFileTypes          = @[ @"app" ];
    panel.message                   = @"Please select an application to repair:";
    panel.directoryURL              = [ NSURL fileURLWithPath: @"/Applications" ];
    
    if( [ panel runModal ] != NSFileHandlingPanelOKButton || panel.URLs.count == 0 )
    {
        if( self.mainWindowController.url == nil )
        {
            [ NSApp terminate: nil ];
        }
        
        return;
    }
    
    self.mainWindowController.url = panel.URLs.firstObject;
    
    [ self.mainWindowController.window center ];
    [ self.mainWindowController showWindow: nil ];
}

@end
