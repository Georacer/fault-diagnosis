//
//  StructuralAnalysisModel.cc
//  MSO
//
//  Created by Erik Frisk on 24/08/15.
//  Copyright (c) 2015 Linköping University. All rights reserved.
//

#include "StructuralAnalysisModel.h"

#pragma mark Constructors, initializations
void
StructuralAnalysisModel::InitEqList( )
{
  EqList a;
  eqList.clear();
  for( int k=0; k < sm->m; k++ ) {
    a.clear();
    a.push_back(k);
    eqList.push_back(a);
  }
}

StructuralAnalysisModel&
StructuralAnalysisModel::operator=( const SparseMatrix& x )
{
  SparseMatrix::operator=(x);
  InitEqList();
  return *this;
}

#pragma mark M+ operation
int
StructuralAnalysisModel::Redundancy()
{
  csd* D;
  
  D = cs_dmperm(sm, 1);
  if (!D) return(-1);
  
  csi *r, *s, nb;
  r = D->r;
  s = D->s;
  nb = D->nb;
  
  long red=(r[nb]-r[nb-1])-(s[nb]-s[nb-1]);
  
  // Free allocated space
  cs_dfree(D);
  
  return( (int)red );
}

void
StructuralAnalysisModel::Plus( )
{
  list<int> rows, cols;
  
  int r=Plus( rows, cols );
  rows.sort();
  if( r>0 ) {
    Get(rows, cols);
  }
}

int
StructuralAnalysisModel::Plus( list<int>& rows, list<int>& cols )
{
  csd* D;
  csi *p, *q, *r, *s;
  long nb,k;
  long nRows, nCols;
  
  D = cs_dmperm(sm, 1);
  if (!D) return(-1);
  
  p = D->p;
  q = D->q;
  r = D->r;
  s = D->s;
  nb = D->nb;
  
  long redundancy=(r[nb]-r[nb-1])-(s[nb]-s[nb-1]);
  if( redundancy>0 ) {
    nRows = r[nb]-r[nb-1];
    nCols = s[nb]-s[nb-1];
    
    for( k=0; k < nRows; k++ ) {
      rows.push_back((int)p[r[nb-1]+k]);
    }
    for( k=0; k < nCols; k++ ) {
      cols.push_back((int)q[s[nb-1]+k]);
    }
  }
  cs_dfree(D);
  return( (int)redundancy );
}

#pragma mark Equivalence class analysis
void
StructuralAnalysisModel::GetEqClass( int e, EqClass& res )
{
  cs* lsm;
  csd* dmres;
  
  // Clear return variable
  res.eq.clear();
  res.var.clear();
  
  // Create a copy of the incidence matrix and remove row e
  lsm = CSCopy( sm );
  RemoveRow( lsm, e );
  
  // Perform a Dulmage-Mendelsohn to compute the equivalence class
  dmres = cs_dmperm(lsm, 0);
  if (!dmres) {
    cerr << "Something is seriously wrong!" << endl;
    exit(-1);
  }
  
  // Extract the equations in the equivalence class
  // and put in res.eq
  res.eq.push_back(e);
  
  csi* p = dmres->p;
  long idx, k;
  for( k=dmres->rr[0]; k < dmres->rr[2]; k++ ) {
    idx = (p[k]<e) ? p[k] : p[k]+1;
    res.eq.push_back((int)idx);
  }
  
  // Extract the equations not in the equivalence class
  // and put in vector notEqClass
  vector<int> notEqClass;
  for( k=dmres->rr[2]; k < dmres->rr[4]; k++ ) {
    idx = (p[k]<e) ? p[k] : p[k]+1;
    notEqClass.push_back((int)idx);
  }
  
  // Compute the variables corresponding to the equivalence class.
  // Only do this if the equivalence class has cardinality larer than 1
  bool inEq, inRest;
  long colStart, colEnd;
  if( res.eq.size()>1 ) {
    for( k=0; k < sm->n; k++ ) {
      colStart = sm->p[k];
      colEnd = sm->p[k+1]-1;
      inEq = (find_first_of(res.eq.begin(), res.eq.end(),
                            &sm->i[colStart],&sm->i[colEnd])==res.eq.end())
      ? false: true;
      if( inEq ) {
        inRest = (find_first_of(notEqClass.begin(), notEqClass.end(),
                                &sm->i[colStart],&sm->i[colEnd])==notEqClass.end())
        ? false: true;
        if( !inRest ) {
          res.var.push_back((int)k);
        }
      }
    }
  }
  
  // Free space allocated for the reduced incidence matrix
  cs_spfree( lsm );
  
  // Free space allocated for the dmperm result.
  cs_dfree(dmres);
  
  // Sort list of equations and variables
  res.eq.sort();
  res.var.sort();
}

#pragma mark Lumping
void
StructuralAnalysisModel::LumpEqClass( EqClass& res )
{
  LumpRows( res.eq );
  DropCols( res.var.begin(), res.var.end() );
}

