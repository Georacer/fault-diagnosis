//
//  msoalg.cpp
//  MSO
//
//  Created by Erik Frisk on 10/09/15.
//  Copyright (c) 2015 Linköping University. All rights reserved.
//

#include "MSOAlg.h"

void
MSOResult::AddMSO( list<EqList>::iterator start, list<EqList>::iterator stop )
{
  if( mode==0 ) {
    list<EqList>::iterator it;
    
    msos.push_back(EqList()); // Push an empty list to the end of the MSO list
    
    // Push all elements in eq to the last element in the MSO list
    for( it=start; it!= stop; it++ ) {
      copy(it->begin(), it->end(), inserter(msos.back(), msos.back().begin()));
    }
  } else {
    numMSOs++;
    if( (numMSOs % verbN) == 0 ) {
      std::cerr << numMSOs << " MSOs found" << std::endl;
    }
  }
}

#ifdef MATIO
int
MSOResult::ExportToMatlab( string s, string varname )
{
  if( mode==1 ) {
    std::cout << "MSO algorithm in counting mode, nothing to export." << std::endl;
    return( 0 );
  }
  mat_t *mat;

  mat = Mat_Open(s.c_str(),MAT_ACC_RDWR);
  if( !mat ) {
    std::cerr << "Unable to create file " << s << ", exiting" << std::endl;
    return( 0 );
  }
  
  // 3. Create equation description object and write to file
  matvar_t *matvar;
  unsigned long dims[2];
  matvar_t** eq_cell;
  mat_int32_t* cellData;
  
  int k,i;
  eq_cell = new matvar_t*[msos.size()];
  MSOList::iterator e;
  EqList::iterator eq;
  k=0;
  for( e=msos.begin(); e!=msos.end(); e++ ) {
    cellData = new mat_int32_t[e->size()];
    // Fill cellData
    i=0;
    for( eq=e->begin(); eq!=e->end(); eq++ ) {
      cellData[i] = *eq+1; // Index in matlab starts with 1
      i++;
    }
    dims[0] = 1; dims[1] = e->size();
    eq_cell[k] = Mat_VarCreate("data",MAT_C_INT32,MAT_T_INT32,2,dims,cellData,0);
    delete [] cellData;
    k++;
  }
  dims[0] = 1; dims[1] = msos.size();
  matvar = Mat_VarCreate(varname.c_str(),MAT_C_CELL,MAT_T_CELL,2,
                         dims,eq_cell,0);
  Mat_VarWrite(mat,matvar,MAT_COMPRESSION_NONE);
  delete [] eq_cell;
  Mat_VarFree(matvar);
  
  Mat_Close(mat);
  return( 1 );
}
#endif

MSOAlg&
MSOAlg::operator=( const SparseMatrix& x )
{
  SM=StructuralAnalysisModel(x);
  InitR();
  return *this;
}

MSOAlg&
MSOAlg::operator=( const StructuralAnalysisModel& x )
{
  SM=x;
  InitR();
  return *this;
}


void
MSOAlg::InitR()
{
  R.clear();
  for(int e=0; e < SM.NRows(); e++ ) {
    R.push_back( e );
  }
}

void
MSOAlg::LumpModel( )
{
  EqList Rl;
  
  // Perform lumping
  EqClass eqClass;
  int e;
  while( !R.empty()  ) {
    e = R.front();
    SM.GetEqClass( e, eqClass );
    if( eqClass.eq.size() > 1 ) {
      SM.LumpEqClass( eqClass ); // Lump structure
      
      if( SubsetQ(R, eqClass.eq) ) {
        // eqClass subset of R, allowed to remove also in lumped
        // structure, add e to list Rl
        Rl.push_back( e );
      }
      
      // Remove elements in equation class from R
      SetDiff(R, eqClass.eq);
      
      // Update indices in R and Rl after lumping operation
      UpdateIndexListAfterLump(R, eqClass.eq);
      UpdateIndexListAfterLump(Rl, eqClass.eq);
    } else {
      if( SubsetQ(R, e) ) {
        // No lumping, simple update of Rl
        Rl.push_back( e );
        
        // Remove first element in R
        R.erase(R.begin());
      }
    }
  }
  
  // Set R object to the lumped R
  R = Rl;
}

