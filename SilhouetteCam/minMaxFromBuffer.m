/*
See LICENSE.txt for this sample’s licensing information.

Abstract:
Implements a function which extracts the smallest and largest values from a pixel buffer.
*/

#import "minMaxFromBuffer.h"
#import <Foundation/Foundation.h>
#import <simd/simd.h>

void minMaxFromPixelBuffer(CVPixelBufferRef pixelBuffer, float* minValue, float* maxValue, MTLPixelFormat pixelFormat)
{
	int width  		= (int)CVPixelBufferGetWidth(pixelBuffer);
	int height 		= (int)CVPixelBufferGetHeight(pixelBuffer);
	int bytesPerRow = (int)CVPixelBufferGetBytesPerRow(pixelBuffer);

	CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
	unsigned char* pixelBufferPointer = CVPixelBufferGetBaseAddress(pixelBuffer);
	__fp16* bufferP_F16 = (__fp16 *) pixelBufferPointer;
	float*  bufferP_F32 = (float  *) pixelBufferPointer;

	bool isFloat16 = (pixelFormat == MTLPixelFormatR16Float);
	uint32_t increment = isFloat16 ?  bytesPerRow/sizeof(__fp16) : bytesPerRow/sizeof(float);

	float min = MAXFLOAT;
	float max = -MAXFLOAT;

	for (int j=0; j < height; j++)
	{
		for (int i=0; i < width; i++)
		{
			float val = ( isFloat16 ) ?  bufferP_F16[i] :  bufferP_F32[i] ;
			if (!isnan(val)) {
				if (val>max) max = val;
				if (val<min) min = val;
			}
		}
		if ( isFloat16 ) {
			bufferP_F16 +=increment;
		}  else {
			bufferP_F32 +=increment;
		}
	}

	CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);

	*minValue = min;
	*maxValue = max;
}

NSArray* pixelConfigurationArrayFromDepthPixelBuffer(CVPixelBufferRef pixelBuffer, MTLPixelFormat pixelFormat, float depthThreshold, uint32_t* bytesPerPixel)
{
    int width          = (int)CVPixelBufferGetWidth(pixelBuffer);
    int height         = (int)CVPixelBufferGetHeight(pixelBuffer);
    int bytesPerRow = (int)CVPixelBufferGetBytesPerRow(pixelBuffer);
    
    CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    unsigned char* pixelBufferPointer = CVPixelBufferGetBaseAddress(pixelBuffer);
    __fp16* bufferP_F16 = (__fp16 *) pixelBufferPointer;
    float*  bufferP_F32 = (float  *) pixelBufferPointer;
    
    bool isFloat16 = (pixelFormat == MTLPixelFormatR16Float);
    uint32_t increment = isFloat16 ?  bytesPerRow/sizeof(__fp16) : bytesPerRow/sizeof(float);
    
    NSMutableArray *pixelValues = [NSMutableArray array];
    for (int j=0; j < height; j++)
    {
        for (int i=0; i < width; i++)
        {
            float val = ( isFloat16 ) ?  bufferP_F16[i] :  bufferP_F32[i] ;
            if (!isnan(val)) {
                if (val < depthThreshold) {
                    [pixelValues addObject:@"x"];
                } else {
                    [pixelValues addObject:@"c"];
                }
            } else {
                [pixelValues addObject:@"c"];
            }
        }
        if ( isFloat16 ) {
            bufferP_F16 +=increment;
        }  else {
            bufferP_F32 +=increment;
        }
    }
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);

    *bytesPerPixel = increment;
    NSLog(@"pixelValues.count = %i, pixelFormatIsFloat16 = %@, valueBytesSize = %i", pixelValues.count, isFloat16 ? @"YES" : @"NO", isFloat16 ? sizeof(__fp16) : sizeof(float));
    
    return pixelValues;
}

void darkenCloseSpotsInPixelBuffer(CVPixelBufferRef pixelBuffer, MTLPixelFormat pixelFormat)
{
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    size_t stride = CVPixelBufferGetBytesPerRow(pixelBuffer);
    char *data = (char *)CVPixelBufferGetBaseAddress(pixelBuffer);
    for (size_t y = 0; y < CVPixelBufferGetHeight(pixelBuffer); ++y) {
        uint32_t *pixels = (uint32_t *)(data + stride * y);
        for (size_t x = 0; x < CVPixelBufferGetWidth(pixelBuffer); ++x)
            pixels[x] = (pixels[x] >> 8) | (pixels[x] << 24);
    }
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
//    int width          = (int)CVPixelBufferGetWidth(pixelBuffer);
//    int height         = (int)CVPixelBufferGetHeight(pixelBuffer);
//    int bytesPerRow = (int)CVPixelBufferGetBytesPerRow(pixelBuffer);
//
//    CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
//    unsigned char* pixelBufferPointer = CVPixelBufferGetBaseAddress(pixelBuffer);
//    __fp16* bufferP_F16 = (__fp16 *) pixelBufferPointer;
//    float*  bufferP_F32 = (float  *) pixelBufferPointer;
//
//    bool isFloat16 = (pixelFormat == MTLPixelFormatR16Float);
//    uint32_t increment = isFloat16 ?  bytesPerRow/sizeof(__fp16) : bytesPerRow/sizeof(float);
//
//    float min = MAXFLOAT;
//    float max = -MAXFLOAT;
//
//    for (int j=0; j < height; j++)
//    {
//        for (int i=0; i < width; i++)
//        {
////            NSLog(@"(%i, %i)", i, j);
//
//            float val = ( isFloat16 ) ?  bufferP_F16[i] :  bufferP_F32[i] ;
//            if (!isnan(val)) {
//                if (val>max) max = val;
//                if (val<min) min = val;
//            }
//
//            if (i < 100 && j < 100) {
//                if (isFloat16) {
//                    bufferP_F16[i] = 0;
//                } else {
//                    bufferP_F32[i] = 0;
//                }
//            }
//        }
//        if ( isFloat16 ) {
//            bufferP_F16 +=increment;
//        }  else {
//            bufferP_F32 +=increment;
//        }
//    }
//
//    CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
//
////    return pixelBuffer;
}
