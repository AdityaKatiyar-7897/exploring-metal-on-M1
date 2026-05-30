#include <metal_stdlib>
using namespace metal;

struct Particle {
    float x;
    float y;
    float vx;
    float vy;
};

kernel void update_particles(
    device Particle *particles [[buffer(0)]],
    uint id [[thread_position_in_grid]])
{
    particles[id].x += particles[id].vx;
    particles[id].y += particles[id].vy;
}
