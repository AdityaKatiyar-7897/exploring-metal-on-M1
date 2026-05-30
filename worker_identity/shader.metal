#include <metal_stdlib>
using namespace metal;

kernel void worker_identity(
    device unsigned int *data [[buffer(0)]],
    uint id [[thread_position_in_grid]])
{
    if(id == 0)
        return;

    data[id] = data[id - 1];
}
