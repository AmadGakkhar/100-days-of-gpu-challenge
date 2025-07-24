#include <stdio.h>
#include <cuda.h>


__global__ void vecadd_kernel(float *x, float *y, float *z, int n)
{

    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n)
    {
        z[i] = x[i] + y[i];
    }
}


void d_vecadd(int n, float *x, float *y, float *z)
{


    float *d_x, *d_y, *d_z;
    cudaMalloc((void **)&d_x, n * sizeof(float));
    cudaMalloc((void **)&d_y, n * sizeof(float));
    cudaMalloc((void **)&d_z, n * sizeof(float));

    cudaMemcpy(d_x, x, n * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_y, y, n * sizeof(float), cudaMemcpyHostToDevice);
    vecadd_kernel<<<ceil(n/256.0), 256>>>(d_x, d_y, d_z, n);
    cudaDeviceSynchronize();
    cudaMemcpy(z, d_z, n * sizeof(float), cudaMemcpyDeviceToHost);

    
    cudaFree(d_x);
    cudaFree(d_y);
    cudaFree(d_z);


}


void vecadd(int n, float *x, float *y, float *z)
{
   

    for (int i = 0; i < n; i++)
    {
        z[i] = x[i] + y[i];
    }

}

int main()
{
    cudaDeviceSynchronize();
    Timer timer;

    int n = 1000;
    float x[n], y[n], z[n], z_d[n];






    // Initialize x and y
    for (int i = 0; i < n; i++)
    {
        x[i] = i * 1.0f;
        y[i] = (n - i) * 1.0f;
    }

    vecadd(n, x, y, z);

    d_vecadd(n, x, y, z_d);
  




    for (int i = 0; i < 10; i++)
    {
        printf("z[%d] = %f\n", i, z[i]);
    }


    return 0;
}
