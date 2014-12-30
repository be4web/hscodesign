#include "fft.h"

#include "fft_tabs.h"

#include <system.h>

#define SQRT1_2 23170 // (1.0 / sqrt(2)) * (1 << 15)

#define BF(x, y, a, b) { \
    x = (a - b) >> 1; \
    y = (a + b) >> 1; \
}

/*
#define CMUL(dre, dim, are, aim, bre, bim) {\
    dre = (are * bre - aim * bim) >> 15;    \
    dim = (are * bim + aim * bre) >> 15;    \
}
*/

#define CMUL(dre, dim, are, aim, bre, bim) {\
    asm("nop"); \
    asm("nop"); \
    dre = ALT_CI_SHIFT_R(are * bre - aim * bim, 15);    \
    asm("nop"); \
    asm("nop"); \
    dim = ALT_CI_SHIFT_R(are * bim + aim * bre, 15);    \
    asm("nop"); \
    asm("nop"); \
}

#define BUTTERFLIES(a0,a1,a2,a3) {\
    BF(t3, t5, t5, t1);\
    BF(a2.re, a0.re, a0.re, t5);\
    BF(a3.im, a1.im, a1.im, t3);\
    BF(t4, t6, t2, t6);\
    BF(a3.re, a1.re, a1.re, t4);\
    BF(a2.im, a0.im, a0.im, t6);\
}

#define TRANSFORM(a0,a1,a2,a3,wre,wim) {\
    CMUL(t1, t2, a2.re, a2.im, wre, -wim);\
    CMUL(t5, t6, a3.re, a3.im, wre, wim);\
    BUTTERFLIES(a0,a1,a2,a3)\
}

#define TRANSFORM_ZERO(a0,a1,a2,a3) {\
    t1 = a2.re;\
    t2 = a2.im;\
    t5 = a3.re;\
    t6 = a3.im;\
    BUTTERFLIES(a0,a1,a2,a3)\
}

static inline void pass(fft_complex *z, const int16_t *wre, unsigned int n)
{
    int32_t t1, t2, t3, t4, t5, t6;
    int o1 = 2*n;
    int o2 = 4*n;
    int o3 = 6*n;
    const int16_t *wim = wre+o1;
    n--;

    TRANSFORM_ZERO(z[0],z[o1],z[o2],z[o3]);
    TRANSFORM(z[1],z[o1+1],z[o2+1],z[o3+1],wre[1],wim[-1]);

    do {
        z += 2;
        wre += 2;
        wim -= 2;
        TRANSFORM(z[0],z[o1],z[o2],z[o3],wre[0],wim[0]);
        TRANSFORM(z[1],z[o1+1],z[o2+1],z[o3+1],wre[1],wim[-1]);
    } while(--n);
}

static inline void fft_4(fft_complex *z)
{
    int32_t t1, t2, t3, t4, t5, t6, t7, t8;

    BF(t3, t1, z[0].re, z[1].re);
    BF(t8, t6, z[3].re, z[2].re);
    BF(z[2].re, z[0].re, t1, t6);
    BF(t4, t2, z[0].im, z[1].im);
    BF(t7, t5, z[2].im, z[3].im);
    BF(z[3].im, z[1].im, t4, t8);
    BF(z[3].re, z[1].re, t3, t7);
    BF(z[2].im, z[0].im, t2, t5);
}

static inline void fft_8(fft_complex *z)
{
    int32_t t1, t2, t3, t4, t5, t6;

    fft_4(z);

    BF(t1, z[5].re, z[4].re, -z[5].re);
    BF(t2, z[5].im, z[4].im, -z[5].im);
    BF(t5, z[7].re, z[6].re, -z[7].re);
    BF(t6, z[7].im, z[6].im, -z[7].im);

    BUTTERFLIES(z[0],z[2],z[4],z[6]);
    TRANSFORM(z[1],z[3],z[5],z[7],SQRT1_2,SQRT1_2);
}

#define DECL_FFT(n, n2, n4)         \
FFT_STATIC_INLINE void fft_##n(fft_complex *z)        \
{                                   \
    fft_##n2(z);                    \
    fft_##n4(z + n4 * 2);           \
    fft_##n4(z + n4 * 3);           \
    pass(z, cos_##n, n4/2);         \
}

#define FFT_STATIC_INLINE static inline
DECL_FFT(16,8,4)
DECL_FFT(32,16,8)
DECL_FFT(64,32,16)
DECL_FFT(128,64,32)
DECL_FFT(256,128,64)
DECL_FFT(512,256,128)

#undef FFT_STATIC_INLINE
#define FFT_STATIC_INLINE
DECL_FFT(1024,512,256)
DECL_FFT(2048,1024,512)
DECL_FFT(4096,2048,1024)

FFT_PERM(4096)
{
    fft_complex *z;
    int i, j;

    in_prev += len - 2048;

    for (i = 0; i < 2048; i++) {
        z = &out[bit_rev_4096[i]];
        //z->re = (in_prev[i] * fft_mask_4096[i]) >> 16;
        z->re = (in_prev[i] * i) >> 11;
        z->im = 0;
    }

    for (j = 0; i < 2048; i++, j++) {
        z = &out[bit_rev_4096[i]];
        //z->re = (in_post[j] * fft_mask_4096[i]) >> 16;
        z->re = (in_post[j] * (4096 - i)) >> 11;
        z->im = 0;
    }
}