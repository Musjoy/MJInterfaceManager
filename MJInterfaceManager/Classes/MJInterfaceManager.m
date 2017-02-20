//
//  MJInterfaceManager.m
//  SnapUpload
//
//  Created by 黄磊 on 16/4/20.
//  Copyright © 2016年 Tomobapps. All rights reserved.
//

#import "MJInterfaceManager.h"
#import "WebInterface.h"
#ifdef MODULE_UTILS
#import "NSDictionary+Utils.h"
#endif

@implementation MJInterfaceManager

#pragma mark -

+ (void)deviceRegister
{
    NSString *describe = @"Device Register";
#ifdef kServerBaseHost
    MJRequestHeader *head = [WebInterface getRequestHeaderModel];
    // 读取本地纪录deviceId
    NSString *theBaseHost = [[kServerBaseHost componentsSeparatedByString:@"://"] objectAtIndex:1];
    NSString *key = [kRequestDeviceInfo stringByAppendingString:theBaseHost];
    NSDictionary *aDic = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (aDic && [aDic isKindOfClass:[NSDictionary class]]
        && aDic[@"deviceId"]
        && [aDic[@"deviceUUID"] isEqualToString:head.deviceUUID]
        && [aDic[@"sysVersion"] isEqualToString:head.sysVersion]
        && [aDic[@"appVersion"] isEqualToString:head.appVersion]
        && [aDic[@"appState"] isEqualToNumber:head.appState]) {
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
#endif
            }
        }
    }];
}

+ (void)registerPush:(NSString *)deviceToken completion:(ActionCompleteBlock)completion
{
    NSString *describe = @"Device Push Register";
    NSDictionary *aSendDic = @{@"deviceToken":deviceToken};
    [WebInterface startRequest:API_REGISTER_PUSH describe:describe body:aSendDic completion:completion];
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
