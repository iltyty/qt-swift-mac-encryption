#ifndef BIOMETRIC_BRIDGE_H
#define BIOMETRIC_BRIDGE_H

#ifdef __cplusplus
extern "C" {
#endif

typedef void (*ResultCallback)(const char* result);

void authenticateAndEncryptBridge(const char* input, ResultCallback callback);
void authenticateAndDecryptBridge(const char* input, ResultCallback callback);

#ifdef __cplusplus
}
#endif

#endif // BIOMETRIC_BRIDGE_H
