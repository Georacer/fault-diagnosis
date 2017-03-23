//#include "hittingset.h"
#include <iostream>
#include <algorithm>

using namespace std;

template<class T> void
HittingSet<T>::Clear()
{
  mhs.clear();
  list<T> el;
  mhs.push_front( el ); // Add empty hitting set
}

template<class T> void 
HittingSet<T>::AddSet(list<T>& x)
{
  list<list<T> > newhs;
  
  // Remove invalidated hitting sets, extend them and insert in list newhs
  for( typename list<list<T> >::iterator it=mhs.begin(); it!= mhs.end();  ) {
    if( !IsValid(*it, x) ) {
      ExtendHS( *it, x, newhs);
      it = mhs.erase(it);
    } else {
      it++;
    }
  }
  // Remove non-minimal elements in newhs
  typename list<list<T> >::iterator remIt;
  remIt = remove_if(newhs.begin(), newhs.end(), NonMinimal<T>(mhs));

  // Add minimal hitting sets in newhs to mhs
  mhs.splice( mhs.end(), newhs, newhs.begin(), remIt );
}

template<class T> void
HittingSet<T>::ExtendHS( const list<T>& s, const list<T>& x, list<list<T> >& newhs)
{
  // Extend s wrt. to x and put in newhs. In case of cutoff mode, do
  // not add if length of new mhs candidate is longer than cutoff
  for( typename list<T>::const_iterator it=x.begin(); it!= x.end(); it++ ) {
    if( cutoff < 0 || (int)s.size() < cutoff ) {
      newhs.push_front( s ); // Add s
      newhs.front().push_back( *it ); // Add one element from x
      newhs.front().sort(); // Make sure the set is sorted
    }
  }
}

template<class T> bool 
HittingSet<T>::IsValid(const list<T>& hs, const list<T>& s)
{
  // Is hs still a hitting-set when set s is added? 
  // Return true if yes, no othwerwise.

  // return true if hs has a non-empty intersection with s

  // currently, implementation do not assume sorted lists. Perhaps a
  // more efficient implementation can be done utilizing this fact.
  return( find_first_of(hs.begin(), hs.end(), 
			s.begin(), s.end())==hs.end() 
	  ? false : true );
}

template<class T> bool
NonMinimal<T>::operator()(list<T>& s) 
{
  // Return true if s is a superset of any element in
  // NonMinimal::[itStart,itStop[
  bool ret=false;

  for( typename list<list<T> >::const_iterator it=itStart; it!=itStop; it++ ) {
    // Test if s is a superset of *it, if so set ret to true and exit
    if( includes( s.begin(), s.end(), it->begin(), it->end() ) ) {
      ret=true;
      break;
    }
  }

  return( ret );
}
