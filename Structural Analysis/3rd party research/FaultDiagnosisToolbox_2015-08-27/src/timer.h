#ifndef _TIMER_H
#define _TIMER_H
#ifdef WIN32
#include <ctime>
#else
#include <sys/resource.h>
#endif

class Timer {
  #ifdef WIN32
  clock_t tictime;
  clock_t toctime;
  #else
  struct rusage ticusage;
  struct rusage tocusage;

  // Subtract two values of type struct timeval.
  // Taken from The GNU C Library Manual at
  // http://www.gnu.org/software/libtool/manual/libc/Elapsed-Time.html
  int timeval_subtract(struct timeval *result,
		       struct timeval *x, struct timeval *y)
  {
    /* Perform the carry for the later subtraction by updating y. */
    if (x->tv_usec < y->tv_usec) {
      int nsec = (y->tv_usec - x->tv_usec) / 1000000 + 1;
      y->tv_usec -= 1000000 * nsec;
      y->tv_sec += nsec;
    }
    if (x->tv_usec - y->tv_usec > 1000000) {
      int nsec = (x->tv_usec - y->tv_usec) / 1000000;
      y->tv_usec += 1000000 * nsec;
      y->tv_sec -= nsec;
    }
    
    /* Compute the time remaining to wait.
       tv_usec is certainly positive. */
    result->tv_sec = x->tv_sec - y->tv_sec;
    result->tv_usec = x->tv_usec - y->tv_usec;
    
    /* Return 1 if result is negative. */
    return x->tv_sec < y->tv_sec;
  };

  #endif
public:
  Timer() { tic(); };
  ~Timer( ) { };
  #ifdef WIN32  
  void tic() { tictime=clock(); toctime=0; };
  void toc() { toctime=clock(); };
  double elapsed() 
  { 
    if( toctime>0 ) { 
      return ((double)((double)(toctime-tictime)*1000/(double)CLOCKS_PER_SEC));

    } else {
      return(-1);
    }
  };
  #else
  void tic() { getrusage(RUSAGE_SELF,&ticusage); tocusage=ticusage; };
  void toc() { getrusage(RUSAGE_SELF,&tocusage); };
  double elapsed() 
  { 
    struct timeval diffs;
    struct timeval diffu;

    timeval_subtract(&diffu,&tocusage.ru_utime,&ticusage.ru_utime);
    timeval_subtract(&diffs,&tocusage.ru_stime,&ticusage.ru_stime);
    double deltasT=1000*(diffs.tv_sec+1e-6*diffs.tv_usec);
    double deltauT=1000*(diffu.tv_sec+1e-6*diffu.tv_usec);

    double deltaT = deltauT;//+deltasT;
    if( deltauT+deltasT>0 ) { 
      return deltaT;
    } else {
      return -1.0;
    }
  };
  #endif
};
#endif
