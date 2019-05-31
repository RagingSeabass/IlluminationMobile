//
//  ImageStacking.m
//  IlluminationMobile
//
//  Created by Christian Schmidt on 08/05/2019.
//  Copyright © 2019 Christian Schmidt. All rights reserved.
//

#ifdef __cplusplus
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"

#import <opencv2/opencv.hpp>
#import "ImageStacking.h"

#pragma clang pop
#endif

using namespace std;
using namespace cv;

#pragma mark - Private Declarations

@interface ImageStacking ()

#ifdef __cplusplus
+ (Mat)_imageToGray:(Mat)img;
+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;
+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;

#endif

@end

#pragma mark - ImageStacking

@implementation ImageStacking

#pragma mark Public

+ (UIImage *)stackImages:(NSMutableArray *)imgList {
    Mat stack;
    int i = 0;
    
    for (UIImage *o in imgList) {
        // Convert to matrix
        UIImage *imageTemp = [UIImage imageWithCGImage:[o CGImage]];
        Mat currImg = [ImageStacking cvMatFromUIImage:imageTemp];
        currImg.convertTo(currImg, CV_32FC4);
        
        if (i == 0) {
            stack = currImg;
        } else {
            accumulate(currImg, stack);
        }
        i++;
    }
    
    stack = stack / [imgList count];
    stack.convertTo(stack, CV_8UC4);
    
    UIImage *refImage = imgList[0];
    // Back to UIImage
    UIImage *ref = [ImageStacking UIImageFromCVMat:stack];
    // Fix orientation of image
    UIImage *finalImage = [UIImage imageWithCGImage:[ref CGImage] scale:[refImage scale] orientation: UIImageOrientationUp];
    
    return finalImage;
    
}

#pragma mark Private

+ (Mat)_imageToGray:(Mat)img {
    Mat greyImg;
    cvtColor(img, greyImg, COLOR_BGR2GRAY);
    return greyImg;
}

// Native OpenCV functions
+ (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNoneSkipLast|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

@end
