#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

#include <iostream>

int main()
{
    @autoreleasepool
    {
        id<MTLDevice> device = MTLCreateSystemDefaultDevice();

        if (!device)
        {
            std::cout << "No Metal device found\n";
            return 1;
        }

        NSError *error = nil;

        NSString *source =
            [NSString stringWithContentsOfFile:@"shader.metal"
                                      encoding:NSUTF8StringEncoding
                                         error:&error];

        if (!source)
        {
            std::cout << "Failed to load shader.metal\n";
            return 1;
        }

        id<MTLLibrary> library =
            [device newLibraryWithSource:source
                                 options:nil
                                   error:&error];

        if (!library)
        {
            std::cout << [[error localizedDescription] UTF8String] << "\n";
            return 1;
        }

        id<MTLFunction> function =
            [library newFunctionWithName:@"add_one"];

        id<MTLComputePipelineState> pipeline =
            [device newComputePipelineStateWithFunction:function
                                                  error:&error];

        const int count = 10;

        id<MTLBuffer> buffer =
            [device newBufferWithLength:count * sizeof(float)
                                options:MTLResourceStorageModeShared];

        float *data = (float *)[buffer contents];

        for (int i = 0; i < count; i++)
            data[i] = i;

        std::cout << "Before:\n";

        for (int i = 0; i < count; i++)
            std::cout << data[i] << " ";

        std::cout << "\n";

        id<MTLCommandQueue> queue = [device newCommandQueue];

        id<MTLCommandBuffer> commandBuffer =
            [queue commandBuffer];

        id<MTLComputeCommandEncoder> encoder =
            [commandBuffer computeCommandEncoder];

        [encoder setComputePipelineState:pipeline];
        [encoder setBuffer:buffer offset:0 atIndex:0];

        MTLSize gridSize = MTLSizeMake(count, 1, 1);
        MTLSize threadgroupSize = MTLSizeMake(1, 1, 1);

        [encoder dispatchThreads:gridSize
          threadsPerThreadgroup:threadgroupSize];

        [encoder endEncoding];

        [commandBuffer commit];
        [commandBuffer waitUntilCompleted];

        std::cout << "After:\n";

        for (int i = 0; i < count; i++)
            std::cout << data[i] << " ";

        std::cout << "\n";
    }

    return 0;
}
