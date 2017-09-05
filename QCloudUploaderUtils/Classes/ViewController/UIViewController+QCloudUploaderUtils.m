//
//  UIViewController+QCloudUploaderUtils.m
//  Pods
//
//  Created by 傅雁锋 on 2017/9/5.
//
//

#import "UIViewController+QCloudUploaderUtils.h"
#import <objc/runtime.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

static const void *extsKey = &extsKey;
static const void *realUploadAssetsKey = &realUploadAssetsKey;
static const void *realUploadImagesKey = &realUploadImagesKey;
static const void *currentUploadIndexKey = &currentUploadIndexKey;
static const void *realUploadImageUrlsKey = &realUploadImageUrlsKey;
static const void *txUploadManagerKey = &txUploadManagerKey;
static const void *videoFileNameKey = &videoFileNameKey;
static const void *isUploadArrayKey = &isUploadArrayKey;

@implementation UIViewController (QCloudUploaderUtils)
    @dynamic exts;
    @dynamic realUploadAssets;
    @dynamic realUploadImages;
    @dynamic realUploadImageUrls;
    @dynamic currentUploadIndex;
    @dynamic isUploadArray;
    @dynamic txUploadManager;
    @dynamic videoFileName;
    //exts
- (NSMutableArray *)exts {
    return objc_getAssociatedObject(self, extsKey);
}
    
