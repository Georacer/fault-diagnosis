#include <iostream>
#include "SparseMatrix.h"

using namespace std;

//
//void
//SparseMatrix::DropNonCausal();


#pragma mark Constructors
SparseMatrix::SparseMatrix( const string s )
{
  FILE* f;
  cs *foo;

  f=fopen(s.c_str(), "r");
  if( !f ) {
    cout << "Error opening file " << s << ", exiting." << endl;
    exit(-1);
  }
  foo = cs_load(f);
  fclose(f);

  sm = cs_compress(foo);
  cs_spfree(foo);
}

SparseMatrix::SparseMatrix( cs* a )
{
  sm = CSCopy( a );
}

SparseMatrix::SparseMatrix( const SparseMatrix& x )
{
  sm = CSCopy( x.sm );
}


SparseMatrix& SparseMatrix::operator=( const SparseMatrix& x )
{
  if( this != &x ) {
    // Free memory and copy the sm object
    cs_spfree(sm);
    sm = CSCopy( x.sm );
  }
  return *this;
}

#pragma mark Simple utility functions
bool
SparseMatrix::IsEmpty()
{
  if( sm==NULL ) {
    return true;
  } else if( sm->m==0 || sm->n==0 ) {
    return true;
  } else {
    return false;
  }
}

void
SparseMatrix::RawPrint()
{
  cs_print( sm, 0 );
}

ostream&
operator<<(ostream& s, SparseMatrix M)
{ 
  M.Print( s );
  return s;
};


void
SparseMatrix::Print( ostream& s )
{
  int m[sm->n][sm->m];
  int col, row, k;

  // Fill array m with zeros
  for( row=0; row < sm->m; row++ ) {
    for( col=0; col < sm->n; col++ ) {
      m[col][row]=0;
    }
  }
  
  // Fill array m with elements from sparse representation
  col=-1;
  for( k=0; k < sm->nzmax; k++ ) {
    while( col < sm->n && k==sm->p[col+1] ) {
      col++;
    }
    m[col][sm->i[k]] = 1;
  }

  // Print matrix row by row
  for( row=0; row < sm->m; row++ ) {
    s << "|";
    for( col=0; col < sm->n; col++ ) {
      if (m[col][row]==0) {
        s << " ";
      } else {
        s << m[col][row];
      }
      if( col < sm->n-1 ) {
        s << " ";
      }
    }
    s << "|"<< endl;
  }
}

void
SparseMatrix::GetInfo( int& nRows, int& nCols, int& nz )
{
  nRows = (int)sm->m;
  nCols = (int)sm->n;
  nz = (int)sm->nzmax;
}

int SparseMatrix::SRank()
{
  // Perform dmperm
  csd* D;
  D = cs_dmperm(sm, 1);
  //  int rank=D->rr[3]-1;
  int rank=(int)D->rr[3];
  
  // Free allocated space
  cs_dfree(D);
  return( rank );
}

void
SparseMatrix::FullIncidenceMatrix(int* im)
{
  // Fill incidence matrix with zeros
  for( int r=0; r < sm->m*sm->n; r++ ) {
    im[r]=0;
  }
  
  // Fill array m with elements from sparse representation
  csi* colP = sm->p;
  csi* rowP = sm->i;
  int col, k;
  col=-1;
  for( k=0; k < sm->nzmax; k++ ) {
    while( col < sm->n && k==colP[col+1] ) {
      col++;
    }
    im[rowP[k]*sm->n+col] = 1;
  }
}

csi
CausalTest(csi i, csi j, double x, void* other )
{
  return x>0;
}

//! Remove all non-causal entries in the sparse matrix.
void
SparseMatrix::DropNonCausal()
{
  cs_fkeep(sm, &CausalTest, NULL);
}


#pragma mark Internal functions for dropping and selecting rows/cols
void
SparseMatrix::RemoveRow( int e )
{
  RemoveRow( sm, e );
}

void
SparseMatrix::RemoveRow( cs* lsm, int e )
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


cs*
SparseMatrix::CSCopy( cs* a )
{
  cs* b;
  
  // Allocate space for copy
  b=cs_spalloc(a->m, a->n, a->nzmax, 1, 0);
  
  // Copy elements in a to sm2
  b->nzmax = a->nzmax;
  b->m = a->m;
  b->n = a->n;
  b->nz = a->nz;
  copy(a->p, a->p+a->n+1,b->p);
  copy(a->i, a->i+a->nzmax,b->i);
  copy(a->x, a->x+a->nzmax,b->x);
  
  // Return b
  return( b );
}

