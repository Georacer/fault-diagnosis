#ifndef _HITTINGSET_H
#define _HITTINGSET_H
#include <list>
#include <iostream>

using namespace std;

template<class T> class HittingSet {
private:
  list<list<T> > mhs;
  int cutoff;
  bool IsValid(const list<T>& hs, const list<T>& s);
  void ExtendHS( const list<T>& s, const list<T>& x, list<list<T> >& newhs);
public:
  HittingSet() : cutoff(-1) { Clear(); };
  ~HittingSet() {};

  void CutOffMode(int n) { cutoff=n; };
  void Clear();
  void AddSet( list<T>& x );
  int Size() { return(mhs.size()); };
  
  typename list<list<T> >::iterator begin() { return( mhs.begin() ); };
  typename list<list<T> >::iterator end() { return( mhs.end() ); };  
};

template<class T>
class NonMinimal {
private:
  typename list<list<T> >::const_iterator itStart, itStop;
public:
  NonMinimal( list<list<T> >& x) { itStart=x.begin(); itStop=x.end(); };
  bool operator()(list<T>& s);
};

#include "hittingset.tcc"
#endif
