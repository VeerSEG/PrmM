#ifndef __CPU__
    #error "__CPU__ Undefined"
#endif
#ifndef __SFRFILE__
#define __SFRFILE__(CPU) "sfr/reg" #CPU ".sfr"
#endif
#ifndef __INT_BIT__
#define __INT_BIT__ 32
#endif
#ifndef __LONG_BIT__
// unknown reason, if not include the Long Bit directly, it will not work for GCC.
#define __LONG_BIT__ 32
#endif
#ifndef __SHORT_BIT__
#define __SHORT_BIT__ 16
#endif