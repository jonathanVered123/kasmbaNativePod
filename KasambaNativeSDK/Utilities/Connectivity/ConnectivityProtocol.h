//
//  ConnectivityProtocol.h
//  Kasamba
//
//  Created by Kobi Kagan on 7/16/17.
//  Copyright © 2017 Kasamba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ConnectivityProtocol <NSObject>

@property (readonly) BOOL isConnectionAvailable;


-(void ) showConnectivityMessage;
-(void ) checkConnectivityAvailableWithCompletion:(void(^ _Nullable)(BOOL isAvailable))completion;
-(void ) notifyAdvisorsChatTryWithNoNetwork;
-(void ) saveChatTryWhenNoNetworkWithAdvisor:(NSNumber* _Nonnull)advisorId andCategoryId:(NSNumber* _Nonnull)categoryId;
-(void ) addAdvisorsChatTryWithNoNetwork:(NSNumber* _Nonnull)advisorId andCategoryId:(NSNumber* _Nonnull)categoryId;

@end
