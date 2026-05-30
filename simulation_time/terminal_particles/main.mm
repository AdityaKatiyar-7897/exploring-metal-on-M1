#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

#include <iostream>
#include <cmath>

struct Particle {
    float x;
    float y;
    float vx;
    float vy;
};

int main()
{
    @autoreleasepool
    {
        const int W = 40;
        const int H = 15;
        const int N = 8;

        Particle particles[N] = {
            {  3,  2,  1,  0 },
            { 10,  4,  1,  0 },
            { 20,  7, -1,  0 },
            { 30, 10, -1,  0 },
            {  5, 12,  0, -1 },
            { 15,  3,  0,  1 },
            { 25,  8,  1, -1 },
            { 35, 13, -1, -1 },
        };

        id<MTLDevice> device = MTLCreateSystemDefaultDevice();
        NSError *error = nil;

        NSString *source =
            [NSString stringWithContentsOfFile:@"shader.metal"
                                      encoding:NSUTF8StringEncoding
                                         error:&error];

        id<MTLLibrary> library =
            [device newLibraryWithSource:source options:nil error:&error];

        id<MTLFunction> function =
            [library newFunctionWithName:@"update_particles"];

        id<MTLComputePipelineState> pipeline =
            [device newComputePipelineStateWithFunction:function error:&error];

        id<MTLBuffer> buffer =
            [device newBufferWithBytes:particles
                                length:sizeof(particles)
                               options:MTLResourceStorageModeShared];

        id<MTLCommandQueue> queue = [device newCommandQueue];
        id<MTLCommandBuffer> commandBuffer = [queue commandBuffer];
        id<MTLComputeCommandEncoder> encoder = [commandBuffer computeCommandEncoder];

        [encoder setComputePipelineState:pipeline];
        [encoder setBuffer:buffer offset:0 atIndex:0];

        [encoder dispatchThreads:MTLSizeMake(N, 1, 1)
           threadsPerThreadgroup:MTLSizeMake(1, 1, 1)];

        [encoder endEncoding];
        [commandBuffer commit];
        [commandBuffer waitUntilCompleted];

        Particle *out = (Particle *)[buffer contents];

        char screen[H][W];

        for(int y = 0; y < H; y++)
            for(int x = 0; x < W; x++)
                screen[y][x] = '.';

        for(int i = 0; i < N; i++)
        {
            int x = (int)round(out[i].x);
            int y = (int)round(out[i].y);

            if(x >= 0 && x < W && y >= 0 && y < H)
                screen[y][x] = '*';
        }

        for(int y = 0; y < H; y++)
        {
            for(int x = 0; x < W; x++)
                std::cout << screen[y][x];

            std::cout << "\n";
        }
    }

    return 0;
}
