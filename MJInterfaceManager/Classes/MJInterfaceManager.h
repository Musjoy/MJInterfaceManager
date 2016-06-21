//
//  MJInterfaceManager.h
//  SnapUpload
//
//  Created by 黄磊 on 16/4/20.
//  Copyright © 2016年 Tomobapps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActionProtocol.h"

/// 请求设备信息
#ifndef kRequestDeviceInfo
#define kRequestDeviceInfo  @"RequestDeviceInfo-"
#endif

// 设备
/** 设备注册 */
static NSString *const API_DEVICE_REGISTER      = @"Device.register";
/** 注册设备推送 */
static NSString *const API_REGISTER_PUSH        = @"Device.registerPush";

// 错误记录
/// 记录错误
static NSString *const API_ERROR_RECORD         = @"Error.record";


@interface MJInterfaceManager : NSObject


#pragma mark -

/** 设备注册 */
+ (void)deviceRegister;

+ (void)registerPush:(NSString *)deviceToken completion:(ActionCompleteBlock)completion;

+ (void)recordError:(NSString *)errorCode location:(NSString *)errorLocation data:(NSDictionary *)errorData completion:(ActionCompleteBlock)completion;

@end
