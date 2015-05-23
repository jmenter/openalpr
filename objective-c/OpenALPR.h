
#import <UIKit/UIKit.h>

@interface OpenALPRResult : NSObject
@property (nonatomic, copy) NSString *licensePlate;
@property (nonatomic) UIBezierPath *recognitionPath;
@end

@interface OpenALPR : NSObject

- (OpenALPRResult *)licensePlateFromImage:(UIImage *)image;
- (void)asyncLicensePlateFromImage:(UIImage *)image
                 completionHandler:(void (^)(OpenALPRResult* result))handler;

@end