cs*
SparseMatrix::RowSelectionMatrix( list<int>::iterator startRow, 
				  list<int>::iterator stopRow, int nrows )
{
  cs *foo, *ret;
 
  foo = cs_spalloc(0, nrows, 1, 1, 1);  
  
  int r=0;
  for(list<int>::iterator it=startRow; it!=stopRow; it++ ) {
    cs_entry(foo, r++, *it, 1);
  }
  ret = cs_compress( foo );
  cs_spfree( foo );
  return( ret );
}

cs* SparseMatrix::ColSelectionMatrix( list<int>::iterator startCol,
				      list<int>::iterator stopCol, int ncols )
{
  cs *foo, *ret;
  foo = cs_spalloc(ncols, 0, 1, 1, 1);  
  
  int r=0;
  for(list<int>::iterator it=startCol; it!=stopCol; it++ ) {
    cs_entry(foo, *it, r++, 1);
  }
  ret = cs_compress( foo );
  cs_spfree( foo );
  return( ret );
}

cs*
SparseMatrix::RowDropMatrix( list<int>::iterator startRow, 
			     list<int>::iterator stopRow , 
			     int nrows )
{
  cs *foo, *ret;
 
  foo = cs_spalloc(0, nrows, 1, 1, 1);  
  int insRow=0;
  int r=0;
  for( list<int>::iterator it=startRow; it != stopRow; it++ ) {
    while( r < *it ) {
      cs_entry(foo, insRow++, r++, 1);
    }
    r++;
  }
  while( r < nrows ) {
    cs_entry(foo, insRow++, r++, 1);
  }

  ret = cs_compress( foo );
  cs_spfree( foo );
  return( ret );
}

cs*
SparseMatrix::ColDropMatrix( list<int>::iterator startCol, 
			     list<int>::iterator stopCol, 
			     int ncols )
{
  cs *foo, *ret;
 
  foo = cs_spalloc(ncols, 0, 1, 1, 1);  
  int insCol=0;
  int c=0;
  for( list<int>::iterator it=startCol; it != stopCol; it++ ) {
    while( c < *it ) {
      cs_entry(foo, c++, insCol++, 1);
    }
    c++;
  }
  while( c < ncols ) {
    cs_entry(foo, c++, insCol++, 1);
  }

  ret = cs_compress( foo );
  cs_spfree( foo );
  return( ret );
}

#pragma mark Getting/dropping rows and columns

void
SparseMatrix::GetRows( list<int>::iterator startRow, list<int>::iterator stopRow )
{
  cs* rowSel = RowSelectionMatrix(startRow, stopRow, (int)sm->m);

  // Perform matrix multiplication
  cs *tmp1;
  tmp1 = cs_multiply(rowSel,sm);

  // Update sm object and free temporary allocated memory
  cs_spfree( sm );
  sm=tmp1;

  cs_spfree( rowSel ); 
}

void
SparseMatrix::GetCols( list<int>::iterator startCol, list<int>::iterator stopCol )
{
  cs* colSel = ColSelectionMatrix(startCol, stopCol, (int)sm->n);

  // Perform matrix multiplication
  cs *tmp1;
  tmp1 = cs_multiply(sm, colSel);
  
  // Update sm object and free temporary allocated memory
  cs_spfree( sm );
  sm=tmp1;

  cs_spfree( colSel ); 
}

void SparseMatrix::Get( list<int>::iterator startRow, list<int>::iterator stopRow,
			list<int>::iterator startCol, list<int>::iterator stopCol )
{
  // Create row and column selection matrices
  cs *rowSel = RowSelectionMatrix( startRow, stopRow, (int)sm->m );
  cs *colSel = ColSelectionMatrix( startCol, stopCol, (int)sm->n );

  // Perform matrix multiplications
  cs *tmp1, *tmp2;
  tmp1 = cs_multiply(rowSel,sm);
  tmp2 = cs_multiply(tmp1,colSel);

  // Update sm object and free temporary allocated memory
  cs_spfree( sm );
  sm=tmp2;

  cs_spfree( tmp1 );
  cs_spfree( rowSel );
  cs_spfree( colSel );
}

