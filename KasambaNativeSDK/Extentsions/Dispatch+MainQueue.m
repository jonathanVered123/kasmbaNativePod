//
//  Dispatch.m
//  Kasamba
//
//  Created by Natan Zalkin on 9/25/17.
//  Copyright © 2017 Kasamba Inc. All rights reserved.
//

#import "Dispatch+MainQueue.h"

void dispatchOnMainThread(dispatch_block_t work) {
    if (NSThread.isMainThread) {
        work();
    }
    else {
        dispatch_async(dispatch_get_main_queue(), work);
    }
}
