#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "TXYBase.h"
#import "TXYUploadManager.h"
#import "UIViewController+QCloudUploaderUtils.h"

FOUNDATION_EXPORT double QCloudUploaderUtilsVersionNumber;
FOUNDATION_EXPORT const unsigned char QCloudUploaderUtilsVersionString[];