void
SparseMatrix::DropCols( list<int>::iterator startCol, list<int>::iterator stopCol )
{
  cs* colSel = ColDropMatrix(startCol, stopCol, (int)sm->n);
  
  // Perform matrix multiplication
  cs *tmp1;
  tmp1 = cs_multiply(sm, colSel);
  
  // Update sm object and free temporary allocated memory
  cs_spfree( sm );
  sm=tmp1;
  
  cs_spfree( colSel );
}

void
SparseMatrix::DropRows( list<int>::iterator startRow, list<int>::iterator stopRow )
{
  cs* rowSel = RowDropMatrix(startRow, stopRow, (int)sm->m);
  
  // Perform matrix multiplication
  cs *tmp1;
  tmp1 = cs_multiply(rowSel,sm);
  
  // Update sm object and free temporary allocated memory
  cs_spfree( sm );
  sm=tmp1;
  
  cs_spfree( rowSel );
}

void
SparseMatrix::Drop( list<int>::iterator startRow, list<int>::iterator stopRow,
                   list<int>::iterator startCol, list<int>::iterator stopCol )
{
  // Assume rows and cols are sorted lists
  
  // Create row and column selection matrices
  cs *rowSel = RowDropMatrix( startRow, stopRow, (int)sm->m );
  cs *colSel = ColDropMatrix( startCol, stopCol, (int)sm->n );
  
  // Perform matrix multiplications
  cs *tmp1, *tmp2;
  tmp1 = cs_multiply(rowSel,sm);
  tmp2 = cs_multiply(tmp1,colSel);
  
  // Update sm object and free temporary allocated memory
  cs_spfree( sm );
  sm=tmp2;
  
  cs_spfree( tmp1 );
  cs_spfree( rowSel );
  cs_spfree( colSel );
}


#pragma mark Dulmage-Mendelsohn decomposition
void
SparseMatrix::DMPerm(DMPermResult& res)
{
  // Perform dmperm
  csd* D;
  D = cs_dmperm(sm, 1);

  // Insert results into result structure
  copy(D->p,D->p+sm->m,inserter(res.p,res.p.begin()));
  copy(D->q,D->q+sm->n,inserter(res.q,res.q.begin()));
  copy(D->r,D->r+D->nb+1,inserter(res.r,res.r.begin()));
  copy(D->s,D->s+D->nb+1,inserter(res.s,res.s.begin()));
  res.nb = (int)D->nb;
  copy(D->rr,D->s+5,inserter(res.rr,res.rr.begin()));
  copy(D->cc,D->cc+5,inserter(res.cc,res.cc.begin()));
  
  // Free allocated space
  cs_dfree(D);
}

int
SparseMatrix::Plus( list<int>& rows, list<int>& cols )
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
  
  int redundancy=(int)((r[nb]-r[nb-1])-(s[nb]-s[nb-1]));
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
  return( redundancy );
}

void
SparseMatrix::Plus( )
{
  list<int> rows, cols;
  
  int r=Plus( rows, cols );
  if( r>0 ) {
    Get(rows, cols);
  }
}


#pragma mark Export to Matlab
#ifdef MATIO
int
SparseMatrix::ExportToMatlab(string fileName, string varName)
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
  matlab_sm.data = sm->x;

  // 2. Create matrix object and write to file 
  matvar_t *matvar;

  unsigned long dims[2];
  dims[0] = (int)sm->m; dims[1] = (int)sm->n;
  matvar = Mat_VarCreate(varName.c_str(),MAT_C_SPARSE,
			 MAT_T_DOUBLE,2,dims,&matlab_sm,MAT_F_DONT_COPY_DATA);
  
  Mat_VarWrite(mat,matvar,MAT_COMPRESSION_NONE);
  Mat_VarFree(matvar);
  Mat_Close(mat);
  return( 1 );
}
#endif

#pragma mark Permute rows/columns in matrix
void
SparseMatrix::Permute( vector<int>& rowp, vector<int>& colp )
{
  csi* pinv = new csi[sm->m]; // row permutation vector 
  csi* q = new csi[sm->n]; // column permutation vector
  
  // Copy column permutation container into integer array
  copy(colp.begin(), colp.end(), q);

  // Create inverse (why?) row permutation vector
  for( int i=0; i < sm->m; i++ ) {
    pinv[rowp[i]]=i;
  }

  cs* perm_sm = cs_permute(sm, pinv, q, 1);

  // Free memory and switch matrix
  cs_spfree( sm );
  sm = perm_sm;

  // Free allocated memory
  delete[] pinv;
  delete[] q;
}

