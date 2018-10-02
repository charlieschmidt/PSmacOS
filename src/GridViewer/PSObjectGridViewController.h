//
//  PSObjectGridViewController.h
//  GridViewer
//
//  Created by Charlie Schmidt on 10/1/18.
//  Copyright © 2018 Charlie Schmidt. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface PSObjectGridViewController : NSViewController <NSStreamDelegate, NSTableViewDataSource, NSTableViewDelegate>

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode ;

@end

NS_ASSUME_NONNULL_END
