//
//  UIViewController+QCloudUploaderUtils.h
//  Pods
//
//  Created by 傅雁锋 on 2017/9/5.
//
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "TXYUploadManager.h"

//TODO 改成可扩展
// 上传腾讯云后的文件id和扩展名的key
#define FILE_ID_KEY @"file_id"
#define FILE_EXTENSION_KEY @"file_extension"

#define FILE_ID_PARAM_KEY @"fileId"
#define FILE_EXTENSION_PARAM_KEY @"fileExtension"

@interface UIViewController (QCloudUploaderUtils)
    
// 当前上传图片索引
@property (strong, nonatomic) NSNumber *currentUploadIndex;
// 上传到腾讯云后腾讯云返回的结果数组（上传给我们自己服务器的id数组再这里面）
@property (nonatomic, strong) NSMutableArray *realUploadImageUrls;
// 最终上传图片的UIImage数组
@property (nonatomic, strong) NSArray *realUploadImages;
// 最终上传图片的Asset数组
@property (nonatomic, strong) NSArray *realUploadAssets;
// 最终上传图片的扩展名数组
@property (nonatomic, strong) NSMutableArray *exts;
// 腾讯云上传管理器
@property (nonatomic, strong) TXYUploadManager *txUploadManager;
// 视频文件名
@property (nonatomic, strong) NSString *videoFileName;

@property (strong, nonatomic) NSNumber *isUploadArray;
    
    // 初始化各种数组
- (void)setUpUploadArray;
    
    // 上传视频
- (void)uploadVideo:(NSURL *)videoUrl firstFrameImage:(UIImage *)firstFrameImage QCloudAppID:(NSString *)QCloudAppID sign:(NSString *)sign bucket:(NSString *)bucket videoSign:(NSString *)videoSign videoBucket:(NSString *)videoBucket completion:(void (^)(NSDictionary *dic, id error))completion;
    
    // 上传照片
- (void)uploadImageWithPhotoArray:(NSArray *)photo assstArray:(NSArray *)asset QCloudAppID:(NSString *)QCloudAppID sign:(NSString *)sign bucket:(NSString *)bucket completion:(void (^)(NSArray *array, id error))completion;

@end
