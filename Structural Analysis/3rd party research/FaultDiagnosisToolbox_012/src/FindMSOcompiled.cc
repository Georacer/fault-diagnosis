#include "mex.h"
#include "timer.h"
#include "matrix.h"
extern "C" {
  #include "cs.h"
}
#include <iostream>
#include <cstring>
#include "StructuralAnalysisModel.h"
#include "MSOAlg.h"

class StructuralAnalysisModelMatlab : public StructuralAnalysisModel {
public:
  StructuralAnalysisModelMatlab( const mxArray *a );  
};

StructuralAnalysisModelMatlab::StructuralAnalysisModelMatlab( const mxArray *a )
{

  if( mxIsSparse(a) ) {
    cs *csm = (cs *)malloc( sizeof(cs) );
    csm->m = mxGetM(a);
    csm->n = mxGetN(a);
    csm->nzmax = mxGetNzmax(a);
    csm->nz = -1;
  
    csm->i = (csi *)malloc( csm->nzmax*sizeof(csi) );
    memcpy(csm->i,(csi *)mxGetIr(a),sizeof(csi)*csm->nzmax);

    csm->p = (csi *)malloc( (csm->n+1)*sizeof(csi) );
    memcpy(csm->p,(csi *)mxGetJc(a),sizeof(csi)*(csm->n+1));

    csm->x = (double *)malloc( (csm->nzmax)*sizeof(double) );
    memcpy(csm->x, (double *)mxGetPr(a), (csm->nzmax)*sizeof(double));

    this->sm = csm;
    InitEqList();
  } else {
    eqList.clear();
  }    
}


class MSOResultMatlab : public MSOResult {
public:
  void CreateOutputCellArray( mxArray **mxOutput );
};

void MSOResultMatlab::CreateOutputCellArray( mxArray **mxOutput )
{
  size_t dims[2] = {1, msos.size()};
  *mxOutput = mxCreateCellArray(2,dims);
  
  MSOList::iterator e;
  EqList::iterator eq;
  int k=0;
  for( e=msos.begin(); e!=msos.end(); e++ ) {
    mxArray *cell = mxCreateDoubleMatrix(1, e->size(),mxREAL);
    double *d = mxGetPr( cell );

    // Fill cellData
    int i=0;
    // e->sort();
    for( eq=e->begin(); eq!=e->end(); eq++ ) {
      d[i] = *eq+1; // Index in matlab starts with 1
      i++;
    }
    mxSetCell(*mxOutput, (mwIndex)k,cell );
    k++;
  }
}
  
void
mexFunction( int nlhs, mxArray *plhs[], 
	     int nrhs, const mxArray*prhs[] )
{
  int verb = 0;
  int countMode = 0;

  // FindMSOcompiled( X, mode, verb )
  if( nrhs > 3 ) {
    mexErrMsgTxt("Too many input arguments"); 
  }
  if( nrhs >= 3 ) {
    verb = (int)mxGetScalar( prhs[2] );
  }
  if( nrhs >= 2 ) {
    countMode = (int)mxGetScalar( prhs[1] );
  }
  
  if (nlhs>2) {
    mexErrMsgTxt("Too many output arguments."); 
  }

  if( !mxIsSparse( prhs[0] ) ) {
    mexErrMsgTxt("First argument must be a sparse matrix"); 
  }    

  if( verb && countMode) {
    mexPrintf("Starting MSO algorithm in counting mode\n");
    mexEvalString("drawnow;"); // Needed to flush output
  }

  StructuralAnalysisModelMatlab sm( prhs[0] );

  MSOAlg msoalg = sm;
  MSOResultMatlab msos;
  Timer t;

  if( countMode ) {
    msos.CountMode();
  }
  
  t.tic();
  msoalg.MSO( msos );
  t.toc();

  if( verb && !countMode ) {
    mexPrintf("|msos| = %d, computed in %f.2 msek\n", msos.Size(), t.elapsed());
  } else if (verb && countMode ) {
    mexPrintf("|msos| = %d, counted in %f.2 msek\n", msos.Size(), t.elapsed());
  }

  if( !countMode) {
    msos.CreateOutputCellArray( &plhs[0] );    
  } else {
    plhs[0] = mxCreateDoubleScalar( (double)msos.Size() );
  }
  if( nlhs > 1 ) {
    plhs[1] = mxCreateDoubleScalar( t.elapsed() );
  }
}
