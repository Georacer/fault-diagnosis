#ifndef _SPARSEMATRIX_H
#define _SPARSEMATRIX_H

#include<string>
#include<list>
#include<vector>
#include<cassert>
#include<iostream>
#ifdef MATIO
#include<matio.h>
#endif

#ifndef NDEBUG
#include <cassert>
#endif

extern "C" {
  #include "cs.h"
//  #include <stdlib.h>
}

using namespace std;

struct DMPermResult {
  vector<int> p;
  vector<int> q;
  vector<int> r;
  vector<int> s;
  int nb;
  vector<int> rr;
  vector<int> cc;
};

class SparseMatrix {
protected:
  cs* sm;

  // Private membership functions
  cs* CSCopy( cs* a ); 
  cs* RowSelectionMatrix( list<int>::iterator startRow, 
			  list<int>::iterator stopRow, int nrows );
  cs* ColSelectionMatrix( list<int>::iterator startCol, 
			  list<int>::iterator stopCol, int ncols );
  cs* RowDropMatrix( list<int>::iterator startRow, 
		     list<int>::iterator stopRow, 
		     int nrows);
  cs* ColDropMatrix( list<int>::iterator startCol, 
		     list<int>::iterator stopCol, 
		     int ncols );
  friend ostream& operator<<(ostream& s, SparseMatrix m);


  void RemoveRow( int e );
  void RemoveRow( cs* lsm, int e );

public:
  SparseMatrix() { sm=(cs *)NULL; };
  SparseMatrix( const string s );
  SparseMatrix( cs* a );  
  SparseMatrix( const SparseMatrix& y );
  SparseMatrix& operator=( const SparseMatrix& y );
  virtual ~SparseMatrix( ) { cs_spfree(sm); };

  bool IsEmpty(); 
  void RawPrint();
  void Print() { Print( cout ); }; 
  void Print( ostream& s );

  void GetRows( list<int>::iterator startRow, list<int>::iterator stopRow );
  void GetCols( list<int>::iterator startCol, list<int>::iterator stopCol );
  void Get( list<int>::iterator startRow, list<int>::iterator stopRow, 
	    list<int>::iterator startCol, list<int>::iterator stopCol );
  //! Get rows and columns
  inline void Get( list<int>& rows, list<int>& cols)  
  { Get(rows.begin(), rows.end(), cols.begin(), cols.end()); };
  inline void GetRows( list<int>& rows)  
  { GetRows(rows.begin(), rows.end()); };
  inline void GetCols( list<int>& cols)  
  { GetCols(cols.begin(), cols.end()); };

  void DropRows( list<int>::iterator startRow, list<int>::iterator stopRow );
  void DropCols( list<int>::iterator startCol, list<int>::iterator stopCol );
  void Drop( list<int>::iterator startRow, list<int>::iterator stopRow, 
	     list<int>::iterator startCol, list<int>::iterator stopCol );
  inline void Drop( list<int>& rows, list<int>& cols) 
  { Drop(rows.begin(), rows.end(), cols.begin(), cols.end()); };
  inline void DropRows( list<int>& rows) 
  { DropRows(rows.begin(), rows.end()); };
  inline void DropCols( list<int>& cols) 
  { DropCols(cols.begin(), cols.end()); };

  inline void Permute( DMPermResult& res ) { Permute(res.p, res.q); };

  void Permute( vector<int>& rowp, vector<int>& colp );

  void DMPerm(DMPermResult& res);

  int SRank();

  void FullIncidenceMatrix(int* im);

  int ExportToMatlab(string fileName, string varName);

  int NRows() { return( (int)sm->m ); };
  int NCols() { return( (int)sm->n ); };
  int nz() { return( (int)sm->nzmax ); };
  void GetInfo( int& nRows, int& nCols, int& nz );
  
  int Plus( list<int>& rows, list<int>& cols );
  void Plus( );
  void DropNonCausal();

  
};

#endif
