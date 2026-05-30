#include <metal_stdlib>
using namespace metal;

kernel void add_one(
    device float *data [[buffer(0)]],
    uint id [[thread_position_in_grid]])
{
    data[id] = id;
}
