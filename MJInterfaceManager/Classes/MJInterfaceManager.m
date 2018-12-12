//
//  MJInterfaceManager.m
//  SnapUpload
//
//  Created by 黄磊 on 16/4/20.
//  Copyright © 2016年 Tomobapps. All rights reserved.
//

#import "MJInterfaceManager.h"
#import HEADER_SERVER_URL
#import <WebInterface/WebInterface.h>
#ifdef  MODULE_UTILS
#import <MJUtils/NSDictionary+Utils.h>
#endif

#ifdef DEBUG
#define kAppState @0        // app状态 0-开发状态 1-发布状态
#else
#define kAppState @1
#endif

#ifndef kServerBaseHost
#define kServerBaseHost @""
#endif

static NSString *s_devicePushId = nil;

@implementation MJInterfaceManager

#pragma mark -

+ (void)deviceRegister
{
#ifdef FUN_WEB_INTERFACE_DEVICE_NEED_APP
    [self deviceAppRegister];
    return;
#endif
    NSString *describe = @"Device Register";
#ifdef kServerBaseHost
    MJRequestHeader *head = [WebInterface getRequestHeaderModel];
    // 读取本地纪录deviceId
    NSString *theBaseHost = [[kServerBaseHost componentsSeparatedByString:@"://"] lastObject];
    NSString *key = [kRequestDeviceInfo stringByAppendingString:theBaseHost];
    NSDictionary *aDic = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (aDic && [aDic isKindOfClass:[NSDictionary class]]
        && aDic[@"deviceId"]
        && [aDic[@"deviceName"] isEqualToString:head.deviceName]
        && [aDic[@"deviceUUID"] isEqualToString:head.deviceUUID]
        && [aDic[@"deviceIDFA"] isEqualToString:head.deviceIDFA]
        && [aDic[@"sysVersion"] isEqualToString:head.sysVersion]
        && [aDic[@"appVersion"] isEqualToString:head.appVersion]
        && [aDic[@"deviceRegionCode"] isEqualToString:head.deviceRegionCode]
        && [aDic[@"firstLanguage"] isEqualToString:head.firstLanguage]
        && [aDic[@"timeZone"] isEqualToNumber:head.timeZone]) {
        head.deviceId = aDic[@"deviceId"];
        [WebInterface resetRequestMode];
        return;
    }
#endif
    
    [WebInterface startRequest:API_DEVICE_REGISTER
                      describe:describe
                          body:@{}
                    completion:^(BOOL isSucceed, NSString *message, id data) {
        if (isSucceed && [data isKindOfClass:[NSDictionary class]]) {
#ifdef kServerBaseHost
            id aDeviceId = data[@"deviceId"];
            if (aDeviceId
                && ![aDeviceId isKindOfClass:[NSNull class]]
                && [data[@"deviceId"] intValue] > 0) {
                // 保存设备id
                MJRequestHeader *head = [WebInterface getRequestHeaderModel];
                head.deviceId = data[@"deviceId"];

                [[NSUserDefaults standardUserDefaults] setObject:[head toDictionary] forKey:key];
                [WebInterface resetRequestMode];
            }
#endif
        }
    }];
}



+ (void)registerPush:(NSString *)deviceToken completion:(ActionCompleteBlock)completion
{
#ifdef FUN_WEB_INTERFACE_DEVICE_NEED_APP
    [self registerAppPush:deviceToken completion:completion];
    return;
#endif
    [self registerPush:API_REGISTER_PUSH deviceToken:deviceToken completion:completion];
}

#ifdef FUN_WEB_INTERFACE_DEVICE_NEED_APP
+ (void)deviceAppRegister
{
    NSString *describe = @"Device App Register";
#ifdef kServerBaseHost
    MJRequestHeader *head = [WebInterface getRequestHeaderModel];
    // 读取本地纪录deviceId
    NSString *theBaseHost = [[kServerBaseHost componentsSeparatedByString:@"://"] lastObject];
    NSString *key = [kRequestDeviceAppInfo stringByAppendingString:theBaseHost];
    NSDictionary *aDic = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (aDic && [aDic isKindOfClass:[NSDictionary class]]
        && aDic[@"deviceAppId"]
        && [aDic[@"deviceName"] isEqualToString:head.deviceName]
        && [aDic[@"deviceUUID"] isEqualToString:head.deviceUUID]
        && [aDic[@"deviceIDFA"] isEqualToString:head.deviceIDFA]
        && [aDic[@"sysVersion"] isEqualToString:head.sysVersion]
        && [aDic[@"appVersion"] isEqualToString:head.appVersion]
        && [aDic[@"deviceRegionCode"] isEqualToString:head.deviceRegionCode]
        && [aDic[@"firstLanguage"] isEqualToString:head.firstLanguage]
        && [aDic[@"timeZone"] isEqualToNumber:head.timeZone]) {
        head.deviceAppId = aDic[@"deviceAppId"];
        [WebInterface resetRequestMode];
        return;
    }
#endif
    
    [WebInterface startRequest:API_DEVICE_APP_REGISTER
                      describe:describe
                          body:@{}
                    completion:^(BOOL isSucceed, NSString *message, id data) {
                        if (isSucceed && [data isKindOfClass:[NSDictionary class]]) {
#ifdef kServerBaseHost
                            id aDeviceId = data[@"deviceAppId"];
                            if (aDeviceId
                                && ![aDeviceId isKindOfClass:[NSNull class]]
                                && [data[@"deviceAppId"] intValue] > 0) {
                                // 保存设备id
                                MJRequestHeader *head = [WebInterface getRequestHeaderModel];
                                head.deviceAppId = data[@"deviceAppId"];
                                
                                [[NSUserDefaults standardUserDefaults] setObject:[head toDictionary] forKey:key];
                                [WebInterface resetRequestMode];
                            }
#endif
                        }
                    }];
}

