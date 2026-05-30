#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

#include <iostream>
#include <cmath>
#include <unistd.h>
#include <cstdlib>

struct Particle
{
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
        const int N = 50;

        Particle particles[N];

        srand(42);

        for(int i = 0; i < N; i++)
        {
            particles[i].x = rand() % W;
            particles[i].y = rand() % H;

            particles[i].vx = (rand() % 3) - 1;
            particles[i].vy = (rand() % 3) - 1;

            if(particles[i].vx == 0 &&
               particles[i].vy == 0)
            {
                particles[i].vx = 1;
            }
        }

        id<MTLDevice> device =
            MTLCreateSystemDefaultDevice();

        NSError *error = nil;

        NSString *source =
            [NSString stringWithContentsOfFile:@"shader.metal"
                                      encoding:NSUTF8StringEncoding
                                         error:&error];

        if(!source)
        {
            std::cout << "Failed to load shader.metal\n";
            return 1;
        }

        id<MTLLibrary> library =
            [device newLibraryWithSource:source
                                 options:nil
                                   error:&error];

        if(!library)
        {
            std::cout
                << [[error localizedDescription]
                    UTF8String]
                << "\n";

            return 1;
        }

        id<MTLFunction> function =
            [library newFunctionWithName:
                @"update_particles"];

        id<MTLComputePipelineState> pipeline =
            [device newComputePipelineStateWithFunction:
                function
                error:&error];

        id<MTLBuffer> buffer =
            [device newBufferWithBytes:
                particles
                length:sizeof(particles)
                options:
                MTLResourceStorageModeShared];

        id<MTLCommandQueue> queue =
            [device newCommandQueue];

        for(int frame = 0; frame < 500; frame++)
        {
            id<MTLCommandBuffer> commandBuffer =
                [queue commandBuffer];

            id<MTLComputeCommandEncoder> encoder =
                [commandBuffer computeCommandEncoder];

            [encoder setComputePipelineState:
                pipeline];

            [encoder setBuffer:
                buffer
                offset:0
                atIndex:0];

            [encoder dispatchThreads:
                MTLSizeMake(N,1,1)
                threadsPerThreadgroup:
                MTLSizeMake(1,1,1)];

            [encoder endEncoding];

            [commandBuffer commit];
            [commandBuffer waitUntilCompleted];

            Particle *out =
                (Particle *)[buffer contents];

            char screen[H][W];

            for(int y = 0; y < H; y++)
            {
                for(int x = 0; x < W; x++)
                {
                    screen[y][x] = '.';
                }
            }

            for(int i = 0; i < N; i++)
            {
                int x =
                    (int)round(out[i].x);

                int y =
                    (int)round(out[i].y);

                if(x >= 0 &&
                   x < W &&
                   y >= 0 &&
                   y < H)
                {
                    screen[y][x] = '*';
                }
            }

            std::cout
                << "\033[2J\033[H";

            for(int y = 0; y < H; y++)
            {
                for(int x = 0; x < W; x++)
                {
                    std::cout
                        << screen[y][x];
                }

                std::cout << "\n";
            }

            usleep(30000);
        }
    }

    return 0;
}
