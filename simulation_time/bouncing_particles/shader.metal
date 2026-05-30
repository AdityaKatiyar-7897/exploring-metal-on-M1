#include <metal_stdlib>
using namespace metal;

struct Particle
{
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

    if (particles[id].x < 0)
    {
        particles[id].x = 0;
        particles[id].vx *= -1;
    }

    if (particles[id].x > 39)
    {
        particles[id].x = 39;
        particles[id].vx *= -1;
    }

    if (particles[id].y < 0)
    {
        particles[id].y = 0;
        particles[id].vy *= -1;
    }

    if (particles[id].y > 14)
    {
        particles[id].y = 14;
        particles[id].vy *= -1;
    }
}