- (void)setExts:(NSMutableArray *)exts {
    objc_setAssociatedObject(self, &extsKey, exts, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
    
    //realUploadAssets
- (NSArray *)realUploadAssets {
    return objc_getAssociatedObject(self, realUploadAssetsKey);
}
    
- (void)setRealUploadAssets:(NSArray *)realUploadAssets {
    objc_setAssociatedObject(self, &realUploadAssetsKey, realUploadAssets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
    
    //realUploadImages
- (NSArray *)realUploadImages {
    return objc_getAssociatedObject(self, realUploadImagesKey);
}
    
- (void)setRealUploadImages:(NSArray *)realUploadImages {
    objc_setAssociatedObject(self, &realUploadImagesKey, realUploadImages, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
    
    //realUploadImageUrls
- (NSMutableArray *)realUploadImageUrls {
    return objc_getAssociatedObject(self, realUploadImageUrlsKey);
}
    
- (void)setRealUploadImageUrls:(NSMutableArray *)realUploadImageUrls {
    objc_setAssociatedObject(self, &realUploadImageUrlsKey, realUploadImageUrls, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
    
    //currentUploadIndex
- (NSNumber *)currentUploadIndex {
    return objc_getAssociatedObject(self, currentUploadIndexKey);
}
    
- (void)setCurrentUploadIndex:(NSNumber *)currentUploadIndex {
    objc_setAssociatedObject(self, &currentUploadIndexKey, currentUploadIndex, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
    
    //isUploadArray
- (NSNumber *)isUploadArray {
    return objc_getAssociatedObject(self, isUploadArrayKey);
}
    
- (void)setIsUploadArray:(NSNumber *)isUploadArray {
    objc_setAssociatedObject(self, &isUploadArrayKey, isUploadArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
    
    //txUploadManager
- (TXYUploadManager *)txUploadManager {
    return objc_getAssociatedObject(self, txUploadManagerKey);
}
    
- (void)setTxUploadManager:(TXYUploadManager *)txUploadManager {
    objc_setAssociatedObject(self, &txUploadManagerKey, txUploadManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
    
    //videoFileName
- (NSString *)videoFileName {
    return objc_getAssociatedObject(self, videoFileNameKey);
}
    
- (void)setVideoFileName:(NSString *)videoFileName {
    objc_setAssociatedObject(self, &videoFileNameKey, videoFileName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
    
- (void)setUpUploadArray {
    
    // self.isUploadArray = true;
    self.exts = [NSMutableArray array];
    self.realUploadImageUrls = [NSMutableArray array];
    self.realUploadImages = [NSMutableArray array];
    self.realUploadAssets = [NSMutableArray array];
    self.currentUploadIndex = @(0);
}
    
- (void)uploadVideo:(NSURL *)videoUrl firstFrameImage:(UIImage *)firstFrameImage QCloudAppID:(NSString *)QCloudAppID sign:(NSString *)sign bucket:(NSString *)bucket videoSign:(NSString *)videoSign videoBucket:(NSString *)videoBucket completion:(void (^)(NSDictionary *dic, id error))completion {
    
    NSDate *date = [NSDate date];
    self.videoFileName = [NSString stringWithFormat:@"%f", date.timeIntervalSince1970];
    
    if (firstFrameImage != nil) {
        self.txUploadManager = [[TXYUploadManager alloc] initWithCloudType:TXYCloudTypeForImage persistenceId:@"upload_image" appId:QCloudAppID];
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg", self.videoFileName];
        NSData *imageData = UIImageJPEGRepresentation(firstFrameImage, 1.2f);
        TXYPhotoUploadTask *uploadTask = [[TXYPhotoUploadTask alloc] initWithImageData:imageData fileName:fileName sign:sign bucket:bucket expiredDate:0 msgContext:@"" fileId:@""];
        
        __weak UIViewController* weakSelf = self;
        [self.txUploadManager upload:uploadTask complete:^(TXYTaskRsp *resp, NSDictionary *context) {
            NSString *firstFrameImageUrl = @"";
            if (resp.retCode >= 0) {
                TXYPhotoUploadTaskRsp *photoResp = (TXYPhotoUploadTaskRsp *)resp;
                firstFrameImageUrl = photoResp.photoURL;
            }
            
            [weakSelf uploadVideo:videoUrl coverImage:firstFrameImageUrl QCloudAppID:QCloudAppID sign:videoSign bucket:videoBucket completion:^(NSDictionary *dic, id error) {
                if (completion) {
                    completion(dic, error);
                }
            }];
        } progress:^(int64_t totalSize, int64_t sendSize, NSDictionary *context) {
            
        } stateChange:^(TXYUploadTaskState state, NSDictionary *context) {
        }];
    } else {
        completion(nil, nil);
    }
}
    
- (void)uploadVideo:(NSURL *)videoUrl coverImage:(NSString *)coverImage QCloudAppID:(NSString *)QCloudAppID sign:(NSString *)sign bucket:(NSString *)bucket completion:(void (^)(NSDictionary *dic, id error))completion {
    self.txUploadManager = [[TXYUploadManager alloc] initWithCloudType:TXYCloudTypeForVideo persistenceId:@"upload_video" appId:QCloudAppID];
//    __weak UIViewController* weakSelf = self;
    
    NSLog(@"url = %@", videoUrl.path);
    
    
    TXYVideoFileInfo *fileInfo = nil;
    if (coverImage.length > 0) {
        fileInfo = [[TXYVideoFileInfo alloc] init];
        fileInfo.coverUrl = coverImage;
    }
    
    //    TXYVideoUploadTask *uploadTask = [[TXYVideoUploadTask alloc] initWithPath:videoUrl.path sign:sign bucket:bucket customAttribute:@"" uploadDirectory:@"/" videoFileInfo:nil msgContext:@""];
    
    NSString *fileName = [NSString stringWithFormat:@"%@.mp4", self.videoFileName];
    
    //TXYVideoUploadTask *uploadTask = [[TXYVideoUploadTask alloc] initWithPath:videoUrl.path sign:sign bucket:bucket fileName:fileName customAttribute:nil uploadDirectory:@"/share/" videoFileInfo:fileInfo msgContext:nil insertOnly:false];
    //    TXYVideoUploadTask *uploadTask = [[TXYVideoUploadTask alloc] initWithPath:videoUrl.path sign:sign bucket:bucket customAttribute:nil uploadDirectory:@"/share/" videoFileInfo:fileInfo msgContext:nil];
    TXYVideoUploadTask *uploadTask = [[TXYVideoUploadTask alloc] initWithPath:videoUrl.path sign:sign bucket:bucket fileName:fileName customAttribute:nil uploadDirectory:@"/share/" videoFileInfo:fileInfo msgContext:nil insertOnly:false];
    
    [self.txUploadManager upload:uploadTask complete:^(TXYTaskRsp *resp, NSDictionary *context) {
        if (resp.retCode >= 0) {
            TXYVideoUploadTaskRsp *videoResp = (TXYVideoUploadTaskRsp *)resp;
            NSLog(@"videoResp.videoUrl = %@", videoResp.fileURL);
            NSMutableDictionary *object = [[NSMutableDictionary alloc] init];
            [object setValue:[NSString stringWithFormat:@"%@.mp4", self.videoFileName] forKey:self.isUploadArray.boolValue ? FILE_ID_KEY : FILE_ID_PARAM_KEY];
            [object setValue:@"mp4" forKey:self.isUploadArray.boolValue ? FILE_EXTENSION_KEY : FILE_EXTENSION_PARAM_KEY];
            if (completion) {
                completion(object, nil);
            }
            
        } else {
            NSString *errorDesc = [NSString stringWithFormat:@"上传小视频失败：%@", resp.descMsg];
            NSLog(@"%@", errorDesc);
            if (completion) {
                completion(nil, errorDesc);
            }
        }
        
    } progress:^(int64_t totalSize, int64_t sendSize, NSDictionary *context) {
        NSLog(@"totalSize = %lld, sendSize = %lld", totalSize, sendSize);
    } stateChange:^(TXYUploadTaskState state, NSDictionary *context) {
        NSLog(@"state = %ld", state );
    }];
}
    
#pragma mark - 上传图片
- (void)uploadImageWithPhotoArray:(NSMutableArray *)photo assstArray:(NSMutableArray *)asset QCloudAppID:(NSString *)QCloudAppID sign:(NSString *)sign bucket:(NSString *)bucket completion:(void (^)(NSArray *array, id error))completion {
    
    [self uploadToQCloudWithphotos:photo asset:asset QCloudAppID:QCloudAppID sign:sign bucket:bucket completion:completion];
}
    
- (void)uploadToQCloudWithphotos:(NSMutableArray *)photo asset:(NSMutableArray *)asset QCloudAppID:(NSString *)QCloudAppID sign:(NSString *)sign bucket:(NSString *)bucket completion:(void (^)(NSArray *array, id error))completion {
    
    if (photo.count == 0 || asset.count == 0) {
        if (completion) {
            completion(@[], nil);
        }
        return;
    }
    
    self.currentUploadIndex = @(0);
    self.realUploadImageUrls = [[NSMutableArray alloc] init];
    [self.exts removeAllObjects];
    self.realUploadImages = [NSArray arrayWithArray:photo];
    self.realUploadAssets = [NSArray arrayWithArray:asset];
    [self uploadSingleImageToQCloudWithSign:sign bucket:bucket  QCloudAppID:QCloudAppID completion:completion];
}
    
- (void)uploadSingleImageToQCloudWithSign:(NSString *)sign bucket:(NSString *)bucket QCloudAppID:(NSString *)QCloudAppID completion:(void (^)(NSArray *array, id error))completion {
    
    if (self.currentUploadIndex.intValue >= self.realUploadImages.count) {
        //TODO 上传urls到服务器
        NSInteger i = 0;
        NSMutableArray *images = [[NSMutableArray alloc] init];
        for (TXYPhotoUploadTaskRsp *resp in self.realUploadImageUrls) {
            NSMutableDictionary *imageObject = [[NSMutableDictionary alloc] init];
            [imageObject setValue:resp.photoFileId forKey:self.isUploadArray.boolValue ? FILE_ID_KEY : FILE_ID_PARAM_KEY];
            [imageObject setValue:self.exts[i] forKey:self.isUploadArray.boolValue ? FILE_EXTENSION_KEY : FILE_EXTENSION_PARAM_KEY];
            
            [images addObject:imageObject];
            i++;
        }
        
        //[self uploadImagesToQCloundComplete:images];
        if (completion) {
            completion(images, nil);
        }
        return;
    }
    
    self.txUploadManager = [[TXYUploadManager alloc] initWithCloudType:TXYCloudTypeForImage persistenceId:@"upload_image" appId:QCloudAppID];
    UIImage *image = [self coversionImage:@"fullResolutionImage" objc:self.realUploadImages[self.currentUploadIndex.intValue]];
    NSArray *assets = self.realUploadAssets;
    id object = assets[self.currentUploadIndex.intValue];
    NSString *fileName;
    NSData *gifData;
    int index = self.currentUploadIndex.intValue+1;
    self.currentUploadIndex = @(index);
    //    self.currentUploadIndex++;
    //    TXYPhotoUploadTask *uploadTask = [[TXYPhotoUploadTask alloc] initWithPath:url sign:[preference stringForKey:QCLOUD_SIGN_PREFERENCE_KEY] bucket:@"image" expiredDate:0 msgContext:@"" fileId:@""];
    if ([object isKindOfClass:[ALAsset class]]) {
        ALAsset *result = (ALAsset *)object;
        fileName = [[result defaultRepresentation] filename];
        if (fileName.length > 0) {
            
            if (([fileName hasSuffix:@".gif"] || [fileName hasSuffix:@".GIF"])) {
                [self.exts addObject:@"gif"];
                ALAssetRepresentation *rep = [result defaultRepresentation];
                Byte *buffer = (Byte*)malloc((NSUInteger)rep.size);
                NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:(NSUInteger)rep.size error:nil];
                gifData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
                [self uploadImageWithFileName:fileName image:image gifData:gifData sign:sign bucket:bucket QCloudAppID:QCloudAppID completion:completion];
            } else {
                [self.exts addObject:@"jpg"];
                [self uploadImageWithFileName:fileName image:image gifData:nil sign:sign bucket:bucket QCloudAppID:QCloudAppID completion:completion];
            }
        }
    } else if ([object isKindOfClass:[PHAsset class]]) {
        
        NSString *fileName = [object valueForKey:@"filename"];
        
        if ([fileName containsString:@"gif"] || [fileName containsString:@"GIF"]) {
            
            [self.exts addObject:@"gif"];
            
            PHCachingImageManager *manager = (PHCachingImageManager *)[PHCachingImageManager defaultManager];
            [manager requestImageDataForAsset:object options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                
                [self uploadImageWithFileName:fileName image:image gifData:imageData sign:sign bucket:bucket QCloudAppID:QCloudAppID completion:completion];
                
            }];
            
        } else {
            [self.exts addObject:@"jpg"];
            [self uploadImageWithFileName:fileName image:image gifData:nil sign:sign bucket:bucket QCloudAppID:QCloudAppID completion:completion];
        }
    } else {
        [self.exts addObject:@"jpg"];
        [self uploadImageWithFileName:fileName image:image gifData:nil sign:sign bucket:bucket QCloudAppID:QCloudAppID completion:completion];
    }
    
}
    
- (void)uploadImageWithFileName:(NSString *)fileName image:(UIImage *)image gifData:(NSData *)gifData sign:(NSString *)sign bucket:(NSString *)bucket QCloudAppID:(NSString *)QCloudAppID completion:(void (^)(NSArray *array, id error))completion {
    
    BOOL canScale = true;
    if (fileName.length > 0 && ([fileName hasSuffix:@".gif"] || [fileName hasSuffix:@".GIF"])) {
        canScale = false;
    } else {
        CGFloat ratio = image.size.width / image.size.height;
        if (ratio > 1.0f) {
            ratio = image.size.height / image.size.width;
        }
        
        if (ratio < 0.2f) {
            canScale = false;
        }
    }
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.2f);
    CGFloat maxLength = 2*1024*1024.0f;
    if (imageData.length > maxLength && canScale) {
        CGFloat scale = maxLength / imageData.length;
        imageData = UIImageJPEGRepresentation(image, scale);
    }
    
    NSString *imageName = fileName.length > 0 ? [fileName hasSuffix:@".GIF"] ? [fileName stringByReplacingOccurrencesOfString:@"GIF" withString:@"gif"] : fileName : [NSString stringWithFormat:@"file%d.jpg", (int)self.currentUploadIndex.intValue+1];
    
    TXYPhotoUploadTask *uploadTask = [[TXYPhotoUploadTask alloc] initWithImageData:gifData ? gifData : imageData fileName:imageName sign:sign bucket:bucket expiredDate:0 msgContext:@"" fileId:@""];
    
    __weak UIViewController* weakSelf = self;
    
    [self.txUploadManager upload:uploadTask complete:^(TXYTaskRsp *resp, NSDictionary *context) {
        if (resp.retCode >= 0) {
            TXYPhotoUploadTaskRsp *photoResp = (TXYPhotoUploadTaskRsp *)resp;
            [weakSelf.realUploadImageUrls addObject:photoResp];
            [weakSelf uploadSingleImageToQCloudWithSign:sign bucket:bucket QCloudAppID:QCloudAppID completion:completion];
        } else {
            NSString *errorDesc = [NSString stringWithFormat:@"上传图片失败：%@", resp.descMsg];
            NSLog(@"%@", errorDesc);
            
            if (completion) {
                completion(@[], nil);
            }
        }
    } progress:^(int64_t totalSize, int64_t sendSize, NSDictionary *context) {
        
    } stateChange:^(TXYUploadTaskState state, NSDictionary *context) {
        
    }];
}
    
- (UIImage *)coversionImage:(NSString *)scale objc:(id)objc {
    if ([objc isKindOfClass:[ALAsset class]]) {
        ALAsset *result = objc;
        ALAssetRepresentation *representation = [result defaultRepresentation];
        CGImageRef ref = [representation fullResolutionImage];
        UIImage *img = [[UIImage alloc] initWithCGImage:ref scale:1.0f orientation:[self getAssetOrientation:representation]];
        return img;
        
    } else if ([objc isKindOfClass:[UIImage class]]) {
        return objc;
    }
    
    return nil;
}
    
- (UIImageOrientation)getAssetOrientation:(ALAssetRepresentation *)representation {
    switch (representation.orientation) {
        case ALAssetOrientationUp:
        return UIImageOrientationUp;
        
        case ALAssetOrientationDown:
        return UIImageOrientationDown;
        
        case ALAssetOrientationLeft:
        return UIImageOrientationLeft;
        
        case ALAssetOrientationRight:
        return UIImageOrientationRight;
        
        case ALAssetOrientationUpMirrored:
        return UIImageOrientationUpMirrored;
        
        case ALAssetOrientationDownMirrored:
        return UIImageOrientationDownMirrored;
        
        case ALAssetOrientationLeftMirrored:
        return UIImageOrientationLeftMirrored;
        
        case ALAssetOrientationRightMirrored:
        return UIImageOrientationRightMirrored;
        
        default:
        break;
    }
    
    return UIImageOrientationUp;
}

@end
