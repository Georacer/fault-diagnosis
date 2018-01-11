#include <math.h>
#include "mex.h"
#include "matrix.h"
#include <list>
#include "hittingset.h"
#include "timer.h"

using namespace std;

class ConflictSet {
private:
  list<list<int> > confSet;
public:
  ConflictSet( const mxArray* mxData );
  ~ConflictSet( ) {};
  int size( ) { return( confSet.size() ); };
  list<list<int> >::iterator begin() { return( confSet.begin() ); };
  list<list<int> >::iterator end() { return( confSet.end() ); };
};

ConflictSet::ConflictSet( const mxArray* mxData )
{
  // Get size of set of conflicts
  mwSize numdim;
  const mwSize *dims;
  numdim = mxGetNumberOfDimensions(mxData);
  dims = mxGetDimensions(mxData);
  if( numdim!=2 ) {
    mexErrMsgTxt( "Inputs must be a one-dimensional cell-array" );
  }  
  int n = max(*dims,*(dims+1));
  
  // Iterate over all conflict sets and place them in confSet
  mxArray *mxConf;
  int cn;
  double *datap, *dp;
  list<int> conf;
  confSet.clear();
  for( int k=0; k <n; k++ ) {
    mxConf = mxGetCell(mxData, k);
    dims = mxGetDimensions(mxConf);
    cn = max(*dims,*(dims+1));
    datap = mxGetPr( mxConf );
    conf.clear();
    for( dp=datap; dp!= datap+cn; dp++ ) {
      conf.push_back( (int)*dp);
    }
    confSet.push_back( conf );
  }
}

void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
{ 
  // Verify number of input arguments
  if (nrhs < 1) { 
    mexErrMsgTxt("One input arguments required."); 
  } else if (nlhs > 2) {
    mexErrMsgTxt("Too many output arguments."); 
  }   
  // Verify that input is a cell-array
  if( !mxIsCell(prhs[0]) ) {
    mexErrMsgTxt("Input must be a cell-array.");
  }

  // In case a cut-off argument is given, configure hitting-set algorithm
  HittingSet<int> hs;
  if( nrhs>1 ) {
    double *cutOffP = mxGetPr( prhs[1] );
    hs.CutOffMode((int)(*cutOffP));
  }

  // Read input sets from Matlab
  ConflictSet confList( prhs[0] );
  
  // Run minimal hitting-set algorithm and time execution
  Timer t;
  t.tic();  
  for( list<list<int> >::iterator it = confList.begin(); it!= confList.end(); it ++ ) {
    hs.AddSet( *it );
  }
  t.toc();

  // Create output cell array from hitting set results
  plhs[0] = mxCreateCellMatrix(1,(mwSize)hs.Size());
  mxArray* mxDoubleArray;
  double* dataPtr=NULL;
  int i=0;
  int l;
  for( list<list<int> >::iterator it=hs.begin(); it != hs.end(); it++ ) {
    mxDoubleArray = mxCreateNumericMatrix(1, it->size(), mxDOUBLE_CLASS, mxREAL); 
    dataPtr = (double *)mxGetPr( mxDoubleArray );
    // copy( it->begin(), it->end(), dataPtr );
    l=0;
    for( list<int>::iterator it2=it->begin(); it2!=it->end(); it2++ ) {
      dataPtr[l++] = *it2;      
    }
    mxSetCell(plhs[0], i++, mxDoubleArray);    
  }

  plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL); 
  double* timeP = mxGetPr(plhs[1]);
  *timeP = t.elapsed();
}