+ (void)registerAppPush:(NSString *)deviceToken completion:(ActionCompleteBlock)completion
{
    [self registerPush:API_REGISTER_APP_PUSH deviceToken:deviceToken completion:completion];
}
#endif

+ (void)registerPush:(NSString *)action  deviceToken:(NSString *)deviceToken completion:(ActionCompleteBlock)completion
{
    NSString *theBaseHost = [[kServerBaseHost componentsSeparatedByString:@"://"] lastObject];
    NSString *key = [kDevicePushInfo stringByAppendingString:theBaseHost];
    
    NSDictionary *aDic = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (aDic && [aDic isKindOfClass:[NSDictionary class]]
        && aDic[@"devicePushId"]
        && [aDic[@"deviceToken"] isEqualToString:deviceToken]
        && [aDic[@"appState"] isEqualToNumber:kAppState]) {
        
        s_devicePushId = aDic[@"devicePushId"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNoticGetDevicePushId object:nil];
        completion ? completion(YES, @"", aDic) : 0;
        return;
    }
    
    NSString *describe = @"Device Push Register";
    NSDictionary *aSendDic = @{@"deviceToken":deviceToken,
                               @"appState":kAppState};
    [WebInterface startRequest:action describe:describe body:aSendDic completion:^(BOOL isSucceed, NSString *message, id data) {
        if (isSucceed) {
            if (data && [data isKindOfClass:[NSDictionary class]]) {
                id devicePushId = data[@"devicePushId"];
                if ([devicePushId isKindOfClass:[NSNumber class]]) {
                    devicePushId = [devicePushId stringValue];
                }
                if ([devicePushId length] > 0) {
                    s_devicePushId = devicePushId;
                    NSDictionary *aDic = @{@"devicePushId"  : devicePushId,
                                           @"deviceToken"   : deviceToken,
                                           @"appState"      : kAppState};
                    [[NSUserDefaults standardUserDefaults] setObject:aDic forKey:key];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNoticGetDevicePushId object:nil];
                }
            }
        }
        completion ? completion(isSucceed, message, data) : 0;
    }];
}


+ (NSString *)getDevicePushId
{
    if (s_devicePushId == nil) {
        // 读取本地的
        NSString *theBaseHost = [[kServerBaseHost componentsSeparatedByString:@"://"] lastObject];
        NSString *key = [kDevicePushInfo stringByAppendingString:theBaseHost];
        NSDictionary *aDic = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        if (aDic && [aDic isKindOfClass:[NSDictionary class]]
            && [aDic[@"devicePushId"] length] > 0) {
            s_devicePushId = aDic[@"devicePushId"];
        }
    }
    return s_devicePushId;
}

+ (void)pushHandled:(NSNumber *)pushId completion:(ActionCompleteBlock)completion
{
    NSString *describe = @"Push Handled";
    NSDictionary *aSendDic = @{@"pushId":pushId};
    [WebInterface startRequest:API_PUSH_HANDLED describe:describe body:aSendDic completion:completion];
}

+ (void)recordError:(NSString *)errorCode location:(NSString *)errorLocation data:(NSDictionary *)errorData completion:(ActionCompleteBlock)completion
{
    if (errorCode.length == 0) {
        return;
    }
    if (errorLocation.length == 0) {
        return;
    }
    NSString *describe = @"Record Error";
    NSMutableDictionary *aSendDic = [@{@"errorCode":errorCode,
                                       @"errorLocation":errorLocation} mutableCopy];
    if (errorData) {
        if ([errorData isKindOfClass:[NSDictionary class]]) {
            [aSendDic setObject:jsonStringFromDic(errorData) forKey:@"errorData"];
        } else {
            [aSendDic setObject:[NSString stringWithFormat:@"%@", errorData] forKey:@"errorData"];
        }
    }
    [WebInterface startRequest:API_ERROR_RECORD describe:describe body:aSendDic completion:completion];
}


@end
