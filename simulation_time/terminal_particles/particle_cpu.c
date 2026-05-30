#include <stdio.h>

typedef struct {
    float x;
    float y;
    float vx;
    float vy;
} Particle;

int main(void)
{
    Particle p = {
        .x = 10,
        .y = 5,
        .vx = 1,
        .vy = 0
    };

    for(int step = 0; step < 10; step++)
    {
        printf("step %d : (%.0f, %.0f)\n",
               step,
               p.x,
               p.y);

        p.x += p.vx;
        p.y += p.vy;
    }

    return 0;
}
