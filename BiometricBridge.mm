#import "BiometricBridge.h"
#import <Foundation/Foundation.h>
#import "QtTouchIDAuth-Swift.h"

void authenticateAndEncryptBridge(const char* input, ResultCallback callback) {
    NSString *inputStr = [NSString stringWithUTF8String:input];
    [BiometricAuth authenticateAndEncrypt:inputStr completion:^(NSString * _Nullable result) {
        if (result && callback) {
            callback([result UTF8String]);
        } else {
            callback(nullptr);
        }
    }];
}

void authenticateAndDecryptBridge(const char* input, ResultCallback callback) {
    NSString *inputStr = [NSString stringWithUTF8String:input];
    [BiometricAuth authenticateAndDecrypt:inputStr completion:^(NSString * _Nullable result) {
        if (result && callback) {
            callback([result UTF8String]);
        } else {
            callback(nullptr);
        }
    }];
}