void
StructuralAnalysisModel::LumpRows( list<int>& rows )
{
  // 1. Determine destination row
  int dest = rows.front();
  
  // 2. Create matrix with only new element for the lumped equation
  cs* l;
  
  // Allocate space
  l=cs_spalloc(sm->m, sm->n, 1, 1, 1);
  
  long col, colStart, colEnd;
  long inLump;
  for( col=0; col < sm->n; col++ ) {
    colStart = sm->p[col];
    colEnd   = sm->p[col+1];
    
    inLump = (find(&sm->i[colStart], &sm->i[colEnd],dest)==&sm->i[colEnd]) ? 0 : 1;
    inLump =
    (find_first_of(rows.begin(), rows.end(), &sm->i[colStart], &sm->i[colEnd])==rows.end())
    ? 0 : (1-inLump);
    
    // If inLump, insert element into row dest in column col
    if( inLump ) {
      cs_entry(l, dest, col, 1);
    }
  }
  
  // Compress cs object
  cs* cl = cs_compress( l );
  cs_spfree( l );
  
  
  // 3. Compute sm+l and update the sm object
  cs *tmp1 = cs_add(sm, cl, 1, 1);
  cs_spfree( sm );
  cs_spfree( cl );
  sm=tmp1;
  
  // 4. Update eqList object
  list<EqList>::iterator insertPos;
  EqList::iterator addIt;
  int insertIdx=rows.front();
  
  int e=0;
  for( list<EqList>::iterator it=eqList.begin(); it!= eqList.end(); ) {
    if( e == insertIdx ) {
      // Save position of lumped equation
      insertPos = it++;
    } else if( find(rows.begin(), rows.end(),e)!=rows.end() ) {
      // Equation with index e is lumped, add to lumpPos
      for( addIt=it->begin();addIt!=it->end();addIt++) {
        insertPos->push_back(*addIt);
      }
      // Remove merged equation from list of equations
      //it = eqList.erase(it);
      it++;
    } else {
      it++;
    }
    e++;
  }
  
  // 5. Remove lumped equations
  list<int>::iterator it=rows.begin(); it++;
  DropRows( it, rows.end() );
}

#pragma mark Get/drop rows/columns
void
StructuralAnalysisModel::GetRows( list<int>::iterator startRow, list<int>::iterator stopRow )
{
  // Assume input list is sorted
  
  // Update sm object
  SparseMatrix::GetRows( startRow, stopRow );
  
  // Update eqList object
  list<EqList>::iterator it=eqList.begin();
  int e=0;
  for( list<int>::iterator it2=startRow; it2!=stopRow; it2++ ) {
    // Remove elements until next row to keep
    while( e < *it2 ) {
      it = eqList.erase( it );
      e++;
    }
    // Step past row to keep
    e++;
    it++;
  }
  if( it!= eqList.end() ) {
    eqList.erase(++it, eqList.end() );
  }
}

void
StructuralAnalysisModel::GetCols( list<int>::iterator startCol, list<int>::iterator stopCol )
{
  SparseMatrix::GetCols(startCol, stopCol);
}

void
StructuralAnalysisModel::Get( list<int>::iterator startRow, list<int>::iterator stopRow,
                             list<int>::iterator startCol, list<int>::iterator stopCol )
{
  SparseMatrix::Get(startRow, stopRow, startCol, stopCol);
  
  // Update eqList object
  list<EqList>::iterator it1, it2;
  int e=0;
  it1 = eqList.begin();
  it2 = it1;
  for( list<int>::iterator getIt=startRow; getIt!=stopRow; getIt++ ) {
    // Determine block of equations to remove
    while( e < *getIt ) {
      it2++;
      e++;
    }
    // Remove set of equations
    it1=eqList.erase(it1, it2 );
    
    // Step past equation to keep and proceed to next set of equations to remove
    it1++;
    it2=it1;
    e++;
  }
  if( it1!= eqList.end() ) {
    eqList.erase(it1, eqList.end() );
  }
  assert(sm->m==(int)eqList.size());
}

void
StructuralAnalysisModel::DropRows( list<int>::iterator startRow, list<int>::iterator stopRow )
{
  // Update sm object
  SparseMatrix::DropRows(startRow, stopRow);
  
  // Update eqList object
  list<EqList>::iterator it=eqList.begin();
  int e=0;
  for( list<int>::iterator it2=startRow; it2!=stopRow; it2++ ) {
    // Step until next drop is found
    while( e < *it2 ) {
      e++;
      it++;
    }
    // Remove equation and proceed to next equation
    it = eqList.erase( it );
    e++;
  }
}

void
StructuralAnalysisModel::DropCols( list<int>::iterator startCol, list<int>::iterator stopCol )
{
  // Update sm object
  SparseMatrix::DropCols(startCol, stopCol);
}

void
StructuralAnalysisModel::Drop( list<int>::iterator startRow, list<int>::iterator stopRow,
                              list<int>::iterator startCol, list<int>::iterator stopCol )
{
  // Update sm object
  SparseMatrix::Drop(startRow, stopRow, startCol, stopCol);
  
  // Update eqList object
  list<EqList>::iterator it=eqList.begin();
  int e=0;
  for( list<int>::iterator it2=startRow; it2!=stopRow; it2++ ) {
    // Step until next drop is found
    while( e < *it2 ) {
      e++;
      it++;
    }
    // Remove equation and proceed to next equation
    it = eqList.erase( it );
    e++;
  }
}

