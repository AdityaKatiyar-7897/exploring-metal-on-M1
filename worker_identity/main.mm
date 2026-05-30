#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

#include <iostream>

int main()
{
    @autoreleasepool
    {
        id<MTLDevice> device = MTLCreateSystemDefaultDevice();

        NSError *error = nil;

        NSString *source =
            [NSString stringWithContentsOfFile:@"shader.metal"
                                      encoding:NSUTF8StringEncoding
                                         error:&error];

        id<MTLLibrary> library =
            [device newLibraryWithSource:source
                                 options:nil
                                   error:&error];

        id<MTLFunction> function =
            [library newFunctionWithName:@"worker_identity"];

        id<MTLComputePipelineState> pipeline =
            [device newComputePipelineStateWithFunction:function
                                                  error:&error];

        const int count = 10;

        id<MTLBuffer> buffer =
            [device newBufferWithLength:
                count * sizeof(unsigned int)
                options:MTLResourceStorageModeShared];

        unsigned int *data =
            (unsigned int *)[buffer contents];

        for(int i = 0; i < count; i++)
        {
            data[i] = 0;
        }

        std::cout << "Before:\n";

        for(int i = 0; i < count; i++)
        {
            std::cout << data[i] << " ";
        }

        std::cout << "\n";

        id<MTLCommandQueue> queue =
            [device newCommandQueue];

        id<MTLCommandBuffer> commandBuffer =
            [queue commandBuffer];

        id<MTLComputeCommandEncoder> encoder =
            [commandBuffer computeCommandEncoder];

        [encoder setComputePipelineState:pipeline];
        [encoder setBuffer:buffer offset:0 atIndex:0];

        MTLSize gridSize =
            MTLSizeMake(count, 1, 1);

        MTLSize threadgroupSize =
            MTLSizeMake(1, 1, 1);

        [encoder dispatchThreads:gridSize
          threadsPerThreadgroup:threadgroupSize];

        [encoder endEncoding];

        [commandBuffer commit];
        [commandBuffer waitUntilCompleted];

        std::cout << "After:\n";

        for(int i = 0; i < count; i++)
        {
            std::cout << data[i] << " ";
        }

        std::cout << "\n";
    }

    return 0;
}
