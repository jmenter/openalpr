
#import "OpenALPR.h"
#include "alpr.h"
#include <OpenCV/opencv.hpp>

using namespace alpr;
using namespace std;

@implementation OpenALPRResult

@end

@interface OpenALPR ()
@property (assign) Alpr *reader;
@end
@implementation OpenALPR

- (instancetype)init;
{
    if (!(self = [super init])) { return nil; }
    
    self.reader = new Alpr("us", [NSBundle.mainBundle pathForResource:@"openalpr" ofType:@"conf"].UTF8String,
                                 [NSBundle.mainBundle.bundlePath stringByAppendingString:@"/runtime_data"].UTF8String);
    return self;
}

- (void)asyncLicensePlateFromImage:(UIImage *)image completionHandler:(void (^)(OpenALPRResult* result))handler;
{
    dispatch_async(dispatch_queue_create("com.test", NULL), ^{
        OpenALPRResult *licensePlate = [self licensePlateFromImage:image];
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(licensePlate);
        });
    });
}

- (OpenALPRResult *)licensePlateFromImage:(UIImage *)image;
{
    cv::Mat frame = [self cvMatFromUIImage:image];
    
    std::vector<AlprRegionOfInterest> regionsOfInterest;
    regionsOfInterest.push_back(AlprRegionOfInterest(0, 0, frame.cols, frame.rows));
    
    string rawOutput = self.reader->toJson(self.reader->recognize(frame.data, (int)frame.elemSize(), frame.cols, frame.rows, regionsOfInterest));

    NSData *data = [[NSString stringWithUTF8String:rawOutput.c_str()] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    if (results[@"results"]) {
        if ([results[@"results"] count] > 0) {
            if (results[@"results"][0][@"plate"]) {
                CGFloat width = UIScreen.mainScreen.bounds.size.width;
                CGFloat ratio = frame.cols / width;
                OpenALPRResult *result = [OpenALPRResult new];
                UIBezierPath *path = [UIBezierPath new];
                NSDictionary *firstPoint = results[@"results"][0][@"coordinates"][0];
                [path moveToPoint:CGPointMake([firstPoint[@"x"] integerValue] / ratio, [firstPoint[@"y"] integerValue] / ratio)];
                for (NSDictionary *coordintate in results[@"results"][0][@"coordinates"]) {
                    [path addLineToPoint:CGPointMake([coordintate[@"x"] integerValue] / ratio, [coordintate[@"y"] integerValue] / ratio)];
                }
                [path closePath];
                result.licensePlate = results[@"results"][0][@"plate"];
                result.recognitionPath = path;
                return result;
            }
        }
    }
    return nil; 
}

- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4);
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data, cols, rows, 8, cvMat.step[0], colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault);
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

@end