void
StructuralAnalysisModel::RemoveRow( int e )
{
  SparseMatrix::RemoveRow( e );
  list<EqList>::iterator it;
  it = eqList.begin();
  for( int k=0; k < e; k++ ) {
    it++;
  }
  eqList.erase( it );
}

void
StructuralAnalysisModel::RemoveRow( cs* lsm, int e )
{
  int k;
  
  // Update row vector i and column vector p;
  csi* rowOrig = lsm->i; // Pointer into the original row vector
  csi* rowUpdate = lsm->i; // Pointer to the update position
  int  remElems=0;
  int  col=-1;
  for( k=0; k < lsm->nzmax; k++ ) {
    if( k>=lsm->p[col+1] ) {
      col++;
      lsm->p[col] = lsm->p[col]-remElems;
    }
    if( *rowOrig < e ) {
      *rowUpdate = *rowOrig;
      rowUpdate++;
    } else if( *rowOrig > e ) {
      *rowUpdate = *rowOrig-1;
      rowUpdate++;
    } else {
      remElems++;
    }
    rowOrig++;
  }
  lsm->p[col+1]=lsm->p[col+1]-remElems;
  
  // Update nzmax
  lsm->nzmax = lsm->nzmax - remElems;
  
  // Update m
  lsm->m = lsm->m-1;
}


#pragma mark Matlab export
#ifdef MATIO
int
StructuralAnalysisModel::ExportToMatlab(string fileName, string XvarName, string EvarName)
{
  mat_t *mat;
  
  mat = Mat_Open(fileName.c_str(),MAT_ACC_RDWR);
  if( !mat ) {
    cerr << "Unable to create file " << fileName << ", exiting" << endl;
    return( 0 );
  }
  
  // 1. Create incidence matrix object and write to file
  mat_sparse_t matlab_sm;
  
  // 1.1 Create data items
  matlab_sm.nzmax=(int)sm->nzmax; // Number of elements
  matlab_sm.nir=(int)sm->nzmax;
  matlab_sm.njc=(int)sm->n+1;
  matlab_sm.ir=(int *)sm->i;
  matlab_sm.jc=(int *)sm->p;
  matlab_sm.ndata=(int)sm->nzmax;
  matlab_sm.data = (int *)sm->x;
  
  // 2. Create matrix object and write to file
  matvar_t *matvar;
  
  size_t dims[2];
  dims[0] = sm->m; dims[1] = sm->n;
  matvar = Mat_VarCreate(XvarName.c_str(),MAT_C_SPARSE,
                         MAT_T_DOUBLE,2,dims,&matlab_sm,MAT_F_DONT_COPY_DATA);
  Mat_VarWrite(mat,matvar,MAT_COMPRESSION_NONE);
  Mat_VarFree(matvar);
  
  // 3. Create equation description object and write to file
  matvar_t** eq_cell;
  mat_int32_t* cellData;
  
  int k,i;
  eq_cell = new matvar_t*[eqList.size()];
  list<EqList>::iterator e;
  EqList::iterator eq;
  k=0;
  for( e=eqList.begin(); e!=eqList.end(); e++ ) {
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
  dims[0] = 1; dims[1] = eqList.size();
  matvar = Mat_VarCreate(EvarName.c_str(),MAT_C_CELL,MAT_T_CELL,2,
                         dims,eq_cell,0);
  Mat_VarWrite(mat,matvar,MAT_COMPRESSION_NONE);
  delete [] eq_cell;
  Mat_VarFree(matvar);
  
  Mat_Close(mat);
  return( 1 );
}
#endif

#pragma mark Print function
void
StructuralAnalysisModel::Print()
{
  int m[sm->n][sm->m];
  long col, row, k, ne;
  csi* colP = sm->p;
  csi* rowP = sm->i;
  
  // Fill array m with zeros
  for( row=0; row < sm->m; row++ ) {
    for( col=0; col < sm->n; col++ ) {
      m[col][row]=0;
    }
  }
  
  // Fill array m with elements from sparse representation
  col=-1;
  for( k=0; k < sm->nzmax; k++ ) {
    while( col < sm->n && k==colP[col+1] ) {
      col++;
    }
    m[col][rowP[k]] = 1;
  }
  
  // Print matrix row by row
  list<EqList>::iterator p;
  EqList::iterator ep;
  p = eqList.begin();
  for( row=0; row < sm->m; row++ ) {
    cout << "|";
    for( col=0; col < sm->n; col++ ) {
      cout << m[col][row];
      if( col < sm->n-1 ) {
        cout << " ";
      }
    }
    cout << "|: ";
    cout << "{";
    k=0;
    ne = p->size();
    for( ep=p->begin(); ep!=p->end(); ep++ ) {
      if(  k==ne-1 ) {
        cout << "e" << *ep;
      } else {
        cout << "e" << *ep << ", ";
      }
      k++;
    }
    cout << "}"<< endl;
    p++;
  }
}