bool
MSOAlg::SubsetQ(const EqList& R1, int e )
{
  EqList::const_iterator it1 = R1.begin();
  bool ret = false;
  while( !ret && it1!=R1.end() ) {
    if( *it1==e ) {
      ret = true;
    }
    it1++;
  }
  return( ret );
}

bool
MSOAlg::SubsetQ(const EqList& R1, const EqList& R2)
{
  // Returns true if R2 is a subset of R1
  
  EqList::const_iterator it1 = R1.begin(), it2=R2.begin();
  bool ret = true;
  while( ret && it1!=R1.end() && it2!=R2.end() ) {
    if( *it1<*it2 ) {
      it1++;
    } else if( *it1==*it2) {
      it1++;
      it2++;
    } else {
      ret = false;
    }
  }
  return( ret );
}

void
MSOAlg::SetDiff(EqList& R1, EqList R2)
{
  EqList::iterator it;
  
  it = set_difference(R1.begin(), R1.end(),
                      R2.begin(), R2.end(),
                      R1.begin());
  R1.erase(it,R1.end());
}

void
MSOAlg::UpdateIndexListAfterLump(EqList& R, EqList& lEq)
{
  EqList::iterator it, it2;
  int nRemEq;
  
  for( it=R.begin(); it != R.end(); it++ ) {
    // Substract index with the number of removed equations before
    // the current element in R
    nRemEq=0;
    it2=lEq.begin(); it2++;
    for( ; it2!=lEq.end(); it2++ ) {
      if( *it2 < *it ) {
        nRemEq++;
      }
    }
    *it = *it-nRemEq;
  }
}

void
MSOAlg::RemoveNextEquation( )
{
  // Remove row corresponding to index e
  SM.RemoveRow( R.front() );
  
  R.pop_front();
  
  // Update list of removal indices
  for( EqList::iterator it=R.begin(); it!=R.end(); it++ ) {
    *it = *it-1;
  }
}

void
MSOAlg::FindMSO( MSOResult& msos )
{
  int fi = SM.NRows()-SM.NCols();
  if( fi==1 ) {
    msos.AddMSO(SM);
  } else {
    LumpModel( ); // Lump model
    MSOAlg Mred;
    while( !R.empty() ) {
      // Create a copy of current state (SM, R) and remove row
      // corresponding to first element in R
      Mred = *this;
      Mred.RemoveNextEquation();
      
      // Remove first element in R
      R.pop_front();
      
      // Call FindMSO recursively
      Mred.FindMSO(msos);
    }
  }
}

void
MSOAlg::MSO( MSOResult& msos )
{
  int nEq = SM.NRows();
  SM.Plus();
  if( nEq!=SM.NRows() ) {
    // Reinitialize list of removable equations
    InitR();
  }
  msos.Clear();
  FindMSO( msos );
}

bool
MSOAlg::CausalPSO()
{
  //  SM.Print();
  // Remove non-causal elements.
  SM.DropNonCausal();
  
  // Compute rank of matrix with only causal elements
  int r=SM.SRank();
  
  // cout << "r=" << r << ", (m,n)=(" << SM.NRows() << ", " << SM.NCols() << ")" << endl;
  
  // MSO is causal if rank equals number of columns
  return( r==SM.NCols() );
}

void
MSOResult::RemoveNonCausal( SparseMatrix& m )
{
  SparseMatrix cm;
  int r, cr;
  for( MSOList::iterator mso=msos.begin(); mso!=msos.end();  ) {
    cm=m;
    cm.GetRows(*mso);
    r = cm.SRank();
    cm.DropNonCausal();
    cr = cm.SRank();
    if( cr<r ) {
      mso = msos.erase( mso );
    } else {
      mso++;
    }
  }
}
